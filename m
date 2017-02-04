From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] tcp: correct memory barrier usage in
 tcp_check_space()
Date: Sat, 4 Feb 2017 17:59:54 +0800
Message-ID: <20170204095954.GA5916@gondor.apana.org.au>
References: <1485312581-13041-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, oleg@redhat.com
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36969 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753811AbdBDKAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 05:00:55 -0500
Content-Disposition: inline
In-Reply-To: <1485312581-13041-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Baron <jbaron@akamai.com> wrote:
> From: Jason Baron <jbaron@akamai.com>
> 
> sock_reset_flag() maps to __clear_bit() not the atomic version clear_bit().
> Thus, we need smp_mb(), smp_mb__after_atomic() is not sufficient.
> 
> Fixes: 3c7151275c0c ("tcp: add memory barriers to write space paths")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Jason Baron <jbaron@akamai.com>

This patch makes no sense.

> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index bfa165cc455a..1e22ae4a5b38 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5028,7 +5028,7 @@ static void tcp_check_space(struct sock *sk)
>        if (sock_flag(sk, SOCK_QUEUE_SHRUNK)) {
>                sock_reset_flag(sk, SOCK_QUEUE_SHRUNK);
>                /* pairs with tcp_poll() */
> -               smp_mb__after_atomic();
> +               smp_mb();
>                if (sk->sk_socket &&
>                    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
>                        tcp_new_space(sk);

The comment says that it's pairing with an mb in tcp_poll, but
tcp_poll doesn't touch QUEUE_SHRUNK at all.  So what exactly is
this barrier for?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
