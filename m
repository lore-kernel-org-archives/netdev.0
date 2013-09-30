From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net] udp6: respect IPV6_DONTFRAG sockopt in case there are pending frames
Date: Mon, 30 Sep 2013 19:56:40 +0200
Message-ID: <20130930175640.GF10771@order.stressinduktion.org>
References: <1380549038-6291-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60680 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab3I3R4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 13:56:42 -0400
Content-Disposition: inline
In-Reply-To: <1380549038-6291-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 30, 2013 at 03:50:38PM +0200, Jiri Pirko wrote:
> if up->pending != 0 dontfrag is left with default value -1. That
> causes that application that do:
> sendto len>mtu flag MSG_MORE
> sendto len>mtu flag 0
> will receive EMSGSIZE errno as the result of the second sendto.
> 
> This patch fixes it by respecting IPV6_DONTFRAG socket option.
> 
> introduced by:
> commit 4b340ae20d0e2366792abe70f46629e576adaf5e "IPv6: Complete IPV6_DONTFRAG support"
> 
> Please push to stable as well.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/ipv6/udp.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 72b7eaa..1878609 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -1225,9 +1225,6 @@ do_udp_sendmsg:
>  	if (tclass < 0)
>  		tclass = np->tclass;
>  
> -	if (dontfrag < 0)
> -		dontfrag = np->dontfrag;
> -
>  	if (msg->msg_flags&MSG_CONFIRM)
>  		goto do_confirm;
>  back_from_confirm:
> @@ -1246,6 +1243,8 @@ back_from_confirm:
>  	up->pending = AF_INET6;
>  
>  do_append_data:
> +	if (dontfrag < 0)
> +		dontfrag = np->dontfrag;
>  	up->len += ulen;
>  	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
>  	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,

Hmm, I wonder if we need the same change in ipv6/raw.c.

Looks good at first sight, but I need to do some more tests.
