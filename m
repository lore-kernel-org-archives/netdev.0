From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 13:17:18 +0000
Message-ID: <8761n19k0w.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:45894 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754089AbaCZNbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 09:31:10 -0400
In-Reply-To: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Tue, 25 Mar 2014 18:42:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> From: Eric Dumazet <edumazet@google.com>
>
> Some applications didn't expect recvmsg() on a non blocking socket
> could return -EINTR. This possibility was added as a side effect
> of commit b3ca9b02b00704 ("net: fix multithreaded signal handling in
> unix recv routines").
>
> To hit this bug, you need to be a bit unlucky, as the u->readlock
> mutex is usually held for very small periods.

This would mean that 'some applications' are broken, cf

[EAGAIN] or [EWOULDBLOCK]
    The socket's file descriptor is marked O_NONBLOCK and no data is
    waiting to be received; or MSG_OOB is set and no out-of-band data is
    available and either the socket's file descriptor is marked
    O_NONBLOCK or the socket does not support blocking to await
    out-of-band data.

[EINTR]
    This function was interrupted by a signal before any data was
    available.
    
http://pubs.opengroup.org/onlinepubs/9699919799/functions/recvmsg.html

and

 EAGAIN or EWOULDBLOCK
              The socket is marked nonblocking and the receive operation
              would block, or a receive timeout had been set and the
              timeout expired before data was received.

 EINTR  The receive was interrupted by delivery of a signal before any
        data were available; see signal(7).

[3.27 Linux recvmsg(2)]

since the function was interrupted before any data was available and it
is unknown if the condition supposed to be signalled by EAGAIN had
otherwise occurred.

A correct 'fix'/ workaround would seem to be using mutex_trylock and
abort execution immediately with -EAGAIN in case the operation had to
wait for the lock, although this is inconsistent with the usual
semantics of 'blocking' which implies that the operation may take an
indefinite amount of time because it waits for an external event which
might never occur.
 
              
>
> Fixes: b3ca9b02b00704 ("net: fix multithreaded signal handling in unix recv routines")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> ---
>  net/unix/af_unix.c |   17 ++++++++++++-----
>  1 file changed, 12 insertions(+), 5 deletions(-)
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index ce6ec6c2f4de..94404f19f9de 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1787,8 +1787,11 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
>  		goto out;
>  
>  	err = mutex_lock_interruptible(&u->readlock);
> -	if (err) {
> -		err = sock_intr_errno(sock_rcvtimeo(sk, noblock));
> +	if (unlikely(err)) {
> +		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
> +		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
> +		 */
> +		err = noblock ? -EAGAIN : -ERESTARTSYS;
>  		goto out;
>  	}
>  
> @@ -1913,6 +1916,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
>  	struct unix_sock *u = unix_sk(sk);
>  	DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr, msg->msg_name);
>  	int copied = 0;
> +	int noblock = flags & MSG_DONTWAIT;
>  	int check_creds = 0;
>  	int target;
>  	int err = 0;
> @@ -1928,7 +1932,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
>  		goto out;
>  
>  	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
> -	timeo = sock_rcvtimeo(sk, flags&MSG_DONTWAIT);
> +	timeo = sock_rcvtimeo(sk, noblock);
>  
>  	/* Lock the socket to prevent queue disordering
>  	 * while sleeps in memcpy_tomsg
> @@ -1940,8 +1944,11 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
>  	}
>  
>  	err = mutex_lock_interruptible(&u->readlock);
> -	if (err) {
> -		err = sock_intr_errno(timeo);
> +	if (unlikely(err)) {
> +		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
> +		 * sk_rcvtimeo is not honored by mutex_lock_interruptible()
> +		 */
> +		err = noblock ? -EAGAIN : -ERESTARTSYS;
>  		goto out;
>  	}
>  
