From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH RFC 2/2] ipv6: Add support for IPsec virtual tunnel interfaces
Date: Thu, 22 Aug 2013 15:47:00 +0800
Message-ID: <5215C1F4.9030609@windriver.com>
References: <20130819062623.GN26773@secunet.com> <20130819062730.GP26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.windriver.com ([128.224.252.3]:43792 "EHLO
	mail7.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475Ab3HVHqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 03:46:50 -0400
In-Reply-To: <20130819062730.GP26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8819=E6=97=A5 14:27, Steffen Klassert wrote:
> This patch adds IPv6  support for IPsec virtual tunnel interfaces
> (vti). IPsec virtual tunnel interfaces provide a routable interface
> for IPsec tunnel endpoints.
>
> Signed-off-by: Steffen Klassert<steffen.klassert@secunet.com>
> ---
>   net/ipv6/Kconfig   |   11 +
>   net/ipv6/Makefile  |    1 +
>   net/ipv6/ip6_vti.c | 1092 +++++++++++++++++++++++++++++++++++++++++=
+++++++++++
>   3 files changed, 1104 insertions(+)
>   create mode 100644 net/ipv6/ip6_vti.c
>
> diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
> index 11b13ea..e1a8d90 100644
> --- a/net/ipv6/Kconfig
> +++ b/net/ipv6/Kconfig
> @@ -153,6 +153,17 @@ config INET6_XFRM_MODE_ROUTEOPTIMIZATION
>   	---help---
>   	  Support for MIPv6 route optimization mode.
>
> +config IPV6_VTI
> +tristate "Virtual (secure) IPv6: tunneling"
> +	select IPV6_TUNNEL
> +	depends on INET6_XFRM_MODE_TUNNEL
> +	---help---
> +	Tunneling means encapsulating data of one protocol type within
> +	another protocol and sending it over a channel that understands the
> +	encapsulating protocol. This can be used with xfrm mode tunnel to g=
ive
> +	the notion of a secure tunnel for IPSEC and then use routing protoc=
ol
> +	on top.
> +
>   config IPV6_SIT
>   	tristate "IPv6: IPv6-in-IPv4 tunnel (SIT driver)"
>   	select INET_TUNNEL
> diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
> index 470a9c0..17bb830 100644
> --- a/net/ipv6/Makefile
> +++ b/net/ipv6/Makefile
> @@ -36,6 +36,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_BEET) +=3D xfrm6_mode_=
beet.o
>   obj-$(CONFIG_IPV6_MIP6) +=3D mip6.o
>   obj-$(CONFIG_NETFILTER)	+=3D netfilter/
>
> +obj-$(CONFIG_IPV6_VTI) +=3D ip6_vti.o
>   obj-$(CONFIG_IPV6_SIT) +=3D sit.o
>   obj-$(CONFIG_IPV6_TUNNEL) +=3D ip6_tunnel.o
>   obj-$(CONFIG_IPV6_GRE) +=3D ip6_gre.o
> diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
> new file mode 100644
> index 0000000..fb0b6b0
> --- /dev/null
> +++ b/net/ipv6/ip6_vti.c
> @@ -0,0 +1,1092 @@
> +/*
> + *	IPv6 virtual tunneling interface
> + *
> + *	Copyright (C) 2013 secunet Security Networks AG
> + *
> + *	Author:
> + *	Steffen Klassert<steffen.klassert@secunet.com>
> + *
> + *	Based on:
> + *	net/ipv6/ip6_tunnel.c
> + *
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	as published by the Free Software Foundation; either version
> + *	2 of the License, or (at your option) any later version.
> + */
> +
> +#include<linux/module.h>
> +#include<linux/capability.h>
> +#include<linux/errno.h>
> +#include<linux/types.h>
> +#include<linux/sockios.h>
> +#include<linux/icmp.h>
> +#include<linux/if.h>
> +#include<linux/in.h>
> +#include<linux/ip.h>
> +#include<linux/if_tunnel.h>
> +#include<linux/net.h>
> +#include<linux/in6.h>
> +#include<linux/netdevice.h>
> +#include<linux/if_arp.h>
> +#include<linux/icmpv6.h>
> +#include<linux/init.h>
> +#include<linux/route.h>
> +#include<linux/rtnetlink.h>
> +#include<linux/netfilter_ipv6.h>
> +#include<linux/slab.h>
> +#include<linux/hash.h>
> +
> +#include<asm/uaccess.h>
> +#include<linux/atomic.h>
> +
> +#include<net/icmp.h>
> +#include<net/ip.h>
> +#include<net/ip_tunnels.h>
> +#include<net/ipv6.h>
> +#include<net/ip6_route.h>
> +#include<net/addrconf.h>
> +#include<net/ip6_tunnel.h>
> +#include<net/xfrm.h>
> +#include<net/net_namespace.h>
> +#include<net/netns/generic.h>
> +
> +#define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK&  ~IPV6_FLOWLABEL_MASK)
> +
> +#define HASH_SIZE_SHIFT  5
> +#define HASH_SIZE (1<<  HASH_SIZE_SHIFT)
> +
> +static u32 HASH(const struct in6_addr *addr1, const struct in6_addr =
*addr2)
> +{
> +	u32 hash =3D ipv6_addr_hash(addr1) ^ ipv6_addr_hash(addr2);
> +
> +	return hash_32(hash, HASH_SIZE_SHIFT);
> +}
> +
> +static int vti6_dev_init(struct net_device *dev);
> +static void vti6_dev_setup(struct net_device *dev);
> +static struct rtnl_link_ops vti6_link_ops __read_mostly;
> +
> +static int vti6_net_id __read_mostly;
> +struct vti6_net {
> +	/* the IPv6 tunnel fallback device */
> +	struct net_device *fb_tnl_dev;
> +	/* lists for storing tunnels in use */
> +	struct ip6_tnl __rcu *tnls_r_l[HASH_SIZE];
> +	struct ip6_tnl __rcu *tnls_wc[1];
> +	struct ip6_tnl __rcu **tnls[2];
> +};
> +
> +static struct net_device_stats *vti6_get_stats(struct net_device *de=
v)
> +{
> +	struct pcpu_tstats sum =3D { 0 };
> +	int i;
> +
> +	for_each_possible_cpu(i) {
> +		const struct pcpu_tstats *tstats =3D per_cpu_ptr(dev->tstats, i);
> +
> +		sum.rx_packets +=3D tstats->rx_packets;
> +		sum.rx_bytes   +=3D tstats->rx_bytes;
> +		sum.tx_packets +=3D tstats->tx_packets;
> +		sum.tx_bytes   +=3D tstats->tx_bytes;
> +	}
> +	dev->stats.rx_packets =3D sum.rx_packets;
> +	dev->stats.rx_bytes   =3D sum.rx_bytes;
> +	dev->stats.tx_packets =3D sum.tx_packets;
> +	dev->stats.tx_bytes   =3D sum.tx_bytes;
> +	return&dev->stats;
> +}
> +
> +#define for_each_vti6_tunnel_rcu(start) \
> +	for (t =3D rcu_dereference(start); t; t =3D rcu_dereference(t->next=
))
> +
> +/**
> + * vti6_tnl_lookup - fetch tunnel matching the end-point addresses
> + *   @net: network namespace
> + *   @remote: the address of the tunnel exit-point
> + *   @local: the address of the tunnel entry-point
> + *
> + * Return:
> + *   tunnel matching given end-points if found,
> + *   else fallback tunnel if its device is up,
> + *   else %NULL
> + **/
> +static struct ip6_tnl *
> +vti6_tnl_lookup(struct net *net, const struct in6_addr *remote,
> +		const struct in6_addr *local)
> +{
> +	unsigned int hash =3D HASH(remote, local);
> +	struct ip6_tnl *t;
> +	struct vti6_net *ip6n =3D net_generic(net, vti6_net_id);
> +
> +	for_each_vti6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
> +		if (ipv6_addr_equal(local,&t->parms.laddr)&&
> +		    ipv6_addr_equal(remote,&t->parms.raddr)&&
> +		    (t->dev->flags&  IFF_UP))
> +			return t;
> +	}
> +	t =3D rcu_dereference(ip6n->tnls_wc[0]);
> +	if (t&&  (t->dev->flags&  IFF_UP))
> +		return t;
> +
> +	return NULL;
> +}
> +
> +/**
> + * vti6_tnl_bucket - get head of list matching given tunnel paramete=
rs
> + *   @p: parameters containing tunnel end-points
> + *
> + * Description:
> + *   vti6_tnl_bucket() returns the head of the list matching the
> + *&struct in6_addr entries laddr and raddr in @p.
> + *
> + * Return: head of IPv6 tunnel list
> + **/
> +static struct ip6_tnl __rcu **
> +vti6_tnl_bucket(struct vti6_net *ip6n, const struct __ip6_tnl_parm *=
p)
> +{
> +	const struct in6_addr *remote =3D&p->raddr;
> +	const struct in6_addr *local =3D&p->laddr;
> +	unsigned int h =3D 0;
> +	int prio =3D 0;
> +
> +	if (!ipv6_addr_any(remote) || !ipv6_addr_any(local)) {
> +		prio =3D 1;
> +		h =3D HASH(remote, local);
> +	}
> +	return&ip6n->tnls[prio][h];
> +}
> +
> +static void
> +vti6_tnl_link(struct vti6_net *ip6n, struct ip6_tnl *t)
> +{
> +	struct ip6_tnl __rcu **tp =3D vti6_tnl_bucket(ip6n,&t->parms);
> +
> +	rcu_assign_pointer(t->next , rtnl_dereference(*tp));
> +	rcu_assign_pointer(*tp, t);
> +}
> +
> +static void
> +vti6_tnl_unlink(struct vti6_net *ip6n, struct ip6_tnl *t)
> +{
> +	struct ip6_tnl __rcu **tp;
> +	struct ip6_tnl *iter;
> +
> +	for (tp =3D vti6_tnl_bucket(ip6n,&t->parms);
> +	     (iter =3D rtnl_dereference(*tp)) !=3D NULL;
> +	     tp =3D&iter->next) {
> +		if (t =3D=3D iter) {
> +			rcu_assign_pointer(*tp, t->next);
> +			break;
> +		}
> +	}
> +}
> +
> +static void vti6_dev_free(struct net_device *dev)
> +{
> +	free_percpu(dev->tstats);
> +	free_netdev(dev);
> +}
> +
> +static int vti6_tnl_create2(struct net_device *dev)
> +{
> +	struct ip6_tnl *t =3D netdev_priv(dev);
> +	struct net *net =3D dev_net(dev);
> +	struct vti6_net *ip6n =3D net_generic(net, vti6_net_id);
> +	int err;
> +
> +	err =3D vti6_dev_init(dev);
> +	if (err<  0)
> +		goto out;
> +
> +	err =3D register_netdevice(dev);
> +	if (err<  0)
> +		goto out;
> +
> +	strcpy(t->parms.name, dev->name);
> +	dev->rtnl_link_ops =3D&vti6_link_ops;
> +
> +	dev_hold(dev);
> +	vti6_tnl_link(ip6n, t);
> +
> +	return 0;
> +
> +out:
> +	return err;
> +}
> +static struct ip6_tnl *vti6_tnl_create(struct net *net, struct __ip6=
_tnl_parm *p)
> +{
> +	struct net_device *dev;
> +	struct ip6_tnl *t;
> +	char name[IFNAMSIZ];
> +	int err;
> +
> +	if (p->name[0])
> +		strlcpy(name, p->name, IFNAMSIZ);
> +	else
> +		sprintf(name, "ip6_vti%%d");
> +
> +	dev =3D alloc_netdev(sizeof (*t), name, vti6_dev_setup);
> +	if (dev =3D=3D NULL)
> +		goto failed;
> +
> +	dev_net_set(dev, net);
> +
> +	t =3D netdev_priv(dev);
> +	t->parms =3D *p;
> +	t->net =3D dev_net(dev);
> +
> +	err =3D vti6_tnl_create2(dev);
> +	if (err<  0)
> +		goto failed_free;
> +
> +	return t;
> +
> +failed_free:
> +	vti6_dev_free(dev);
> +failed:
> +	return NULL;
> +}
> +
> +/**
> + * vti6_locate - find or create tunnel matching given parameters
> + *   @net: network namespace
> + *   @p: tunnel parameters
> + *   @create: !=3D 0 if allowed to create new tunnel if no match fou=
nd
> + *
> + * Description:
> + *   vti6_locate() first tries to locate an existing tunnel
> + *   based on @parms. If this is unsuccessful, but @create is set a =
new
> + *   tunnel device is created and registered for use.
> + *
> + * Return:
> + *   matching tunnel or NULL
> + **/
> +static struct ip6_tnl *vti6_locate(struct net *net, struct __ip6_tnl=
_parm *p, int create)
> +{
> +	const struct in6_addr *remote =3D&p->raddr;
> +	const struct in6_addr *local =3D&p->laddr;
> +	struct ip6_tnl __rcu **tp;
> +	struct ip6_tnl *t;
> +	struct vti6_net *ip6n =3D net_generic(net, vti6_net_id);
> +
> +	for (tp =3D vti6_tnl_bucket(ip6n, p);
> +	     (t =3D rtnl_dereference(*tp)) !=3D NULL;
> +	     tp =3D&t->next) {
> +		if (ipv6_addr_equal(local,&t->parms.laddr)&&
> +		    ipv6_addr_equal(remote,&t->parms.raddr))
> +			return t;
> +	}
> +	if (!create)
> +		return NULL;
> +	return vti6_tnl_create(net, p);
> +}
> +
> +/**
> + * vti6_dev_uninit - tunnel device uninitializer
> + *   @dev: the device to be destroyed
> + *
> + * Description:
> + *   vti6_dev_uninit() removes tunnel from its list
> + **/
> +static void
> +vti6_dev_uninit(struct net_device *dev)
> +{
> +	struct ip6_tnl *t =3D netdev_priv(dev);
> +	struct net *net =3D dev_net(dev);
> +	struct vti6_net *ip6n =3D net_generic(net, vti6_net_id);
> +
> +	if (dev =3D=3D ip6n->fb_tnl_dev)
> +		RCU_INIT_POINTER(ip6n->tnls_wc[0], NULL);
> +	else
> +		vti6_tnl_unlink(ip6n, t);
> +	ip6_tnl_dst_reset(t);
> +	dev_put(dev);
> +}
> +
> +/**
> + * vti6_tnl_err - tunnel error handler
> + *
> + * Description:
> + *   vti6_err() handle errors in the tunnel.
> + **/
> +static int
> +vti6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> +	 u8 type, u8 code, int offset, __be32 info)
> +{
> +	struct net *net =3D dev_net(skb->dev);
> +	const struct ipv6hdr *ipv6h =3D (const struct ipv6hdr *) skb->data;
> +	struct ip6_tnl *t;
> +	int err =3D -ENOENT;
> +
> +	rcu_read_lock();
> +	if ((t =3D vti6_tnl_lookup(net,&ipv6h->daddr,
> +				&ipv6h->saddr)) =3D=3D NULL)
> +		goto out;
> +
> +	if (t->parms.proto !=3D IPPROTO_IPV6&&  t->parms.proto !=3D 0)
> +		goto out;
> +
> +	err =3D 0;
> +
> +	switch (type) {
> +	case ICMPV6_DEST_UNREACH:
> +	case ICMPV6_TIME_EXCEED:
> +	case ICMPV6_PARAMPROB:
> +	break;
> +	case ICMPV6_PKT_TOOBIG:
> +		ip6_update_pmtu(skb, net, info, 0, 0);
> +	}
> +
> +
> +out:
> +	rcu_read_unlock();
> +	return err;
> +}
> +
> +static int vti6_rcv(struct sk_buff *skb)
> +{
> +	struct ip6_tnl *t;
> +	const struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
> +
> +	rcu_read_lock();
> +
> +	if ((t =3D vti6_tnl_lookup(dev_net(skb->dev),&ipv6h->saddr,
> +					&ipv6h->daddr)) !=3D NULL) {
> +		struct pcpu_tstats *tstats;
> +
> +		if (t->parms.proto !=3D IPPROTO_IPV6&&  t->parms.proto !=3D 0) {
> +			rcu_read_unlock();
> +			goto discard;
> +		}
> +
> +		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
> +			rcu_read_unlock();
> +			return 0;
> +		}
> +
> +		if (!ip6_tnl_rcv_ctl(t,&ipv6h->daddr,&ipv6h->saddr)) {
> +			t->dev->stats.rx_dropped++;
> +			rcu_read_unlock();
> +			goto discard;
> +		}
> +
> +		tstats =3D this_cpu_ptr(t->dev->tstats);
> +		tstats->rx_packets++;
> +		tstats->rx_bytes +=3D skb->len;
> +
> +		skb->mark =3D 0;
> +		secpath_reset(skb);
> +		skb->dev =3D t->dev;
> +
> +		rcu_read_unlock();
> +		return 0;
> +	}
> +	rcu_read_unlock();
> +	return 1;
> +
> +discard:
> +	kfree_skb(skb);
> +	return 0;
> +}
> +
> +/**
> + * vti6_addr_conflict - compare packet addresses to tunnel's own
> + *   @t: the outgoing tunnel device
> + *   @hdr: IPv6 header from the incoming packet
> + *
> + * Description:
> + *   Avoid trivial tunneling loop by checking that tunnel exit-point
> + *   doesn't match source of incoming packet.
> + *
> + * Return:
> + *   1 if conflict,
> + *   0 else
> + **/
> +static inline bool
> +vti6_addr_conflict(const struct ip6_tnl *t, const struct ipv6hdr *hd=
r)
> +{
> +	return ipv6_addr_equal(&t->parms.raddr,&hdr->saddr);
> +}
> +
> +/**
> + * vti6_xmit - send a packet
> + *   @skb: the outgoing socket buffer
> + *   @dev: the outgoing tunnel device
> + **/
> +static int vti6_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct net *net =3D dev_net(dev);
> +	struct ip6_tnl *t =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D&t->dev->stats;
> +	struct dst_entry *dst =3D NULL, *ndst =3D NULL;
> +	struct flowi6 fl6;
> +	struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
> +	struct net_device *tdev;
> +	int err =3D -1;
> +
> +	if ((t->parms.proto !=3D IPPROTO_IPV6&&  t->parms.proto !=3D 0) ||
> +	    !ip6_tnl_xmit_ctl(t) || vti6_addr_conflict(t, ipv6h))
> +		return err;
> +
> +	dst =3D ip6_tnl_dst_check(t);
> +	if (!dst) {
> +		memcpy(&fl6,&t->fl.u.ip6, sizeof(fl6));
> +
> +		ndst =3D ip6_route_output(net, NULL,&fl6);
> +
> +		if (ndst->error)
> +			goto tx_err_link_failure;
> +		ndst =3D xfrm_lookup(net, ndst, flowi6_to_flowi(&fl6), NULL, 0);
> +		if (IS_ERR(ndst)) {
> +			err =3D PTR_ERR(ndst);
> +			ndst =3D NULL;
> +			goto tx_err_link_failure;
> +		}
> +		dst =3D ndst;
> +	}
> +
> +	if (!dst->xfrm || dst->xfrm->props.mode !=3D XFRM_MODE_TUNNEL)
> +		goto tx_err_link_failure;
> +
> +	tdev =3D dst->dev;
> +
> +	if (tdev =3D=3D dev) {
> +		stats->collisions++;
> +		net_warn_ratelimited("%s: Local routing loop detected!\n",
> +				     t->parms.name);
> +		goto tx_err_dst_release;
> +	}
> +
> +
> +	skb_dst_drop(skb);
> +	skb_dst_set_noref(skb, dst);
> +
> +	ip6tunnel_xmit(skb, dev);
> +	if (ndst)
> +		ip6_tnl_dst_store(t, ndst);
> +	return 0;
> +tx_err_link_failure:
> +	stats->tx_carrier_errors++;
> +	dst_link_failure(skb);
> +tx_err_dst_release:

Maybe it's necessary to count stats->tx_errors as well.

> +	dst_release(ndst);
> +	return err;
> +}

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
