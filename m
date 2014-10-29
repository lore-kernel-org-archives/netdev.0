From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on
 linux-next
Date: Wed, 29 Oct 2014 12:40:41 -0700
Message-ID: <1414611641.2420.54.camel@jtkirshe-mobl>
References: <20141029155620.GA4886@kria>
	 <20141029180734.GQ12706@worktop.programming.kicks-ass.net>
	 <alpine.DEB.2.11.1410291918060.5308@nanos>
	 <20141029193603.GS12706@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-O+sDjg7563QFZqVfM4eI"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141029193603.GS12706@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-O+sDjg7563QFZqVfM4eI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-29 at 20:36 +0100, Peter Zijlstra wrote:
> On Wed, Oct 29, 2014 at 07:33:00PM +0100, Thomas Gleixner wrote:
> > Yuck. No. You are just papering over the problem.
> >=20
> > What happens if you add 'threadirqs' to the kernel command line? Or if
> > the interrupt line is shared with a real threaded interrupt user?
> >=20
> > The proper solution is to have a poll_lock for e1000 which serializes
> > the hardware interrupt against netpoll instead of using
> > disable/enable_irq().
> >=20
> > In fact that's less expensive than the disable/enable_irq() dance and
> > the chance of contention is pretty low. If done right it will be a
> > NOOP for the CONFIG_NET_POLL_CONTROLLER=3Dn case.
> >=20
>=20
> OK a little something like so then I suppose.. But I suspect most all
> the network drivers will need this and maybe more, disable_irq() is a
> popular little thing and we 'just' changed semantics on them.

Thomas- if you are fine with Peter's patch, I can get this under
testing.

>=20
> ---
>  drivers/net/ethernet/intel/e1000/e1000.h      |  2 ++
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 22 +++++++++++++++++----=
-
>  kernel/irq/manage.c                           |  2 +-
>  3 files changed, 20 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ether=
net/intel/e1000/e1000.h
> index 69707108d23c..3f48609f2318 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000.h
> +++ b/drivers/net/ethernet/intel/e1000/e1000.h
> @@ -323,6 +323,8 @@ struct e1000_adapter {
>  	struct delayed_work watchdog_task;
>  	struct delayed_work fifo_stall_task;
>  	struct delayed_work phy_info_task;
> +
> +	spinlock_t irq_lock;
>  };
> =20
>  enum e1000_state_t {
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/=
ethernet/intel/e1000/e1000_main.c
> index 5f6aded512f5..d12cbffe2149 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -1310,6 +1310,7 @@ static int e1000_sw_init(struct e1000_adapter *adap=
ter)
>  	e1000_irq_disable(adapter);
> =20
>  	spin_lock_init(&adapter->stats_lock);
> +	spin_lock_init(&adapter->irq_lock);
> =20
>  	set_bit(__E1000_DOWN, &adapter->flags);
> =20
> @@ -3748,10 +3749,8 @@ void e1000_update_stats(struct e1000_adapter *adap=
ter)
>   * @irq: interrupt number
>   * @data: pointer to a network interface device structure
>   **/
> -static irqreturn_t e1000_intr(int irq, void *data)
> +static irqreturn_t __e1000_intr(int irq, struct e1000_adapter *adapter)
>  {
> -	struct net_device *netdev =3D data;
> -	struct e1000_adapter *adapter =3D netdev_priv(netdev);
>  	struct e1000_hw *hw =3D &adapter->hw;
>  	u32 icr =3D er32(ICR);
> =20
> @@ -3793,6 +3792,19 @@ static irqreturn_t e1000_intr(int irq, void *data)
>  	return IRQ_HANDLED;
>  }
> =20
> +static irqreturn_t e1000_intr(int irq, void *data)
> +{
> +	struct net_device *netdev =3D data;
> +	struct e1000_adapter *adapter =3D netdev_priv(netdev);
> +	irqreturn_t ret;
> +
> +	spin_lock(&adapter->irq_lock);
> +	ret =3D __e1000_intr(irq, adapter);
> +	spin_unlock(&adapter->irq_lock);
> +
> +	return ret;
> +}
> +
>  /**
>   * e1000_clean - NAPI Rx polling callback
>   * @adapter: board private structure
> @@ -5217,9 +5229,9 @@ static void e1000_netpoll(struct net_device *netdev=
)
>  {
>  	struct e1000_adapter *adapter =3D netdev_priv(netdev);
> =20
> -	disable_irq(adapter->pdev->irq);
> +	spin_lock(&adapter->irq_lock)
>  	e1000_intr(adapter->pdev->irq, netdev);
> -	enable_irq(adapter->pdev->irq);
> +	spin_unlock(&adapter->irq_lock)
>  }
>  #endif
> =20
> diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> index 0a9104b4608b..b5a4a06bf2fd 100644
> --- a/kernel/irq/manage.c
> +++ b/kernel/irq/manage.c
> @@ -427,7 +427,7 @@ EXPORT_SYMBOL(disable_irq_nosync);
>   *	to complete before returning. If you use this function while
>   *	holding a resource the IRQ handler may need you will deadlock.
>   *
> - *	This function may be called - with care - from IRQ context.
> + *	This function may _NOT_ be called from IRQ context.
>   */
>  void disable_irq(unsigned int irq)
>  {



--=-O+sDjg7563QFZqVfM4eI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUUUK5AAoJEOVv75VaS+3OpGIP/iKB0r5+6BIyFwQIsyOty24N
Iw8/XdDuTef3taRouEJy+Du1sWHieId2XmnXBzxMEPSaFKheq/05Pck4E/kxwRai
HYppl7pW9khTifoqLhsrjUdOE1is5E9K9rTQivkC6UZdMBqoap2lBI8cZaQeZmNm
S1SEAF2xcr6DgVH84O5H1bPHYOC/FQB17Yzt5Xg9FXKm/u90jNoylUeEIl76H83A
Bf/WP/Adb41sRgAjphR9ljaTDss3Dd+ar00DDTQkCDSFPQgtLl6Cmvw9LEXhXWth
ADsxHYURRxhPTj+f1stfw8oT31gicwkKPUgWeMUJmMyNe2iZH0ZJBLMllBaIuaip
ap5099MC9i2LvAcqzl4e83V2sgjjMnKFueN7awfLMUrN+YpxA7CLPzZV29xW8Lii
IBeCKX4Tf3PAMlIfbcH2/kZreDyVKFbdsZE/Ggo+2vNEQunbVTqsZQy2rfU1OzM7
HwRxHX6iQSYpOHZSvgfSDIRLw7hpVrbX6kjexFuD6OgN15QEMsnmD/dXDsrsPKMI
+qkegPfwAXT61QQBcBKuYN+QZp9esWFLmMs3C5GnNd8lDy2SiM8SQ09WFSvHO0wV
F1CNBI3PKNkFJE8dQsQjyXNmNqlj5iHpaapwNE1Eh1tABAp8YTv6YH5OOKunZXnX
mSkjlsqs2xaEn1o+egtP
=Yms5
-----END PGP SIGNATURE-----

--=-O+sDjg7563QFZqVfM4eI--
