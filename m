From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Unix socket buffer attribution
Date: Fri, 25 Jan 2013 16:53:59 -0800
Message-ID: <1359161639.12374.3686.camel@edumazet-glaptop>
References: <CAJ4BwwEY6vc3_rxou6PMxAZCdzW0X5WtsRX3SLGkP3g9df209g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yannick Koehler <yannick@koehler.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:56935 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729Ab3AZAyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 19:54:03 -0500
Received: by mail-pb0-f54.google.com with SMTP id rr4so514477pbb.41
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 16:54:02 -0800 (PST)
In-Reply-To: <CAJ4BwwEY6vc3_rxou6PMxAZCdzW0X5WtsRX3SLGkP3g9df209g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-25 at 10:32 -0500, Yannick Koehler wrote:
> This patch should fix an issue where unix socket buffer remains
> accounted as part of the socket sndbuf (sk_wmem_alloc) instead of
> being accounted as part of the receiving socket rcvbuf
> (sk_rmem_alloc), leading to a situation where if one of the receiving
> socket isn't calling recvfrom() the sending socket can no more send to
> any of its listeners, even those which properly behave.  This could
> create a DOS situation where the unix socket is reachable by many
> users on the same linux machine.
> 
> Signed-off-by: Yannick Koehler <yannick@koehler.name>
> 

Your patch is mangled, check Documentation/email-clients.txt

> diff -uprN -X linux-3.6/Documentation/dontdiff
> linux-3.6-vanilla/include/net/af_unix.h
> linux-3.6/include/net/af_unix.h
> --- linux-3.6-vanilla/include/net/af_unix.h 2012-09-30 19:47:46.000000000 -0400
> +++ linux-3.6/include/net/af_unix.h 2013-01-24 15:26:20.000000000 -0500
> @@ -34,6 +34,7 @@ struct unix_skb_parms {
>  #ifdef CONFIG_SECURITY_NETWORK
>   u32 secid; /* Security ID */
>  #endif
> + struct sock *peer; /* Skb's peer sk */
>  };
> 
>  #define UNIXCB(skb) (*(struct unix_skb_parms *)&((skb)->cb))
> diff -uprN -X linux-3.6/Documentation/dontdiff
> linux-3.6-vanilla/net/unix/af_unix.c linux-3.6/net/unix/af_unix.c
> --- linux-3.6-vanilla/net/unix/af_unix.c 2012-09-30 19:47:46.000000000 -0400
> +++ linux-3.6/net/unix/af_unix.c 2013-01-24 15:24:57.000000000 -0500
> @@ -1426,6 +1426,35 @@ static void maybe_add_creds(struct sk_bu
>  }
> 
>  /*
> + * Reduce the refcount from sk_wmem_alloc on the peer sk.
> + * Then remove invoke sock_rfree to release the memory
> + * from the current sock sk_rmem_alloc.
> + */
> +static void unix_sock_wrfree(struct sk_buff *skb)
> +{
> + struct sock *sk = UNIXCB(skb).peer;
> +
> + if (sk)
> + sk_free(sk);
> +
> + sock_rfree(skb);

Unfortunately it wont work, sock_rfree() can only be called with socket
lock held.

> +}
> +
> +static inline void unix_set_owner_r(struct sk_buff *skb, struct sock *sk,
> +     struct sock *other)
> +{
> + /* This operation garantee the peer sk isn't freed. */
> + atomic_add(1, &sk->sk_wmem_alloc);
> +
> + skb_orphan(skb);
> + skb->sk = other;
> + skb->destructor = unix_sock_wrfree;
> + atomic_add(skb->truesize, &other->sk_rmem_alloc);
> + sk_mem_charge(other, skb->truesize);
> + UNIXCB(skb).peer = sk;
> +}
> +
> +/*
>   * Send AF_UNIX data.
>   */
> 
> @@ -1579,9 +1607,16 @@ restart:
>   goto restart;
>   }
> 
> + if (atomic_read(&other->sk_rmem_alloc) + skb->truesize >=
> +    (unsigned)other->sk_rcvbuf) {
> + err = -EAGAIN;
> + goto out_unlock;
> + }

This might add a regression on clients expecting to block.

> +
>   if (sock_flag(other, SOCK_RCVTSTAMP))
>   __net_timestamp(skb);
>   maybe_add_creds(skb, sock, other);
> + unix_set_owner_r(skb, sk, other);
>   skb_queue_tail(&other->sk_receive_queue, skb);
>   if (max_level > unix_sk(other)->recursion_level)
>   unix_sk(other)->recursion_level = max_level;
> @@ -1696,7 +1731,14 @@ static int unix_stream_sendmsg(struct ki
>      (other->sk_shutdown & RCV_SHUTDOWN))
>   goto pipe_err_free;
> 
> + if (atomic_read(&other->sk_rmem_alloc) + skb->truesize >=
> +    (unsigned)other->sk_rcvbuf) {
> + err = -EAGAIN;
> + goto pipe_err_free;
> + }
> +

This might add a regression on clients expecting to block.


>   maybe_add_creds(skb, sock, other);
> + unix_set_owner_r(skb, sk, other);
>   skb_queue_tail(&other->sk_receive_queue, skb);
>   if (max_level > unix_sk(other)->recursion_level)
>   unix_sk(other)->recursion_level = max_level;
> @@ -1807,7 +1849,7 @@ static int unix_dgram_recvmsg(struct kio
>   POLLOUT | POLLWRNORM | POLLWRBAND);
> 
>   if (msg->msg_name)
> - unix_copy_addr(msg, skb->sk);
> + unix_copy_addr(msg, UNIXCB(skb).peer);
> 
>   if (size > skb->len - skip)
>   size = skb->len - skip;
> @@ -2007,7 +2049,7 @@ again:
> 
>   /* Copy address just once */
>   if (sunaddr) {
> - unix_copy_addr(msg, skb->sk);
> + unix_copy_addr(msg, UNIXCB(skb).peer);
>   sunaddr = NULL;
>   }
