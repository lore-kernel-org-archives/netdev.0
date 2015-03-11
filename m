From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add real socket cookies
Date: Wed, 11 Mar 2015 17:53:45 -0400 (EDT)
Message-ID: <20150311.175345.836846566788322568.davem@davemloft.net>
References: <1426027533.11398.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbbCKVxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:53:47 -0400
In-Reply-To: <1426027533.11398.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Mar 2015 15:45:33 -0700

> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index 14d02ea905b6..a097ae38b639 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -678,7 +678,8 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
>  		newsk->sk_write_space = sk_stream_write_space;
>  
>  		newsk->sk_mark = inet_rsk(req)->ir_mark;
> -
> +		atomic64_cmpxchg(&newsk->sk_cookie, 0,
> +				 atomic64_read(&inet_rsk(req)->ir_cookie));
>  		newicsk->icsk_retransmits = 0;
>  		newicsk->icsk_backoff	  = 0;
>  		newicsk->icsk_probes_out  = 0;

I think you have to be more careful here.

sk_clone_lock() is not going to zero out sk_cookie for you, it only
does so if the priority has __GFP_ZERO in it and some callsites use
just plain GFP_ATOMIC.

Therefore, you can't just assume sk_cookie is zero.

Just use atomic64_set() here, you have exclusive access to this piece
of memory at this point in time, and you'll save an unnecessary atomic
operation as well.
