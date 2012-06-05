From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v2 PATCH] netfilter: xt_HMARK: fix endian bugs and warnings
Date: Wed, 6 Jun 2012 01:41:21 +0200
Message-ID: <20120605234121.GA27165@1984>
References: <1337330146-26305-1-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	dan.carpenter@oracle.com, hans.schillstrom@ericsson.com
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49500 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753785Ab2FEXlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 19:41:25 -0400
Content-Disposition: inline
In-Reply-To: <1337330146-26305-1-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 18, 2012 at 10:35:46AM +0200, Hans Schillstrom wrote:
> A mix of u32 and __be32 causes endian warning.
> The hash value produced is now the same for big and little endian machines.
> i.e. a mix of Big and Little endian in a cluster is now possible.

Applied with minor glitches, Thanks Hans.

I have rewritten the description.

> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
> ---
>  include/linux/netfilter/xt_HMARK.h |    5 +++
>  net/netfilter/xt_HMARK.c           |   69 ++++++++++++++++++++----------------
>  2 files changed, 43 insertions(+), 31 deletions(-)
> 
> diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
> index abb1650..826fc58 100644
> --- a/include/linux/netfilter/xt_HMARK.h
> +++ b/include/linux/netfilter/xt_HMARK.h
> @@ -27,7 +27,12 @@ union hmark_ports {
>  		__u16	src;
>  		__u16	dst;
>  	} p16;
> +	struct {
> +		__be16	src;
> +		__be16	dst;
> +	} b16;
>  	__u32	v32;
> +	__be32	b32;
>  };
>  
>  struct xt_hmark_info {
> diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
> index 0a96a43..5119666 100644
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

I have converted this uint8_t to u8. I think I'm responsible for that
slipped through.

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
> @@ -58,6 +58,22 @@ hmark_addr_mask(int l3num, const __u32 *addr32, const __u32 *mask)
>  	return 0;
>  }
>  
> +static inline void hmark_swap_ports(union hmark_ports *uports,
> +				    const struct xt_hmark_info *info)
> +{
> +	union hmark_ports hp;
> +	u16 src,dst;
> +
> +	hp.b32 = (uports->b32 & info->port_mask.b32) | info->port_set.b32;
> +	src = ntohs(hp.b16.src);
> +	dst = ntohs(hp.b16.dst);
> +
> +	if (dst > src)
> +		uports->v32 = (dst << 16) | src;
> +	else
> +		uports->v32 = (src << 16) | dst;
> +}
> +
>  static int
>  hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
>  		    const struct xt_hmark_info *info)
> @@ -74,22 +90,19 @@ hmark_ct_set_htuple(const struct sk_buff *skb, struct hmark_tuple *t,
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
>  
>  	t->proto = nf_ct_protonum(ct);
>  	if (t->proto != IPPROTO_ICMP) {
> -		t->uports.p16.src = otuple->src.u.all;
> -		t->uports.p16.dst = rtuple->src.u.all;
> -		t->uports.v32 = (t->uports.v32 & info->port_mask.v32) |
> -				info->port_set.v32;
> -		if (t->uports.p16.dst < t->uports.p16.src)
> -			swap(t->uports.p16.dst, t->uports.p16.src);
> +		t->uports.b16.src = otuple->src.u.all;
> +		t->uports.b16.dst = rtuple->src.u.all;
> +		hmark_swap_ports(&t->uports, info);
>  	}
>  
>  	return 0;
> @@ -102,11 +115,13 @@ static inline u32

I've added this comment on top of hmark_hash:

/* This hash function is endian independent, to ensure consistent hashing if
 * the cluster is composed of big and little endian systems. */

In case that someone is curious about all those conversions.

>  hmark_hash(struct hmark_tuple *t, const struct xt_hmark_info *info)
[...]
