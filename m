From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_HMARK: fix endian bugs and warnings
Date: Thu, 17 May 2012 01:26:57 +0200
Message-ID: <20120516232657.GB1599@1984>
References: <1337180442-32581-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	dan.carpenter@oracle.com, hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337180442-32581-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 16, 2012 at 05:00:42PM +0200, Hans Schillstrom wrote:
> A mix of u32 and __be32 causes endian warning.
> The hash value produced is now the same for big and little endian machines.
> i.e. a mix of Big and Little endian in a cluster is now possible.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> ---
>  include/linux/netfilter/xt_HMARK.h |    5 ++-
>  net/netfilter/xt_HMARK.c           |   68 ++++++++++++++++++++---------------
>  2 files changed, 42 insertions(+), 31 deletions(-)
> 
> diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
> index abb1650..8b6307a 100644
> --- a/include/linux/netfilter/xt_HMARK.h
> +++ b/include/linux/netfilter/xt_HMARK.h
> @@ -24,10 +24,11 @@ enum {
>  
>  union hmark_ports {
>  	struct {
> -		__u16	src;
> -		__u16	dst;
> +		__be16	src;
> +		__be16	dst;
>  	} p16;
>  	__u32	v32;
> +	__be32	b32;
>  };
>  
>  struct xt_hmark_info {
> diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
> index 32fbd73..7bb7b5e 100644
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
> @@ -58,6 +58,25 @@ hmark_addr_mask(int l3num, const __u32 *addr32, const __u32 *mask)
>  	return 0;
>  }
>  
> +static inline void hmark_port_order(union hmark_ports *uports,

comestical change, better call this hmark_swap_ports

> +				    const struct xt_hmark_info *info)
> +{
> +	union hmark_ports hp;
> +
> +	hp.b32 = (uports->b32 & info->port_mask.b32) | info->port_set.b32;
> +	hp.v32 = ntohl(hp.b32);
> +	/* Make it endian safe into jhash() */
> +#if defined(__LITTLE_ENDIAN)
> +	if ((__force u16) uports->p16.dst >
> +	    (__force u16) uports->p16.src)
> +#else
> +	if ((__force u16) uports->p16.src >
> +	    (__force u16) uports->p16.dst)
> +#endif

This ifdef is ugly. I prefer if you use ntohs the ports and store
the values in some local variable, then compare and swap if required.

Just like you do with the IPv4 address.

> +		swap(hp.p16.src, hp.p16.dst);
> +	uports->v32 = hp.v32;
> +}
> +
>  static int
>  hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
>  		    const struct xt_hmark_info *info)
> @@ -74,10 +93,10 @@ hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
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
> @@ -86,10 +105,7 @@ hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
>  	if (t->proto != IPPROTO_ICMP) {
>  		t->uports.p16.src = otuple->src.u.all;
>  		t->uports.p16.dst = rtuple->src.u.all;
> -		t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
> -				info->port_set.v32;
> -		if (t->uports.p16.dst < t->uports.p16.src)
> -			swap(t->uports.p16.dst, t->uports.p16.src);
> +		hmark_port_order(&t->uports, info);
>  	}
>  
>  	return 0;
> @@ -102,11 +118,13 @@ static inline u32
>  hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
>  {
>  	u32 hash;
> +	u32 src = ntohl(t->src);
> +	u32 dst = ntohl(t->dst);
>  
> -	if (t->dst < t->src)
> -		swap(t->src, t->dst);
> +	if (dst < src)
> +		swap(src, dst);
>  
> -	hash = jhash_3words(t->src, t->dst, t->uports.v32, info->hashrnd);
> +	hash = jhash_3words(src, dst, t->uports.v32, info->hashrnd);
>  	hash = hash ^ (t->proto & info->proto_mask);
>  
>  	return (((u64)hash * info->hmodulus) >> 32) + info->hoffset;
> @@ -125,12 +143,7 @@ hmark_set_tuple_ports(const struct sk_buff *skb, unsigned int nhoff,
>  	nhoff += protoff;
>  	if (skb_copy_bits(skb, nhoff, &t->uports, sizeof(t->uports)) < 0)
>  		return;
> -
> -	t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
> -			info->port_set.v32;
> -
> -	if (t->uports.p16.dst < t->uports.p16.src)
> -		swap(t->uports.p16.dst, t->uports.p16.src);
> +	hmark_port_order(&t->uports, info);
>  }
>  
>  #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
> @@ -178,8 +191,8 @@ hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
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
> @@ -255,11 +268,8 @@ hmark_pkt_set_htuple_ipv4(const struct sk_buff *skb, struct hmark_tuple *t,
>  		}
>  	}
>  
> -	t->src = (__force u32) ip->saddr;
> -	t->dst = (__force u32) ip->daddr;
> -
> -	t->src &= info->src_mask.ip;
> -	t->dst &= info->dst_mask.ip;
> +	t->src = ip->saddr & info->src_mask.ip;
> +	t->dst = ip->daddr & info->dst_mask.ip;
>  
>  	if (info->flags & XT_HMARK_FLAG(XT_HMARK_METHOD_L3))
>  		return 0;
> -- 
> 1.7.2.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
