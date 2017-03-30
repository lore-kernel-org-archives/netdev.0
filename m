From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: possible race between tcp_done() and tcp_poll()
Date: Wed, 29 Mar 2017 19:31:30 -0700
Message-ID: <1490841090.24891.58.camel@edumazet-glaptop3.roam.corp.google.com>
References: <34d952a3-77cd-ea53-c3e3-ccde91d5cf63@jp.fujitsu.com>
         <75d1b617-b143-3061-fcc7-4cca26ffc9fe@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33991 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753284AbdC3Cbd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 22:31:33 -0400
Received: by mail-pg0-f67.google.com with SMTP id o123so6320450pga.1
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 19:31:32 -0700 (PDT)
In-Reply-To: <75d1b617-b143-3061-fcc7-4cca26ffc9fe@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-30 at 09:35 +0900, Seiichi Ikarashi wrote:
> Similar to a4d258036ed9 ("tcp: Fix race in tcp_poll").
> 
> Between receiving a packet and tcp_poll(), sk->sk_err is protected by memory barriers but
> sk->sk_shutdown and sk->sk_state are not.

...

>  So possibly, POLLIN|POLLRDNORM|POLLRDHUP might
> not be set even when receiving a RST packet.
> 
> Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
> 
> ---
>  net/ipv4/tcp.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index cf45555..c8bc86e 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -456,6 +456,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
>  
>  	sock_poll_wait(file, sk_sleep(sk), wait);
>  
> +	/* This barrier is coupled with smp_wmb() in tcp_reset() */
> +	smp_rmb();
>  	state = sk_state_load(sk);

Are you telling us that sk_state_load() has no barrier ?

This would imply that smp_load_acquire() should be replaced ?

>  	if (state == TCP_LISTEN)
>  		return inet_csk_listen_poll(sk);
> @@ -540,8 +542,6 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
>  		 */
>  		mask |= POLLOUT | POLLWRNORM;
>  	}
> -	/* This barrier is coupled with smp_wmb() in tcp_reset() */
> -	smp_rmb();
>  	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
>  		mask |= POLLERR;
>  
> @@ -3291,6 +3291,9 @@ void tcp_done(struct sock *sk)
>  
>  	sk->sk_shutdown = SHUTDOWN_MASK;
>  
> +	/* This barrier is coupled with smp_rmb() in tcp_poll() */
> +	smp_wmb();
> +
>  	if (!sock_flag(sk, SOCK_DEAD))
>  		sk->sk_state_change(sk);
>  	else

Might I ask on which arch you got a problem ?

Thanks !
