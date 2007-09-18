From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] return useful listenq info in tcp_info and INET_DIAG_INFO
Date: Tue, 18 Sep 2007 12:54:31 -0700 (PDT)
Message-ID: <200709181954.MAA25525@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=X-roman8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:34770 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526AbXIRTyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 15:54:55 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel12.hp.com (Postfix) with ESMTP id EF88634559
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 12:54:43 -0700 (PDT)
Received: (from raj@localhost)
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) id MAA25525
	for netdev@vger.kernel.org; Tue, 18 Sep 2007 12:54:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return some useful information such as the maximum listen backlog and the
current listen backlog in the tcp_info structure and INET_DIAG_INFO.

Signed-off-by: Rick Jones <rick.jones2@hp.com>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---

diff -r bdcdd0e1ee9d net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	Sat Sep 01 07:00:31 2007 +0000
+++ b/net/ipv4/tcp.c	Tue Sep 18 11:02:26 2007 -0700
@@ -2030,8 +2030,14 @@ void tcp_get_info(struct sock *sk, struc
 	info->tcpi_snd_mss = tp->mss_cache;
 	info->tcpi_rcv_mss = icsk->icsk_ack.rcv_mss;
 
-	info->tcpi_unacked = tp->packets_out;
-	info->tcpi_sacked = tp->sacked_out;
+	if (sk->sk_state == TCP_LISTEN) {
+		info->tcpi_unacked = sk->sk_ack_backlog;
+		info->tcpi_sacked = sk->sk_max_ack_backlog;
+	}
+	else {
+		info->tcpi_unacked = tp->packets_out;
+		info->tcpi_sacked = tp->sacked_out;
+	}
 	info->tcpi_lost = tp->lost_out;
 	info->tcpi_retrans = tp->retrans_out;
 	info->tcpi_fackets = tp->fackets_out;
diff -r bdcdd0e1ee9d net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	Sat Sep 01 07:00:31 2007 +0000
+++ b/net/ipv4/tcp_diag.c	Tue Sep 18 11:02:26 2007 -0700
@@ -25,11 +25,14 @@ static void tcp_diag_get_info(struct soc
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_info *info = _info;
 
-	if (sk->sk_state == TCP_LISTEN)
+	if (sk->sk_state == TCP_LISTEN) {
 		r->idiag_rqueue = sk->sk_ack_backlog;
-	else
+		r->idiag_wqueue = sk->sk_max_ack_backlog;
+	}
+	else {
 		r->idiag_rqueue = tp->rcv_nxt - tp->copied_seq;
-	r->idiag_wqueue = tp->write_seq - tp->snd_una;
+		r->idiag_wqueue = tp->write_seq - tp->snd_una;
+	}
 	if (info != NULL)
 		tcp_get_info(sk, info);
 }
