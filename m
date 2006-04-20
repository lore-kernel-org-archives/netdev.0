From: Andrew Grover <andrew.grover@intel.com>
Subject: [PATCH 7/10] [IOAT] cleanup_rbuf -> tcp_cleanup_rbuf and make static
Date: Thu, 20 Apr 2006 13:50:25 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0604201340080.22544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:1169 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751275AbWDTUuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 16:50:25 -0400
Received: from orsfmr100.jf.intel.com (orsfmr100.jf.intel.com [10.7.209.16])
	by orsfmr003.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k3KKoPS4000307
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:50:25 GMT
Received: from nwlxmail01.jf.intel.com (nwlxmail01.jf.intel.com [10.7.171.40])
	by orsfmr100.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k3KKoP2u016115
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:50:25 GMT
Received: from isotope.jf.intel.com (isotope.jf.intel.com [10.23.35.8])
	by nwlxmail01.jf.intel.com (8.12.10/8.12.9/MailSET/Hub) with ESMTP id k3KKoPhF021541
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 13:50:25 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Needed to be able to call tcp_cleanup_rbuf in tcp_input.c for I/OAT

Signed-off-by: Chris Leech <christopher.leech@intel.com>

---

 include/net/tcp.h |    2 ++
 net/ipv4/tcp.c    |   10 +++++-----

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 54e4367..ca5bdaf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -294,6 +294,8 @@ extern int			tcp_rcv_established(struct 
 
 extern void			tcp_rcv_space_adjust(struct sock *sk);
 
+extern void			tcp_cleanup_rbuf(struct sock *sk, int copied);
+
 extern int			tcp_twsk_unique(struct sock *sk,
 						struct sock *sktw, void *twp);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 87f68e7..b10f78c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -937,7 +937,7 @@ static int tcp_recv_urg(struct sock *sk,
  * calculation of whether or not we must ACK for the sake of
  * a window update.
  */
-static void cleanup_rbuf(struct sock *sk, int copied)
+void tcp_cleanup_rbuf(struct sock *sk, int copied)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int time_to_ack = 0;
@@ -1086,7 +1086,7 @@ int tcp_read_sock(struct sock *sk, read_
 
 	/* Clean up data we have read: This will do ACK frames. */
 	if (copied)
-		cleanup_rbuf(sk, copied);
+		tcp_cleanup_rbuf(sk, copied);
 	return copied;
 }
 
@@ -1220,7 +1220,7 @@ int tcp_recvmsg(struct kiocb *iocb, stru
 			}
 		}
 
-		cleanup_rbuf(sk, copied);
+		tcp_cleanup_rbuf(sk, copied);
 
 		if (!sysctl_tcp_low_latency && tp->ucopy.task == user_recv) {
 			/* Install new reader */
@@ -1391,7 +1391,7 @@ skip_copy:
 	 */
 
 	/* Clean up data we have read: This will do ACK frames. */
-	cleanup_rbuf(sk, copied);
+	tcp_cleanup_rbuf(sk, copied);
 
 	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
@@ -1853,7 +1853,7 @@ static int do_tcp_setsockopt(struct sock
 			    (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT) &&
 			    inet_csk_ack_scheduled(sk)) {
 				icsk->icsk_ack.pending |= ICSK_ACK_PUSHED;
-				cleanup_rbuf(sk, 1);
+				tcp_cleanup_rbuf(sk, 1);
 				if (!(val & 1))
 					icsk->icsk_ack.pingpong = 1;
 			}
-- 
1.2.6



