From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Sat, 25 Jan 2014 17:37:57 -0800
Message-ID: <1390700277.27806.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390690127-559-1-git-send-email-fw@strlen.de>
	 <1390690127-559-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:36849 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbaAZBh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 20:37:58 -0500
Received: by mail-pb0-f52.google.com with SMTP id jt11so4639222pbb.11
        for <netdev@vger.kernel.org>; Sat, 25 Jan 2014 17:37:58 -0800 (PST)
In-Reply-To: <1390690127-559-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-25 at 23:48 +0100, Florian Westphal wrote:
> Given:
> Host <mtu1500> R1 <mtu1200> R2
> 
> Host sends tcp stream which is routed via R1 and R2.
> R1 nics perform GRO.
> 
> In this case, the kernel will fail to send ICMP fragmentation needed
> messages (or pkt too big for ipv6), as gso packets currently bypass the
> dst mtu checks in forward path. Instead, Linux tries to send out packets
> exceeding R1-R2 link mtu.
> 
> When locking route MTU on Host (i.e., no ipv4 DF bit set), R1 does
> not fragment the packets when forwarding, and again tries to send out
> packets exceeding R1-R2 link mtu.
> 
> This alters the forwarding dstmtu checks to take the individual gso
> segment lengths into account.
> 
> For ipv6, we send out pkt too big error for gso if the individual
> segments are too big.
> 
> For ipv4, we either send icmp fragmentation needed, or, if the DF bit
> is not set, perform software segmentation and let the output path
> create fragments when the packet is leaving the machine.  This is
> technically not 100% accurate, as the error message will contain the
> gro-skb tcp header (we'd have to segment unconditionally and use first
> segment instead), but it does seem to work.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  include/linux/skbuff.h | 17 +++++++++++++++
>  net/ipv4/ip_forward.c  | 58 ++++++++++++++++++++++++++++++++++++++++++++++++--
>  net/ipv6/ip6_output.c  | 18 ++++++++++++++--
>  3 files changed, 89 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 3d76066..37cb679 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2811,5 +2811,22 @@ static inline bool skb_head_is_locked(const struct sk_buff *skb)
>  {
>  	return !skb->head_frag || skb_cloned(skb);
>  }
> +
> +/**
> + * skb_gso_network_seglen - Return length of individual segments of a gso packet
> + *
> + * @skb: GSO skb
> + *
> + * skb_gso_network_seglen is used to determine the real size of the
> + * individual segments, including Layer3 (IP, IPv6) and L4 headers (TCP/UDP).
> + *
> + * The MAC/L2 header is not accounted for.
> + */
> +static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
> +{
> +	unsigned int hdr_len = skb_transport_header(skb) -
> +			       skb_network_header(skb);
> +	return hdr_len + skb_gso_transport_seglen(skb);
> +}
>  #endif	/* __KERNEL__ */
>  #endif	/* _LINUX_SKBUFF_H */
> diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
> index 694de3b..78f2e2a 100644
> --- a/net/ipv4/ip_forward.c
> +++ b/net/ipv4/ip_forward.c
> @@ -39,6 +39,58 @@
>  #include <net/route.h>
>  #include <net/xfrm.h>
>  
> +static bool ip_may_fragment(const struct sk_buff *skb)
> +{
> +	return unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) == 0) ||
> +	       !skb->local_df;
> +}
> +
> +static bool ip_gso_exceeds_dst_mtu(const struct sk_buff *skb)
> +{
> +	if (skb->local_df || !skb_is_gso(skb))
> +		return false;
> +	return skb_gso_network_seglen(skb) > dst_mtu(skb_dst(skb));
> +}
> +
> +static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
> +{
> +	unsigned len;
> +
> +	if (skb->local_df)
> +		return false;
> +	len = skb_is_gso(skb) ? skb_gso_network_seglen(skb) : skb->len;
> +
> +	return len > mtu;

The function should avoid extra computation/tests for small packets.

if (skb->len <= mtu || skb->local_df)
	return false;

if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
	return false;

return true;

> +}
> +
> +/* called if GSO skb needs to be fragmented on forward.  */
> +static int ip_forward_finish_gso(struct sk_buff *skb)
> +{
> +	struct sk_buff *segs = skb_gso_segment(skb, 0);

0 is very pessimistic.

Have you tried :

netdev_features_t features = netif_skb_features(skb); 
struct sk_buff *segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);


> +	int ret = 0;
> +
> +	if (IS_ERR(segs)) {
> +		kfree_skb(skb);
> +		return -ENOMEM;
> +	}
> +
> +	consume_skb(skb);
> +
> +	do {
> +		struct sk_buff *nskb = segs->next;
> +		int err;
> +
> +		segs->next = NULL;
> +		err = dst_output(segs);
> +
> +		if (err && ret == 0)
> +			ret = err;
> +		segs = nskb;
> +	} while (segs);
> +
> +	return ret;
> +}
> +
