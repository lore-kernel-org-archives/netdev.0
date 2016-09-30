From: Greg <gvrose8192@gmail.com>
Subject: Re: [PATCH net v2] net: pktgen: fix pkt_size
Date: Fri, 30 Sep 2016 08:39:20 -0700
Message-ID: <1475249960.3279.1.camel@gmail.com>
References: <5277a40b08c491bd4ff8f6e3276718848f7406e8.1475246890.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Bogdan Hamciuc <bogdan.hamciuc@freescale.com>,
        Ben Greear <greearb@candelatech.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35950 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932515AbcI3PjW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 11:39:22 -0400
Received: by mail-pa0-f66.google.com with SMTP id cd13so3115257pac.3
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 08:39:22 -0700 (PDT)
In-Reply-To: <5277a40b08c491bd4ff8f6e3276718848f7406e8.1475246890.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-30 at 16:56 +0200, Paolo Abeni wrote:
> The commit 879c7220e828 ("net: pktgen: Observe needed_headroom
> of the device") increased the 'pkt_overhead' field value by
> LL_RESERVED_SPACE.
> As a side effect the generated packet size, computed as:
> 
> 	/* Eth + IPh + UDPh + mpls */
> 	datalen = pkt_dev->cur_pkt_size - 14 - 20 - 8 -
> 		  pkt_dev->pkt_overhead;
> 
> is decreased by the same value.
> The above changed slightly the behavior of existing pktgen users,
> and made the procfs interface somewhat inconsistent.
> Fix it by restoring the previous pkt_overhead value and using
> LL_RESERVED_SPACE as extralen in skb allocation.
> Also, change pktgen_alloc_skb() to only partially reserve
> the headroom to allow the caller to prefetch from ll header
> start.
> 
> v1 -> v2:
>  - fixed some typos in the comments
> 
> Fixes: 879c7220e828 ("net: pktgen: Observe needed_headroom of the device")
> Suggested-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/core/pktgen.c | 21 ++++++++++-----------
>  1 file changed, 10 insertions(+), 11 deletions(-)
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index bbd118b..5219a9e 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2286,7 +2286,7 @@ out:
>  
>  static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
>  {
> -	pkt_dev->pkt_overhead = LL_RESERVED_SPACE(pkt_dev->odev);
> +	pkt_dev->pkt_overhead = 0;
>  	pkt_dev->pkt_overhead += pkt_dev->nr_labels*sizeof(u32);
>  	pkt_dev->pkt_overhead += VLAN_TAG_SIZE(pkt_dev);
>  	pkt_dev->pkt_overhead += SVLAN_TAG_SIZE(pkt_dev);
> @@ -2777,13 +2777,13 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
>  }
>  
>  static struct sk_buff *pktgen_alloc_skb(struct net_device *dev,
> -					struct pktgen_dev *pkt_dev,
> -					unsigned int extralen)
> +					struct pktgen_dev *pkt_dev)
>  {
> +	unsigned int extralen = LL_RESERVED_SPACE(dev);
>  	struct sk_buff *skb = NULL;
> -	unsigned int size = pkt_dev->cur_pkt_size + 64 + extralen +
> -			    pkt_dev->pkt_overhead;
> +	unsigned int size;
>  
> +	size = pkt_dev->cur_pkt_size + 64 + extralen + pkt_dev->pkt_overhead;
>  	if (pkt_dev->flags & F_NODE) {
>  		int node = pkt_dev->node >= 0 ? pkt_dev->node : numa_node_id();
>  
> @@ -2796,8 +2796,9 @@ static struct sk_buff *pktgen_alloc_skb(struct net_device *dev,
>  		 skb = __netdev_alloc_skb(dev, size, GFP_NOWAIT);
>  	}
>  
> +	/* the caller pre-fetches from skb->data and reserves for the mac hdr */
>  	if (likely(skb))
> -		skb_reserve(skb, LL_RESERVED_SPACE(dev));
> +		skb_reserve(skb, extralen - 16);

Is the 16 here the same as HD_DATA_MOD?

Magic numbers...

Thanks,

- Greg

>  
>  	return skb;
>  }
> @@ -2830,16 +2831,14 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>  	mod_cur_headers(pkt_dev);
>  	queue_map = pkt_dev->cur_queue_map;
>  
> -	datalen = (odev->hard_header_len + 16) & ~0xf;
> -
> -	skb = pktgen_alloc_skb(odev, pkt_dev, datalen);
> +	skb = pktgen_alloc_skb(odev, pkt_dev);
>  	if (!skb) {
>  		sprintf(pkt_dev->result, "No memory");
>  		return NULL;
>  	}
>  
>  	prefetchw(skb->data);
> -	skb_reserve(skb, datalen);
> +	skb_reserve(skb, 16);
>  
>  	/*  Reserve for ethernet and IP header  */
>  	eth = (__u8 *) skb_push(skb, 14);
> @@ -2959,7 +2958,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
>  	mod_cur_headers(pkt_dev);
>  	queue_map = pkt_dev->cur_queue_map;
>  
> -	skb = pktgen_alloc_skb(odev, pkt_dev, 16);
> +	skb = pktgen_alloc_skb(odev, pkt_dev);
>  	if (!skb) {
>  		sprintf(pkt_dev->result, "No memory");
>  		return NULL;
