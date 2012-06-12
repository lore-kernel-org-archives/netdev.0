From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: Add support for hardware checksumming on
 egress
Date: Tue, 12 Jun 2012 14:43:20 +0200
Message-ID: <1339505000.22704.132.camel@edumazet-glaptop>
References: <1339496765-3093-1-git-send-email-bogdan.hamciuc@freescale.com>
	 <1339496765-3093-2-git-send-email-bogdan.hamciuc@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47085 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab2FLMnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 08:43:25 -0400
Received: by eaak11 with SMTP id k11so2169469eaa.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 05:43:24 -0700 (PDT)
In-Reply-To: <1339496765-3093-2-git-send-email-bogdan.hamciuc@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-12 at 13:26 +0300, Bogdan Hamciuc wrote:
> Netpoll used to compute its own csum; but if the device supports, we
> should let it do the checksum itself.
> 
> Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
> ---
>  net/core/netpoll.c |   14 ++++++++++----
>  1 files changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 9a08068..f5d00b4 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -385,13 +385,19 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
>  	udph->source = htons(np->local_port);
>  	udph->dest = htons(np->remote_port);
>  	udph->len = htons(udp_len);
> -	udph->check = 0;
> -	udph->check = csum_tcpudp_magic(np->local_ip,
> +
> +	/* Only querying the IPv4 csumming capabilities */
> +	if (np->dev->features & NETIF_F_IP_CSUM)
> +		skb->ip_summed = CHECKSUM_PARTIAL;
> +	else {
> +		skb->ip_summed = CHECKSUM_NONE;
> +		udph->check = csum_tcpudp_magic(np->local_ip,
>  					np->remote_ip,
>  					udp_len, IPPROTO_UDP,
>  					csum_partial(udph, udp_len, 0));
> -	if (udph->check == 0)
> -		udph->check = CSUM_MANGLED_0;
> +		if (udph->check == 0)
> +			udph->check = CSUM_MANGLED_0;
> +	}
>  
>  	skb_push(skb, sizeof(*iph));
>  	skb_reset_network_header(skb);

Hi Bogdan

I cant see how this can possibly work ?

Which NIC was able to send a good UDP frame after this patch ?
