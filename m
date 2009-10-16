From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 4/4 v2] net: Fix for dst_negative_advice
Date: Fri, 16 Oct 2009 12:52:02 +0530
Message-ID: <20091016072202.24384.11010.sendpatchset@localhost.localdomain>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:44845 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756590AbZJPHWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 03:22:55 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9G7J81n018413
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:19:08 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9G7JSnF1532078
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:19:28 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9G7M626010749
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:22:07 +1100
In-Reply-To: <20091016072107.24384.17358.sendpatchset@localhost.localdomain>
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
--- org/include/net/dst.h	2009-10-16 11:59:20.000000000 +0530
+++ new/include/net/dst.h	2009-10-16 12:01:03.000000000 +0530
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
--- org/net/core/sock.c	2009-10-16 11:59:20.000000000 +0530
+++ new/net/core/sock.c	2009-10-16 12:01:03.000000000 +0530
@@ -352,6 +352,12 @@ discard_and_relse:
 }
 EXPORT_SYMBOL(sk_receive_skb);
 
+void sk_reset_txq(struct sock *sk)
+{
+	sk_record_tx_queue(sk, -1);
+}
+EXPORT_SYMBOL(sk_reset_txq);
+
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = sk->sk_dst_cache;
diff -ruNp org/net/dccp/timer.c new/net/dccp/timer.c
--- org/net/dccp/timer.c	2009-10-16 11:59:20.000000000 +0530
+++ new/net/dccp/timer.c	2009-10-16 12:01:03.000000000 +0530
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
--- org/net/decnet/af_decnet.c	2009-10-16 11:59:20.000000000 +0530
+++ new/net/decnet/af_decnet.c	2009-10-16 12:01:03.000000000 +0530
@@ -1955,7 +1955,7 @@ static int dn_sendmsg(struct kiocb *iocb
 	}
 
 	if ((flags & MSG_TRYHARD) && sk->sk_dst_cache)
-		dst_negative_advice(&sk->sk_dst_cache);
+		dst_negative_advice(&sk->sk_dst_cache, sk);
 
 	mss = scp->segsize_rem;
 	fctype = scp->services_rem & NSP_FC_MASK;
diff -ruNp org/net/ipv4/tcp_timer.c new/net/ipv4/tcp_timer.c
--- org/net/ipv4/tcp_timer.c	2009-10-16 11:59:20.000000000 +0530
+++ new/net/ipv4/tcp_timer.c	2009-10-16 12:01:03.000000000 +0530
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
