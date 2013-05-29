From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update RPS target at poll for inet
Date: Tue, 28 May 2013 18:07:57 -0700
Message-ID: <1369789677.3301.589.camel@edumazet-glaptop>
References: <20130529004731.0CC5280D76@donbot.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, pjt@google.com,
	maze@google.com, therbert@google.com
To: majnemer@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:52232 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932863Ab3E2BIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:08:00 -0400
Received: by mail-pb0-f41.google.com with SMTP id xb12so8575682pbc.14
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 18:08:00 -0700 (PDT)
In-Reply-To: <20130529004731.0CC5280D76@donbot.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-28 at 17:47 -0700, majnemer@google.com wrote:
> Hello,
> 
> The current state of affairs is that read(2)/write(2) will engage
> RPS (receive packet steering) for internet protocol sockets while
> poll(2) does not.
> 
> We noticed that this is suboptimal for scenarios similar to the following:
> 1. Perform a poll(2) on a socket.
> 2. Block in sock_poll_wait (or something similar).
> 3. Perform a read(2) on the previously mentioned socket.
> 
> This patch updates the RPS target during poll(2) which improves this scenario.
> 
> Concretely, we saw improvements on the order of ~20% for the median and
> ~6% for the mean on our internal packet forwarding workload. Let me know if
> there is another workload I should take a look at.
> 
> Thanks,
> David
> 
> -----------------------------8<---------------------------
> 
> When poll(2) gets called with an ip socket, update the flow target to be the
> poller. The data will be on the appropriate CPU when the poller later calls
> recvmsg(2).
> 
> Signed-off-by: David Majnemer <majnemer@google.com>
> ---
>  include/net/inet_common.h |  2 ++
>  net/ipv4/af_inet.c        | 13 ++++++++++++-
>  net/ipv4/tcp.c            |  2 ++
>  net/ipv4/udp.c            |  2 ++
>  4 files changed, 18 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/inet_common.h b/include/net/inet_common.h
> index 2340087..21ecdb3 100644
> --- a/include/net/inet_common.h
> +++ b/include/net/inet_common.h
> @@ -20,6 +20,8 @@ extern int __inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
>  				 int addr_len, int flags);
>  extern int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
>  			      int addr_len, int flags);
> +extern unsigned int inet_dgram_poll(struct file *file, struct socket *sock,
> +				    poll_table *wait);
>  extern int inet_accept(struct socket *sock, struct socket *newsock, int flags);
>  extern int inet_sendmsg(struct kiocb *iocb, struct socket *sock,
>  			struct msghdr *msg, size_t size);
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index b05ae96..e864612 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -567,6 +567,17 @@ int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
>  }
>  EXPORT_SYMBOL(inet_dgram_connect);
>  
> +unsigned int inet_dgram_poll(struct file *file, struct socket *sock,
> +			     poll_table *wait)
> +{
> +	struct sock *sk = sock->sk;
> +
> +	sock_rps_record_flow(sk);
> +
> +	return datagram_poll(file, sock, wait);
> +}
> +EXPORT_SYMBOL(inet_dgram_poll);
> +
>  static long inet_wait_for_connect(struct sock *sk, long timeo, int writebias)
>  {
>  	DEFINE_WAIT(wait);
> @@ -1001,7 +1012,7 @@ static const struct proto_ops inet_sockraw_ops = {
>  	.socketpair	   = sock_no_socketpair,
>  	.accept		   = sock_no_accept,
>  	.getname	   = inet_getname,
> -	.poll		   = datagram_poll,
> +	.poll		   = inet_dgram_poll,
>  	.ioctl		   = inet_ioctl,
>  	.listen		   = sock_no_listen,
>  	.shutdown	   = inet_shutdown,
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index ba4186e..6aa930a 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -436,6 +436,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
>  	struct sock *sk = sock->sk;
>  	const struct tcp_sock *tp = tcp_sk(sk);
>  
> +	sock_rps_record_flow(sk);
> +
>  	sock_poll_wait(file, sk_sleep(sk), wait);
>  	if (sk->sk_state == TCP_LISTEN)
>  		return inet_csk_listen_poll(sk);
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index aa5eff4..c7338ec 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1967,6 +1967,8 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
>  	unsigned int mask = datagram_poll(file, sock, wait);
>  	struct sock *sk = sock->sk;
>  
> +	sock_rps_record_flow(sk);
> +
>  	/* Check for false positives due to checksum errors */
>  	if ((mask & POLLRDNORM) && !(file->f_flags & O_NONBLOCK) &&
>  	    !(sk->sk_shutdown & RCV_SHUTDOWN) && !first_packet_length(sk))

I do understand the UDP/TCP parts in udp_poll()/tcp_poll()

But I don't see how inet_dgram_poll() is expected to work.

I do not think raw socket calls sock_rps_save_rxhash(sk, skb).

Its done only for tcp sockets, and connected udp sockets.
