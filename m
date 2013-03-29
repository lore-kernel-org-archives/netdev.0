From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: add a synchronize_net() in
 netdev_rx_handler_unregister()
Date: Fri, 29 Mar 2013 12:20:11 -0700
Message-ID: <20130329192011.GO3320@linux.vnet.ibm.com>
References: <1364490997.6345.237.camel@gandalf.local.home>
 <1364491792.15753.47.camel@edumazet-glaptop>
 <20130329094856.GB1677@minipsycho.orion>
 <1364562082.5113.16.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364562082.5113.16.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 29, 2013 at 06:01:22AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> On Fri, 2013-03-29 at 10:48 +0100, Jiri Pirko wrote:
>=20
> > Hmm. I think that this might be issue introduced by:
> > commit a9b3cd7f323b2e57593e7215362a7b02fc933e3a
> > Author: Stephen Hemminger <shemminger@vyatta.com>
> > Date:   Mon Aug 1 16:19:00 2011 +0000
> >=20
> >     rcu: convert uses of rcu_assign_pointer(x, NULL) to RCU_INIT_PO=
INTER
> >=20
> >=20
> > Because, if rcu_dereference(dev->rx_handler) is null,
> > rcu_dereference(dev->rx_handler_data) is never done. Therefore I be=
lieve
> > we are hitting following scenario:
> >=20
> >=20
> >    CPU0				CPU1
> >    ----				----
> >   			    dev->rx_handler_data =3D NULL
> >  rcu_read_lock()
> >  			    dev->rx_handler =3D NULL
> >=20
> >=20
> > CPU0 will see rx_handler set and yet, rx_handler_data nulled. Write
> > barrier in rcu_assign_pointer() might prevent this reorder from hap=
pening.
> > Therefore I suggest:
> >=20
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 0caa38e..c16b829 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3332,8 +3332,8 @@ void netdev_rx_handler_unregister(struct net_=
device *dev)
> >  {
> > =20
> >  	ASSERT_RTNL();
> > -	RCU_INIT_POINTER(dev->rx_handler, NULL);
> > -	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
> > +	rcu_assign_pointer(dev->rx_handler, NULL);
> > +	rcu_assign_pointer(dev->rx_handler_data, NULL);
> >  }
> >  EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
> > =20
> >=20
>=20
> Nope this changes nothing at all.
>=20
> However, we can fix the bug in a different way, if we want to avoid a
> test in fast path.
>=20
> With following patch, we can make sure that a reader seeing a non NUL=
L
> rx_handler has a guarantee to see a non NULL rx_handler_data
>=20
> Thanks
>=20
> [PATCH] net: add a synchronize_net() in netdev_rx_handler_unregister(=
)
>=20
> commit 35d48903e97819 (bonding: fix rx_handler locking) added a race
> in bonding driver, reported by Steven Rostedt who did a very good
> diagnosis :
>=20
> <quoting Steven>
>=20
> I'm currently debugging a crash in an old 3.0-rt kernel that one of o=
ur
> customers is seeing. The bug happens with a stress test that loads an=
d
> unloads the bonding module in a loop (I don't know all the details as
> I'm not the one that is directly interacting with the customer). But =
the
> bug looks to be something that may still be present and possibly pres=
ent
> in mainline too. It will just be much harder to trigger it in mainlin=
e.
>=20
> In -rt, interrupts are threads, and can schedule in and out just like
> any other thread. Note, mainline now supports interrupt threads so th=
is
> may be easily reproducible in mainline as well. I don't have the abil=
ity
> to tell the customer to try mainline or other kernels, so my hands ar=
e
> somewhat tied to what I can do.
>=20
> But according to a core dump, I tracked down that the eth irq thread
> crashed in bond_handle_frame() here:
>=20
>         slave =3D bond_slave_get_rcu(skb->dev);
>         bond =3D slave->bond; <--- BUG
>=20
>=20
> the slave returned was NULL and accessing slave->bond caused a NULL
> pointer dereference.
>=20
> Looking at the code that unregisters the handler:
>=20
> void netdev_rx_handler_unregister(struct net_device *dev)
> {
>=20
>         ASSERT_RTNL();
>         RCU_INIT_POINTER(dev->rx_handler, NULL);
>         RCU_INIT_POINTER(dev->rx_handler_data, NULL);
> }
>=20
> Which is basically:
>         dev->rx_handler =3D NULL;
>         dev->rx_handler_data =3D NULL;
>=20
> And looking at __netif_receive_skb() we have:
>=20
>         rx_handler =3D rcu_dereference(skb->dev->rx_handler);
>         if (rx_handler) {
>                 if (pt_prev) {
>                         ret =3D deliver_skb(skb, pt_prev, orig_dev);
>                         pt_prev =3D NULL;
>                 }
>                 switch (rx_handler(&skb)) {
>=20
> My question to all of you is, what stops this interrupt from happenin=
g
> while the bonding module is unloading?  What happens if the interrupt
> triggers and we have this:
>=20
>=20
>         CPU0                    CPU1
>         ----                    ----
>   rx_handler =3D skb->dev->rx_handler
>=20
>                         netdev_rx_handler_unregister() {
>                            dev->rx_handler =3D NULL;
>                            dev->rx_handler_data =3D NULL;
>=20
>   rx_handler()
>    bond_handle_frame() {
>     slave =3D skb->dev->rx_handler;
>     bond =3D slave->bond; <-- NULL pointer dereference!!!
>=20
>=20
> What protection am I missing in the bond release handler that would
> prevent the above from happening?
>=20
> </quoting Steven>
>=20
> We can fix bug this in two ways. First is adding a test in
> bond_handle_frame() and others to check if rx_handler_data is NULL.
>=20
> A second way is adding a synchronize_net() in
> netdev_rx_handler_unregister() to make sure that a rcu protected read=
er
> has the guarantee to see a non NULL rx_handler_data.
>=20
> The second way is better as it avoids an extra test in fast path.
>=20
> Reported-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Cc: Paul E. McKenney <paulmck@us.ibm.com>

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

With kudos to Steven Rostedt for his analogy between RCU and
Schr=F6dinger's cat.  ;-)

> ---
>  net/core/dev.c |    6 ++++++
>  1 file changed, 6 insertions(+)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b13e5c7..56932a4 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3314,6 +3314,7 @@ int netdev_rx_handler_register(struct net_devic=
e *dev,
>  	if (dev->rx_handler)
>  		return -EBUSY;
>=20
> +	/* Note: rx_handler_data must be set before rx_handler */
>  	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
>  	rcu_assign_pointer(dev->rx_handler, rx_handler);
>=20
> @@ -3334,6 +3335,11 @@ void netdev_rx_handler_unregister(struct net_d=
evice *dev)
>=20
>  	ASSERT_RTNL();
>  	RCU_INIT_POINTER(dev->rx_handler, NULL);
> +	/* a reader seeing a non NULL rx_handler in a rcu_read_lock()
> +	 * section has a guarantee to see a non NULL rx_handler_data
> +	 * as well.
> +	 */
> +	synchronize_net();
>  	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
>  }
>  EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
