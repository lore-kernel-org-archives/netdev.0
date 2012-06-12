From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: Fix skb tail pointer in netpoll_send_udp()
Date: Tue, 12 Jun 2012 14:22:46 +0200
Message-ID: <1339503766.22704.116.camel@edumazet-glaptop>
References: <1339496765-3093-1-git-send-email-bogdan.hamciuc@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55320 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab2FLMWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 08:22:51 -0400
Received: by eeit10 with SMTP id t10so2189401eei.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 05:22:50 -0700 (PDT)
In-Reply-To: <1339496765-3093-1-git-send-email-bogdan.hamciuc@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-12 at 13:26 +0300, Bogdan Hamciuc wrote:
> As skb->tail wasn't updated after skb_copy_to_linear_data(), subsequent
> calls to skb_realloc_headroom() (as made by an ethernet driver's
> ndo_start_xmit routine) would only effectively copy the packet headers,
> leaving garbage in the payload.
> 
> In the process, removed some unnecessary code.
> 
> Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
> ---
>  net/core/netpoll.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 3d84fb9..9a08068 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -362,22 +362,22 @@ EXPORT_SYMBOL(netpoll_send_skb_on_dev);
>  
>  void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
>  {
> -	int total_len, eth_len, ip_len, udp_len;
> +	int total_len, ip_len, udp_len;
>  	struct sk_buff *skb;
>  	struct udphdr *udph;
>  	struct iphdr *iph;
>  	struct ethhdr *eth;
>  
>  	udp_len = len + sizeof(*udph);
> -	ip_len = eth_len = udp_len + sizeof(*iph);
> -	total_len = eth_len + ETH_HLEN + NET_IP_ALIGN;
> +	ip_len = udp_len + sizeof(*iph);
> +	total_len = ip_len + ETH_HLEN + NET_IP_ALIGN;
>  
>  	skb = find_skb(np, total_len, total_len - len);
>  	if (!skb)
>  		return;
>  
>  	skb_copy_to_linear_data(skb, msg, len);
> -	skb->len += len;
> +	skb_put(skb, len);
>  
>  	skb_push(skb, sizeof(*udph));
>  	skb_reset_transport_header(skb);

Hmm, real question is why skb_realloc_headroom() is even necessary...

I suspect we need to reserve more bytes.

	total_len = ip_len + ETH_HLEN + NET_IP_ALIGN + NET_SKB_PAD;

or something like that ?

Which driver triggers the bug ?
