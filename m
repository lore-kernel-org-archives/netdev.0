From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 1/2] af_unix: fix unix_dgram_poll() behavior for EPOLLOUT
 event
Date: Sun, 31 Oct 2010 12:07:32 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1010311206290.16129@davide-lnx1>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>  <1288380431.2680.3.camel@edumazet-laptop>  <20101030123403.5e01540d@chocolatine.cbg.collabora.co.uk>  <1288443217.2680.962.camel@edumazet-laptop>  <1288444678.2680.966.camel@edumazet-laptop>
  <20101030224703.065e70f6@chocolatine.cbg.collabora.co.uk> <1288539383.2660.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1990304434-1288552052=:16129"
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:46546 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213Ab0JaTIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 15:08:53 -0400
Received: from davide-lnx1.local
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S360DB7> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Sun, 31 Oct 2010 15:08:07 -0400
In-Reply-To: <1288539383.2660.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1990304434-1288552052=:16129
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sun, 31 Oct 2010, Eric Dumazet wrote:

> Le samedi 30 octobre 2010 à 22:47 +0100, Alban Crequy a écrit :
> > Le Sat, 30 Oct 2010 15:17:58 +0200,
> > Eric Dumazet <eric.dumazet@gmail.com> a écrit :
> > 
> > > > Problem is the peer_wait, that epoll doesnt seem to be plugged into.
> > > > 
> > > > Bug is in unix_dgram_poll()
> > > > 
> > > > It calls sock_poll_wait( ... &unix_sk(other)->peer_wait,) only if
> > > > socket is 'writable'. Its a clear bug
> > 
> > Yes, it looks weird...
> > 
> > > > Try this patch please ?
> > 
> > I will be away from computer and I will continue to work on this from
> > the 20th of November.
> 
> OK, no problem. I tried it and it solves the problem. Here is an
> official patch submission.
> 
> David, for your convenience, I cooked a patch serie for the 2 patches
> against af_unix unix_dgram_poll().

Looks good to me...

Acked-by: Davide Libenzi <davidel@xmailserver.org>




> The third patch (af_unix: unix_write_space() use keyed wakeups)) can be
> applied as is.
> 
> Thanks !
> 
> [PATCH 1/2] af_unix: fix unix_dgram_poll() behavior for EPOLLOUT event
> 
> Alban Crequy reported a problem with connected dgram af_unix sockets and
> provided a test program. epoll() would miss to send an EPOLLOUT event
> when a thread unqueues a packet from the other peer, making its receive
> queue not full.
> 
> This is because unix_dgram_poll() fails to call sock_poll_wait(file,
> &unix_sk(other)->peer_wait, wait);
> if the socket is not writeable at the time epoll_ctl(ADD) is called. 
> 
> We must call sock_poll_wait(), regardless of 'writable' status, so that
> epoll can be notified later of states changes.
> 
> Misc: avoids testing twice (sk->sk_shutdown & RCV_SHUTDOWN)
> 
> Reported-by: Alban Crequy <alban.crequy@collabora.co.uk>
> Cc: Davide Libenzi <davidel@xmailserver.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/unix/af_unix.c |   24 +++++++++---------------
>  1 file changed, 9 insertions(+), 15 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 0ebc777..7375131 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2072,13 +2072,12 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
>  		mask |= POLLERR;
>  	if (sk->sk_shutdown & RCV_SHUTDOWN)
> -		mask |= POLLRDHUP;
> +		mask |= POLLRDHUP | POLLIN | POLLRDNORM;
>  	if (sk->sk_shutdown == SHUTDOWN_MASK)
>  		mask |= POLLHUP;
>  
>  	/* readable? */
> -	if (!skb_queue_empty(&sk->sk_receive_queue) ||
> -	    (sk->sk_shutdown & RCV_SHUTDOWN))
> +	if (!skb_queue_empty(&sk->sk_receive_queue))
>  		mask |= POLLIN | POLLRDNORM;
>  
>  	/* Connection-based need to check for termination and startup */
> @@ -2090,20 +2089,15 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  			return mask;
>  	}
>  
> -	/* writable? */
>  	writable = unix_writable(sk);
> -	if (writable) {
> -		other = unix_peer_get(sk);
> -		if (other) {
> -			if (unix_peer(other) != sk) {
> -				sock_poll_wait(file, &unix_sk(other)->peer_wait,
> -					  wait);
> -				if (unix_recvq_full(other))
> -					writable = 0;
> -			}
> -
> -			sock_put(other);
> +	other = unix_peer_get(sk);
> +	if (other) {
> +		if (unix_peer(other) != sk) {
> +			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
> +			if (unix_recvq_full(other))
> +				writable = 0;
>  		}
> +		sock_put(other);
>  	}
>  
>  	if (writable)
> 


- Davide


--8323329-1990304434-1288552052=:16129--
