From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: ensure epoll edge trigger wakeup when out of memory
Date: Sun, 17 May 2015 19:50:54 -0700
Message-ID: <1431917454.621.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150515211707.D9FC480066@prod-mail-relay07.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	ncardwell@google.com, ycheng@google.com
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38225 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbERCu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 22:50:56 -0400
Received: by igcau1 with SMTP id au1so36964939igc.1
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 19:50:55 -0700 (PDT)
In-Reply-To: <20150515211707.D9FC480066@prod-mail-relay07.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 21:17 +0000, Jason Baron wrote:
> From: Jason Baron <jbaron@akamai.com>
> 
> If we really can't get an skb allocated, make sure that we let
> userspace know. This at least gives us a chance to re-try or abort.
> 
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> ---
>  net/ipv4/tcp.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index ecccfdc..d7d85e8 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -986,6 +986,9 @@ do_error:
>  	if (copied)
>  		goto out;
>  out_err:
> +	/* make sure we wake any epoll edge trigger waiter */
> +	if (unlikely(sk->sk_write_queue == 0 && err == -EAGAIN))
> +		sk->sk_write_space(sk);
>  	return sk_stream_error(sk, flags, err);
>  }
>  
> @@ -1274,6 +1277,9 @@ do_error:
>  		goto out;
>  out_err:
>  	err = sk_stream_error(sk, flags, err);
> +	/* make sure we wake any epoll edge trigger waiter */
> +	if (unlikely(sk->sk_write_queue == 0 && err == -EAGAIN))
> +		sk->sk_write_space(sk);
>  	release_sock(sk);
>  	return err;
>  }

I wonder if we should return ENOMEM here, otherwise application has no
way to avoid to spin forever ?
