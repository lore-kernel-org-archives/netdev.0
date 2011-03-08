From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Tue, 8 Mar 2011 11:57:38 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103081030090.1529@ja.ssi.bg>
References: <20110307.205815.193699096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57277 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752291Ab1CHJxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 04:53:02 -0500
In-Reply-To: <20110307.205815.193699096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Mon, 7 Mar 2011, David Miller wrote:

> When doing output route lookups, we have to select the source address
> if the user has not specified an explicit one.
>
> First, if the route has an explicit preferred source address
> specified, then we use that.
>
> Otherwise we search the route's outgoing interface for a suitable
> address.
>
> This search can be precomputed and cached at route insertion time.
>
> The only missing part is that we have to refresh this precomputed
> value any time addresses are added or removed from the interface, and
> this is accomplished by fib_update_nh_saddrs().
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> include/net/ip_fib.h     |    7 +++++--
> net/ipv4/fib_frontend.c  |    2 ++
> net/ipv4/fib_semantics.c |   31 ++++++++++++++++++++++++-------
> 3 files changed, 31 insertions(+), 9 deletions(-)
>
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 523a170..0e14083 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -60,6 +60,7 @@ struct fib_nh {
> #endif
> 	int			nh_oif;
> 	__be32			nh_gw;
> +	__be32			nh_saddr;
> };
>
> /*
> @@ -139,11 +140,13 @@ struct fib_result_nl {
>
> #endif /* CONFIG_IP_ROUTE_MULTIPATH */
>
> -#define FIB_RES_PREFSRC(res)		((res).fi->fib_prefsrc ? : __fib_res_prefsrc(&res))
> +#define FIB_RES_SADDR(res)		(FIB_RES_NH(res).nh_saddr)
> #define FIB_RES_GW(res)			(FIB_RES_NH(res).nh_gw)
> #define FIB_RES_DEV(res)		(FIB_RES_NH(res).nh_dev)
> #define FIB_RES_OIF(res)		(FIB_RES_NH(res).nh_oif)
>
> +#define FIB_RES_PREFSRC(res)		((res).fi->fib_prefsrc ? : FIB_RES_SADDR(res))
> +
> struct fib_table {
> 	struct hlist_node tb_hlist;
> 	u32		tb_id;
> @@ -224,8 +227,8 @@ extern void fib_select_default(struct fib_result *res);
> extern int ip_fib_check_default(__be32 gw, struct net_device *dev);
> extern int fib_sync_down_dev(struct net_device *dev, int force);
> extern int fib_sync_down_addr(struct net *net, __be32 local);
> +extern void fib_update_nh_saddrs(struct net_device *dev);
> extern int fib_sync_up(struct net_device *dev);
> -extern __be32  __fib_res_prefsrc(struct fib_result *res);
> extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res);
>
> /* Exported by fib_trie.c */
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index ad0778a..1d2233c 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -890,10 +890,12 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
> #ifdef CONFIG_IP_ROUTE_MULTIPATH
> 		fib_sync_up(dev);
> #endif
> +		fib_update_nh_saddrs(dev);
> 		rt_cache_flush(dev_net(dev), -1);
> 		break;
> 	case NETDEV_DOWN:
> 		fib_del_ifaddr(ifa);
> +		fib_update_nh_saddrs(dev);
> 		if (ifa->ifa_dev->ifa_list == NULL) {
> 			/* Last address was deleted from this interface.
> 			 * Disable IP.
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 6349a21..952c737 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -853,6 +853,12 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
> 				goto err_inval;
> 	}
>
> +	change_nexthops(fi) {
> +		nexthop_nh->nh_saddr = inet_select_addr(nexthop_nh->nh_dev,
> +							nexthop_nh->nh_gw,
> +							nexthop_nh->nh_scope);
> +	} endfor_nexthops(fi)
> +
> link_it:
> 	ofi = fib_find_info(fi);
> 	if (ofi) {
> @@ -898,13 +904,6 @@ failure:
> 	return ERR_PTR(err);
> }
>
> -/* Find appropriate source address to this destination */
> -
> -__be32 __fib_res_prefsrc(struct fib_result *res)
> -{
> -	return inet_select_addr(FIB_RES_DEV(*res), FIB_RES_GW(*res), res->scope);
> -}
> -
> int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
> 		  u32 tb_id, u8 type, u8 scope, __be32 dst, int dst_len, u8 tos,
> 		  struct fib_info *fi, unsigned int flags)
> @@ -1128,6 +1127,24 @@ out:
> 	return;
> }
>
> +void fib_update_nh_saddrs(struct net_device *dev)
> +{
> +	struct hlist_head *head;
> +	struct hlist_node *node;
> +	struct fib_nh *nh;
> +	unsigned int hash;
> +
> +	hash = fib_devindex_hashfn(dev->ifindex);
> +	head = &fib_info_devhash[hash];
> +	hlist_for_each_entry(nh, node, head, nh_hash) {
> +		if (nh->nh_dev != dev)
> +			continue;
> +		nh->nh_saddr = inet_select_addr(nh->nh_dev,
> +						nh->nh_gw,
> +						nh->nh_scope);

 	The idea to have per-nexthop src is good, mostly for
multipath routes. May be one day it will be possible to
provide prefsrc for nexthop from user space.

 	But I see problems with this patch. nh_scope
indicates if the nexthop is gatewayed (RT_SCOPE_LINK) or
direct (RT_SCOPE_HOST). OTOH, the addresses can be with
different scope: host, link, global (default). Same for
the routes.

 	Before now it was possible to bring device up, to add
scope host address there, to add some link route without prefsrc.
In this case the output route will ignore the scope host address,
it can not be exposed to link or universe, global address
from another device will be selected. inet_select_addr works
in this way: get address with scope <= provided_scope from
provided_device or global address from another device.

 	It means, even if there are addresses on the
concerned device it does not mean the routes on this device
are required to use prefsrc from this device. We must
restrict the scope according to the provided for the
route: cfg->fc_scope. That is how it worked before now:
__fib_res_prefsrc uses res->scope, it was set by
fib_semantic_match() with fa_scope, fa_scope is set
from cfg->fc_scope. Then we will select proper saddr
according to the provided scope for the route: host,
link or global route.

 	Also, may be we must be prepared to call
fib_update_nh_saddrs for last_ip events, just like
fib_sync_down_addr is called. Or we have to implement it
as fib_saddr/fib_src and fib_update_nh_saddrs should be part of
fib_sync_down_addr. fib_saddr can be set from fib_prefsrc or
from inet_select_addr(nh->nh_dev, nh->nh_gw, cfg->fc_scope)
and then we should replace fib_prefsrc hashing with
fib_saddr hashing, so that events can invalidate these
routes.

 	But as we need nh_saddr to replace __fib_res_prefsrc()
I think we should add additional hashing, just like for
fib_prefsrc, we need nh_saddr_hash. fib_update_nh_saddrs
should be called to walk nh_saddr_hash entries, from
the same place where fib_sync_down_addr is called.
As the addresses have nothing to do with the link
state, I don't think it is correct to call fib_update_nh_saddrs
for DEV events.

> +	}
> +}
> +
> #ifdef CONFIG_IP_ROUTE_MULTIPATH
>
> /*
> -- 
> 1.7.4.1

Regards

--
Julian Anastasov <ja@ssi.bg>
