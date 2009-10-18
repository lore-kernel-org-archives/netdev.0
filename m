From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 4/4 v3] net: Fix for dst_negative_advice
Date: Sun, 18 Oct 2009 18:38:16 +0530
Message-ID: <20091018130816.3960.87384.sendpatchset@localhost.localdomain>
References: <20091018130727.3960.32107.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([59.145.155.9]:60292 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbZJRNIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 09:08:18 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9ICunNe004929
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:26:49 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9ID8J9V2392276
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:38:19 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9ID8IsB024749
	for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 18:38:19 +0530
In-Reply-To: <20091018130727.3960.32107.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

dst_negative_advice() should check for changed dst and reset
sk_tx_queue_mapping accordingly. Pass sock to the callers of
dst_negative_advice.

(sk_reset_txq is defined just for use by dst_negative_advice. The
only way I could find to get around this is to move dst_negative_()
from dst.h to dst.c, include sock.h in dst.c, etc)

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/net/dst.h      |   12 ++++++++++--
 net/core/sock.c        |    6 ++++++
 net/dccp/timer.c       |    4 ++--
 net/decnet/af_decnet.c |    2 +-
 net/ipv4/tcp_timer.c   |    4 ++--
 5 files changed, 21 insertions(+), 7 deletions(-)

diff -ruNp org/include/net/dst.h new/include/net/dst.h
--- org/include/net/dst.h	2009-10-16 21:30:56.000000000 +0530
+++ new/include/net/dst.h	2009-10-16 21:31:30.000000000 +0530
@@ -222,11 +222,19 @@ static inline void dst_confirm(struct ds
 		neigh_confirm(dst->neighbour);
 }
 
-static inline void dst_negative_advice(struct dst_entry **dst_p)
+static inline void dst_negative_advice(struct dst_entry **dst_p,
+				       struct sock *sk)
 {
 	struct dst_entry * dst = *dst_p;
-	if (dst && dst->ops->negative_advice)
+	if (dst && dst->ops->negative_advice) {
 		*dst_p = dst->ops->negative_advice(dst);
+
+		if (dst != *dst_p) {
+			extern void sk_reset_txq(struct sock *sk);
+
+			sk_reset_txq(sk);
+		}
+	}
 }
 
 static inline void dst_link_failure(struct sk_buff *skb)
diff -ruNp org/net/core/sock.c new/net/core/sock.c
--- org/net/core/sock.c	2009-10-16 21:30:56.000000000 +0530
+++ new/net/core/sock.c	2009-10-16 21:32:33.000000000 +0530
@@ -352,6 +352,12 @@ discard_and_relse:
 }
 EXPORT_SYMBOL(sk_receive_skb);
 
+void sk_reset_txq(struct sock *sk)
+{
+	sk_tx_queue_clear(sk);
+}
+EXPORT_SYMBOL(sk_reset_txq);
+
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = sk->sk_dst_cache;
diff -ruNp org/net/dccp/timer.c new/net/dccp/timer.c
--- org/net/dccp/timer.c	2009-10-16 21:30:56.000000000 +0530
+++ new/net/dccp/timer.c	2009-10-16 21:31:30.000000000 +0530
@@ -38,7 +38,7 @@ static int dccp_write_timeout(struct soc
 
 	if (sk->sk_state == DCCP_REQUESTING || sk->sk_state == DCCP_PARTOPEN) {
 		if (icsk->icsk_retransmits != 0)
-			dst_negative_advice(&sk->sk_dst_cache);
+			dst_negative_advice(&sk->sk_dst_cache, sk);
 		retry_until = icsk->icsk_syn_retries ?
 			    : sysctl_dccp_request_retries;
 	} else {
@@ -63,7 +63,7 @@ static int dccp_write_timeout(struct soc
 			   Golden words :-).
 		   */
 
-			dst_negative_advice(&sk->sk_dst_cache);
+			dst_negative_advice(&sk->sk_dst_cache, sk);
 		}
 
 		retry_until = sysctl_dccp_retries2;
diff -ruNp org/net/decnet/af_decnet.c new/net/decnet/af_decnet.c
--- org/net/decnet/af_decnet.c	2009-10-16 21:30:56.000000000 +0530
+++ new/net/decnet/af_decnet.c	2009-10-16 21:31:30.000000000 +0530
@@ -1955,7 +1955,7 @@ static int dn_sendmsg(struct kiocb *iocb
 	}
 
 	if ((flags & MSG_TRYHARD) && sk->sk_dst_cache)
-		dst_negative_advice(&sk->sk_dst_cache);
+		dst_negative_advice(&sk->sk_dst_cache, sk);
 
 	mss = scp->segsize_rem;
 	fctype = scp->services_rem & NSP_FC_MASK;
diff -ruNp org/net/ipv4/tcp_timer.c new/net/ipv4/tcp_timer.c
--- org/net/ipv4/tcp_timer.c	2009-10-16 21:30:56.000000000 +0530
+++ new/net/ipv4/tcp_timer.c	2009-10-16 21:31:30.000000000 +0530
@@ -141,14 +141,14 @@ static int tcp_write_timeout(struct sock
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits)
-			dst_negative_advice(&sk->sk_dst_cache);
+			dst_negative_advice(&sk->sk_dst_cache, sk);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
 		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
-			dst_negative_advice(&sk->sk_dst_cache);
+			dst_negative_advice(&sk->sk_dst_cache, sk);
 		}
 
 		retry_until = sysctl_tcp_retries2;
