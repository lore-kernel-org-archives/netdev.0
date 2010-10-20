From: akpm@linux-foundation.org
Subject: [patch 1/1] net: avoid limits overflow
Date: Wed, 20 Oct 2010 15:59:41 -0700
Message-ID: <201010202259.o9KMxfgq009580@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	eric.dumazet@gmail.com, holt@sgi.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44225 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756085Ab0JTW7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 18:59:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Robin Holt tried to boot a 16TB machine and found some limits were reached
: sysctl_tcp_mem[2], sysctl_udp_mem[2]

We can switch infrastructure to use long "instead" of "int", now
atomic_long_t primitives are available for free.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Reported-by: Robin Holt <holt@sgi.com>
Reviewed-by: Robin Holt <holt@sgi.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/net/dn.h               |    2 +-
 include/net/sock.h             |    4 ++--
 include/net/tcp.h              |    6 +++---
 include/net/udp.h              |    4 ++--
 net/core/sock.c                |   14 +++++++-------
 net/decnet/af_decnet.c         |    2 +-
 net/decnet/sysctl_net_decnet.c |    4 ++--
 net/ipv4/proc.c                |    8 ++++----
 net/ipv4/sysctl_net_ipv4.c     |    5 ++---
 net/ipv4/tcp.c                 |    4 ++--
 net/ipv4/tcp_input.c           |   11 +++++++----
 net/ipv4/udp.c                 |    4 ++--
 net/sctp/protocol.c            |    2 +-
 net/sctp/socket.c              |    4 ++--
 net/sctp/sysctl.c              |    4 ++--
 15 files changed, 40 insertions(+), 38 deletions(-)

diff -puN include/net/dn.h~net-avoid-limits-overflow include/net/dn.h
--- a/include/net/dn.h~net-avoid-limits-overflow
+++ a/include/net/dn.h
@@ -225,7 +225,7 @@ extern int decnet_di_count;
 extern int decnet_dr_count;
 extern int decnet_no_fc_max_cwnd;
 
-extern int sysctl_decnet_mem[3];
+extern long sysctl_decnet_mem[3];
 extern int sysctl_decnet_wmem[3];
 extern int sysctl_decnet_rmem[3];
 
diff -puN include/net/sock.h~net-avoid-limits-overflow include/net/sock.h
--- a/include/net/sock.h~net-avoid-limits-overflow
+++ a/include/net/sock.h
@@ -762,7 +762,7 @@ struct proto {
 
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(struct sock *sk);
-	atomic_t		*memory_allocated;	/* Current allocated memory. */
+	atomic_long_t		*memory_allocated;	/* Current allocated memory. */
 	struct percpu_counter	*sockets_allocated;	/* Current number of sockets. */
 	/*
 	 * Pressure flag: try to collapse.
@@ -771,7 +771,7 @@ struct proto {
 	 * is strict, actions are advisory and have some latency.
 	 */
 	int			*memory_pressure;
-	int			*sysctl_mem;
+	long			*sysctl_mem;
 	int			*sysctl_wmem;
 	int			*sysctl_rmem;
 	int			max_header;
diff -puN include/net/tcp.h~net-avoid-limits-overflow include/net/tcp.h
--- a/include/net/tcp.h~net-avoid-limits-overflow
+++ a/include/net/tcp.h
@@ -224,7 +224,7 @@ extern int sysctl_tcp_fack;
 extern int sysctl_tcp_reordering;
 extern int sysctl_tcp_ecn;
 extern int sysctl_tcp_dsack;
-extern int sysctl_tcp_mem[3];
+extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
 extern int sysctl_tcp_app_win;
@@ -247,7 +247,7 @@ extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 
-extern atomic_t tcp_memory_allocated;
+extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
 extern int tcp_memory_pressure;
 
@@ -280,7 +280,7 @@ static inline bool tcp_too_many_orphans(
 	}
 
 	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
-	    atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
+	    atomic_long_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
 		return true;
 	return false;
 }
diff -puN include/net/udp.h~net-avoid-limits-overflow include/net/udp.h
--- a/include/net/udp.h~net-avoid-limits-overflow
+++ a/include/net/udp.h
@@ -105,10 +105,10 @@ static inline struct udp_hslot *udp_hash
 
 extern struct proto udp_prot;
 
-extern atomic_t udp_memory_allocated;
+extern atomic_long_t udp_memory_allocated;
 
 /* sysctl variables for udp */
-extern int sysctl_udp_mem[3];
+extern long sysctl_udp_mem[3];
 extern int sysctl_udp_rmem_min;
 extern int sysctl_udp_wmem_min;
 
diff -puN net/core/sock.c~net-avoid-limits-overflow net/core/sock.c
--- a/net/core/sock.c~net-avoid-limits-overflow
+++ a/net/core/sock.c
@@ -1653,10 +1653,10 @@ int __sk_mem_schedule(struct sock *sk, i
 {
 	struct proto *prot = sk->sk_prot;
 	int amt = sk_mem_pages(size);
-	int allocated;
+	long allocated;
 
 	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
-	allocated = atomic_add_return(amt, prot->memory_allocated);
+	allocated = atomic_long_add_return(amt, prot->memory_allocated);
 
 	/* Under limit. */
 	if (allocated <= prot->sysctl_mem[0]) {
@@ -1714,7 +1714,7 @@ suppress_allocation:
 
 	/* Alas. Undo changes. */
 	sk->sk_forward_alloc -= amt * SK_MEM_QUANTUM;
-	atomic_sub(amt, prot->memory_allocated);
+	atomic_long_sub(amt, prot->memory_allocated);
 	return 0;
 }
 EXPORT_SYMBOL(__sk_mem_schedule);
@@ -1727,12 +1727,12 @@ void __sk_mem_reclaim(struct sock *sk)
 {
 	struct proto *prot = sk->sk_prot;
 
-	atomic_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
+	atomic_long_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
 		   prot->memory_allocated);
 	sk->sk_forward_alloc &= SK_MEM_QUANTUM - 1;
 
 	if (prot->memory_pressure && *prot->memory_pressure &&
-	    (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0]))
+	    (atomic_long_read(prot->memory_allocated) < prot->sysctl_mem[0]))
 		*prot->memory_pressure = 0;
 }
 EXPORT_SYMBOL(__sk_mem_reclaim);
@@ -2452,12 +2452,12 @@ static char proto_method_implemented(con
 
 static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
 {
-	seq_printf(seq, "%-9s %4u %6d  %6d   %-3s %6u   %-3s  %-10s "
+	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
 			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
 		   proto->name,
 		   proto->obj_size,
 		   sock_prot_inuse_get(seq_file_net(seq), proto),
-		   proto->memory_allocated != NULL ? atomic_read(proto->memory_allocated) : -1,
+		   proto->memory_allocated != NULL ? atomic_long_read(proto->memory_allocated) : -1L,
 		   proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
 		   proto->max_header,
 		   proto->slab == NULL ? "no" : "yes",
diff -puN net/decnet/af_decnet.c~net-avoid-limits-overflow net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c~net-avoid-limits-overflow
+++ a/net/decnet/af_decnet.c
@@ -155,7 +155,7 @@ static const struct proto_ops dn_proto_o
 static DEFINE_RWLOCK(dn_hash_lock);
 static struct hlist_head dn_sk_hash[DN_SK_HASH_SIZE];
 static struct hlist_head dn_wild_sk;
-static atomic_t decnet_memory_allocated;
+static atomic_long_t decnet_memory_allocated;
 
 static int __dn_setsockopt(struct socket *sock, int level, int optname, char __user *optval, unsigned int optlen, int flags);
 static int __dn_getsockopt(struct socket *sock, int level, int optname, char __user *optval, int __user *optlen, int flags);
diff -puN net/decnet/sysctl_net_decnet.c~net-avoid-limits-overflow net/decnet/sysctl_net_decnet.c
--- a/net/decnet/sysctl_net_decnet.c~net-avoid-limits-overflow
+++ a/net/decnet/sysctl_net_decnet.c
@@ -38,7 +38,7 @@ int decnet_log_martians = 1;
 int decnet_no_fc_max_cwnd = NSP_MIN_WINDOW;
 
 /* Reasonable defaults, I hope, based on tcp's defaults */
-int sysctl_decnet_mem[3] = { 768 << 3, 1024 << 3, 1536 << 3 };
+long sysctl_decnet_mem[3] = { 768 << 3, 1024 << 3, 1536 << 3 };
 int sysctl_decnet_wmem[3] = { 4 * 1024, 16 * 1024, 128 * 1024 };
 int sysctl_decnet_rmem[3] = { 4 * 1024, 87380, 87380 * 2 };
 
@@ -324,7 +324,7 @@ static ctl_table dn_table[] = {
 		.data = &sysctl_decnet_mem,
 		.maxlen = sizeof(sysctl_decnet_mem),
 		.mode = 0644,
-		.proc_handler = proc_dointvec,
+		.proc_handler = proc_doulongvec_minmax
 	},
 	{
 		.procname = "decnet_rmem",
diff -puN net/ipv4/proc.c~net-avoid-limits-overflow net/ipv4/proc.c
--- a/net/ipv4/proc.c~net-avoid-limits-overflow
+++ a/net/ipv4/proc.c
@@ -59,13 +59,13 @@ static int sockstat_seq_show(struct seq_
 	local_bh_enable();
 
 	socket_seq_show(seq);
-	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
+	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld\n",
 		   sock_prot_inuse_get(net, &tcp_prot), orphans,
 		   tcp_death_row.tw_count, sockets,
-		   atomic_read(&tcp_memory_allocated));
-	seq_printf(seq, "UDP: inuse %d mem %d\n",
+		   atomic_long_read(&tcp_memory_allocated));
+	seq_printf(seq, "UDP: inuse %d mem %ld\n",
 		   sock_prot_inuse_get(net, &udp_prot),
-		   atomic_read(&udp_memory_allocated));
+		   atomic_long_read(&udp_memory_allocated));
 	seq_printf(seq, "UDPLITE: inuse %d\n",
 		   sock_prot_inuse_get(net, &udplite_prot));
 	seq_printf(seq, "RAW: inuse %d\n",
diff -puN net/ipv4/sysctl_net_ipv4.c~net-avoid-limits-overflow net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c~net-avoid-limits-overflow
+++ a/net/ipv4/sysctl_net_ipv4.c
@@ -398,7 +398,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_mem,
 		.maxlen		= sizeof(sysctl_tcp_mem),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_doulongvec_minmax
 	},
 	{
 		.procname	= "tcp_wmem",
@@ -602,8 +602,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero
+		.proc_handler	= proc_doulongvec_minmax,
 	},
 	{
 		.procname	= "udp_rmem_min",
diff -puN net/ipv4/tcp.c~net-avoid-limits-overflow net/ipv4/tcp.c
--- a/net/ipv4/tcp.c~net-avoid-limits-overflow
+++ a/net/ipv4/tcp.c
@@ -282,7 +282,7 @@ int sysctl_tcp_fin_timeout __read_mostly
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
-int sysctl_tcp_mem[3] __read_mostly;
+long sysctl_tcp_mem[3] __read_mostly;
 int sysctl_tcp_wmem[3] __read_mostly;
 int sysctl_tcp_rmem[3] __read_mostly;
 
@@ -290,7 +290,7 @@ EXPORT_SYMBOL(sysctl_tcp_mem);
 EXPORT_SYMBOL(sysctl_tcp_rmem);
 EXPORT_SYMBOL(sysctl_tcp_wmem);
 
-atomic_t tcp_memory_allocated;	/* Current allocated memory. */
+atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
 EXPORT_SYMBOL(tcp_memory_allocated);
 
 /*
diff -puN net/ipv4/tcp_input.c~net-avoid-limits-overflow net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c~net-avoid-limits-overflow
+++ a/net/ipv4/tcp_input.c
@@ -259,8 +259,11 @@ static void tcp_fixup_sndbuf(struct sock
 	int sndmem = tcp_sk(sk)->rx_opt.mss_clamp + MAX_TCP_HEADER + 16 +
 		     sizeof(struct sk_buff);
 
-	if (sk->sk_sndbuf < 3 * sndmem)
-		sk->sk_sndbuf = min(3 * sndmem, sysctl_tcp_wmem[2]);
+	if (sk->sk_sndbuf < 3 * sndmem) {
+		sk->sk_sndbuf = 3 * sndmem;
+		if (sk->sk_sndbuf > sysctl_tcp_wmem[2])
+			sk->sk_sndbuf = sysctl_tcp_wmem[2];
+	}
 }
 
 /* 2. Tuning advertised window (window_clamp, rcv_ssthresh)
@@ -396,7 +399,7 @@ static void tcp_clamp_window(struct sock
 	if (sk->sk_rcvbuf < sysctl_tcp_rmem[2] &&
 	    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK) &&
 	    !tcp_memory_pressure &&
-	    atomic_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
+	    atomic_long_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
 		sk->sk_rcvbuf = min(atomic_read(&sk->sk_rmem_alloc),
 				    sysctl_tcp_rmem[2]);
 	}
@@ -4861,7 +4864,7 @@ static int tcp_should_expand_sndbuf(stru
 		return 0;
 
 	/* If we are under soft global TCP memory pressure, do not expand.  */
-	if (atomic_read(&tcp_memory_allocated) >= sysctl_tcp_mem[0])
+	if (atomic_long_read(&tcp_memory_allocated) >= sysctl_tcp_mem[0])
 		return 0;
 
 	/* If we filled the congestion window, do not expand.  */
diff -puN net/ipv4/udp.c~net-avoid-limits-overflow net/ipv4/udp.c
--- a/net/ipv4/udp.c~net-avoid-limits-overflow
+++ a/net/ipv4/udp.c
@@ -110,7 +110,7 @@
 struct udp_table udp_table __read_mostly;
 EXPORT_SYMBOL(udp_table);
 
-int sysctl_udp_mem[3] __read_mostly;
+long sysctl_udp_mem[3] __read_mostly;
 EXPORT_SYMBOL(sysctl_udp_mem);
 
 int sysctl_udp_rmem_min __read_mostly;
@@ -119,7 +119,7 @@ EXPORT_SYMBOL(sysctl_udp_rmem_min);
 int sysctl_udp_wmem_min __read_mostly;
 EXPORT_SYMBOL(sysctl_udp_wmem_min);
 
-atomic_t udp_memory_allocated;
+atomic_long_t udp_memory_allocated;
 EXPORT_SYMBOL(udp_memory_allocated);
 
 #define MAX_UDP_PORTS 65536
diff -puN net/sctp/protocol.c~net-avoid-limits-overflow net/sctp/protocol.c
--- a/net/sctp/protocol.c~net-avoid-limits-overflow
+++ a/net/sctp/protocol.c
@@ -92,7 +92,7 @@ static struct sctp_af *sctp_af_v6_specif
 struct kmem_cache *sctp_chunk_cachep __read_mostly;
 struct kmem_cache *sctp_bucket_cachep __read_mostly;
 
-int sysctl_sctp_mem[3];
+long sysctl_sctp_mem[3];
 int sysctl_sctp_rmem[3];
 int sysctl_sctp_wmem[3];
 
diff -puN net/sctp/socket.c~net-avoid-limits-overflow net/sctp/socket.c
--- a/net/sctp/socket.c~net-avoid-limits-overflow
+++ a/net/sctp/socket.c
@@ -111,12 +111,12 @@ static void sctp_sock_migrate(struct soc
 static char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;
 
 extern struct kmem_cache *sctp_bucket_cachep;
-extern int sysctl_sctp_mem[3];
+extern long sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
 
 static int sctp_memory_pressure;
-static atomic_t sctp_memory_allocated;
+static atomic_long_t sctp_memory_allocated;
 struct percpu_counter sctp_sockets_allocated;
 
 static void sctp_enter_memory_pressure(struct sock *sk)
diff -puN net/sctp/sysctl.c~net-avoid-limits-overflow net/sctp/sysctl.c
--- a/net/sctp/sysctl.c~net-avoid-limits-overflow
+++ a/net/sctp/sysctl.c
@@ -54,7 +54,7 @@ static int sack_timer_max = 500;
 static int addr_scope_max = 3; /* check sctp_scope_policy_t in include/net/sctp/constants.h for max entries */
 static int rwnd_scale_max = 16;
 
-extern int sysctl_sctp_mem[3];
+extern long sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
 
@@ -203,7 +203,7 @@ static ctl_table sctp_table[] = {
 		.data		= &sysctl_sctp_mem,
 		.maxlen		= sizeof(sysctl_sctp_mem),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_doulongvec_minmax
 	},
 	{
 		.procname	= "sctp_rmem",
_
