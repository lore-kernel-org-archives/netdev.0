From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: No more expensive sock_hold()/sock_put() on each
 tx
Date: Wed, 10 Jun 2009 01:17:43 -0700 (PDT)
Message-ID: <20090610.011743.230851451.davem@davemloft.net>
References: <4A275380.1050601@gmail.com>
	<20090603.215621.136203134.davem@davemloft.net>
	<4A27916B.7030607@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754279AbZFJIRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 04:17:41 -0400
In-Reply-To: <4A27916B.7030607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Jun 2009 11:18:35 +0200

> @@ -1172,12 +1186,18 @@ void __init sk_init(void)
>  void sock_wfree(struct sk_buff *skb)
>  {
>  	struct sock *sk = skb->sk;
> +	int res;
>  
>  	/* In case it might be waiting for more memory. */
> -	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
> +	res = atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
>  	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
>  		sk->sk_write_space(sk);
> -	sock_put(sk);
> +	/*
> +	 * if sk_wmem_alloc reached 0, we are last user and should
> +	 * free this sock, as sk_free() call could not do it.
> +	 */
> +	if (res == 0)
> +		__sk_free(sk);
>  }
>  EXPORT_SYMBOL(sock_wfree);
>  

Eric, I don't understand this part, please enlighten me :-)

Just because we've liberated all of the write buffer space, that does
not mean that it's time to kill off the socket completely.

Right?
