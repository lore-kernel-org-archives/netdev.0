From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pktgen: Add UDPCSUM flag to support UDP
 checksums
Date: Tue, 23 Jul 2013 09:34:12 -0700
Message-ID: <1374597252.3449.26.camel@edumazet-glaptop>
References: <7a919a32ea457c580cf35c3a1b394d5ff041a441.1374596306.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:47893 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933197Ab3GWQeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 12:34:14 -0400
Received: by mail-pb0-f51.google.com with SMTP id um15so8638940pbc.24
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 09:34:13 -0700 (PDT)
In-Reply-To: <7a919a32ea457c580cf35c3a1b394d5ff041a441.1374596306.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 18:20 +0200, Thomas Graf wrote:
> UDP checksums are optional, hence pktgen has been omitting them in
> favour of performance. The optional flag UDPCSUM enables UDP
> checksumming. If the output device supports hardware checksumming
> the skb is prepared and marked CHECKSUM_PARTIAL, otherwise the
> checksum is generated in software.
> 

Seems useful.

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  include/net/udp.h |  1 +
>  net/core/pktgen.c | 34 +++++++++++++++++++++++++++++++---
>  net/ipv4/udp.c    |  3 ++-
>  3 files changed, 34 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 74c10ec..ef2e0b7 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -183,6 +183,7 @@ extern int udp_sendmsg(struct kiocb *iocb, struct sock *sk,
>  			    struct msghdr *msg, size_t len);
>  extern int udp_push_pending_frames(struct sock *sk);
>  extern void udp_flush_pending_frames(struct sock *sk);
> +extern void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
>  extern int udp_rcv(struct sk_buff *skb);
>  extern int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
>  extern int udp_disconnect(struct sock *sk, int flags);
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 9640972..2d1d48c 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -160,6 +160,7 @@
>  #include <net/net_namespace.h>
>  #include <net/checksum.h>
>  #include <net/ipv6.h>
> +#include <net/udp.h>
>  #include <net/addrconf.h>
>  #ifdef CONFIG_XFRM
>  #include <net/xfrm.h>
> @@ -198,6 +199,7 @@
>  #define F_QUEUE_MAP_RND (1<<13)	/* queue map Random */
>  #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
>  #define F_NODE          (1<<15)	/* Node memory alloc*/
> +#define F_UDPCSUM       (1<<16) /* Include UDP checksum */
>  
>  /* Thread control flag bits */
>  #define T_STOP        (1<<0)	/* Stop run */
> @@ -631,6 +633,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>  	if (pkt_dev->flags & F_UDPDST_RND)
>  		seq_printf(seq, "UDPDST_RND  ");
>  
> +	if (pkt_dev->flags & F_UDPCSUM)
> +		seq_printf(seq, "UDPCSUM  ");
> +
>  	if (pkt_dev->flags & F_MPLS_RND)
>  		seq_printf(seq,  "MPLS_RND  ");
>  
> @@ -1228,6 +1233,9 @@ static ssize_t pktgen_if_write(struct file *file,
>  		else if (strcmp(f, "!NODE_ALLOC") == 0)
>  			pkt_dev->flags &= ~F_NODE;
>  
> +		else if (strcmp(f, "UDPCSUM") == 0)
> +			pkt_dev->flags |= F_UDPCSUM;
> +
>  		else {
>  			sprintf(pg_result,
>  				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
> @@ -2733,7 +2741,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>  	udph->source = htons(pkt_dev->cur_udp_src);
>  	udph->dest = htons(pkt_dev->cur_udp_dst);
>  	udph->len = htons(datalen + 8);	/* DATA + udphdr */
> -	udph->check = 0;	/* No checksum */
> +	udph->check = 0;
>  
>  	iph->ihl = 5;
>  	iph->version = 4;
> @@ -2747,11 +2755,31 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>  	iph->frag_off = 0;
>  	iplen = 20 + 8 + datalen;
>  	iph->tot_len = htons(iplen);
> -	iph->check = 0;
> -	iph->check = ip_fast_csum((void *)iph, iph->ihl);

This seems not relevant to your patch.

>  	skb->protocol = protocol;
>  	skb->dev = odev;
>  	skb->pkt_type = PACKET_HOST;
> +
> +	if (!(pkt_dev->flags & F_UDPCSUM)) {
> +		skb->ip_summed = CHECKSUM_NONE;
> +	} else if (odev->features & NETIF_F_V4_CSUM) {
> +		skb->ip_summed = CHECKSUM_PARTIAL;
> +		skb->csum = 0;
> +		udp4_hwcsum(skb, udph->source, udph->dest);
> +	} else {
> +		__wsum csum = 0;
> +
> +		csum = udp_csum(skb);
> +
> +		/* add protocol-dependent pseudo-header */
> +		udph->check = csum_tcpudp_magic(udph->source, udph->dest,
> +						datalen + 8, IPPROTO_UDP, csum);
> +
> +		if (udph->check == 0)
> +			udph->check = CSUM_MANGLED_0;
> +	}
> +
> +	ip_send_check(iph);
> +


What about IPv6 side ?

Thanks
