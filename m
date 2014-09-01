From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next] sock: consistent errqueue errors and signals
Date: Mon, 01 Sep 2014 23:25:44 +0200
Message-ID: <1409606744.21965.37.camel@localhost>
References: <1409534896-372-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752441AbaIAVZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2014 17:25:52 -0400
In-Reply-To: <1409534896-372-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On So, 2014-08-31 at 21:28 -0400, Willem de Bruijn wrote:
> When a socket error is pending, send()/recv() must abort their normal
> operation and return the error. An error means having non-zero
> sk->sk_err or having non-empty sk->sk_error_queue.
> 
> Currently, the behavior for the second is inconsistent depending on
> whether an error has previously been dequeued. In all cases,
> recv()/send() test sk->sk_err. This is not modified on enqueue onto
> the error queue, so may be 0. It is modified on dequeue, however, to
> match the queued skb's errno. I observed the following when two errors
> were queued:
> 
>   ret = poll(pollfd, 1, -1);
>   assert(ret == 1);
>   assert(pollfd.revents == POLLERR);
> 
>   ret = recv(fd, buf, size, MSG_NONBLOCK);
>   assert(ret == -1 && errno == EAGAIN);		/* <-- A */
> 
>   ret = recv(fd, buf, size, MSG_ERRQUEUE);
>   assert(ret > 0);
> 
>   ret = recv(fd, buf, size, MSG_NONBLOCK);
>   assert(ret == -1 && errno == ENOMSG);		/* <-- B */
> 
>   ret = recv(fd, buf, size, MSG_ERRQUEUE);
>   assert(ret > 0);
> 
> The recv call in B returns the error code embedded in
> SKB_EXT_ERR(skb), in this case ENOMSG, because I am working with
> timestamps. The recv call in A should have returned the
> same.
> 
> Implement this behavior. This may surprise existing applications.
> 
> Also make the wake-up signal when data is ready on the error queue
> consistent between enqueue and dequeue: use sk_error_report in both
> cases.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> 
> ---
> 
> This approach leaves one issue:
> The states of sk->sk_err and sk->sk_error_queue are related, but only
> loosely. Error queue enqueue, dequeue and other code may overwrite
> sk->sk_err unconditionally. For one, sock_error will reset
> sk->sk_err to 0 even if sk->sk_error_queue is not empty. If socket
> calls should abort on all errors, then should be change to test
> sk_error_queue.qlen. But, doing so requires taking a lock in a busy
> data path.
> ---
>  net/core/skbuff.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 163b673..f7a280b 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3485,8 +3485,11 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
>  	skb_dst_force(skb);
>  
>  	skb_queue_tail(&sk->sk_error_queue, skb);
> +	sk->sk_err = SKB_EXT_ERR(skb)->ee.ee_errno;
> +
>  	if (!sock_flag(sk, SOCK_DEAD))
> -		sk->sk_data_ready(sk);
> +		sk->sk_error_report(sk);
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL(sock_queue_err_skb);

>From my experience in IPv6 code, we only do sk->sk_err updates directly
in protocol error handling code. In case of UDP IPv6 errors for example
we now notify sk_error_report two times with this patch (before the
patch we did sk_data_ready (this is what you changed) and
sk_error_report).

I really wonder if setting sk->sk_err in this function is the right
thing to do. It also depends on socket state bits (e.g. np->recverr) if
the update happens. So we still cannot get rid of the protocol dependent
sk->sk_err updates.

It looks like we have to check all error handling functions in the
protocols. Maybe timestamp code needs to adapt?

Thanks,
Hannes
