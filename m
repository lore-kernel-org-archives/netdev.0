From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 nf-next 1/6] net: untangle ip_fragment and bridge
 netfilter
Date: Mon, 16 Mar 2015 23:55:45 +0100
Message-ID: <20150316225545.GA4454@salvia>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
 <1426179925-18220-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55198 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933406AbbCPWvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 18:51:55 -0400
Content-Disposition: inline
In-Reply-To: <1426179925-18220-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch changes the interface ip_fragment(). If this sounds
reasonable to you, please ack it and I'll route it to you in the next
nf-next batch.

Thanks.

On Thu, Mar 12, 2015 at 06:05:20PM +0100, Florian Westphal wrote:
> Long time ago it was possible for the netfilter ip_conntrack
> core to call ip_fragment in POST_ROUTING hook.
> 
> This is no longer the case, so the only case where bridge netfilter
> ends up calling ip_fragment is the direct call site in br_netfilter.c.
> 
> Add ll and mtu arguments for ip_fragment and then get rid of the bridge
> netfilter specific helpers from ip_fragment.
> 
> Cc: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  include/linux/netfilter_bridge.h | 17 -----------------
>  include/net/ip.h                 |  4 ++--
>  net/bridge/br_netfilter.c        | 23 ++++++++++++++++++++---
>  net/ipv4/ip_output.c             | 37 +++++++++++++++++++++----------------
>  4 files changed, 43 insertions(+), 38 deletions(-)
> 
> diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
> index ed0d3bf..fbbd5de 100644
> --- a/include/linux/netfilter_bridge.h
> +++ b/include/linux/netfilter_bridge.h
> @@ -35,24 +35,8 @@ static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
>  	}
>  }
>  
> -static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
> -{
> -	if (unlikely(skb->nf_bridge->mask & BRNF_PPPoE))
> -		return PPPOE_SES_HLEN;
> -	return 0;
> -}
> -
>  int br_handle_frame_finish(struct sk_buff *skb);
>  
> -/* This is called by the IP fragmenting code and it ensures there is
> - * enough room for the encapsulating header (if there is one). */
> -static inline unsigned int nf_bridge_pad(const struct sk_buff *skb)
> -{
> -	if (skb->nf_bridge)
> -		return nf_bridge_encap_header_len(skb);
> -	return 0;
> -}
> -
>  static inline void br_drop_fake_rtable(struct sk_buff *skb)
>  {
>  	struct dst_entry *dst = skb_dst(skb);
> @@ -62,7 +46,6 @@ static inline void br_drop_fake_rtable(struct sk_buff *skb)
>  }
>  
>  #else
> -#define nf_bridge_pad(skb)			(0)
>  #define br_drop_fake_rtable(skb)	        do { } while (0)
>  #endif /* CONFIG_BRIDGE_NETFILTER */
>  
> diff --git a/include/net/ip.h b/include/net/ip.h
> index 025c61c..2905a4b 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -108,8 +108,8 @@ int ip_local_deliver(struct sk_buff *skb);
>  int ip_mr_input(struct sk_buff *skb);
>  int ip_output(struct sock *sk, struct sk_buff *skb);
>  int ip_mc_output(struct sock *sk, struct sk_buff *skb);
> -int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
> -int ip_do_nat(struct sk_buff *skb);
> +int ip_fragment(struct sk_buff *skb, unsigned int mtu,
> +		unsigned int ll_rs, int (*output)(struct sk_buff *));
>  void ip_send_check(struct iphdr *ip);
>  int __ip_local_out(struct sk_buff *skb);
>  int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index bd2d24d..550ee19 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -812,26 +812,43 @@ static int br_nf_push_frag_xmit(struct sk_buff *skb)
>  	return br_dev_queue_push_xmit(skb);
>  }
>  
> +static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
> +{
> +	if (skb->nf_bridge->mask & BRNF_PPPoE)
> +		return PPPOE_SES_HLEN;
> +	return 0;
> +}
> +
>  static int br_nf_dev_queue_xmit(struct sk_buff *skb)
>  {
>  	int ret;
>  	int frag_max_size;
> -	unsigned int mtu_reserved;
> +	unsigned int mtu_reserved, mtu;
>  
>  	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
>  		return br_dev_queue_push_xmit(skb);
>  
>  	mtu_reserved = nf_bridge_mtu_reduction(skb);
> +	mtu = min(skb->dev->mtu, IP_MAX_MTU);
>  	/* This is wrong! We should preserve the original fragment
>  	 * boundaries by preserving frag_list rather than refragmenting.
>  	 */
> -	if (skb->len + mtu_reserved > skb->dev->mtu) {
> +	if (skb->len + mtu_reserved > mtu) {
> +		unsigned int llrs;
> +
>  		frag_max_size = BR_INPUT_SKB_CB(skb)->frag_max_size;
>  		if (br_parse_ip_options(skb))
>  			/* Drop invalid packet */
>  			return NF_DROP;
>  		IPCB(skb)->frag_max_size = frag_max_size;
> -		ret = ip_fragment(skb, br_nf_push_frag_xmit);
> +
> +		/* for bridged IP traffic encapsulated inside f.e. a vlan header,
> +		 * we need to make room for the encapsulating header
> +		 */
> +		llrs = nf_bridge_encap_header_len(skb);
> +
> +		mtu -= mtu_reserved;
> +		ret = ip_fragment(skb, mtu, llrs, br_nf_push_frag_xmit);
>  	} else
>  		ret = br_dev_queue_push_xmit(skb);
>  
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index a7aea20..fe5ec3f 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -216,6 +216,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>  	netdev_features_t features;
>  	struct sk_buff *segs;
>  	int ret = 0;
> +	unsigned int mtu;
>  
>  	/* common case: locally created skb or seglen is <= mtu */
>  	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
> @@ -236,6 +237,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>  		return -ENOMEM;
>  	}
>  
> +	mtu = ip_skb_dst_mtu(skb);
>  	consume_skb(skb);
>  
>  	do {
> @@ -243,7 +245,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>  		int err;
>  
>  		segs->next = NULL;
> -		err = ip_fragment(segs, ip_finish_output2);
> +		err = ip_fragment(segs, mtu, 0, ip_finish_output2);
>  
>  		if (err && ret == 0)
>  			ret = err;
> @@ -255,6 +257,8 @@ static int ip_finish_output_gso(struct sk_buff *skb)
>  
>  static int ip_finish_output(struct sk_buff *skb)
>  {
> +	unsigned int mtu;
> +
>  #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
>  	/* Policy lookup after SNAT yielded a new policy */
>  	if (skb_dst(skb)->xfrm != NULL) {
> @@ -265,8 +269,9 @@ static int ip_finish_output(struct sk_buff *skb)
>  	if (skb_is_gso(skb))
>  		return ip_finish_output_gso(skb);
>  
> -	if (skb->len > ip_skb_dst_mtu(skb))
> -		return ip_fragment(skb, ip_finish_output2);
> +	mtu = ip_skb_dst_mtu(skb);
> +	if (skb->len > mtu)
> +		return ip_fragment(skb, mtu, 0, ip_finish_output2);
>  
>  	return ip_finish_output2(skb);
>  }
> @@ -472,20 +477,28 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
>  	skb_copy_secmark(to, from);
>  }
>  
> -/*
> +/**
> + *	ip_fragment - fragment IP datagram or send ICMP error
> + *
> + *	@skb: the skb to fragment
> + *	@mtu: mtu to use for fragmentation
> + *	@ll_rs: extra linklayer space required
> + *	@output: transmit function used to send fragments
> + *
>   *	This IP datagram is too large to be sent in one piece.  Break it up into
>   *	smaller pieces (each of size equal to IP header plus
>   *	a block of the data of the original IP data part) that will yet fit in a
>   *	single device frame, and queue such a frame for sending.
>   */
> -
> -int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
> +int ip_fragment(struct sk_buff *skb,
> +		unsigned int mtu, unsigned int ll_rs,
> +		int (*output)(struct sk_buff *))
>  {
>  	struct iphdr *iph;
>  	int ptr;
>  	struct net_device *dev;
>  	struct sk_buff *skb2;
> -	unsigned int mtu, hlen, left, len, ll_rs;
> +	unsigned int hlen, left, len;
>  	int offset;
>  	__be16 not_last_frag;
>  	struct rtable *rt = skb_rtable(skb);
> @@ -499,7 +512,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
>  
>  	iph = ip_hdr(skb);
>  
> -	mtu = ip_skb_dst_mtu(skb);
>  	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
>  		     (IPCB(skb)->frag_max_size &&
>  		      IPCB(skb)->frag_max_size > mtu))) {
> @@ -516,10 +528,6 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
>  
>  	hlen = iph->ihl * 4;
>  	mtu = mtu - hlen;	/* Size of data space */
> -#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
> -	if (skb->nf_bridge)
> -		mtu -= nf_bridge_mtu_reduction(skb);
> -#endif
>  	IPCB(skb)->flags |= IPSKB_FRAG_COMPLETE;
>  
>  	/* When frag_list is given, use it. First, check its validity:
> @@ -636,10 +644,7 @@ slow_path:
>  	left = skb->len - hlen;		/* Space per frame */
>  	ptr = hlen;		/* Where to start from */
>  
> -	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
> -	 * we need to make room for the encapsulating header
> -	 */
> -	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));
> +	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, ll_rs);
>  
>  	/*
>  	 *	Fragment the datagram.
> -- 
> 2.0.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
