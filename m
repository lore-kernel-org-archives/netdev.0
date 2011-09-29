From: Muraliraja Muniraju <muralira@google.com>
Subject: [PATCH] net-proc: expose the tos values in /proc/net/[tcp|udp]
Date: Thu, 29 Sep 2011 12:22:42 -0700
Message-ID: <1317324162-21621-1-git-send-email-muralira@google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Murali Raja <muralira@google.com>
To: "David S. Miller\"" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <ka
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Raja <muralira@google.com>

This patch exports the tos values from the inet_sock struct
for tcp and udp into the /proc/net/tcp or /proc/net/udp respectively.
This will not pickup per packet tos changes but it will address most
of the cases. This is mainly useful as it would decrease reliance on
tcpdump and also people without root access will be able to read
the values.

Signed-off-by: Murali Raja <muralira@google.com>
---
 net/ipv4/tcp_ipv4.c |    7 +++++--
 net/ipv4/udp.c      |    5 +++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index dd3fad9..b036184 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2416,6 +2416,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 	__u16 destp = ntohs(inet->inet_dport);
 	__u16 srcp = ntohs(inet->inet_sport);
 	int rx_queue;
+	unsigned int tos;
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
 		timer_active	= 1;
@@ -2439,8 +2440,10 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		 */
 		rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 
+	tos = inet->tos;
+
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5d %8d %lu %d %pK %lu %lu %u %u %d%n",
+			"%08X %5d %8d %lu %d %pK %lu %lu %u %u %d %u%n",
 		i, src, srcp, dest, destp, sk->sk_state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2455,7 +2458,7 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i, int *len)
 		jiffies_to_clock_t(icsk->icsk_ack.ato),
 		(icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		tp->snd_cwnd,
-		tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh,
+		tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh, tos,
 		len);
 }
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ebaa96b..588786e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2092,15 +2092,16 @@ static void udp4_format_sock(struct sock *sp, struct seq_file *f,
 	__be32 src  = inet->inet_rcv_saddr;
 	__u16 destp	  = ntohs(inet->inet_dport);
 	__u16 srcp	  = ntohs(inet->inet_sport);
+	unsigned int tos = inet->tos;
 
 	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
-		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d%n",
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d %d%n",
 		bucket, src, srcp, dest, destp, sp->sk_state,
 		sk_wmem_alloc_get(sp),
 		sk_rmem_alloc_get(sp),
 		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
 		atomic_read(&sp->sk_refcnt), sp,
-		atomic_read(&sp->sk_drops), len);
+		atomic_read(&sp->sk_drops), tos, len);
 }
 
 int udp4_seq_show(struct seq_file *seq, void *v)
-- 
1.7.3.1
