From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 3/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:07:03 -0500
Message-ID: <1289524023.5167.67.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60691 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755614Ab0KLBIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:08:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 1f85ef2..0ac8ff2 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -948,13 +948,26 @@ static void raw_sock_seq_show(struct seq_file *seq, struct sock *sp, int i)
 	__u16 destp = 0,
 	      srcp  = inet->inet_num;
 
-	seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
-		i, src, srcp, dest, destp, sp->sk_state,
-		sk_wmem_alloc_get(sp),
-		sk_rmem_alloc_get(sp),
-		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
-		atomic_read(&sp->sk_refcnt), sp, atomic_read(&sp->sk_drops));
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
+			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d\n",
+			i, src, srcp, dest, destp, sp->sk_state,
+			sk_wmem_alloc_get(sp),
+			sk_rmem_alloc_get(sp),
+			0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
+			atomic_read(&sp->sk_refcnt),
+			sp, atomic_read(&sp->sk_drops));
+	else
+		seq_printf(seq, "%4d: %08X:%04X %08X:%04X"
+			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %d\n",
+			i, src, srcp, dest, destp, sp->sk_state,
+			sk_wmem_alloc_get(sp),
+			sk_rmem_alloc_get(sp),
+			0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
+			atomic_read(&sp->sk_refcnt),
+			0, atomic_read(&sp->sk_drops));
+
 }
 
 static int raw_seq_show(struct seq_file *seq, void *v)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8f8527d..a37eeb4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2388,24 +2388,47 @@ static void get_openreq4(struct sock *sk, struct request_sock *req,
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	int ttd = req->expires - jiffies;
 
-	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p%n",
-		i,
-		ireq->loc_addr,
-		ntohs(inet_sk(sk)->inet_sport),
-		ireq->rmt_addr,
-		ntohs(ireq->rmt_port),
-		TCP_SYN_RECV,
-		0, 0, /* could print option size, but that is af dependent. */
-		1,    /* timers active (only the expire timer) */
-		jiffies_to_clock_t(ttd),
-		req->retrans,
-		uid,
-		0,  /* non standard timer */
-		0, /* open_requests have no inode */
-		atomic_read(&sk->sk_refcnt),
-		req,
-		len);
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(f, "%4d: %08X:%04X %08X:%04X"
+			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %p%n",
+			i,
+			ireq->loc_addr,
+			ntohs(inet_sk(sk)->inet_sport),
+			ireq->rmt_addr,
+			ntohs(ireq->rmt_port),
+			TCP_SYN_RECV,
+			0, 0, /* could print option size,
+				 but that is af dependent. */
+			1,    /* timers active (only the expire timer) */
+			jiffies_to_clock_t(ttd),
+			req->retrans,
+			uid,
+			0,  /* non standard timer */
+			0, /* open_requests have no inode */
+			atomic_read(&sk->sk_refcnt),
+			req,
+			len);
+	else
+		seq_printf(f, "%4d: %08X:%04X %08X:%04X"
+			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %u %d %d%n",
+			i,
+			ireq->loc_addr,
+			ntohs(inet_sk(sk)->inet_sport),
+			ireq->rmt_addr,
+			ntohs(ireq->rmt_port),
+			TCP_SYN_RECV,
+			0, 0, /* could print option size,
+				 but that is af dependent. */
+			1,    /* timers active (only the expire timer) */
+			jiffies_to_clock_t(ttd),
+			req->retrans,
+			uid,
+			0,  /* non standard timer */
+			0, /* open_requests have no inode */
+			atomic_read(&sk->sk_refcnt),
+			0,
+			len);
 }
 
 static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
@@ -2443,24 +2466,46 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		 */
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
-	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
-		i, src, srcp, dest, destp, sk->sk_state,
-		tp->write_seq - tp->snd_una,
-		rx_queue,
-		timer_active,
-		jiffies_to_clock_t(timer_expires - jiffies),
-		icsk->icsk_retransmits,
-		sock_i_uid(sk),
-		icsk->icsk_probes_out,
-		sock_i_ino(sk),
-		atomic_read(&sk->sk_refcnt), sk,
-		jiffies_to_clock_t(icsk->icsk_rto),
-		jiffies_to_clock_t(icsk->icsk_ack.ato),
-		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
-		tp->snd_cwnd,
-		tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh,
-		len);
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X "
+			"%02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
+			i, src, srcp, dest, destp, sk->sk_state,
+			tp->write_seq - tp->snd_una,
+			rx_queue,
+			timer_active,
+			jiffies_to_clock_t(timer_expires - jiffies),
+			icsk->icsk_retransmits,
+			sock_i_uid(sk),
+			icsk->icsk_probes_out,
+			sock_i_ino(sk),
+			atomic_read(&sk->sk_refcnt), sk,
+			jiffies_to_clock_t(icsk->icsk_rto),
+			jiffies_to_clock_t(icsk->icsk_ack.ato),
+			(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
+			tp->snd_cwnd,
+			tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh,
+			len);
+	else
+		seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X "
+			"%02X:%08lX %08X %5d %8d %lu %d %d %lu %lu %u %u %d%n",
+			i, src, srcp, dest, destp, sk->sk_state,
+			tp->write_seq - tp->snd_una,
+			rx_queue,
+			timer_active,
+			jiffies_to_clock_t(timer_expires - jiffies),
+			icsk->icsk_retransmits,
+			sock_i_uid(sk),
+			icsk->icsk_probes_out,
+			sock_i_ino(sk),
+			atomic_read(&sk->sk_refcnt), 0,
+			jiffies_to_clock_t(icsk->icsk_rto),
+			jiffies_to_clock_t(icsk->icsk_ack.ato),
+			(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
+			tp->snd_cwnd,
+			tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh,
+			len);
+
 }
 
 static void get_timewait4_sock(struct inet_timewait_sock *tw,
@@ -2478,11 +2523,20 @@ static void get_timewait4_sock(struct inet_timewait_sock *tw,
 	destp = ntohs(tw->tw_dport);
 	srcp  = ntohs(tw->tw_sport);
 
-	seq_printf(f, "%4d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p%n",
-		i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
-		3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
-		atomic_read(&tw->tw_refcnt), tw, len);
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(f, "%4d: %08X:%04X %08X:%04X"
+			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p%n",
+			i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
+			3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
+			atomic_read(&tw->tw_refcnt), tw, len);
+	else
+		seq_printf(f, "%4d: %08X:%04X %08X:%04X"
+			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %d%n",
+			i, src, srcp, dest, destp, tw->tw_substate, 0, 0,
+			3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
+			atomic_read(&tw->tw_refcnt), 0, len);
+
 }
 
 #define TMPSZ 150
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 28cb2d7..41c391d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2045,14 +2045,26 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 	__u16 destp	  = ntohs(inet->inet_dport);
 	__u16 srcp	  = ntohs(inet->inet_sport);
 
-	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
-		bucket, src, srcp, dest, destp, sp->sk_state,
-		sk_wmem_alloc_get(sp),
-		sk_rmem_alloc_get(sp),
-		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
-		atomic_read(&sp->sk_refcnt), sp,
-		atomic_read(&sp->sk_drops), len);
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(f, "%5d: %08X:%04X %08X:%04X"
+			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
+			bucket, src, srcp, dest, destp, sp->sk_state,
+			sk_wmem_alloc_get(sp),
+			sk_rmem_alloc_get(sp),
+			0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
+			atomic_read(&sp->sk_refcnt), sp,
+			atomic_read(&sp->sk_drops), len);
+	else
+		seq_printf(f, "%5d: %08X:%04X %08X:%04X"
+			" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %d%n",
+			bucket, src, srcp, dest, destp, sp->sk_state,
+			sk_wmem_alloc_get(sp),
+			sk_rmem_alloc_get(sp),
+			0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
+			atomic_read(&sp->sk_refcnt), 0,
+			atomic_read(&sp->sk_drops), len);
+
 }
 
 int udp4_seq_show(struct seq_file *seq, void *v)



