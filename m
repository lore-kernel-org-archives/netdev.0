From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/1] net: Add rtnl_lock for netif_device_attach/detach
Date: Tue, 22 Apr 2014 18:26:36 +0100
Message-ID: <1398187596.7767.60.camel@deadeye.wl.decadent.org.uk>
References: <1397632082-18453-1-git-send-email-zhen-hual@hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Se94WuL3tJsfIamJns3f"
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Li, Zhen-Hua" <zhen-hual@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397632082-18453-1-git-send-email-zhen-hual@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Se94WuL3tJsfIamJns3f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-16 at 15:08 +0800, Li, Zhen-Hua wrote:
> From: "Li, Zhen-Hua" <zhen-hual@hp.com>
>=20
> As netif_running is called in netif_device_attach/detach. There should be
> rtnl_lock/unlock called, to avoid dev stat change during netif_device_att=
ach
> and detach being called.
> I checked NIC some drivers,  some of them have netif_device_attach/detach
> called between rtnl_lock/unlock, while some drivers do not.
>=20
> This patch is tring to find a generic way to fix this for all NIC drivers=
.

I don't think you can generically use the RTNL lock for this.

> Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>
> ---
>  net/core/dev.c |   18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5b3042e..795bbc5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2190,10 +2190,19 @@ EXPORT_SYMBOL(__dev_kfree_skb_any);
>   */
>  void netif_device_detach(struct net_device *dev)
>  {
> +	/**
> +	 * As netif_running is called , rtnl_lock and unlock are needed to
> +	 * avoid __LINK_STATE_START bit changes during this function call.
> +	 */
> +	int need_unlock;
> +
> +	need_unlock =3D rtnl_trylock();

It is never correct to use trylock and then continue even if it fails.
I think you're trying to simulate a reentrant mutex but this will fail
if *any* task already has the mutex.

Furthermore it is currently allowed and useful to call these functions
from atomic context (transmit or completion path) where it is not
possible to hold the mutex.

>  	if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
>  	    netif_running(dev)) {
>  		netif_tx_stop_all_queues(dev);
>  	}
> +	if (need_unlock)
> +		rtnl_unlock();
>  }
>  EXPORT_SYMBOL(netif_device_detach);

For netif_device_detach(), I wonder whether it is necessary to check
netif_running().  What are we trying to avoid?

> @@ -2205,11 +2214,20 @@ EXPORT_SYMBOL(netif_device_detach);
>   */
>  void netif_device_attach(struct net_device *dev)
>  {
> +       /**
> +        * As netif_running is called , rtnl_lock and unlock are needed t=
o
> +        * avoid __LINK_STATE_START bit changes during this function call=
.
> +        */
> +       int need_unlock;
> +
> +       need_unlock =3D rtnl_trylock();
>         if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
>             netif_running(dev)) {
>                 netif_tx_wake_all_queues(dev);
>                 __netdev_watchdog_up(dev);
>         }
> +       if (need_unlock)
> +               rtnl_unlock();
>  }
>  EXPORT_SYMBOL(netif_device_attach);

I do see a problem if netif_device_detach() races with
dev_deactivate_many(), which is being mitigated but not avoided by the
test of netif_running().

I think a proper solution is going to involve changing
dev_deactivate_many() as well, removing the use of netif_running(), and
possible using cmpxchg() to atomically manipulate multiple bits of
dev->state.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-Se94WuL3tJsfIamJns3f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1amTOe/yOyVhhEJAQrXrRAAqSYBXPHgTHzE6cxzl9I7n15xvysC3Bkd
puhc8nFji00rY/RKt50QWQNpAKCbHby6UQl5OEYFIH6s9GLORlkCTUgmdKT/zv0i
Fhvf6FcjW+AwhpKrZBp3Hjaej4Lrt70Ioeq1tEEe2D+MQKzBgZgjYJvRfdfhAYCw
WGOz3kbuE71YRJOhMSLUbhWFXMb+f2SwGptDniFFxN7Eo7eWtejZXH11QDRB9di+
pOCMSrtCY/Ue/ljFhhJ2eoD4cYVqK0pRr6uxiXOsLRxZWAxRRzgGa9vt4UiD3f5e
Oysd6PULOE3duAnXxN/cyRtguF1CJ/zK4gpkaoe/czBpX5Lr3oDGlIkz/kLrU5y6
k/v39pptUHlgxrXp8kX5ToxP0ItP735+hSXBM/+dSpny9LEBxHiWjLXX5tFMM1Qg
ri80t57KASXi0+kvOtYFu9y0TPOZ44njI74sYHMegcl7u9b8AmOmMGGwxsq0RmYJ
q3KGNDgulTYI0N1wTdSYc61DEyfNDhd88d2fC/bh+K2t8I+VHgq5WWDwnB3Dx731
E37PRl+7VDf5TtMaA8wDf7E4Sl5MR6fL6mSiVKgoY8mGLpgbvvhjWByHJRGtxXdj
VK10iHYcwqn83TT1MIQNBd5d8XDMHPO50sh1AnQ5fc9HGzZ0hW4LhTx2sgA37179
2jJDlBkg1IE=
=KXDx
-----END PGP SIGNATURE-----

--=-Se94WuL3tJsfIamJns3f--
