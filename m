From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 16:40:52 +0200
Message-ID: <20120514144052.GD12992@1984>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	dan.carpenter@oracle.com, hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 03:42:23PM +0200, Hans Schillstrom wrote:
> A mix of u32 and __be32 causes endian warning.
> Switch to __be32 and __be16 for addresses and ports.
> Added (__force u32) at some places.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/linux/netfilter/xt_HMARK.h |    4 ++--
>  net/netfilter/xt_HMARK.c           |   35 ++++++++++++++++++-----------------
>  2 files changed, 20 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
> index abb1650..e2af67e 100644
> --- a/include/linux/netfilter/xt_HMARK.h
> +++ b/include/linux/netfilter/xt_HMARK.h
> @@ -24,8 +24,8 @@ enum {
>  
>  union hmark_ports {
>  	struct {
> -		__u16	src;
> -		__u16	dst;
> +		__be16	src;
> +		__be16	dst;
>  	} p16;
>  	__u32	v32;
>  };
> diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
> index 32fbd73..38ed442 100644
> --- a/net/netfilter/xt_HMARK.c
> +++ b/net/netfilter/xt_HMARK.c
> @@ -32,13 +32,13 @@ MODULE_ALIAS("ipt_HMARK");
>  MODULE_ALIAS("ip6t_HMARK");
>  
>  struct hmark_tuple {
> -	u32			src;
> -	u32			dst;
> +	__be32			src;
> +	__be32			dst;
>  	union hmark_ports	uports;
>  	uint8_t			proto;
>  };
>  
> -static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
> +static inline __be32 hmark_addr6_mask(const __be32 *addr32, const __be32 *mask)
>  {
>  	return (addr32[0] & mask[0]) ^
>  	       (addr32[1] & mask[1]) ^
> @@ -46,8 +46,8 @@ static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
>  	       (addr32[3] & mask[3]);
>  }
>  
> -static inline u32
> -hmark_addr_mask(int l3num, const __u32 *addr32, const __u32 *mask)
> +static inline __be32
> +hmark_addr_mask(int l3num, const __be32 *addr32, const __be32 *mask)
>  {
>  	switch (l3num) {
>  	case AF_INET:
> @@ -74,10 +74,10 @@ hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
>  	otuple = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
>  	rtuple = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
>  
> -	t->src = hmark_addr_mask(otuple->src.l3num, otuple->src.u3.all,
> -				 info->src_mask.all);
> -	t->dst = hmark_addr_mask(otuple->src.l3num, rtuple->src.u3.all,
> -				 info->dst_mask.all);
> +	t->src = hmark_addr_mask(otuple->src.l3num, otuple->src.u3.ip6,
> +				 info->src_mask.ip6);
> +	t->dst = hmark_addr_mask(otuple->src.l3num, rtuple->src.u3.ip6,
> +				 info->dst_mask.ip6);
>  
>  	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
>  		return 0;
> @@ -88,7 +88,7 @@ hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
>  		t->uports.p16.dst = rtuple->src.u.all;
>  		t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
>  				info->port_set.v32;
> -		if (t->uports.p16.dst < t->uports.p16.src)
> +		if (ntohs(t->uports.p16.dst) < ntohs(t->uports.p16.src))

Do we really need this to make sparse happy?

>  			swap(t->uports.p16.dst, t->uports.p16.src);
>  	}
>  
> @@ -103,10 +103,11 @@ hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
>  {
>  	u32 hash;
>  
> -	if (t->dst < t->src)
> +	if (ntohl(t->dst) < ntohl(t->src))
>  		swap(t->src, t->dst);
>  
> -	hash = jhash_3words(t->src, t->dst, t->uports.v32, info->hashrnd);
> +	hash = jhash_3words((__force u32) t->src, (__force u32) t->dst,
> +			    t->uports.v32, info->hashrnd);
>  	hash = hash ^ (t->proto & info->proto_mask);
>  
>  	return (hash % info->hmodulus) + info->hoffset;

This will clash with my patch. No problem, I'll manually fix it
myself.

> @@ -129,7 +130,7 @@ hmark_set_tuple_ports(const struct sk_buff *skb, unsigned int nhoff,
>  	t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
>  			info->port_set.v32;
>  
> -	if (t->uports.p16.dst < t->uports.p16.src)
> +	if (ntohs(t->uports.p16.dst) < ntohs(t->uports.p16.src))
>  		swap(t->uports.p16.dst, t->uports.p16.src);
>  }
>  
> @@ -178,8 +179,8 @@ hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
>  			return -1;
>  	}
>  noicmp:
> -	t->src = hmark_addr6_mask(ip6->saddr.s6_addr32, info->src_mask.all);
> -	t->dst = hmark_addr6_mask(ip6->daddr.s6_addr32, info->dst_mask.all);
> +	t->src = hmark_addr6_mask(ip6->saddr.s6_addr32, info->src_mask.ip6);
> +	t->dst = hmark_addr6_mask(ip6->daddr.s6_addr32, info->dst_mask.ip6);
>  
>  	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
>  		return 0;
> @@ -255,8 +256,8 @@ hmark_pkt_set_htuple_ipv4(const struct sk_buff *skb, struct hmark_tuple *t,
>  		}
>  	}
>  
> -	t->src = (__force u32) ip->saddr;
> -	t->dst = (__force u32) ip->daddr;
> +	t->src = ip->saddr;
> +	t->dst = ip->daddr;
>  
>  	t->src &= info->src_mask.ip;
>  	t->dst &= info->dst_mask.ip;
> -- 
> 1.7.2.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
