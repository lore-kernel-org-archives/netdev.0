From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next 2/3] ipv4: L3 and L4 hash-based multipath routing
Date: Thu, 18 Jun 2015 15:52:22 -0700
Message-ID: <55834BA6.7050405@redhat.com>
References: <1434571686-5149-1-git-send-email-pch@ordbogen.com> <1434571686-5149-3-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-api@vger.kernel.org
To: =?UTF-8?B?UGV0ZXIgTsO4cmx1bmQ=?= <pch@ordbogen.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791AbbFRWw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 18:52:26 -0400
In-Reply-To: <1434571686-5149-3-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/17/2015 01:08 PM, Peter N=C3=B8rlund wrote:
> This patch adds L3 and L4 hash-based multipath routing, selectable on=
 a
> per-route basis with the reintroduced RTA_MP_ALGO attribute. The defa=
ult is
> now RT_MP_ALG_L3_HASH.
>
> Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
> ---
>   include/net/ip_fib.h           |  4 ++-
>   include/net/route.h            |  5 ++--
>   include/uapi/linux/rtnetlink.h | 14 ++++++++++-
>   net/ipv4/fib_frontend.c        |  4 +++
>   net/ipv4/fib_semantics.c       | 34 ++++++++++++++++++++++---
>   net/ipv4/icmp.c                |  4 +--
>   net/ipv4/route.c               | 56 +++++++++++++++++++++++++++++++=
++++-------
>   net/ipv4/xfrm4_policy.c        |  2 +-
>   8 files changed, 103 insertions(+), 20 deletions(-)
>
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 4be4f25..250d98e 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -37,6 +37,7 @@ struct fib_config {
>   	u32			fc_flags;
>   	u32			fc_priority;
>   	__be32			fc_prefsrc;
> +	int			fc_mp_alg;
>   	struct nlattr		*fc_mx;
>   	struct rtnexthop	*fc_mp;
>   	int			fc_mx_len;
> @@ -116,6 +117,7 @@ struct fib_info {
>   	int			fib_nhs;
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>   	int			fib_mp_weight;
> +	int			fib_mp_alg;
>   #endif
>   	struct rcu_head		rcu;
>   	struct fib_nh		fib_nh[0];
> @@ -308,7 +310,7 @@ int ip_fib_check_default(__be32 gw, struct net_de=
vice *dev);
>   int fib_sync_down_dev(struct net_device *dev, int force);
>   int fib_sync_down_addr(struct net *net, __be32 local);
>   int fib_sync_up(struct net_device *dev);
> -void fib_select_multipath(struct fib_result *res);
> +void fib_select_multipath(struct fib_result *res, const struct flowi=
4 *flow);
>
>   /* Exported by fib_trie.c */
>   void fib_trie_init(void);
> diff --git a/include/net/route.h b/include/net/route.h
> index fe22d03..1fc7deb 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -110,7 +110,8 @@ struct in_device;
>   int ip_rt_init(void);
>   void rt_cache_flush(struct net *net);
>   void rt_flush_dev(struct net_device *dev);
> -struct rtable *__ip_route_output_key(struct net *, struct flowi4 *fl=
p);
> +struct rtable *__ip_route_output_key(struct net *, struct flowi4 *fl=
p,
> +				     const struct flowi4 *mp_flow);
>   struct rtable *ip_route_output_flow(struct net *, struct flowi4 *fl=
p,
>   				    struct sock *sk);
>   struct dst_entry *ipv4_blackhole_route(struct net *net,
> @@ -267,7 +268,7 @@ static inline struct rtable *ip_route_connect(str=
uct flowi4 *fl4,
>   			      sport, dport, sk);
>
>   	if (!dst || !src) {
> -		rt =3D __ip_route_output_key(net, fl4);
> +		rt =3D __ip_route_output_key(net, fl4, NULL);
>   		if (IS_ERR(rt))
>   			return rt;
>   		ip_rt_put(rt);
> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtne=
tlink.h
> index 17fb02f..dff4a72 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -271,6 +271,18 @@ enum rt_scope_t {
>   #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
>   #define RTM_F_PREFIX		0x800	/* Prefix addresses		*/
>
> +/* Multipath algorithms */
> +
> +enum rt_mp_alg_t {
> +	RT_MP_ALG_L3_HASH,	/* Was IP_MP_ALG_NONE */
> +	RT_MP_ALG_PER_PACKET,	/* Was IP_MP_ALG_RR */
> +	RT_MP_ALG_DRR,		/* not used */
> +	RT_MP_ALG_RANDOM,	/* not used */
> +	RT_MP_ALG_WRANDOM,	/* not used */
> +	RT_MP_ALG_L4_HASH,
> +	__RT_MP_ALG_MAX
> +};
> +
>   /* Reserved table identifiers */
>
>   enum rt_class_t {
> @@ -301,7 +313,7 @@ enum rtattr_type_t {
>   	RTA_FLOW,
>   	RTA_CACHEINFO,
>   	RTA_SESSION, /* no longer used */
> -	RTA_MP_ALGO, /* no longer used */
> +	RTA_MP_ALGO,
>   	RTA_TABLE,
>   	RTA_MARK,
>   	RTA_MFC_STATS,
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 872494e..376e8c1 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -590,6 +590,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX +=
 1] =3D {
>   	[RTA_PREFSRC]		=3D { .type =3D NLA_U32 },
>   	[RTA_METRICS]		=3D { .type =3D NLA_NESTED },
>   	[RTA_MULTIPATH]		=3D { .len =3D sizeof(struct rtnexthop) },
> +	[RTA_MP_ALGO]		=3D { .type =3D NLA_U32 },
>   	[RTA_FLOW]		=3D { .type =3D NLA_U32 },
>   };
>
> @@ -650,6 +651,9 @@ static int rtm_to_fib_config(struct net *net, str=
uct sk_buff *skb,
>   			cfg->fc_mp =3D nla_data(attr);
>   			cfg->fc_mp_len =3D nla_len(attr);
>   			break;
> +		case RTA_MP_ALGO:
> +			cfg->fc_mp_alg =3D nla_get_u32(attr);
> +			break;
>   		case RTA_FLOW:
>   			cfg->fc_flow =3D nla_get_u32(attr);
>   			break;
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 8c8df80..da06e88 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -257,6 +257,11 @@ static inline int nh_comp(const struct fib_info =
*fi, const struct fib_info *ofi)
>   {
>   	const struct fib_nh *onh =3D ofi->fib_nh;
>
> +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> +	if (fi->fib_mp_alg !=3D ofi->fib_mp_alg)
> +		return -1;
> +#endif
> +
>   	for_nexthops(fi) {
>   		if (nh->nh_oif !=3D onh->nh_oif ||
>   		    nh->nh_gw  !=3D onh->nh_gw ||
> @@ -896,6 +901,7 @@ struct fib_info *fib_create_info(struct fib_confi=
g *cfg)
>
>   	if (cfg->fc_mp) {
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> +		fi->fib_mp_alg =3D cfg->fc_mp_alg;
>   		err =3D fib_get_nhs(fi, cfg->fc_mp, cfg->fc_mp_len, cfg);
>   		if (err !=3D 0)
>   			goto failure;
> @@ -1085,6 +1091,10 @@ int fib_dump_info(struct sk_buff *skb, u32 por=
tid, u32 seq, int event,
>   		struct rtnexthop *rtnh;
>   		struct nlattr *mp;
>
> +		if (fi->fib_mp_alg &&
> +		    nla_put_u32(skb, RTA_MP_ALGO, fi->fib_mp_alg))
> +			goto nla_put_failure;
> +
>   		mp =3D nla_nest_start(skb, RTA_MULTIPATH);
>   		if (!mp)
>   			goto nla_put_failure;
> @@ -1312,15 +1322,31 @@ int fib_sync_up(struct net_device *dev)
>   }
>
>   /*
> - * The algorithm is suboptimal, but it provides really
> - * fair weighted route distribution.
> + * Compute multipath hash based on 3- or 5-tuple
>    */
> -void fib_select_multipath(struct fib_result *res)
> +static int fib_multipath_hash(const struct fib_result *res,
> +			      const struct flowi4 *flow)
> +{
> +	u32 hash =3D flow->saddr ^ flow->daddr;
> +
> +	if (res->fi->fib_mp_alg =3D=3D RT_MP_ALG_L4_HASH && flow->flowi4_pr=
oto !=3D 0)
> +		hash ^=3D flow->flowi4_proto ^ flow->fl4_sport ^ flow->fl4_dport;
> +
> +	hash ^=3D hash >> 16;
> +	hash ^=3D hash >> 8;
> +	return hash & 0xFF;
> +}
> +

This hash is still far from optimal.  Really I think you should look at=
=20
something such as jhash_3words or the like for mixing up the addresses.=
=20
  Right now just XORing the values together like you are will end up=20
with a fairly high collision rate since for example in the case of two=20
endpoints on the same subnet you would lose the subnet as a result of=20
XORing the source and destination addresses.  Also you would lose the=20
port data in the case of a protocol using something such as UDP where=20
the source and destination ports might be the same value.

> +void fib_select_multipath(struct fib_result *res, const struct flowi=
4 *flow)
>   {
>   	struct fib_info *fi =3D res->fi;
>   	u8 w;
>
> -	w =3D bitrev8(this_cpu_inc_return(fib_mp_rr_counter));
> +	if (res->fi->fib_mp_alg =3D=3D RT_MP_ALG_PER_PACKET) {
> +		w =3D bitrev8(this_cpu_inc_return(fib_mp_rr_counter));
> +	} else {
> +		w =3D fib_multipath_hash(res, flow);
> +	}
>
>   	for_nexthops(fi) {
>   		if (w >=3D atomic_read(&nh->nh_mp_upper_bound))
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index f5203fb..3abcfea 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -459,7 +459,7 @@ static struct rtable *icmp_route_lookup(struct ne=
t *net,
>   	fl4->fl4_icmp_type =3D type;
>   	fl4->fl4_icmp_code =3D code;
>   	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
> -	rt =3D __ip_route_output_key(net, fl4);
> +	rt =3D __ip_route_output_key(net, fl4, NULL);
>   	if (IS_ERR(rt))
>   		return rt;
>
> @@ -481,7 +481,7 @@ static struct rtable *icmp_route_lookup(struct ne=
t *net,
>   		goto relookup_failed;
>
>   	if (inet_addr_type(net, fl4_dec.saddr) =3D=3D RTN_LOCAL) {
> -		rt2 =3D __ip_route_output_key(net, &fl4_dec);
> +		rt2 =3D __ip_route_output_key(net, &fl4_dec, NULL);
>   		if (IS_ERR(rt2))
>   			err =3D PTR_ERR(rt2);
>   	} else {
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index f605598..a1ec62c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1006,7 +1006,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, stru=
ct net *net, u32 mtu,
>
>   	__build_flow_key(&fl4, NULL, iph, oif,
>   			 RT_TOS(iph->tos), protocol, mark, flow_flags);
> -	rt =3D __ip_route_output_key(net, &fl4);
> +	rt =3D __ip_route_output_key(net, &fl4, NULL);
>   	if (!IS_ERR(rt)) {
>   		__ip_rt_update_pmtu(rt, &fl4, mtu);
>   		ip_rt_put(rt);
> @@ -1025,7 +1025,7 @@ static void __ipv4_sk_update_pmtu(struct sk_buf=
f *skb, struct sock *sk, u32 mtu)
>   	if (!fl4.flowi4_mark)
>   		fl4.flowi4_mark =3D IP4_REPLY_MARK(sock_net(sk), skb->mark);
>
> -	rt =3D __ip_route_output_key(sock_net(sk), &fl4);
> +	rt =3D __ip_route_output_key(sock_net(sk), &fl4, NULL);
>   	if (!IS_ERR(rt)) {
>   		__ip_rt_update_pmtu(rt, &fl4, mtu);
>   		ip_rt_put(rt);
> @@ -1094,7 +1094,7 @@ void ipv4_redirect(struct sk_buff *skb, struct =
net *net,
>
>   	__build_flow_key(&fl4, NULL, iph, oif,
>   			 RT_TOS(iph->tos), protocol, mark, flow_flags);
> -	rt =3D __ip_route_output_key(net, &fl4);
> +	rt =3D __ip_route_output_key(net, &fl4, NULL);
>   	if (!IS_ERR(rt)) {
>   		__ip_do_redirect(rt, skb, &fl4, false);
>   		ip_rt_put(rt);
> @@ -1109,7 +1109,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, stru=
ct sock *sk)
>   	struct rtable *rt;
>
>   	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
> -	rt =3D __ip_route_output_key(sock_net(sk), &fl4);
> +	rt =3D __ip_route_output_key(sock_net(sk), &fl4, NULL);
>   	if (!IS_ERR(rt)) {
>   		__ip_do_redirect(rt, skb, &fl4, false);
>   		ip_rt_put(rt);
> @@ -1631,6 +1631,39 @@ out:
>   	return err;
>   }
>
> +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> +/* Fill flow key data based on packet for use in multipath routing. =
*/
> +static void ip_multipath_flow(const struct sk_buff *skb, struct flow=
i4 *flow)
> +{
> +	const struct iphdr *iph;
> +
> +	iph =3D ip_hdr(skb);
> +
> +	flow->saddr =3D iph->saddr;
> +	flow->daddr =3D iph->daddr;
> +	flow->flowi4_proto =3D iph->protocol;
> +	flow->fl4_sport =3D 0;
> +	flow->fl4_dport =3D 0;
> +
> +	if (unlikely(ip_is_fragment(iph)))
> +		return;
> +

I'm not sure if checking for fragmentation is enough.  For example if=20
this system is routing and received a flow of UDP packets, some=20
fragmented some not then it might end up mixing them over 2 separate=20
next hops since some will include L4 header data and some won't.

As such you may want to have the option to exclude UDP from the=20
protocols listed below.

> +	if (iph->protocol =3D=3D IPPROTO_TCP ||
> +	    iph->protocol =3D=3D IPPROTO_UDP ||
> +	    iph->protocol =3D=3D IPPROTO_SCTP) {
> +		__be16 _ports;
> +		const __be16 *ports;
> +
> +		ports =3D skb_header_pointer(skb, iph->ihl * 4, sizeof(_ports),
> +					   &_ports);
> +		if (ports) {
> +			flow->fl4_sport =3D ports[0];
> +			flow->fl4_dport =3D ports[1];
> +		}
> +	}
> +}
> +#endif /* CONFIG_IP_ROUTE_MULTIPATH */
> +
>   static int ip_mkroute_input(struct sk_buff *skb,
>   			    struct fib_result *res,
>   			    const struct flowi4 *fl4,
> @@ -1638,8 +1671,12 @@ static int ip_mkroute_input(struct sk_buff *sk=
b,
>   			    __be32 daddr, __be32 saddr, u32 tos)
>   {
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
> -	if (res->fi && res->fi->fib_nhs > 1)
> -		fib_select_multipath(res);
> +	if (res->fi && res->fi->fib_nhs > 1) {
> +		struct flowi4 mp_flow;
> +
> +		ip_multipath_flow(skb, &mp_flow);
> +		fib_select_multipath(res, &mp_flow);
> +	}

What is the point in populating the mp_flow if you don't know if it is=20
going to be used?  You are populating it in ip_multipath_flow, and then=
=20
you might completely ignore it in fib_select_multipath.

Maybe instead of passing the mp_flow you could instead look at passing =
a=20
function pointer that would alter the flow for the multipath case inste=
ad.

>   #endif
>
>   	/* create a routing cache entry */
> @@ -2012,7 +2049,8 @@ add:
>    * Major route resolver routine.
>    */
>
> -struct rtable *__ip_route_output_key(struct net *net, struct flowi4 =
*fl4)
> +struct rtable *__ip_route_output_key(struct net *net, struct flowi4 =
*fl4,
> +				     const struct flowi4 *mp_flow)
>   {
>   	struct net_device *dev_out =3D NULL;
>   	__u8 tos =3D RT_FL_TOS(fl4);
> @@ -2170,7 +2208,7 @@ struct rtable *__ip_route_output_key(struct net=
 *net, struct flowi4 *fl4)
>
>   #ifdef CONFIG_IP_ROUTE_MULTIPATH
>   	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0)
> -		fib_select_multipath(&res);
> +		fib_select_multipath(&res, (mp_flow ? mp_flow : fl4));
>   	else
>   #endif
>   	if (!res.prefixlen &&
> @@ -2273,7 +2311,7 @@ struct dst_entry *ipv4_blackhole_route(struct n=
et *net, struct dst_entry *dst_or
>   struct rtable *ip_route_output_flow(struct net *net, struct flowi4 =
*flp4,
>   				    struct sock *sk)
>   {
> -	struct rtable *rt =3D __ip_route_output_key(net, flp4);
> +	struct rtable *rt =3D __ip_route_output_key(net, flp4, NULL);
>
>   	if (IS_ERR(rt))
>   		return rt;
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index bff6974..7eae158 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -31,7 +31,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct =
net *net, struct flowi4 *fl4,
>   	if (saddr)
>   		fl4->saddr =3D saddr->a4;
>
> -	rt =3D __ip_route_output_key(net, fl4);
> +	rt =3D __ip_route_output_key(net, fl4, NULL);
>   	if (!IS_ERR(rt))
>   		return &rt->dst;
>
>
