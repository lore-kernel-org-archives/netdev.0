From: Richard Sailer <richard@weltraumpflege.org>
Subject: [PATCH net] tcp_timer.c: Add kernel-doc function descriptions
Date: Fri,  8 Jul 2016 22:58:26 +0200
Message-ID: <1468011506-358-1-git-send-email-richard@weltraumpflege.org>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloster.rz.uni-augsburg.de ([137.250.2.98]:36778 "EHLO
	gloster.rz.uni-augsburg.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753604AbcGHVMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 17:12:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds kernel-doc style descriptions for 6 functions and
fixes 1 typo.

Signed-off-by: Richard Sailer <richard@weltraumpflege.org>
---
 net/ipv4/tcp_timer.c | 66 +++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 57 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index debdd8b..bdccd67 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -24,6 +24,13 @@
 
 int sysctl_tcp_thin_linear_timeouts __read_mostly;
 
+/**
+ *   tcp_write_err() - close socket and save error info.
+ *   @sk:  The socket the error has appeared on.
+ *
+ *   Returns: Nothing (void)
+ */
+
 static void tcp_write_err(struct sock *sk)
 {
 	sk->sk_err = sk->sk_err_soft ? : ETIMEDOUT;
@@ -33,7 +40,12 @@ static void tcp_write_err(struct sock *sk)
 	__NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTONTIMEOUT);
 }
 
-/* Do not allow orphaned sockets to eat all our resources.
+/**
+ * tcp_out_of_resources() - Close socket if out of resources
+ * @sk:        pointer to current socket
+ * @do_reset:  send a last packet with reset flag
+ *
+ * Do not allow orphaned sockets to eat all our resources.
  * This is direct violation of TCP specs, but it is required
  * to prevent DoS attacks. It is called when a retransmission timeout
  * or zero probe timeout occurs on orphaned socket.
@@ -74,7 +86,12 @@ static int tcp_out_of_resources(struct sock *sk, bool do_reset)
 	return 0;
 }
 
-/* Calculate maximal number or retries on an orphaned socket. */
+/**
+ * tcp_orphan_retries() - Returns maximal number of retries on an orphaned socket
+ * @sk:    Pointer to the current socket.
+ * @alive: bool, socket alive state
+ *
+ */
 static int tcp_orphan_retries(struct sock *sk, bool alive)
 {
 	int retries = sock_net(sk)->ipv4.sysctl_tcp_orphan_retries; /* May be zero. */
@@ -115,10 +132,22 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 	}
 }
 
-/* This function calculates a "timeout" which is equivalent to the timeout of a
- * TCP connection after "boundary" unsuccessful, exponentially backed-off
+
+/**
+ *  retransmits_timed_out() - returns true if this connection has timed out
+ *  @sk:       The current socket
+ *  @boundary: max number of retransmissions
+ *  @timeout:  A custom timeout value.
+ *             If set to 0 the default timeout is calculated and used.
+ *             Using TCP_RTO_MIN and the number of unsuccessful retransmits.
+ *  @syn_set:  true if the SYN Bit was set.
+ *
+ * The default "timeout" value this function can calculate and use
+ * is equivalent to the timeout of a TCP Connection
+ * after "boundary" unsuccessful, exponentially backed-off
  * retransmissions with an initial RTO of TCP_RTO_MIN or TCP_TIMEOUT_INIT if
  * syn_set flag is set.
+ *
  */
 static bool retransmits_timed_out(struct sock *sk,
 				  unsigned int boundary,
@@ -257,6 +286,16 @@ out:
 		sk_mem_reclaim(sk);
 }
 
+
+/**
+ * tcp_delack_timer() - The TCP delayed ACK timeout handler.
+ * @data:  Pointer to the current socket. (gets casted to struct sock *)
+ *
+ * This function gets (indirectly) called when the kernel timer for a TCP packet
+ * of this socket expires. Calls tcp_delack_timer_handler() to do the actual work.
+ *
+ * Returns: Nothing (void)
+ */
 static void tcp_delack_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
@@ -350,10 +389,18 @@ static void tcp_fastopen_synack_timer(struct sock *sk)
 			  TCP_TIMEOUT_INIT << req->num_timeout, TCP_RTO_MAX);
 }
 
-/*
- *	The TCP retransmit timer.
- */
 
+/**
+ * tcp_retransmit_timer() - The TCP retransmit timout handler.
+ * @sk:  Pointer to the current socket.
+ *
+ * This function gets called when the kernel timer for a TCP packet
+ * of this socket expires.
+ *
+ * It handles retransmission, timer adjustment and other necesarry measures.
+ *
+ * Returns: Nothing (void)
+ */
 void tcp_retransmit_timer(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -494,7 +541,8 @@ out_reset_timer:
 out:;
 }
 
-/* Called with BH disabled */
+/* Called with bottom-half processing disabled.
+   Called by tcp_write_timer() */
 void tcp_write_timer_handler(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -539,7 +587,7 @@ static void tcp_write_timer(unsigned long data)
 	if (!sock_owned_by_user(sk)) {
 		tcp_write_timer_handler(sk);
 	} else {
-		/* deleguate our work to tcp_release_cb() */
+		/* delegate our work to tcp_release_cb() */
 		if (!test_and_set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags))
 			sock_hold(sk);
 	}
-- 
2.8.1
