From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 4/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:31:52 -0500
Message-ID: <1289147512.3090.141.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:54894 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529Ab0KGQco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:32:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

diff -urp linux-2.6.37-rc1.orig/net/ipv6/raw.c linux-2.6.37-rc1/net/ipv6/raw.c
--- linux-2.6.37-rc1.orig/net/ipv6/raw.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/ipv6/raw.c	2010-11-07 10:18:08.000000000 -0500
@@ -1231,7 +1231,7 @@ static void raw6_sock_seq_show(struct se
 	srcp  = inet_sk(sp)->inet_num;
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -1243,7 +1243,7 @@ static void raw6_sock_seq_show(struct se
 		   0, 0L, 0,
 		   sock_i_uid(sp), 0,
 		   sock_i_ino(sp),
-		   atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
+		   atomic_read(&sp->sk_refcnt), 0, atomic_read(&sp->sk_drops));
 }
 
 static int raw6_seq_show(struct seq_file *seq, void *v)
diff -urp linux-2.6.37-rc1.orig/net/ipv6/tcp_ipv6.c linux-2.6.37-rc1/net/ipv6/tcp_ipv6.c
--- linux-2.6.37-rc1.orig/net/ipv6/tcp_ipv6.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/ipv6/tcp_ipv6.c	2010-11-07 10:17:51.000000000 -0500
@@ -1975,7 +1975,7 @@ static void get_openreq6(struct seq_file
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3],
@@ -1991,7 +1991,7 @@ static void get_openreq6(struct seq_file
 		   uid,
 		   0,  /* non standard timer */
 		   0, /* open_requests have no inode */
-		   0, req);
+		   0, 0);
 }
 
 static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
@@ -2026,7 +2026,7 @@ static void get_tcp6_sock(struct seq_fil
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %lu %lu %u %u %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -2041,7 +2041,7 @@ static void get_tcp6_sock(struct seq_fil
 		   sock_i_uid(sp),
 		   icsk->icsk_probes_out,
 		   sock_i_ino(sp),
-		   atomic_read(&sp->sk_refcnt), sp,
+		   atomic_read(&sp->sk_refcnt), 0,
 		   jiffies_to_clock_t(icsk->icsk_rto),
 		   jiffies_to_clock_t(icsk->icsk_ack.ato),
 		   (icsk->icsk_ack.quick << 1 ) | icsk->icsk_ack.pingpong,
@@ -2068,7 +2068,7 @@ static void get_timewait6_sock(struct se
 
 	seq_printf(seq,
 		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %d\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -2076,7 +2076,7 @@ static void get_timewait6_sock(struct se
 		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
 		   tw->tw_substate, 0, 0,
 		   3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
-		   atomic_read(&tw->tw_refcnt), tw);
+		   atomic_read(&tw->tw_refcnt), 0);
 }
 
 static int tcp6_seq_show(struct seq_file *seq, void *v)
diff -urp linux-2.6.37-rc1.orig/net/ipv6/udp.c linux-2.6.37-rc1/net/ipv6/udp.c
--- linux-2.6.37-rc1.orig/net/ipv6/udp.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/ipv6/udp.c	2010-11-07 10:16:57.000000000 -0500
@@ -1395,7 +1395,7 @@ static void udp6_sock_seq_show(struct se
 	srcp  = ntohs(inet->inet_sport);
 	seq_printf(seq,
 		   "%5d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %d\n",
 		   bucket,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -1407,7 +1407,7 @@ static void udp6_sock_seq_show(struct se
 		   0, 0L, 0,
 		   sock_i_uid(sp), 0,
 		   sock_i_ino(sp),
-		   atomic_read(&sp->sk_refcnt), sp,
+		   atomic_read(&sp->sk_refcnt), 0,
 		   atomic_read(&sp->sk_drops));
 }



