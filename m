From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: splice from half-closed socket returning -EAGAIN
Date: Mon, 5 Jan 2009 07:47:29 +0100
Message-ID: <20090105064728.GE16185@xi.wantstofly.org>
References: <20090104133054.GB16185@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Mansell <ben@zeus.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:48545 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbZAEGrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 01:47:32 -0500
Content-Disposition: inline
In-Reply-To: <20090104133054.GB16185@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 04, 2009 at 02:30:54PM +0100, Lennert Buytenhek wrote:

> When doing a nonblocking splice() from a half-closed TCP socket
> (POLLRDHUP, FIN sent by the other side), I get -EAGAIN, while I was
> expecting that to return zero.  Non-blocking read/readv/recv/recvfrom/
> recvmsg on a half-closed socket also returns zero AFAIK, and in
> general, a zero return on a read operation meaning "EOF" seems to be
> well-established.
> 
> Is there any reason why splice() doesn't do this?  -EAGAIN hints that
> the operation might succeed in the future, but since the socket is
> half-closed, this won't ever happen.  Also, it's kind of annoying to
> have to poll for POLLRDHUP separately, as this isn't needed when using
> "copyful" socket I/O -- and there doesn't seem to be any other way of
> telling that a half-close has occured on the source socket.
> 
> (Test app attached, tested on 2.6.27.5 and 2.6.28.)

How about something like this?


From: Lennert Buytenhek <buytenh@wantsofly.org>
Subject: tcp: don't mask EOF and socket errors on nonblocking splice receive

Currently, setting SPLICE_F_NONBLOCK on splice from a TCP socket
results in masking of EOF (RDHUP) and error conditions on the socket
by an -EAGAIN return.  Move the NONBLOCK check in tcp_splice_read()
to be after the EOF and error checks to fix this.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c5aca0b..9e31f91 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -571,41 +571,41 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 	lock_sock(sk);
 
 	timeo = sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);
 	while (tss.len) {
 		ret = __tcp_splice_read(sk, &tss);
 		if (ret < 0)
 			break;
 		else if (!ret) {
 			if (spliced)
 				break;
-			if (flags & SPLICE_F_NONBLOCK) {
-				ret = -EAGAIN;
-				break;
-			}
 			if (sock_flag(sk, SOCK_DONE))
 				break;
 			if (sk->sk_err) {
 				ret = sock_error(sk);
 				break;
 			}
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				break;
 			if (sk->sk_state == TCP_CLOSE) {
 				/*
 				 * This occurs when user tries to read
 				 * from never connected socket.
 				 */
 				if (!sock_flag(sk, SOCK_DONE))
 					ret = -ENOTCONN;
 				break;
 			}
+			if (flags & SPLICE_F_NONBLOCK) {
+				ret = -EAGAIN;
+				break;
+			}
 			if (!timeo) {
 				ret = -EAGAIN;
 				break;
 			}
 			sk_wait_data(sk, &timeo);
 			if (signal_pending(current)) {
 				ret = sock_intr_errno(timeo);
 				break;
 			}
 			continue;
