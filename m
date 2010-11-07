From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 3/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:31:48 -0500
Message-ID: <1289147508.3090.140.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:51434 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753681Ab0KGQbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:31:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

diff -urp linux-2.6.37-rc1.orig/net/ipv4/af_inet.c linux-2.6.37-rc1/net/ipv4/af_inet.c
--- linux-2.6.37-rc1.orig/net/ipv4/af_inet.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/ipv4/af_inet.c	2010-11-07 10:31:41.000000000 -0500
@@ -139,12 +139,13 @@ void inet_sock_destruct(struct sock *sk)
 	sk_mem_reclaim(sk);
 
 	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
-		pr_err("Attempt to release TCP socket in state %d %p\n",
-		       sk->sk_state, sk);
+		pr_err("Attempt to release TCP socket in state %d %lu\n",
+		       sk->sk_state, sock_i_ino(sk));
 		return;
 	}
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		pr_err("Attempt to release alive inet socket %p\n", sk);
+		pr_err("Attempt to release alive inet socket %lu\n",
+			sock_i_ino(sk));
 		return;
 	}
 
diff -urp linux-2.6.37-rc1.orig/net/ipv4/raw.c linux-2.6.37-rc1/net/ipv4/raw.c
--- linux-2.6.37-rc1.orig/net/ipv4/raw.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/ipv4/raw.c	2010-11-07 10:15:44.000000000 -0500
@@ -949,12 +949,12 @@ static void raw_sock_seq_show(struct seq
 	      srcp  = inet->inet_num;
 
 	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %d\n",
 		i, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
-		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
+		atomic_read(&sp->sk_refcnt), 0, atomic_read(&sp->sk_drops));
 }
 
 static int raw_seq_show(struct seq_file *seq, void *v)
diff -urp linux-2.6.37-rc1.orig/net/ipv4/tcp_ipv4.c linux-2.6.37-rc1/net/ipv4/tcp_ipv4.c
--- linux-2.6.37-rc1.orig/net/ipv4/tcp_ipv4.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/ipv4/tcp_ipv4.c	2010-11-07 10:15:21.000000000 -0500
@@ -2389,7 +2389,7 @@ static void get_openreq4(struct sock *sk
 	int ttd = req->expires - jiffies;
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %d%n",
 		i,
 		ireq->loc_addr,
 		ntohs(inet_sk(sk)->inet_sport),
@@ -2404,7 +2404,7 @@ static void get_openreq4(struct sock *sk
 		0,  /* non standard timer */
 		0, /* open_requests have no inode */
 		atomic_read(&sk->sk_refcnt),
-		req,
+		0,
 		len);
 }
 
@@ -2444,7 +2444,7 @@ static void get_tcp4_sock(struct sock *s
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
+			"%08X %5d %8d %lu %d %d %lu %lu %u %u %d%n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2454,7 +2454,7 @@ static void get_tcp4_sock(struct sock *s
 		sock_i_uid(sk),
 		icsk->icsk_probes_out,
 		sock_i_ino(sk),
-		atomic_read(&sk->sk_refcnt), sk,
+		atomic_read(&sk->sk_refcnt), 0,
 		jiffies_to_clock_t(icsk->icsk_rto),
 		jiffies_to_clock_t(icsk->icsk_ack.ato),
 		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
@@ -2479,10 +2479,10 @@ static void get_timewait4_sock(struct in
 	srcp  = ntohs(tw->tw_sport);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %d%n",
 		i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
 		3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
-		atomic_read(&tw->tw_refcnt), tw, len);
+		atomic_read(&tw->tw_refcnt), 0, len);
 }
 
 #define TMPSZ 150
diff -urp linux-2.6.37-rc1.orig/net/ipv4/udp.c linux-2.6.37-rc1/net/ipv4/udp.c
--- linux-2.6.37-rc1.orig/net/ipv4/udp.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/ipv4/udp.c	2010-11-07 10:11:07.000000000 -0500
@@ -2046,12 +2046,12 @@ static void udp4_format_sock(struct sock
 	__u16 srcp	  = ntohs(inet->inet_sport);
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
-		atomic_read(&sp->sk_refcnt), sp,
+		atomic_read(&sp->sk_refcnt), 0,
 		atomic_read(&sp->sk_drops), len);
 }
 



