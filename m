From: Wakko Warner <wakko@animx.eu.org>
Subject: Re: [PATCH net] ipv4: only create late gso-skb if skb is already set
 up with CHECKSUM_PARTIAL
Date: Thu, 25 Feb 2016 19:07:06 -0500
Message-ID: <20160226000706.GA25882@animx.eu.org>
References: <1456163005-15809-1-git-send-email-hannes@stressinduktion.org>
Reply-To: Wakko Warner <wakko@animx.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tn-76-7-162-101.sta.embarqhsd.net ([76.7.162.101]:40848 "EHLO
	animx.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544AbcBZAHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 19:07:09 -0500
Content-Disposition: inline
In-Reply-To: <1456163005-15809-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> Otherwise we break the contract with GSO to only pass CHECKSUM_PARTIAL
> skbs down. This can easily happen with UDP+IPv4 sockets with the first
> MSG_MORE write smaller than the MTU, second write is a sendfile.
> 
> Returning -EOPNOTSUPP lets the callers fall back into normal sendmsg path,
> were we calculate the checksum manually during copying.
> 
> Commit d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked
> sockets") started to exposes this bug.
> 
> Fixes: d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets")
> Reported-by: Jiri Benc <jbenc@redhat.com>
> Cc: Jiri Benc <jbenc@redhat.com>
> Reported-by: Wakko Warner <wakko@animx.eu.org>
> Cc: Wakko Warner <wakko@animx.eu.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I just tested this with 2 of my VMs.  It appears to have fixed the issue.

> ---
>  net/ipv4/ip_output.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 64878efa045c13..565bf64b2b7d60 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1236,13 +1236,16 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
>  	if (!skb)
>  		return -EINVAL;
>  
> -	cork->length += size;
>  	if ((size + skb->len > mtu) &&
>  	    (sk->sk_protocol == IPPROTO_UDP) &&
>  	    (rt->dst.dev->features & NETIF_F_UFO)) {
> +		if (skb->ip_summed != CHECKSUM_PARTIAL)
> +			return -EOPNOTSUPP;
> +
>  		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
>  		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
>  	}
> +	cork->length += size;
>  
>  	while (size > 0) {
>  		if (skb_is_gso(skb)) {
> -- 
> 2.5.0
> 
-- 
 Microsoft has beaten Volkswagen's world record.  Volkswagen only created 22
 million bugs.
