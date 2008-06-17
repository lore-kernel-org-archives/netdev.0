From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Killing sk->sk_callback_lock (was Re: [PATCH] net/core/sock.c remove extra wakeup)
Date: Wed, 18 Jun 2008 09:33:38 +1000
Message-ID: <20080617233338.GA16824@gondor.apana.org.au>
References: <484F43A3020000760003F543@lucius.provo.novell.com> <4856C12F020000C700039679@lucius.provo.novell.com> <4856C12F020000C700039679@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Gregory Haskins <GHaskins@novell.com>,
	chuck.lever@oracle.com, netdev@vger.kernel.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36027 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759867AbYFQXdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:33:45 -0400
Content-Disposition: inline
In-Reply-To: <4856C12F020000C700039679@lucius.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 07:38:23PM -0600, Patrick Mullaney wrote:
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 1a394d0..a26d223 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1159,7 +1159,6 @@ static long sock_wait_for_wmem(struct sock * sk, long timeo)
>  			break;
>  		if (signal_pending(current))
>  			break;
> -		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
>  		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
>  		if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf)
>  			break;
> @@ -1167,9 +1166,11 @@ static long sock_wait_for_wmem(struct sock * sk, long timeo)
>  			break;
>  		if (sk->sk_err)
>  			break;
> +		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
>  		timeo = schedule_timeout(timeo);
>  	}
>  	finish_wait(sk->sk_sleep, &wait);
> +	clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
>  	return timeo;
>  }

This is buggy.  You're relying on the caller to not call this
on the same socket concurrently.  While this may be true for
UDP right now (which is a less than ideal situation in itself),
it isn't true in general.  In particular, raw sockets still
allow parallel writes to the same socket.

So forget about the flags and just do the two queues as you proposed
yourself :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
