From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: reduce cpu usage when SO_SNDBUF is
 set
Date: Wed, 22 Jun 2016 10:34:14 -0700
Message-ID: <1466616854.6850.69.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1466608332.git.jbaron@akamai.com>
	 <c873de17bfcf341eafda5ee7762c3f2c26579ff1.1466608332.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33862 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcFVReR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:34:17 -0400
Received: by mail-pa0-f66.google.com with SMTP id us13so4424791pab.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 10:34:16 -0700 (PDT)
In-Reply-To: <c873de17bfcf341eafda5ee7762c3f2c26579ff1.1466608332.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 11:32 -0400, Jason Baron wrote:
> From: Jason Baron <jbaron@akamai.com>
> 
> When SO_SNDBUF is set and we are under tcp memory pressure, the effective
> write buffer space can be much lower than what was set using SO_SNDBUF. For
> example, we may have set the buffer to 100kb, but we may only be able to
> write 10kb. In this scenario poll()/select()/epoll(), are going to
> continuously return POLLOUT, followed by -EAGAIN from write(), and thus
> result in a tight loop. Note that epoll in edge-triggered does not have
> this issue since it only triggers once data has been ack'd. There is no
> issue here when SO_SNDBUF is not set, since the tcp layer will auto tune
> the sk->sndbuf.


Still, generating one POLLOUT event per incoming ACK will not please
epoll() users in edge-trigger mode.

Host is under global memory pressure, so we probably want to drain
socket queues _and_ reduce cpu pressure.

Strategy to insure all sockets converge to small amounts ASAP is simply
the best answer.

Letting big SO_SNDBUF offenders hog memory while their queue is big
is not going to help sockets who can not get ACK
(elephants get more ACK than mice, so they have more chance to succeed
their new allocations)

Your patch adds lot of complexity logic in tcp_sendmsg() and
tcp_sendpage().


I would prefer a simpler patch like :


 net/ipv4/tcp.c |   26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5c7ed147449c..68bf035180d5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -370,6 +370,26 @@ static int retrans_to_secs(u8 retrans, int timeout, int rto_max)
 	return period;
 }
 
+static bool tcp_throttle_writes(const struct sock *sk)
+{
+	return unlikely(tcp_memory_pressure &&
+			sk->sk_wmem_queued >= sysctl_tcp_wmem[0]);
+}
+
+static bool tcp_is_writeable(const struct sock *sk)
+{
+	if (tcp_throttle_writes(sk))
+		return false;
+	return sk_stream_is_writeable(sk);
+}
+
+static void tcp_write_space(struct sock *sk)
+{
+	if (tcp_throttle_writes(sk))
+		return;
+	sk_stream_write_space(sk);
+}
+
 /* Address-family independent initialization for a tcp_sock.
  *
  * NOTE: A lot of things set to zero explicitly by call to
@@ -412,7 +432,7 @@ void tcp_init_sock(struct sock *sk)
 
 	sk->sk_state = TCP_CLOSE;
 
-	sk->sk_write_space = sk_stream_write_space;
+	sk->sk_write_space = tcp_write_space;
 	sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 
 	icsk->icsk_sync_mss = tcp_sync_mss;
@@ -517,7 +537,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 			mask |= POLLIN | POLLRDNORM;
 
 		if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
-			if (sk_stream_is_writeable(sk)) {
+			if (tcp_is_writeable(sk)) {
 				mask |= POLLOUT | POLLWRNORM;
 			} else {  /* send SIGIO later */
 				sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
@@ -529,7 +549,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 				 * pairs with the input side.
 				 */
 				smp_mb__after_atomic();
-				if (sk_stream_is_writeable(sk))
+				if (tcp_is_writeable(sk))
 					mask |= POLLOUT | POLLWRNORM;
 			}
 		} else
