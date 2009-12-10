From: Eric Paris <eparis@redhat.com>
Subject: [PATCH] net: export the number of times the recv queue was full
Date: Thu, 10 Dec 2009 16:09:20 -0500
Message-ID: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759392AbZLJVJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 16:09:14 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nBAL9LW5017850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 16:09:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We got a request in which a customer was trying to determine how often their
recieve queue was full and thus they were sending a zero window back to the
other side.  By the time they would notice the slowdowns they would have all
empty receive queues and wouldn't know which socket was a problem.  It also
allows them to find the sockets in which they need to up the recv queue size
rather than doing it for all sockets across the box.  This patch exports that
information via /proc/net/tcp.

# cat /proc/net/tcp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
[snip]
  10: D7E70B0A:0016 E4E70B0A:E0BD 01 00000000:00000000 02:000AF288 00000000     0        0 12598 4 ffff88003e4c1e00 20 3 17 5 -1 0
  11: 0100007F:2710 0100007F:B91D 01 00000000:000113DA 02:000AEFA6 00000000     0        0 12592 2 ffff88003e7b2800 20 11 0 2 -1 8

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 Documentation/networking/proc_net_tcp.txt |    4 +++-
 include/linux/tcp.h                       |    3 +++
 net/ipv4/tcp.c                            |    3 +++
 net/ipv4/tcp_ipv4.c                       |    5 ++++-
 net/ipv4/tcp_output.c                     |    4 +++-
 net/ipv6/tcp_ipv6.c                       |   10 +++++++---
 6 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/proc_net_tcp.txt b/Documentation/networking/proc_net_tcp.txt
index 4a79209..03375f4 100644
--- a/Documentation/networking/proc_net_tcp.txt
+++ b/Documentation/networking/proc_net_tcp.txt
@@ -24,7 +24,9 @@ up into 3 parts because of the length of the line):
       |        |----------------------> receive-queue
       |-------------------------------> transmit-queue
 
-   1000        0 54165785 4 cd1e6040 25 4 27 3 -1
+   1000        0 54165785 4 cd1e6040 25 4 27 3 -1 12
+    |          |    |     |    |     |  | |  | |  |--> number of times socket
+    |          |    |     |    |     |  | |  | |       replied with zero window
     |          |    |     |    |     |  | |  | |--> slow start size threshold, 
     |          |    |     |    |     |  | |  |      or -1 if the threshold
     |          |    |     |    |     |  | |  |      is >= 0xFFFF
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7fee8a4..b50627d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -163,6 +163,8 @@ struct tcp_info {
 	__u32	tcpi_rcv_space;
 
 	__u32	tcpi_total_retrans;
+
+	__u32	tcpi_rcv_wnd_zero_cnt;
 };
 
 /* for TCP_MD5SIG socket option */
@@ -376,6 +378,7 @@ struct tcp_sock {
  	u32	rcv_wnd;	/* Current receiver window		*/
 	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
 	u32	pushed_seq;	/* Last pushed seq, required to talk to windows */
+	u32	rcv_wnd_zero_cnt;
 	u32	lost_out;	/* Lost packets			*/
 	u32	sacked_out;	/* SACK'd packets			*/
 	u32	fackets_out;	/* FACK'd packets			*/
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b0a26bb..3fa846e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2061,6 +2061,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	tp->snd_cwnd_cnt = 0;
 	tp->bytes_acked = 0;
 	tp->window_clamp = 0;
+	tp->rcv_wnd_zero_cnt = 0;
 	tcp_set_ca_state(sk, TCP_CA_Open);
 	tcp_clear_retrans(tp);
 	inet_csk_delack_init(sk);
@@ -2432,6 +2433,8 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_rcv_space = tp->rcvq_space.space;
 
 	info->tcpi_total_retrans = tp->total_retrans;
+
+	info->tcpi_rcv_wnd_zero_cnt = tp->rcv_wnd_zero_cnt;
 }
 
 EXPORT_SYMBOL_GPL(tcp_get_info);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 15e9603..d61ecb8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1885,6 +1885,8 @@ static int tcp_v4_init_sock(struct sock *sk)
 	 *	cookie_in_always, cookie_out_never,
 	 *	s_data_constant, s_data_in, s_data_out
 	 */
+	tp->rcv_wnd_zero_cnt = 0;
+
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -2343,7 +2345,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d%n",
+			"%08X %5d %8d %lu %d %p %lu %lu %u %u %d %u%n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2359,6 +2361,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		tp->snd_cwnd,
 		tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh,
+		tp->rcv_wnd_zero_cnt,
 		len);
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 93316a9..337676d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -277,8 +277,10 @@ static u16 tcp_select_window(struct sock *sk)
 	new_win >>= tp->rx_opt.rcv_wscale;
 
 	/* If we advertise zero window, disable fast path. */
-	if (new_win == 0)
+	if (new_win == 0) {
+		tp->rcv_wnd_zero_cnt++;
 		tp->pred_flags = 0;
+	}
 
 	return new_win;
 }
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ee9cf62..8f6c992 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1925,6 +1925,8 @@ static int tcp_v6_init_sock(struct sock *sk)
 	 *	cookie_in_always, cookie_out_never,
 	 *	s_data_constant, s_data_in, s_data_out
 	 */
+	tp->rcv_wnd_zero_cnt = 0;
+
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -2010,8 +2012,9 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	}
 
 	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u %d\n",
+		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X %02X "
+		   "%08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %lu %lu %u %u "
+		   "%d %u\n",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -2031,7 +2034,8 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		   jiffies_to_clock_t(icsk->icsk_ack.ato),
 		   (icsk->icsk_ack.quick << 1 ) | icsk->icsk_ack.pingpong,
 		   tp->snd_cwnd,
-		   tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh
+		   tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh,
+		   tp->rcv_wnd_zero_cnt
 		   );
 }
 

