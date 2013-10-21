From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] netpoll: linearize skb before accessing its data
Date: Mon, 21 Oct 2013 15:25:36 -0700
Message-ID: <1382394336.3284.92.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:63075 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab3JUWZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 18:25:37 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so5944987pdj.36
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 15:25:37 -0700 (PDT)
In-Reply-To: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-21 at 23:31 +0200, Antonio Quartulli wrote:
> __netpoll_rx() assumes that the data buffer of the received
> skb is linear and then passes it to rx_hook().
> However this is not true because the skb has not been
> linearized yet.
> 
> This can cause rx_hook() to access non allocated memory
> while parsing the received data.
> 
> Fix __netpoll_rx() by explicitly linearising the skb.
> 
> Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
> ---
> 
> I checked linux-3.0 and this bug seems to be already there. Please consider
> queueing it for stable.
> 
> 
> Regards,
> 
> 
> 
>  net/core/netpoll.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index fc75c9e..97cff18 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -814,6 +814,9 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
>  		if (pskb_trim_rcsum(skb, len))
>  			goto out;
>  
> +		if (skb_linearize(skb))
> +			goto out;
> +
>  		iph = (struct iphdr *)skb->data;
>  		if (iph->protocol != IPPROTO_UDP)
>  			goto out;
> @@ -855,6 +858,8 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
>  			goto out;
>  		if (pskb_trim_rcsum(skb, len + sizeof(struct ipv6hdr)))
>  			goto out;
> +		if (skb_linearize(skb))
> +			goto out;
>  		ip6h = ipv6_hdr(skb);
>  		if (!pskb_may_pull(skb, sizeof(struct udphdr)))
>  			goto out;

Well, if you linearize the skb, no need for pskb_may_pull(),
and it would be better to do it once at the beginning...


Anyway, how I see nothing sets rx_hook, what am I missing ?

# git grep -n rx_hook
include/linux/netpoll.h:27:     void (*rx_hook)(struct netpoll *, int, char *, int);
include/linux/netpoll.h:44:     struct list_head rx_np; /* netpolls that registered an rx_hook */
net/core/netpoll.c:639:                 /* If there are several rx_hooks for the same address,
net/core/netpoll.c:722:                 /* If there are several rx_hooks for the same address,
net/core/netpoll.c:837:                 np->rx_hook(np, ntohs(uh->source),
net/core/netpoll.c:875:                 np->rx_hook(np, ntohs(uh->source),
net/core/netpoll.c:1065:        if (np->rx_hook) {
