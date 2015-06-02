From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC net-next 2/3] ipv4: storing and retrieval of per-nexthop
 encap
Date: Tue, 02 Jun 2015 09:01:44 -0700
Message-ID: <556DD368.8070806@cumulusnetworks.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com> <1433177175-16775-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36678 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759594AbbFBQBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 12:01:48 -0400
Received: by qgf2 with SMTP id 2so60650736qgf.3
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 09:01:47 -0700 (PDT)
In-Reply-To: <1433177175-16775-3-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/15, 9:46 AM, Robert Shearman wrote:
> Parse RTA_ENCAP attribute for one path and multipath routes. The encap
> length is stored in a newly added field to fib_nh, nh_encap_len,
> although this is added to a padding hole in the structure so that it
> doesn't increase the size at all. The encap data itself is stored at
> the end of the array of nexthops. Whilst this means that retrieval
> isn't optimal, especially if there are multiple nexthops, this avoids
> the memory cost of an extra pointer, as well as any potential change
> to the cache or instruction layout that could cause a performance
> impact.
>
> Currently, the dst structure allocated to represent the destination of
> the packet and used for retrieving the encap by the encap-type
> interface has been grown through the addition of the rt_encap_len and
> rt_encap fields. This isn't desirable and could be fixed by defining a
> new destination type with operations copied from the normal case,
> other than the addition of the get_encap operation.
>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>   include/net/ip_fib.h     |   2 +
>   include/net/route.h      |   3 +
>   net/ipv4/fib_frontend.c  |   3 +
>   net/ipv4/fib_lookup.h    |   2 +
>   net/ipv4/fib_semantics.c | 179 ++++++++++++++++++++++++++++++++++++++++++++++-
>   net/ipv4/route.c         |  24 +++++++
>   6 files changed, 211 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 54271ed0ed45..a06cec5eb3aa 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -44,6 +44,7 @@ struct fib_config {
>   	u32			fc_flow;
>   	u32			fc_nlflags;
>   	struct nl_info		fc_nlinfo;
> +	struct nlattr *fc_encap;
>    };
>   
>   struct fib_info;
> @@ -75,6 +76,7 @@ struct fib_nh {
>   	struct fib_info		*nh_parent;
>   	unsigned int		nh_flags;
>   	unsigned char		nh_scope;
> +	unsigned char		nh_encap_len;
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>   	int			nh_weight;
>   	int			nh_power;
> diff --git a/include/net/route.h b/include/net/route.h
> index fe22d03afb6a..e8b58914c4c1 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -64,6 +64,9 @@ struct rtable {
>   	/* Miscellaneous cached information */
>   	u32			rt_pmtu;
>   
> +	unsigned int		rt_encap_len;
> +	void			*rt_encap;
> +
>   	struct list_head	rt_uncached;
>   	struct uncached_list	*rt_uncached_list;
>   };
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 872494e6e6eb..aa538ab7e3b9 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -656,6 +656,9 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
>   		case RTA_TABLE:
>   			cfg->fc_table = nla_get_u32(attr);
>   			break;
> +		case RTA_ENCAP:
> +			cfg->fc_encap = attr;
> +			break;
>   		}
>   	}
>   
> diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
> index c6211ed60b03..003318c51ae8 100644
> --- a/net/ipv4/fib_lookup.h
> +++ b/net/ipv4/fib_lookup.h
> @@ -34,6 +34,8 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event, u32 tb_id,
>   		  unsigned int);
>   void rtmsg_fib(int event, __be32 key, struct fib_alias *fa, int dst_len,
>   	       u32 tb_id, const struct nl_info *info, unsigned int nlm_flags);
> +const void *fib_get_nh_encap(const struct fib_info *fi,
> +			     const struct fib_nh *nh);
>   
>   static inline void fib_result_assign(struct fib_result *res,
>   				     struct fib_info *fi)
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 28ec3c1823bf..db466b636241 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -257,6 +257,9 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
>   	const struct fib_nh *onh = ofi->fib_nh;
>   
>   	for_nexthops(fi) {
> +		const void *onh_encap = fib_get_nh_encap(fi, nh);
> +		const void *nh_encap = fib_get_nh_encap(fi, nh);
> +
>   		if (nh->nh_oif != onh->nh_oif ||
>   		    nh->nh_gw  != onh->nh_gw ||
>   		    nh->nh_scope != onh->nh_scope ||
> @@ -266,7 +269,10 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
>   #ifdef CONFIG_IP_ROUTE_CLASSID
>   		    nh->nh_tclassid != onh->nh_tclassid ||
>   #endif
> -		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
> +		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD) ||
> +		    nh->nh_encap_len != onh->nh_encap_len ||
> +		    memcmp(nh_encap, onh_encap, nh->nh_encap_len)
> +			)
>   			return -1;
>   		onh++;
>   	} endfor_nexthops(fi);
> @@ -374,6 +380,11 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
>   		/* may contain flow and gateway attribute */
>   		nhsize += 2 * nla_total_size(4);
>   
> +		for_nexthops(fi) {
> +			if (nh->nh_encap_len)
> +				nhsize += nla_total_size(nh->nh_encap_len);
> +		} endfor_nexthops(fi);
> +
>   		/* all nexthops are packed in a nested attribute */
>   		payload += nla_total_size(fi->fib_nhs * nhsize);
>   	}
> @@ -434,6 +445,83 @@ static int fib_detect_death(struct fib_info *fi, int order,
>   	return 1;
>   }
>   
> +static int fib_total_encap(struct fib_config *cfg)
> +{
> +	struct net *net = cfg->fc_nlinfo.nl_net;
> +	int total_encap_len = 0;
> +
> +	if (cfg->fc_mp) {
> +		int remaining = cfg->fc_mp_len;
> +		struct rtnexthop *rtnh = cfg->fc_mp;
> +
> +		while (rtnh_ok(rtnh, remaining)) {
> +			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
> +			int attrlen;
> +
> +			attrlen = rtnh_attrlen(rtnh);
> +			nla = nla_find(attrs, attrlen, RTA_ENCAP);
> +			if (nla) {
> +				struct net_device *dev;
> +				int len;
> +
> +				dev = __dev_get_by_index(net,
> +							 rtnh->rtnh_ifindex);
> +				if (!dev)
> +					return -EINVAL;
> +
> +				/* Determine space required */
> +				len = rtnl_parse_encap(dev, nla, NULL);
> +				if (len < 0)
> +					return len;
> +
> +				total_encap_len += len;
> +			}
> +
> +			rtnh = rtnh_next(rtnh, &remaining);
> +		}
> +	} else {
> +		if (cfg->fc_encap) {
> +			struct net_device *dev;
> +			int len;
> +
> +			dev = __dev_get_by_index(net, cfg->fc_oif);
> +			if (!dev)
> +				return -EINVAL;
> +
> +			/* Determine space required */
> +			len = rtnl_parse_encap(dev, cfg->fc_encap, NULL);
> +			if (len < 0)
> +				return len;
> +
> +			total_encap_len += len;
> +		}
> +	}
> +
> +	return total_encap_len;
> +}
we could avoid parsing and finding this device twice, if fib_nh just 
held a pointer to the encap_info
(or tunnel info) ?. And the encap_info/tun_info could be refcounted and 
shared between
nexthops ?. In my implementation i have just a pointer to parsed encap state
in fib_nh

> +
> +static void *__fib_get_nh_encap(const struct fib_info *fi,
> +				const struct fib_nh *the_nh)
> +{
> +	char *cur_encap_ptr = (char *)(fi->fib_nh + fi->fib_nhs);
> +
> +	for_nexthops(fi) {
> +		if (nh == the_nh)
> +			return cur_encap_ptr;
> +		cur_encap_ptr += nh->nh_encap_len;
> +	} endfor_nexthops(fi);
> +
> +	return NULL;
> +}
> +
> +const void *fib_get_nh_encap(const struct fib_info *fi, const struct fib_nh *nh)
> +{
> +	if (!nh->nh_encap_len)
> +		return NULL;
> +
> +	return __fib_get_nh_encap(fi, nh);
> +}
> +
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>   
>   static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining)
> @@ -475,6 +563,26 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
>   			if (nexthop_nh->nh_tclassid)
>   				fi->fib_net->ipv4.fib_num_tclassid_users++;
>   #endif
> +			nla = nla_find(attrs, attrlen, RTA_ENCAP);
> +			if (nla) {
> +				struct net *net = cfg->fc_nlinfo.nl_net;
> +				struct net_device *dev;
> +				void *nh_encap;
> +				int len;
> +
> +				dev = __dev_get_by_index(net,
> +							 nexthop_nh->nh_oif);
> +				if (!dev)
> +					return -EINVAL;
> +
> +				nh_encap = __fib_get_nh_encap(fi, nexthop_nh);
> +
> +				/* Fill in nh encap */
> +				len = rtnl_parse_encap(dev, nla, nh_encap);
> +				if (len < 0)
> +					return len;
> +				nexthop_nh->nh_encap_len = len;
> +			}
>   		}
>   
>   		rtnh = rtnh_next(rtnh, &remaining);
> @@ -495,6 +603,17 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
>   	if (cfg->fc_priority && cfg->fc_priority != fi->fib_priority)
>   		return 1;
>   
> +	if (cfg->fc_encap) {
> +		const void *nh_encap = fib_get_nh_encap(fi, fi->fib_nh);
> +
> +		if (!fi->fib_nh->nh_oif ||
> +		    rtnl_match_encap(fi->fib_nh->nh_dev,
> +				     cfg->fc_encap,
> +				     fi->fib_nh->nh_encap_len,
> +				     nh_encap))
> +			return 1;
> +	}
> +
>   	if (cfg->fc_oif || cfg->fc_gw) {
>   		if ((!cfg->fc_oif || cfg->fc_oif == fi->fib_nh->nh_oif) &&
>   		    (!cfg->fc_gw  || cfg->fc_gw == fi->fib_nh->nh_gw))
> @@ -530,6 +649,17 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
>   			if (nla && nla_get_u32(nla) != nh->nh_tclassid)
>   				return 1;
>   #endif
> +			nla = nla_find(attrs, attrlen, RTA_ENCAP);
> +			if (nla) {
> +				const void *nh_encap = fib_get_nh_encap(fi, nh);
> +
> +				if (!nh->nh_oif ||
> +				    rtnl_match_encap(nh->nh_dev,
> +						     cfg->fc_encap,
> +						     nh->nh_encap_len,
> +						     nh_encap))
> +					return 1;
> +			}
>   		}
>   
>   		rtnh = rtnh_next(rtnh, &remaining);
> @@ -760,6 +890,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
>   	struct fib_info *ofi;
>   	int nhs = 1;
>   	struct net *net = cfg->fc_nlinfo.nl_net;
> +	int encap_len;
>   
>   	if (cfg->fc_type > RTN_MAX)
>   		goto err_inval;
> @@ -798,7 +929,14 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
>   			goto failure;
>   	}
>   
> -	fi = kzalloc(sizeof(*fi)+nhs*sizeof(struct fib_nh), GFP_KERNEL);
> +	encap_len = fib_total_encap(cfg);
> +	if (encap_len < 0) {
> +		err = encap_len;
> +		goto failure;
> +	}
> +
> +	fi = kzalloc(sizeof(*fi) + nhs * sizeof(struct fib_nh) + encap_len,
> +		     GFP_KERNEL);
>   	if (!fi)
>   		goto failure;
>   	fib_info_cnt++;
> @@ -886,6 +1024,26 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>   		nh->nh_weight = 1;
>   #endif
> +		if (cfg->fc_encap) {
> +			struct net_device *dev;
> +			void *nh_encap;
> +			int len;
> +
> +			err = -EINVAL;
> +			dev = __dev_get_by_index(net, nh->nh_oif);
> +			if (!dev)
> +				goto failure;
> +
> +			nh_encap = __fib_get_nh_encap(fi, nh);
> +
> +			/* Fill in nh encap */
> +			len = rtnl_parse_encap(dev, cfg->fc_encap, nh_encap);
> +			if (len < 0 || len > sizeof(nh->nh_encap_len) * 8) {
> +				err = len;
> +				goto failure;
> +			}
> +			nh->nh_encap_len = len;
> +		}
>   	}
>   
>   	if (fib_props[cfg->fc_type].error) {
> @@ -1023,6 +1181,8 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>   	    nla_put_in_addr(skb, RTA_PREFSRC, fi->fib_prefsrc))
>   		goto nla_put_failure;
>   	if (fi->fib_nhs == 1) {
> +		const void *nh_encap;
> +
>   		if (fi->fib_nh->nh_gw &&
>   		    nla_put_in_addr(skb, RTA_GATEWAY, fi->fib_nh->nh_gw))
>   			goto nla_put_failure;
> @@ -1034,6 +1194,12 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>   		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
>   			goto nla_put_failure;
>   #endif
> +
> +		nh_encap = fib_get_nh_encap(fi, &fi->fib_nh[0]);
> +		if (nh_encap && rtnl_fill_encap(fi->fib_nh[0].nh_dev, skb,
> +						fi->fib_nh[0].nh_encap_len,
> +						nh_encap))
> +			goto nla_put_failure;
>   	}
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>   	if (fi->fib_nhs > 1) {
> @@ -1045,6 +1211,8 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>   			goto nla_put_failure;
>   
>   		for_nexthops(fi) {
> +			const void *nh_encap;
> +
>   			rtnh = nla_reserve_nohdr(skb, sizeof(*rtnh));
>   			if (!rtnh)
>   				goto nla_put_failure;
> @@ -1061,6 +1229,13 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
>   			    nla_put_u32(skb, RTA_FLOW, nh->nh_tclassid))
>   				goto nla_put_failure;
>   #endif
> +
> +			nh_encap = fib_get_nh_encap(fi, nh);
> +			if (nh_encap && rtnl_fill_encap(nh->nh_dev, skb,
> +							nh->nh_encap_len,
> +							nh_encap))
> +				goto nla_put_failure;
> +
>   			/* length of rtnetlink header + attributes */
>   			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
>   		} endfor_nexthops(fi);
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index f6055984c307..d52fa3d168a5 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -110,6 +110,8 @@
>   #endif
>   #include <net/secure_seq.h>
>   
> +#include "fib_lookup.h"
> +
>   #define RT_FL_TOS(oldflp4) \
>   	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
>   
> @@ -138,6 +140,8 @@ static void		 ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
>   					   struct sk_buff *skb, u32 mtu);
>   static void		 ip_do_redirect(struct dst_entry *dst, struct sock *sk,
>   					struct sk_buff *skb);
> +static int		ipv4_dst_get_encap(const struct dst_entry *dst,
> +					   const void **encap);
>   static void		ipv4_dst_destroy(struct dst_entry *dst);
>   
>   static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
> @@ -163,6 +167,7 @@ static struct dst_ops ipv4_dst_ops = {
>   	.redirect =		ip_do_redirect,
>   	.local_out =		__ip_local_out,
>   	.neigh_lookup =		ipv4_neigh_lookup,
> +	.get_encap =		ipv4_dst_get_encap,
>   };
>   
>   #define ECN_OR_COST(class)	TC_PRIO_##class
> @@ -1145,6 +1150,15 @@ static void ipv4_link_failure(struct sk_buff *skb)
>   		dst_set_expires(&rt->dst, 0);
>   }
>   
> +static int ipv4_dst_get_encap(const struct dst_entry *dst,
> +			      const void **encap)
> +{
> +	const struct rtable *rt = (const struct rtable *)dst;
> +
> +	*encap = rt->rt_encap;
> +	return rt->rt_encap_len;
> +}
> +
>   static int ip_rt_bug(struct sock *sk, struct sk_buff *skb)
>   {
>   	pr_debug("%s: %pI4 -> %pI4, %s\n",
> @@ -1394,6 +1408,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
>   
>   	if (fi) {
>   		struct fib_nh *nh = &FIB_RES_NH(*res);
> +		const void *nh_encap;
>   
>   		if (nh->nh_gw && nh->nh_scope == RT_SCOPE_LINK) {
>   			rt->rt_gateway = nh->nh_gw;
> @@ -1403,6 +1418,15 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
>   #ifdef CONFIG_IP_ROUTE_CLASSID
>   		rt->dst.tclassid = nh->nh_tclassid;
>   #endif
> +
> +		nh_encap = fib_get_nh_encap(fi, nh);
> +		if (unlikely(nh_encap)) {
> +			rt->rt_encap = kmemdup(nh_encap, nh->nh_encap_len,
> +					       GFP_KERNEL);
> +			if (rt->rt_encap)
> +				rt->rt_encap_len = nh->nh_encap_len;
> +		}
> +

And..., you could make the rtable point to the same encap info.
