From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:07:06 -0500
Message-ID: <1289524026.5167.68.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60723 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757206Ab0KLBIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:08:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7e41e2c..53dbdd0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1973,25 +1973,49 @@ static void get_openreq6(struct seq_file *seq,
 	if (ttd < 0)
 		ttd = 0;
 
-	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
-		   i,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3],
-		   ntohs(inet_rsk(req)->loc_port),
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3],
-		   ntohs(inet_rsk(req)->rmt_port),
-		   TCP_SYN_RECV,
-		   0,0, /* could print option size, but that is af dependent. */
-		   1,   /* timers active (only the expire timer) */
-		   jiffies_to_clock_t(ttd),
-		   req->retrans,
-		   uid,
-		   0,  /* non standard timer */
-		   0, /* open_requests have no inode */
-		   0, req);
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(seq,
+			"%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+			"%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
+			i,
+			src->s6_addr32[0], src->s6_addr32[1],
+			src->s6_addr32[2], src->s6_addr32[3],
+			ntohs(inet_rsk(req)->loc_port),
+			dest->s6_addr32[0], dest->s6_addr32[1],
+			dest->s6_addr32[2], dest->s6_addr32[3],
+			ntohs(inet_rsk(req)->rmt_port),
+			TCP_SYN_RECV,
+			0, 0, /* could print option size,
+				 but that is af dependent. */
+			1,    /* timers active (only the expire timer) */
+			jiffies_to_clock_t(ttd),
+			req->retrans,
+			uid,
+			0,  /* non standard timer */
+			0, /* open_requests have no inode */
+			0, req);
+	else
+		seq_printf(seq,
+			"%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+			"%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %d\n",
+			i,
+			src->s6_addr32[0], src->s6_addr32[1],
+			src->s6_addr32[2], src->s6_addr32[3],
+			ntohs(inet_rsk(req)->loc_port),
+			dest->s6_addr32[0], dest->s6_addr32[1],
+			dest->s6_addr32[2], dest->s6_addr32[3],
+			ntohs(inet_rsk(req)->rmt_port),
+			TCP_SYN_RECV,
+			0, 0, /* could print option size,
+				 but that is af dependent. */
+			1,    /* timers active (only the expire timer) */
+			jiffies_to_clock_t(ttd),
+			req->retrans,
+			uid,
+			0,  /* non standard timer */
+			0, /* open_requests have no inode */
+			0, 0);
 }
 
 static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
@@ -2024,30 +2048,57 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		timer_expires = jiffies;
 	}
 
-	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u %d\n",
-		   i,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3], srcp,
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
-		   sp->sk_state,
-		   tp->write_seq-tp->snd_una,
-		   (sp->sk_state == TCP_LISTEN) ? sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
-		   timer_active,
-		   jiffies_to_clock_t(timer_expires - jiffies),
-		   icsk->icsk_retransmits,
-		   sock_i_uid(sp),
-		   icsk->icsk_probes_out,
-		   sock_i_ino(sp),
-		   atomic_read(&sp->sk_refcnt), sp,
-		   jiffies_to_clock_t(icsk->icsk_rto),
-		   jiffies_to_clock_t(icsk->icsk_ack.ato),
-		   (icsk->icsk_ack.quick << 1 ) | icsk->icsk_ack.pingpong,
-		   tp->snd_cwnd,
-		   tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh
-		   );
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(seq,
+			"%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+			"%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u %d\n",
+			i,
+			src->s6_addr32[0], src->s6_addr32[1],
+			src->s6_addr32[2], src->s6_addr32[3], srcp,
+			dest->s6_addr32[0], dest->s6_addr32[1],
+			dest->s6_addr32[2], dest->s6_addr32[3], destp,
+			sp->sk_state,
+			tp->write_seq-tp->snd_una,
+			(sp->sk_state == TCP_LISTEN) ?
+			sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
+			timer_active,
+			jiffies_to_clock_t(timer_expires - jiffies),
+			icsk->icsk_retransmits,
+			sock_i_uid(sp),
+			icsk->icsk_probes_out,
+			sock_i_ino(sp),
+			atomic_read(&sp->sk_refcnt), sp,
+			jiffies_to_clock_t(icsk->icsk_rto),
+			jiffies_to_clock_t(icsk->icsk_ack.ato),
+			(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
+			tp->snd_cwnd,
+			tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh);
+	else
+		seq_printf(seq,
+			"%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+			"%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %d %lu %lu %u %u %d\n",
+			i,
+			src->s6_addr32[0], src->s6_addr32[1],
+			src->s6_addr32[2], src->s6_addr32[3], srcp,
+			dest->s6_addr32[0], dest->s6_addr32[1],
+			dest->s6_addr32[2], dest->s6_addr32[3], destp,
+			sp->sk_state,
+			tp->write_seq-tp->snd_una,
+			(sp->sk_state == TCP_LISTEN) ?
+			sp->sk_ack_backlog : (tp->rcv_nxt - tp->copied_seq),
+			timer_active,
+			jiffies_to_clock_t(timer_expires - jiffies),
+			icsk->icsk_retransmits,
+			sock_i_uid(sp),
+			icsk->icsk_probes_out,
+			sock_i_ino(sp),
+			atomic_read(&sp->sk_refcnt), 0,
+			jiffies_to_clock_t(icsk->icsk_rto),
+			jiffies_to_clock_t(icsk->icsk_ack.ato),
+			(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
+			tp->snd_cwnd,
+			tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh);
 }
 
 static void get_timewait6_sock(struct seq_file *seq,
@@ -2066,17 +2117,31 @@ static void get_timewait6_sock(struct seq_file *seq,
 	destp = ntohs(tw->tw_dport);
 	srcp  = ntohs(tw->tw_sport);
 
-	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
-		   i,
-		   src->s6_addr32[0], src->s6_addr32[1],
-		   src->s6_addr32[2], src->s6_addr32[3], srcp,
-		   dest->s6_addr32[0], dest->s6_addr32[1],
-		   dest->s6_addr32[2], dest->s6_addr32[3], destp,
-		   tw->tw_substate, 0, 0,
-		   3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
-		   atomic_read(&tw->tw_refcnt), tw);
+	/* Only expose kernel addresses to privileged readers */
+	if (capable(CAP_NET_ADMIN))
+		seq_printf(seq,
+			"%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+			"%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %p\n",
+			i,
+			src->s6_addr32[0], src->s6_addr32[1],
+			src->s6_addr32[2], src->s6_addr32[3], srcp,
+			dest->s6_addr32[0], dest->s6_addr32[1],
+			dest->s6_addr32[2], dest->s6_addr32[3], destp,
+			tw->tw_substate, 0, 0,
+			3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
+			atomic_read(&tw->tw_refcnt), tw);
+	else
+		seq_printf(seq,
+			"%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
+			"%02X %08X:%08X %02X:%08lX %08X %5d %8d %d %d %d\n",
+			i,
+			src->s6_addr32[0], src->s6_addr32[1],
+			src->s6_addr32[2], src->s6_addr32[3], srcp,
+			dest->s6_addr32[0], dest->s6_addr32[1],
+			dest->s6_addr32[2], dest->s6_addr32[3], destp,
+			tw->tw_substate, 0, 0,
+			3, jiffies_to_clock_t(ttd), 0, 0, 0, 0,
+			atomic_read(&tw->tw_refcnt), 0);
 }
 
 static int tcp6_seq_show(struct seq_file *seq, void *v)



