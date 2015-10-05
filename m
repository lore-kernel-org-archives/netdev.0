From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 3/3] af_unix: optimize the unix_dgram_recvmsg()
Date: Mon, 5 Oct 2015 09:41:51 +0200
Message-ID: <20151005074151.GD2903@worktop.programming.kicks-ass.net>
References: <cover.1443817522.git.jbaron@akamai.com>
 <ba2b4c5c1d6fd3d99cd4b1286edace56c0f84a0d.1443817522.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	rweikusat@mobileactivedefense.com, viro@zeniv.linux.org.uk,
	davidel@xmailserver.org, dave@stgolabs.net, olivier@mauras.ch,
	pageexec@freemail.hu, torvalds@linux-foundation.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ba2b4c5c1d6fd3d99cd4b1286edace56c0f84a0d.1443817522.git.jbaron@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2015 at 08:44:02PM +0000, Jason Baron wrote:
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index f789423..b8ed1bc 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c

> @@ -1079,6 +1079,9 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
>  
>  	prepare_to_wait_exclusive(&u->peer_wait, &wait, TASK_INTERRUPTIBLE);
>  
> +	set_bit(UNIX_NOSPACE, &u->flags);
> +	/* pairs with mb in unix_dgram_recv */
> +	smp_mb__after_atomic();
>  	sched = !sock_flag(other, SOCK_DEAD) &&
>  		!(other->sk_shutdown & RCV_SHUTDOWN) &&
>  		unix_recvq_full(other);
> @@ -1623,17 +1626,22 @@ restart:
>  
>  	if (unix_peer(other) != sk && unix_recvq_full(other)) {
>  		if (!timeo) {
> +			set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
> +			/* pairs with mb in unix_dgram_recv */
> +			smp_mb__after_atomic();
> +			if (unix_recvq_full(other)) {
> +				err = -EAGAIN;
> +				goto out_unlock;
> +			}
> +		} else {

> @@ -1939,8 +1947,14 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
>  		goto out_unlock;
>  	}
>  
> +	/* pairs with unix_dgram_poll() and wait_for_peer() */
> +	smp_mb();
> +	if (test_bit(UNIX_NOSPACE, &u->flags)) {
> +		clear_bit(UNIX_NOSPACE, &u->flags);
> +		wake_up_interruptible_sync_poll(&u->peer_wait,
> +						POLLOUT | POLLWRNORM |
> +						POLLWRBAND);
> +	}
>  
>  	if (msg->msg_name)
>  		unix_copy_addr(msg, skb->sk);
> @@ -2468,20 +2493,19 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  	if (!(poll_requested_events(wait) & (POLLWRBAND|POLLWRNORM|POLLOUT)))
>  		return mask;
>  
>  	other = unix_peer_get(sk);
> +	if (unix_dgram_writable(sk, other)) {
>  		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
> +	} else {
>  		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
> +		set_bit(UNIX_NOSPACE, &unix_sk(other)->flags);
> +		/* pairs with mb in unix_dgram_recv */
> +		smp_mb__after_atomic();
> +		if (unix_dgram_writable(sk, other))
> +			mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
> +	}
> +	if (other)
> +		sock_put(other);
>  
>  	return mask;
>  }


So I must object to these barrier comments; stating which other barrier
they pair with is indeed good and required, but its not sufficient.

A barrier comment should also explain the data ordering -- the most
important part.

As it stands its not clear to me these barriers are required at all, but
this is not code I understand so I might well miss something obvious.
