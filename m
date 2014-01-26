From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: add and use skb_gso_transport_seglen()
Date: Sat, 25 Jan 2014 17:28:08 -0800
Message-ID: <1390699688.27806.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390690127-559-1-git-send-email-fw@strlen.de>
	 <1390690127-559-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:60986 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaAZB2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 20:28:10 -0500
Received: by mail-pb0-f45.google.com with SMTP id un15so4582037pbc.18
        for <netdev@vger.kernel.org>; Sat, 25 Jan 2014 17:28:09 -0800 (PST)
In-Reply-To: <1390690127-559-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-25 at 23:48 +0100, Florian Westphal wrote:
> This moves part of Eric Dumazets skb_gso_seglen helper from tbf sched to
> skbuff core so it may be reused by upcoming ip forwarding path patch.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  include/linux/skbuff.h |  1 +
>  net/core/skbuff.c      | 26 ++++++++++++++++++++++++++
>  net/sched/sch_tbf.c    | 12 +++---------
>  3 files changed, 30 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 6f69b3f..3d76066 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2371,6 +2371,7 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
>  void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len);
>  int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
>  void skb_scrub_packet(struct sk_buff *skb, bool xnet);
> +unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
>  struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
>  
>  struct skb_checksum_ops {
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 06e72d3..2e1fd75 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -45,6 +45,7 @@
>  #include <linux/mm.h>
>  #include <linux/interrupt.h>
>  #include <linux/in.h>
> +#include <linux/tcp.h>
>  #include <linux/inet.h>
>  #include <linux/slab.h>
>  #include <linux/netdevice.h>
> @@ -71,6 +72,8 @@
>  #include <trace/events/skb.h>
>  #include <linux/highmem.h>
>  
> +#include <uapi/linux/udp.h>


Normally you should not use uapi/

#include <linux/udp.h>

> +
>  struct kmem_cache *skbuff_head_cache __read_mostly;
>  static struct kmem_cache *skbuff_fclone_cache __read_mostly;
>  
> @@ -3592,3 +3595,26 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
>  	nf_reset_trace(skb);
>  }
>  EXPORT_SYMBOL_GPL(skb_scrub_packet);
> +
> +/**
> + * skb_gso_transport_seglen - Return length of individual segments of a gso packet
> + *
> + * @skb: GSO skb
> + *
> + * skb_gso_transport_seglen is used to determine the real size of the
> + * individual segments, including Layer4 headers (TCP/UDP).
> + *
> + * The MAC/L2 or network (IP, IPv6) headers are not accounted for.
> + */
> +unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
> +{
> +	const struct skb_shared_info *shinfo = skb_shinfo(skb);
> +	unsigned int hdr_len;
> +
> +	if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
> +		hdr_len = tcp_hdrlen(skb);
> +	else
> +		hdr_len = sizeof(struct udphdr);
> +	return hdr_len + shinfo->gso_size;
> +}
> +EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 887e672..837a61b 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c

It seems you forgot to remove from this file this include :

#include <net/tcp.h>

> @@ -148,16 +148,10 @@ static u64 psched_ns_t2l(const struct psched_ratecfg *r,
>   * Return length of individual segments of a gso packet,
>   * including all headers (MAC, IP, TCP/UDP)
>   */
> -static unsigned int skb_gso_seglen(const struct sk_buff *skb)
> +static unsigned int skb_gso_mac_seglen(const struct sk_buff *skb)
>  {
>  	unsigned int hdr_len = skb_transport_header(skb) - skb_mac_header(skb);
> -	const struct skb_shared_info *shinfo = skb_shinfo(skb);
> -
> -	if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
> -		hdr_len += tcp_hdrlen(skb);
> -	else
> -		hdr_len += sizeof(struct udphdr);
> -	return hdr_len + shinfo->gso_size;
> +	return hdr_len + skb_gso_transport_seglen(skb);
>  }
>  
>  /* GSO packet is too big, segment it so that tbf can transmit
> @@ -202,7 +196,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	int ret;
>  
>  	if (qdisc_pkt_len(skb) > q->max_size) {
> -		if (skb_is_gso(skb) && skb_gso_seglen(skb) <= q->max_size)
> +		if (skb_is_gso(skb) && skb_gso_mac_seglen(skb) <= q->max_size)
>  			return tbf_segment(skb, sch);
>  		return qdisc_reshape_fail(skb, sch);
>  	}


Otherwise, this seems good, thanks !
