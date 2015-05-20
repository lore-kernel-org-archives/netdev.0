From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: af_unix: implement stream sendpage
 support
Date: Wed, 20 May 2015 16:21:34 -0700
Message-ID: <1432164094.4060.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
	 <06647895d82d7a5188b522c00cf28398b3410628.1432135413.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34048 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbbETXVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 19:21:36 -0400
Received: by igbhj9 with SMTP id hj9so2335880igb.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 16:21:35 -0700 (PDT)
In-Reply-To: <06647895d82d7a5188b522c00cf28398b3410628.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 17:35 +0200, Hannes Frederic Sowa wrote:
> This patch implements sendpage support for AF_UNIX SOCK_STREAM
> sockets. This is also required for a complete splice implementation.
> 
> The implementation is a bit tricky because we append to already existing
> skbs and so have to hold unix_sk->readlock to protect the reading side
> from dropping the tail of the sk_receive_queue.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/unix/af_unix.c | 105 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 104 insertions(+), 1 deletion(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 941b3d2..9bb880a 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -518,6 +518,8 @@ static int unix_ioctl(struct socket *, unsigned int, unsigned long);
>  static int unix_shutdown(struct socket *, int);
>  static int unix_stream_sendmsg(struct socket *, struct msghdr *, size_t);
>  static int unix_stream_recvmsg(struct socket *, struct msghdr *, size_t, int);
> +static ssize_t unix_stream_sendpage(struct socket *, struct page *, int offset,
> +				    size_t size, int flags);
>  static int unix_dgram_sendmsg(struct socket *, struct msghdr *, size_t);
>  static int unix_dgram_recvmsg(struct socket *, struct msghdr *, size_t, int);
>  static int unix_dgram_connect(struct socket *, struct sockaddr *,
> @@ -558,7 +560,7 @@ static const struct proto_ops unix_stream_ops = {
>  	.sendmsg =	unix_stream_sendmsg,
>  	.recvmsg =	unix_stream_recvmsg,
>  	.mmap =		sock_no_mmap,
> -	.sendpage =	sock_no_sendpage,
> +	.sendpage =	unix_stream_sendpage,
>  	.set_peek_off =	unix_set_peek_off,
>  };
>  
> @@ -1720,6 +1722,107 @@ out_err:
>  	return sent ? : err;
>  }
>  
> +static ssize_t unix_stream_sendpage(struct socket *socket, struct page *page,
> +				    int offset, size_t size, int flags)
> +{
> +	int err;
> +	bool send_sigpipe;
> +	struct sock *sk, *other;
> +	struct sk_buff *skb, *newskb, *tail;
> +
> +	err = 0;
> +	tail = NULL;
> +	newskb = NULL;
> +	sk = socket->sk;
> +	send_sigpipe = true;
> +
> +	if (flags & MSG_OOB)
> +		return -EOPNOTSUPP;
> +
> +	other = unix_peer(sk);
> +	if (!other || sk->sk_state != TCP_ESTABLISHED)
> +		return -ENOTCONN;
> +
> +	if (false) {
> +alloc_skb:
> +		unix_state_unlock(other);
> +		mutex_unlock(&unix_sk(other)->readlock);
> +		newskb = sock_alloc_send_pskb(sk, 0, 0, flags & MSG_DONTWAIT,
> +					      &err, 0);
> +		if (!newskb)
> +			return err;
> +	}
> +
> +	/* we must acquire readlock as we modify already present
> +	 * skbs in the sk_receive_queue and mess with skb->len
> +	 */
> +	err = mutex_lock_interruptible(&unix_sk(other)->readlock);
> +	if (err) {
> +		err = flags & MSG_DONTWAIT ? -EAGAIN : -ERESTARTSYS;
> +		send_sigpipe = false;
> +		goto err;
> +	}
> +
> +	if (sk->sk_shutdown & SEND_SHUTDOWN) {
> +		err = -EPIPE;
> +		goto err_unlock;
> +	}
> +
> +	unix_state_lock(other);
> +
> +	if (sock_flag(other, SOCK_DEAD) ||
> +	    other->sk_shutdown & RCV_SHUTDOWN) {
> +		err = -EPIPE;
> +		goto err_state_unlock;
> +	}
> +
> +	skb = skb_peek_tail(&other->sk_receive_queue);
> +	if (tail && tail == skb) {
> +		skb = newskb;
> +	} else if (!skb) {
> +		if (newskb)
> +			skb = newskb;
> +		else
> +			goto alloc_skb;
> +	} else if (newskb) {
> +		/* this is fast path, we don't necessarily need to
> +		 * call to kfree_skb even though with newskb == NULL
> +		 * this - does no harm
> +		 */
> +		consume_skb(newskb);
> +	}
> +
> +	if (skb_append_pagefrags(skb, page, offset, size)) {
> +		tail = skb;
> +		goto alloc_skb;
> +	}
> +
> +	skb->len += size;
> +	skb->data_len += size;
> +	skb->truesize += size;
> +	atomic_add(size, &sk->sk_wmem_alloc);
> +
> +	if (newskb)
> +		skb_queue_tail(&other->sk_receive_queue, newskb);

Are you sure we need the skb_queue_tail() here (taking spinlock) ?

This would tell us there might be a possible race.

A comment would be nice eventually.
