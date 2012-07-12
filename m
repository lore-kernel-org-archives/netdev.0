From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH 02/16] ipv4: Deliver ICMP redirects to sockets too.
Date: Thu, 12 Jul 2012 23:58:37 +0900
Message-ID: <20120712235837.4d611326830a16f9a035dd75@gmail.com>
References: <20120712.011049.831106026936792516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:42498 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932528Ab2GLO6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:58:42 -0400
Received: by yhmm54 with SMTP id m54so2788119yhm.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 07:58:41 -0700 (PDT)
In-Reply-To: <20120712.011049.831106026936792516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jul 2012 01:10:49 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> And thus, we can remove the ping_err() hack.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/icmp.c |    8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 18e39d1..5885146 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -782,13 +782,7 @@ static void icmp_redirect(struct sk_buff *skb)
>  		break;
>  	}
>  
> -	/* Ping wants to see redirects.
> -         * Let's pretend they are errors of sorts... */
> -	if (iph->protocol == IPPROTO_ICMP &&
> -	    iph->ihl >= 5 &&
> -	    pskb_may_pull(skb, (iph->ihl<<2)+8)) {
> -		ping_err(skb, icmp_hdr(skb)->un.gateway);
> -	}
> +	icmp_socket_deliver(skb, icmp_hdr(skb)->un.gateway);

icmp_redirect() just checks skb->len is larger than
sizeof(struct iphdr) and then ping_err() is called.
In ping_err(), *icmph is derived from following code without
sanity check of skb->len. So, I think avobe deleted checks about
skb->len need to move to ping_err() in case of packets are malformed.

	struct icmphdr *icmph = (struct icmphdr *)(skb->data+(iph->ihl<<2))
