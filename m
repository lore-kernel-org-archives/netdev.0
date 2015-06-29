From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sock: honor GFP_ATOMIC when allocating send skbs
Date: Mon, 29 Jun 2015 15:36:05 +0200
Message-ID: <1435584965.4110.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435583216-19877-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:36143 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbbF2NgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 09:36:10 -0400
In-Reply-To: <1435583216-19877-1-git-send-email-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-29 at 15:06 +0200, Jason A. Donenfeld wrote:
> Some sockets set sock->sk->sk_allocation = GFP_ATOMIC. In spite of this,
> functions that call sock_alloc_send_skb will then call
> sock_alloc_send_pskb, which very often results in sleeping. Since the
> intention of callers setting sk_allocation = GFP_ATOMIC might be to be
> able to send from atomic context, we need to honor this and not sleep.


What exact problem have you noticed ? We need details please.

GFP_ATOMIC in these path does not mean 'do not wait' but instead
'allocate from emergency pools'.

We already have many ways to state ' do not wait', maybe you should use
them.

> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> ---
>  net/core/sock.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 1e1fe9a..f00e691 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1804,34 +1804,37 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
>  				     unsigned long data_len, int noblock,
>  				     int *errcode, int max_page_order)
>  {
>  	struct sk_buff *skb;
>  	long timeo;
>  	int err;
>  
>  	timeo = sock_sndtimeo(sk, noblock);
>  	for (;;) {
>  		err = sock_error(sk);
>  		if (err != 0)
>  			goto failure;
>  
>  		err = -EPIPE;
>  		if (sk->sk_shutdown & SEND_SHUTDOWN)
>  			goto failure;
>  
> +		if (sk->sk_allocation & GFP_ATOMIC)
> +			break;
> +

This is the wrong place to put this test, as following one is probably
the one that is hit most of the times (fast path)


>  		if (sk_wmem_alloc_get(sk) < sk->sk_sndbuf)
>  			break;


Anyway, testing for GFP_ATOMIC 'flag' is wrong.

You probably meant to test __GFP_WAIT instead, but you need to give more
details.
