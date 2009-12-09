From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/3] tcp: Remove check in __tcp_push_pending_frames
Date: Wed, 09 Dec 2009 13:56:13 +0530
Message-ID: <20091209082613.19055.58864.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:47916 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbZLII0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 03:26:09 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id nB981lrt009912
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 13:31:48 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB98QEMi2269350
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 13:56:15 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB98QE8p004200
	for <netdev@vger.kernel.org>; Wed, 9 Dec 2009 19:26:14 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

tcp_push checks tcp_send_head and calls __tcp_push_pending_frames,
which again checks tcp_send_head, and this unnecessary check is
done for every other caller of __tcp_push_pending_frames.

Remove tcp_send_head check in __tcp_push_pending_frames and add
the check to tcp_push_pending_frames. Other functions call
__tcp_push_pending_frames only when tcp_send_head would evaluate
to true.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/net/tcp.h     |   16 +++++++++-------
 net/ipv4/tcp_output.c |    5 -----
 2 files changed, 9 insertions(+), 12 deletions(-)

diff -ruNp org/include/net/tcp.h new/include/net/tcp.h
--- org/include/net/tcp.h	2009-12-04 18:15:26.000000000 +0530
+++ new/include/net/tcp.h	2009-12-09 09:57:39.000000000 +0530
@@ -857,13 +857,6 @@ static inline void tcp_check_probe_timer
 					  icsk->icsk_rto, TCP_RTO_MAX);
 }
 
-static inline void tcp_push_pending_frames(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	__tcp_push_pending_frames(sk, tcp_current_mss(sk), tp->nonagle);
-}
-
 static inline void tcp_init_wl(struct tcp_sock *tp, u32 seq)
 {
 	tp->snd_wl1 = seq;
@@ -1366,6 +1359,15 @@ static inline int tcp_write_queue_empty(
 	return skb_queue_empty(&sk->sk_write_queue);
 }
 
+static inline void tcp_push_pending_frames(struct sock *sk)
+{
+	if (tcp_send_head(sk)) {
+		struct tcp_sock *tp = tcp_sk(sk);
+
+		__tcp_push_pending_frames(sk, tcp_current_mss(sk), tp->nonagle);
+	}
+}
+
 /* Start sequence of the highest skb with SACKed bit, valid only if
  * sacked > 0 or when the caller has ensured validity by itself.
  */
diff -ruNp org/net/ipv4/tcp_output.c new/net/ipv4/tcp_output.c
--- org/net/ipv4/tcp_output.c	2009-12-04 18:16:00.000000000 +0530
+++ new/net/ipv4/tcp_output.c	2009-12-04 18:16:24.000000000 +0530
@@ -1799,11 +1799,6 @@ static int tcp_write_xmit(struct sock *s
 void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 			       int nonagle)
 {
-	struct sk_buff *skb = tcp_send_head(sk);
-
-	if (!skb)
-		return;
-
 	/* If we are closed, the bytes will have to remain here.
 	 * In time closedown will finish, we empty the write queue and
 	 * all will be happy.
