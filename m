From: David Miller <davem@davemloft.net>
Subject: Re: strange tcp behavior
Date: Thu, 02 Aug 2007 19:21:34 -0700 (PDT)
Message-ID: <20070802.192134.107254907.davem@davemloft.net>
References: <46B21148.2090004@simon.arlott.org.uk>
	<20070802180842.GA6864@2ka.mipt.ru>
	<20070802184840.GA8901@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon@fire.lp0.eu, john@screen.lv, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51313
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754408AbXHCCVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 22:21:34 -0400
In-Reply-To: <20070802184840.GA8901@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 2 Aug 2007 22:48:42 +0400

> On Thu, Aug 02, 2007 at 10:08:42PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > So, following patch fixes problem for me.
> 
> Or this one. Essentially the same though.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

So, this bug got introduced partly in 2.3.15, which is when
we SMP threaded the networking stack.

The error check was present in inet_sendmsg() previously, it
looked like this:

int inet_sendmsg(struct socket *sock, struct msghdr *msg, int size,
		 struct scm_cookie *scm)
{
	struct sock *sk = sock->sk;

	if (sk->shutdown & SEND_SHUTDOWN) {
		if (!(msg->msg_flags&MSG_NOSIGNAL))
			send_sig(SIGPIPE, current, 1);
		return(-EPIPE);
	}
	if (sk->prot->sendmsg == NULL) 
		return(-EOPNOTSUPP);
	if(sk->err)
		return sock_error(sk);

	/* We may need to bind the socket. */
	if (inet_autobind(sk) != 0)
		return -EAGAIN;

	return sk->prot->sendmsg(sk, msg, size);
}

I believe the idea was to move the sk->err check down into
tcp_sendmsg().

But this raises a major issue.

What in the world are we doing allowing stream sockets to autobind?
That is totally bogus.  Even if we autobind, that won't make a connect
happen.

There is logic down in TCP to handle all of these details properly
as long as we don't do this bogus autobind stuff.

do_tcp_sendpages() and tcp_sendmsg() both invoke sk_stream_wait_connect()
if TCP is in a state where data sending is not possible.  Inside of
sk_stream_wait_connect() it handles socket errors as first priority,
then if no socket errors are pending it checks if we are trying to
connect currently and if not returns -EPIPE.  It is exactly what we
want under these circumstances.

So the bug is purely that autobind is attempted for TCP sockets at
all.

TCP's sendpage handles this correctly already, it calls directly down
into tcp_sendpage(), inet_sendpage() is not used at all.

So the fix is to make tcp_sendmsg() direct as well, that bypasses all
of this autobind madness.  The error checking and state verification
in TCP's sendmsg() and sendpage() implementations will do the right
thing.

Comments?

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c209361..185c7ec 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -281,7 +281,7 @@ extern int			tcp_v4_remember_stamp(struct sock *sk);
 
 extern int		    	tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 
-extern int			tcp_sendmsg(struct kiocb *iocb, struct sock *sk,
+extern int			tcp_sendmsg(struct kiocb *iocb, struct socket *sock,
 					    struct msghdr *msg, size_t size);
 extern ssize_t			tcp_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 06c08e5..e681034 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -831,7 +831,7 @@ const struct proto_ops inet_stream_ops = {
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
-	.sendmsg	   = inet_sendmsg,
+	.sendmsg	   = tcp_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = tcp_sendpage,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index da4c0b6..7e74011 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -658,9 +658,10 @@ static inline int select_size(struct sock *sk)
 	return tmp;
 }
 
-int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		size_t size)
 {
+	struct sock *sk = sock->sk;
 	struct iovec *iov;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3f5f742..9c94627 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2425,7 +2425,6 @@ struct proto tcp_prot = {
 	.shutdown		= tcp_shutdown,
 	.setsockopt		= tcp_setsockopt,
 	.getsockopt		= tcp_getsockopt,
-	.sendmsg		= tcp_sendmsg,
 	.recvmsg		= tcp_recvmsg,
 	.backlog_rcv		= tcp_v4_do_rcv,
 	.hash			= tcp_v4_hash,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index eed0937..b5f9637 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -484,7 +484,7 @@ const struct proto_ops inet6_stream_ops = {
 	.shutdown	   = inet_shutdown,		/* ok		*/
 	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
 	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
-	.sendmsg	   = inet_sendmsg,		/* ok		*/
+	.sendmsg	   = tcp_sendmsg,		/* ok		*/
 	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = tcp_sendpage,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f10f368..cbdb784 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2115,7 +2115,6 @@ struct proto tcpv6_prot = {
 	.shutdown		= tcp_shutdown,
 	.setsockopt		= tcp_setsockopt,
 	.getsockopt		= tcp_getsockopt,
-	.sendmsg		= tcp_sendmsg,
 	.recvmsg		= tcp_recvmsg,
 	.backlog_rcv		= tcp_v6_do_rcv,
 	.hash			= tcp_v6_hash,
