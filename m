From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix possible socket refcount problem for ipv6
Date: Wed, 05 Sep 2012 22:57:00 +0200
Message-ID: <1346878620.13121.161.camel@edumazet-glaptop>
References: <1346878398-4782-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58098 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937Ab2IEU5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 16:57:10 -0400
Received: by bkwj10 with SMTP id j10so480222bkw.19
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2012 13:57:09 -0700 (PDT)
In-Reply-To: <1346878398-4782-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-05 at 23:53 +0300, Julian Anastasov wrote:
> 	commit 144d56e91044181ec0ef67aeca91e9a8b5718348
> ("tcp: fix possible socket refcount problem") is missing
> the IPv6 part. As tcp_release_cb is shared by both protocols
> we should hold sock reference for the TCP_MTU_REDUCED_DEFERRED
> bit.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/ipv6/tcp_ipv6.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 09078b9..f3bfb8b 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -403,8 +403,9 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  		tp->mtu_info = ntohl(info);
>  		if (!sock_owned_by_user(sk))
>  			tcp_v6_mtu_reduced(sk);
> -		else
> -			set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags);
> +		else if (!test_and_set_bit(TCP_MTU_REDUCED_DEFERRED,
> +					   &tp->tsq_flags))
> +			sock_hold(sk);
>  		goto out;
>  	}
>  

Thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
