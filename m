From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Wed, 2 Sep 2009 12:01:07 -0700
Message-ID: <20090902120107.15146e4e@nehalam>
References: <20090902081429.GB4878@ff.dom.local>
	<4A9E2CC7.1010103@gmail.com>
	<20090902.013002.181288977.davem@davemloft.net>
	<4A9E6551.4030209@gmail.com>
	<4A9E699B.7080400@gmail.com>
	<20090902092351.11649796@nehalam>
	<4A9E9D8A.50406@trash.net>
	<4A9EA250.2010209@gmail.com>
	<4A9EA8C6.2000501@gmail.com>
	<4A9EBB68.2080903@hp.com>
	<4A9EBF9C.2030904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54457 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752619AbZIBTBL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 15:01:11 -0400
In-Reply-To: <4A9EBF9C.2030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Sep 2009 20:55:24 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Brian Haley a =C3=A9crit :
> > Eric Dumazet wrote:
> >> diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
> >> index 3c1895e..0525a1d 100644
> >> --- a/include/net/rtnetlink.h
> >> +++ b/include/net/rtnetlink.h
> >> @@ -70,6 +70,8 @@ struct rtnl_link_ops {
> >>  	size_t			(*get_xstats_size)(const struct net_device *dev);
> >>  	int			(*fill_xstats)(struct sk_buff *skb,
> >>  					       const struct net_device *dev);
> >> +	int			(*get_tx_queues)(struct net*, struct nlattr *tb[],
> >> +						 int *tx_queues, int *real_tx_queues);
> >=20
> > 	int			(*get_tx_queues)(struct net *net, struct nlattr *tb[],
> >=20
> > Total nitpick, but tbird highlighted it because of the missing "net=
".
> >=20
>=20
> Thats right, and I believe some gcc versions could complain
>=20
> Thanks Brian
>=20
> [PATCH net-next-2.6] vlan: multiqueue vlan device
>=20
> vlan devices are currently not multi-queue capable.
>=20
> We can do that with a new rtnl_link_ops method,
> get_tx_queues(), called from rtnl_create_link()
>=20
> This new method gets num_tx_queues/real_num_tx_queues
> from real device.
>=20
> register_vlan_device() is also handled.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  include/net/rtnetlink.h  |    2 ++
>  net/8021q/vlan.c         |    5 +++--
>  net/8021q/vlan_netlink.c |   20 ++++++++++++++++++++
>  net/core/rtnetlink.c     |   10 +++++++++-
>  4 files changed, 34 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
> index 3c1895e..3f4ab54 100644
> --- a/include/net/rtnetlink.h
> +++ b/include/net/rtnetlink.h
> @@ -70,6 +70,8 @@ struct rtnl_link_ops {
>  	size_t			(*get_xstats_size)(const struct net_device *dev);
>  	int			(*fill_xstats)(struct sk_buff *skb,
>  					       const struct net_device *dev);
> +	int			(*get_tx_queues)(struct net *net, struct nlattr *tb[],
> +						 int *tx_queues, int *real_tx_queues);
>  };
> =20
>  extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index e814794..8836575 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -330,12 +330,13 @@ static int register_vlan_device(struct net_devi=
ce *real_dev, u16 vlan_id)
>  		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
>  	}
> =20
> -	new_dev =3D alloc_netdev(sizeof(struct vlan_dev_info), name,
> -			       vlan_setup);
> +	new_dev =3D alloc_netdev_mq(sizeof(struct vlan_dev_info), name,
> +				  vlan_setup, real_dev->num_tx_queues);
> =20
>  	if (new_dev =3D=3D NULL)
>  		return -ENOBUFS;
> =20
> +	new_dev->real_num_tx_queues =3D real_dev->real_num_tx_queues;
>  	dev_net_set(new_dev, net);
>  	/* need 4 bytes for extra VLAN header info,
>  	 * hope the underlying device can handle it.
> diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
> index e9c91dc..8ce4122 100644
> --- a/net/8021q/vlan_netlink.c
> +++ b/net/8021q/vlan_netlink.c
> @@ -100,6 +100,25 @@ static int vlan_changelink(struct net_device *de=
v,
>  	return 0;
>  }
> =20
> +static int vlan_get_tx_queues(struct net *net,=20
> +			      struct nlattr *tb[],
> +			      int *num_tx_queues,
> +			      int *real_num_tx_queues)


Nitpick again.  use unsigned unless you have some reason
to allow -1.
