From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 4/4 RFC] pktgen: Allow sending IPv4 TCP
 packets
Date: Thu, 31 Jul 2014 21:32:20 -0700 (PDT)
Message-ID: <20140731.213220.2290285957519220651.davem@davemloft.net>
References: <1406737212-23351-1-git-send-email-zoltan.kiss@citrix.com>
	<1406737212-23351-5-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, minipli@googlemail.com,
	dborkman@redhat.com, tgraf@suug.ch, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaHAEcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 00:32:22 -0400
In-Reply-To: <1406737212-23351-5-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 30 Jul 2014 17:20:12 +0100

> This is a prototype patch to enable sending IPv4 TCP packets with pktgen. The
> original motivation is to test TCP GSO with xen-netback/netfront, but I'm not
> sure about how the checksum should be set up, and also someone should verify the
> GSO settings I'm using.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Joe Perches <joe@perches.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org
> ---
> v3:
> - mention explicitly that this for IPv4
> - memset the TCP header and set up doff
> - rework of checksum handling and GSO setting in fill_packet_ipv4
> - bail out in pktgen_xmit if the device won't be able to handle GSO
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 0d0aaac..9d93bda 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -162,6 +162,7 @@
>  #include <net/checksum.h>
>  #include <net/ipv6.h>
>  #include <net/udp.h>
> +#include <net/tcp.h>
>  #include <net/ip6_checksum.h>
>  #include <net/addrconf.h>
>  #ifdef CONFIG_XFRM
> @@ -203,6 +204,7 @@
>  #define F_NODE          (1<<15)	/* Node memory alloc*/
>  #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
>  #define F_PATTERN       (1<<17)	/* Fill the payload with a pattern */
> +#define F_TCP           (1<<18)	/* Send TCP packet instead of UDP */
>  
>  /* Thread control flag bits */
>  #define T_STOP        (1<<0)	/* Stop run */
> @@ -664,6 +666,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>  	if (pkt_dev->flags & F_PATTERN)
>  		seq_puts(seq, "PATTERN  ");
>  
> +	if (pkt_dev->flags & F_TCP)
> +		seq_puts(seq, "TCP  ");
> +
>  	if (pkt_dev->flags & F_MPLS_RND)
>  		seq_puts(seq,  "MPLS_RND  ");
>  
> @@ -1342,6 +1347,12 @@ static ssize_t pktgen_if_write(struct file *file,
>  		else if (strcmp(f, "!PATTERN") == 0)
>  			pkt_dev->flags &= ~F_PATTERN;
>  
> +		else if (strcmp(f, "TCP") == 0)
> +			pkt_dev->flags |= F_TCP;
> +
> +		else if (strcmp(f, "!TCP") == 0)
> +			pkt_dev->flags &= ~F_TCP;
> +
>  		else {
>  			sprintf(pg_result,
>  				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
> @@ -2955,7 +2966,8 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>  {
>  	struct sk_buff *skb = NULL;
>  	__u8 *eth;
> -	struct udphdr *udph;
> +	struct udphdr *udph = NULL;
> +	struct tcphdr *tcph;
>  	int datalen, iplen;
>  	struct iphdr *iph;
>  	__be16 protocol = htons(ETH_P_IP);
> @@ -3017,29 +3029,40 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
>  	iph = (struct iphdr *) skb_put(skb, sizeof(struct iphdr));
>  
>  	skb_set_transport_header(skb, skb->len);
> -	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
> +
> +	if (pkt_dev->flags & F_TCP) {
> +		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
> +			  sizeof(struct tcphdr) - pkt_dev->pkt_overhead;
> +		tcph = (struct tcphdr *)skb_put(skb, sizeof(struct tcphdr));
> +		memset(tcph, 0, sizeof(*tcph));
> +		tcph->source = htons(pkt_dev->cur_udp_src);
> +		tcph->dest = htons(pkt_dev->cur_udp_dst);
> +		tcph->doff = sizeof(struct tcphdr) >> 2;
> +	} else {
> +		datalen = pkt_dev->cur_pkt_size - ETH_HLEN - 20 -
> +			  sizeof(struct udphdr) - pkt_dev->pkt_overhead;
> +		udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
> +		udph->source = htons(pkt_dev->cur_udp_src);
> +		udph->dest = htons(pkt_dev->cur_udp_dst);
> +		udph->len = htons(datalen + sizeof(struct udphdr));
> +		udph->check = 0;
> +	}
> +

As more protocols (SCTP, etc.) get supported, this is going to become
completely unmanageable.  Please use callbacks or something like that
so this function doesn't turn into even more spaghetti.

> +	} else if (pkt_dev->flags & F_TCP) {
> +		struct inet_sock inet;
> +
> +		inet.inet_saddr = iph->saddr;
> +		inet.inet_daddr = iph->daddr;
> +		skb->ip_summed = CHECKSUM_NONE;
> +		tcp_v4_send_check((struct sock *)&inet, skb);

Please don't do things like this.  Making fake sockets on the stack, don't
do it.

Do other non-socket contexts compute TCP checksums this way?  Check
netfilter or similar, see what they do.

Worst case export __tcp_v4_send_check() or just duplicate it's contents
in the tcp case here.
