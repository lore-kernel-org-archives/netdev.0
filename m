From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] include listenq max/backlog in tcp_info and related reports
Date: Tue, 11 Sep 2007 11:31:00 -0700 (PDT)
Message-ID: <200709111831.LAA06892@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=X-roman8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:54257 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761766AbXIKSbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 14:31:12 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel10.hp.com (Postfix) with ESMTP id C1C513416C
	for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 11:31:01 -0700 (PDT)
Received: (from raj@localhost)
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) id LAA06892
	for netdev@vger.kernel.org; Tue, 11 Sep 2007 11:31:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return some useful information such as the maximum listen backlog and
the current listen backlog in the tcp_info structure and have that 
match what one can see in /proc/net/tcp and /proc/net/tcp6.

Signed-off-by: Rick Jones <rick.jones2@hp.com>
---

diff -r bdcdd0e1ee9d Documentation/networking/proc_net_tcp.txt
--- a/Documentation/networking/proc_net_tcp.txt	Sat Sep 01 07:00:31 2007 +0000
+++ b/Documentation/networking/proc_net_tcp.txt	Mon Sep 10 16:09:46 2007 -0700
@@ -20,8 +20,8 @@ up into 3 parts because of the length of
       |        |     |     |       |--> number of unrecovered RTO timeouts
       |        |     |     |----------> number of jiffies until timer expires
       |        |     |----------------> timer_active (see below)
-      |        |----------------------> receive-queue
-      |-------------------------------> transmit-queue
+      |        |----------------------> receive-queue or connection backlog
+      |-------------------------------> transmit-queue or connection limit
 
    1000        0 54165785 4 cd1e6040 25 4 27 3 -1
     |          |    |     |    |     |  | |  | |--> slow start size threshold, 
diff -r bdcdd0e1ee9d net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	Sat Sep 01 07:00:31 2007 +0000
+++ b/net/ipv4/tcp.c	Mon Sep 10 16:09:46 2007 -0700
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
diff -r bdcdd0e1ee9d net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	Sat Sep 01 07:00:31 2007 +0000
+++ b/net/ipv4/tcp_ipv4.c	Mon Sep 10 16:09:46 2007 -0700
@@ -2320,7 +2320,8 @@ static void get_tcp4_sock(struct sock *s
 	sprintf(tmpbuf, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
 			"%08X %5d %8d %lu %d %p %u %u %u %u %d",
 		i, src, srcp, dest, destp, sk->sk_state,
-		tp->write_seq - tp->snd_una,
+		sk->sk_state == TCP_LISTEN ? sk->sk_max_ack_backlog :
+					     (tp->write_seq - tp->snd_una),
 		sk->sk_state == TCP_LISTEN ? sk->sk_ack_backlog :
 					     (tp->rcv_nxt - tp->copied_seq),
 		timer_active,
diff -r bdcdd0e1ee9d net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	Sat Sep 01 07:00:31 2007 +0000
+++ b/net/ipv6/tcp_ipv6.c	Mon Sep 10 16:09:46 2007 -0700
@@ -2005,8 +2005,10 @@ static void get_tcp6_sock(struct seq_fil
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
 		   sp->sk_state,
-		   tp->write_seq-tp->snd_una,
-		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
+		   (sp->sk_state == TCP_LISTEN) ? sp->sk_max_ack_backlog:
+						  tp->write_seq-tp->snd_una,
+		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : 
+					(tp->rcv_nxt - tp->copied_seq),
 		   timer_active,
 		   jiffies_to_clock_t(timer_expires - jiffies),
 		   icsk->icsk_retransmits,
