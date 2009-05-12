From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 12 May 2009 10:21:12 +0200
Message-ID: <4A093178.9020105@cosmosbay.com>
References: <49C380A6.4000904@cosmosbay.com> <4A092F59.7020900@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58242 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756673AbZELIVP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 04:21:15 -0400
In-Reply-To: <4A092F59.7020900@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> One point of contention in high network loads is the dst_release() pe=
rformed
> when a transmited skb is freed. This is because NIC tx completion cal=
ls
> dev_kree_skb() long after original call to dev_queue_xmit(skb).
>=20
> CPU cache is cold and the atomic op in dst_release() stalls. On SMP, =
this is
> quite visible if one CPU is 100% handling softirqs for a network devi=
ce,
> since dst_clone() is done by other cpus, involving cache line ping po=
ngs.
>=20
> It seems right place to release dst is in dev_hard_start_xmit(), for =
most
> devices but ones that are virtual, and some exceptions.
>=20
> David Miller suggested to define a new device flag, set in alloc_netd=
ev_mq()
> (so that most devices set it at init time), and carefuly unset in dev=
ices
> which dont want a NULL skb->dst in their ndo_start_xmit().
>=20
> List of devices that must clear this flag is :
>=20
> - loopback device, because it calls netif_rx() and quoting Patrick :
>     "ip_route_input() doesn't accept loopback addresses, so loopback =
packets
>      already need to have a dst_entry attached."
> - appletalk/ipddp.c : needs skb->dst in its xmit function
>=20
> - And all devices that call again dev_queue_xmit() from their xmit fu=
nction
> (as some classifiers need skb->dst) : bonding, macvlan, eql, ifb, hdl=
c_fr
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  drivers/net/appletalk/ipddp.c   |    1 +
>  drivers/net/bonding/bond_main.c |    1 +
>  drivers/net/eql.c               |    1 +
>  drivers/net/ifb.c               |    1 +
>  drivers/net/loopback.c          |    1 +
>  drivers/net/macvlan.c           |    1 +
>  drivers/net/wan/hdlc_fr.c       |    1 +
>  include/linux/if.h              |    3 +++
>  net/core/dev.c                  |    9 +++++++++
>  9 files changed, 19 insertions(+)
>=20
> diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ip=
ddp.c
> index da64ba8..0268561 100644
> --- a/drivers/net/appletalk/ipddp.c
> +++ b/drivers/net/appletalk/ipddp.c
> @@ -71,6 +71,7 @@ static struct net_device * __init ipddp_init(void)
>  	if (!dev)
>  		return ERR_PTR(-ENOMEM);
> =20
> +	dev->priv_flags &=3D IFF_XMIT_DST_RELEASE;


Oops, I forgot the  ~ here, sorry

>  	strcpy(dev->name, "ipddp%d");
> =20
>  	if (version_printed++ =3D=3D 0)
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 815191d..a29f421 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -5148,6 +5148,7 @@ int bond_create(char *name, struct bond_params =
*params)
>  		goto out_rtnl;
>  	}
> =20
> +	bond_dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
>  	if (!name) {
>  		res =3D dev_alloc_name(bond_dev, "bond%d");
>  		if (res < 0)
> diff --git a/drivers/net/eql.c b/drivers/net/eql.c
> index 5210bb1..19b7dd9 100644
> --- a/drivers/net/eql.c
> +++ b/drivers/net/eql.c
> @@ -194,6 +194,7 @@ static void __init eql_setup(struct net_device *d=
ev)
> =20
>  	dev->type       	=3D ARPHRD_SLIP;
>  	dev->tx_queue_len 	=3D 5;		/* Hands them off fast */
> +	dev->priv_flags	       &=3D ~IFF_XMIT_DST_RELEASE;
>  }
> =20
>  static int eql_open(struct net_device *dev)
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 60a2630..96713ef 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -156,6 +156,7 @@ static void ifb_setup(struct net_device *dev)
> =20
>  	dev->flags |=3D IFF_NOARP;
>  	dev->flags &=3D ~IFF_MULTICAST;
> +	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
>  	random_ether_addr(dev->dev_addr);
>  }
> =20
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index 6f71157..da472c6 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -170,6 +170,7 @@ static void loopback_setup(struct net_device *dev=
)
>  	dev->tx_queue_len	=3D 0;
>  	dev->type		=3D ARPHRD_LOOPBACK;	/* 0x0001*/
>  	dev->flags		=3D IFF_LOOPBACK;
> +	dev->priv_flags	       &=3D ~IFF_XMIT_DST_RELEASE;
>  	dev->features 		=3D NETIF_F_SG | NETIF_F_FRAGLIST
>  		| NETIF_F_TSO
>  		| NETIF_F_NO_CSUM
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 329cd50..d5334b4 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -414,6 +414,7 @@ static void macvlan_setup(struct net_device *dev)
>  {
>  	ether_setup(dev);
> =20
> +	dev->priv_flags	       &=3D ~IFF_XMIT_DST_RELEASE;
>  	dev->netdev_ops		=3D &macvlan_netdev_ops;
>  	dev->destructor		=3D free_netdev;
>  	dev->header_ops		=3D &macvlan_hard_header_ops,
> diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
> index 8005301..bfa0161 100644
> --- a/drivers/net/wan/hdlc_fr.c
> +++ b/drivers/net/wan/hdlc_fr.c
> @@ -1054,6 +1054,7 @@ static void pvc_setup(struct net_device *dev)
>  	dev->flags =3D IFF_POINTOPOINT;
>  	dev->hard_header_len =3D 10;
>  	dev->addr_len =3D 2;
> +	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
>  }
> =20
>  static const struct net_device_ops pvc_ops =3D {
> diff --git a/include/linux/if.h b/include/linux/if.h
> index 1108f3e..b9a6229 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -67,6 +67,9 @@
>  #define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
>  #define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use *=
/
>  #define IFF_WAN_HDLC	0x200		/* WAN HDLC device		*/
> +#define IFF_XMIT_DST_RELEASE 0x400	/* dev_hard_start_xmit() is allow=
ed to
> +					 * release skb->dst
> +					 */
> =20
>  #define IF_GET_IFACE	0x0001		/* for querying only */
>  #define IF_GET_PROTO	0x0002
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 14dd725..b9aef53 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1688,6 +1688,14 @@ int dev_hard_start_xmit(struct sk_buff *skb, s=
truct net_device *dev,
>  				goto gso;
>  		}
> =20
> +		/*
> +		 * If device doesnt need skb->dst, release it right now while
> +		 * its hot in this cpu cache
> +		 */
> +		if ((dev->priv_flags & IFF_XMIT_DST_RELEASE) && skb->dst) {
> +			dst_release(skb->dst);
> +			skb->dst =3D NULL;
> +		}
>  		rc =3D ops->ndo_start_xmit(skb, dev);
>  		/*
>  		 * TODO: if skb_orphan() was called by
> @@ -5028,6 +5036,7 @@ struct net_device *alloc_netdev_mq(int sizeof_p=
riv, const char *name,
>  	netdev_init_queues(dev);
> =20
>  	INIT_LIST_HEAD(&dev->napi_list);
> +	dev->priv_flags =3D IFF_XMIT_DST_RELEASE;
>  	setup(dev);
>  	strcpy(dev->name, name);
>  	return dev;
>=20

