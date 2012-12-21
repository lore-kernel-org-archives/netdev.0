From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4/ip_gre: make ipgre_tunnel_xmit() not parse
 network header as IP unconditionally
Date: Thu, 20 Dec 2012 17:48:41 -0800
Message-ID: <1356054521.21834.4043.camel@edumazet-glaptop>
References: <9ee0cd8f94e1ee866b40ee7b6755e8d8705325c9.1356052319.git.yamahata@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Isaku Yamahata <yamahata@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:53285 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681Ab2LUBso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 20:48:44 -0500
Received: by mail-da0-f50.google.com with SMTP id h15so1816914dan.9
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 17:48:43 -0800 (PST)
In-Reply-To: <9ee0cd8f94e1ee866b40ee7b6755e8d8705325c9.1356052319.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 10:12 +0900, Isaku Yamahata wrote:
> ipgre_tunnel_xmit() parses network header as IP unconditionally.
> But transmitting packets are not always IP packet. For example such packet
> can be sent by packet socket with sockaddr_ll.sll_protocol set.
> So make the function check if skb->protocol is IP.
> 
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> ---
>  net/ipv4/ip_gre.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index a85ae2f..8fcf0ed 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -760,7 +760,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  
>  	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
>  		gre_hlen = 0;
> -		tiph = (const struct iphdr *)skb->data;
> +		if (skb->protocol == htons(ETH_P_IP))
> +			tiph = (const struct iphdr *)skb->data;
> +		else
> +			tiph = &tunnel->parms.iph;
>  	} else {
>  		gre_hlen = tunnel->hlen;
>  		tiph = &tunnel->parms.iph;

Seems good to me thanks !

Acked-by: Eric Dumazet <edumazet@google.com>

BTW, it seems another bug exists at line 931 : We dereference tiph while
it could point to freed memory because of the skb_realloc_headroom() at
line 893

I'll send a patch.
