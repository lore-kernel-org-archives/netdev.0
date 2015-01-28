From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: tcp: null pointer crash in __inet_put_port
Date: Wed, 28 Jan 2015 13:03:35 -0800
Message-ID: <1422479015.21689.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422460613-10782-1-git-send-email-harouth@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:46290 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbbA2BU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:20:26 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so27485998iec.8
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 17:20:25 -0800 (PST)
In-Reply-To: <1422460613-10782-1-git-send-email-harouth@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-28 at 08:56 -0700, Harout Hedeshian wrote:
> Hello,
> 
> We are observing a crash in __inet_put_port() wherein icsk_bind_hash
> is null (stack trace below).
> 
> net/ipv4/inet_hashtables.c:
> tb = inet_csk(sk)->icsk_bind_hash;
> __sk_del_bind_node(sk);
> tb->num_owners--;       <-- tb is unconditionally dereferenced here
> 
> From the RAM dumps: [D:0xFFFFFFC0222FB6F8] icsk_bind_hash = 0x0 = ,
> 
> The caller of inet_put_port() in this case is tcp_set_state() which
> already does a null check on this particular field before calling
> inet_put_port().
> 
> net/ipv4/tcp.c:
> if (inet_csk(sk)->icsk_bind_hash &&
>    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
> 	inet_put_port(sk);
> 
> It seems that inet_put_port() does some locking by disabling bottom
> halves, but this locking is happening after the null check.
> 
> Additionally, I see tcp_v4_destroy_sock() also calling inet_put_port()
> after doing a similar null check. However, I am unsure if it would
> ever be called on the same socket.
> 
> Does the proposed solution of locking the bottom halves from
> tcp_set_state() make any sense here? Or use some other locking mechanism
> directly on the socket?

>  net/ipv4/tcp.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3075723..f3b5714 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1910,9 +1910,11 @@ void tcp_set_state(struct sock *sk, int state)
>  			TCP_INC_STATS(sock_net(sk), TCP_MIB_ESTABRESETS);
>  
>  		sk->sk_prot->unhash(sk);
> +		local_bh_disable();
>  		if (inet_csk(sk)->icsk_bind_hash &&
>  		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
>  			inet_put_port(sk);
> +		local_bh_enable();
>  		/* fall through */
>  	default:
>  		if (oldstate == TCP_ESTABLISHED)


I don't think it makes sense.

tcp_set_state() should only be used on a locked socket.

I believe you are papering over another bug.

bh are disabled in inet_put_port because of the spin_lock() that can be
taken both from process and softirq contexts.
