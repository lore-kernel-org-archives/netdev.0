From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: avoid limits overflow
Date: Wed, 10 Nov 2010 10:24:26 +0100
Message-ID: <1289381066.2860.109.camel@edumazet-laptop>
References: <20101002112405.951704198@gulag1.americas.sgi.com>
	 <20101002112419.248437367@gulag1.americas.sgi.com>
	 <1286025736.2582.1827.camel@edumazet-laptop>
	 <20101005.145055.63017205.davem@davemloft.net>
	 <20101110061507.GF4330@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	w@1wt.eu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:62076 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab0KJJYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 04:24:32 -0500
In-Reply-To: <20101110061507.GF4330@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 00:15 -0600, Robin Holt a =C3=A9cri=
t :
> On Tue, Oct 05, 2010 at 02:50:55PM -0700, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Sat, 02 Oct 2010 15:22:16 +0200
> >=20
> > > [PATCH] net: avoid limits overflow
> > >=20
> > > Robin Holt tried to boot a 16TB machine and found some limits wer=
e
> > > reached : sysctl_tcp_mem[2], sysctl_udp_mem[2]
> > >=20
> > > We can switch infrastructure to use long "instead" of "int", now
> > > atomic_long_t primitives are available for free.
> > >=20
> > > Reported-by: Robin Holt <holt@sgi.com>
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > Eric please resubmit this when the sysctl fix is resolved.
>=20
> It looks like the sysctl fix is upstream.  Has this been resubmitted
> and I missed it?
>=20
> Robin

I believe it was in Andrew mm tree for a while, and Andrew sent it do
David the 21th of october, I am not sure what happened.

Here it is again for latest linux-2.6 tree, thanks for the headup !

[PATCH] net: avoid limits overflow

Robin Holt tried to boot a 16TB machine and found some limits were
reached : sysctl_tcp_mem[2], sysctl_udp_mem[2]

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

diff --git a/include/net/dn.h b/include/net/dn.h
index e5469f7..a514a3c 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -225,7 +225,7 @@ extern int decnet_di_count;
 extern int decnet_dr_count;
 extern int decnet_no_fc_max_cwnd;
=20
-extern int sysctl_decnet_mem[3];
+extern long sysctl_decnet_mem[3];
 extern int sysctl_decnet_wmem[3];
 extern int sysctl_decnet_rmem[3];
=20
diff --git a/include/net/sock.h b/include/net/sock.h
index c7a7362..a6338d0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -762,7 +762,7 @@ struct proto {
=20
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(struct sock *sk);
-	atomic_t		*memory_allocated;	/* Current allocated memory. */
+	atomic_long_t		*memory_allocated;	/* Current allocated memory. */
 	struct percpu_counter	*sockets_allocated;	/* Current number of socket=
s. */
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
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4fee042..e36c874 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
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
=20
-extern atomic_t tcp_memory_allocated;
+extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
 extern int tcp_memory_pressure;
=20
@@ -280,7 +280,7 @@ static inline bool tcp_too_many_orphans(struct sock=
 *sk, int shift)
 	}
=20
 	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
-	    atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
+	    atomic_long_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
 		return true;
 	return false;
 }
diff --git a/include/net/udp.h b/include/net/udp.h
index 200b828..bb967dd 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -105,10 +105,10 @@ static inline struct udp_hslot *udp_hashslot2(str=
uct udp_table *table,
=20
 extern struct proto udp_prot;
=20
-extern atomic_t udp_memory_allocated;
+extern atomic_long_t udp_memory_allocated;
=20
 /* sysctl variables for udp */
-extern int sysctl_udp_mem[3];
+extern long sysctl_udp_mem[3];
 extern int sysctl_udp_rmem_min;
 extern int sysctl_udp_wmem_min;
=20
diff --git a/net/core/sock.c b/net/core/sock.c
index 3eed542..fb60801 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1653,10 +1653,10 @@ int __sk_mem_schedule(struct sock *sk, int size=
, int kind)
 {
 	struct proto *prot =3D sk->sk_prot;
 	int amt =3D sk_mem_pages(size);
-	int allocated;
+	long allocated;
=20
 	sk->sk_forward_alloc +=3D amt * SK_MEM_QUANTUM;
-	allocated =3D atomic_add_return(amt, prot->memory_allocated);
+	allocated =3D atomic_long_add_return(amt, prot->memory_allocated);
=20
 	/* Under limit. */
 	if (allocated <=3D prot->sysctl_mem[0]) {
@@ -1714,7 +1714,7 @@ suppress_allocation:
=20
 	/* Alas. Undo changes. */
 	sk->sk_forward_alloc -=3D amt * SK_MEM_QUANTUM;
-	atomic_sub(amt, prot->memory_allocated);
+	atomic_long_sub(amt, prot->memory_allocated);
 	return 0;
 }
 EXPORT_SYMBOL(__sk_mem_schedule);
@@ -1727,12 +1727,12 @@ void __sk_mem_reclaim(struct sock *sk)
 {
 	struct proto *prot =3D sk->sk_prot;
=20
-	atomic_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
+	atomic_long_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHIFT,
 		   prot->memory_allocated);
 	sk->sk_forward_alloc &=3D SK_MEM_QUANTUM - 1;
=20
 	if (prot->memory_pressure && *prot->memory_pressure &&
-	    (atomic_read(prot->memory_allocated) < prot->sysctl_mem[0]))
+	    (atomic_long_read(prot->memory_allocated) < prot->sysctl_mem[0]))
 		*prot->memory_pressure =3D 0;
 }
 EXPORT_SYMBOL(__sk_mem_reclaim);
@@ -2452,12 +2452,12 @@ static char proto_method_implemented(const void=
 *method)
=20
 static void proto_seq_printf(struct seq_file *seq, struct proto *proto=
)
 {
-	seq_printf(seq, "%-9s %4u %6d  %6d   %-3s %6u   %-3s  %-10s "
+	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
 			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2=
c %2c %2c\n",
 		   proto->name,
 		   proto->obj_size,
 		   sock_prot_inuse_get(seq_file_net(seq), proto),
-		   proto->memory_allocated !=3D NULL ? atomic_read(proto->memory_all=
ocated) : -1,
+		   proto->memory_allocated !=3D NULL ? atomic_long_read(proto->memor=
y_allocated) : -1L,
 		   proto->memory_pressure !=3D NULL ? *proto->memory_pressure ? "yes=
" : "no" : "NI",
 		   proto->max_header,
 		   proto->slab =3D=3D NULL ? "no" : "yes",
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index d6b93d1..a76b78d 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -155,7 +155,7 @@ static const struct proto_ops dn_proto_ops;
 static DEFINE_RWLOCK(dn_hash_lock);
 static struct hlist_head dn_sk_hash[DN_SK_HASH_SIZE];
 static struct hlist_head dn_wild_sk;
-static atomic_t decnet_memory_allocated;
+static atomic_long_t decnet_memory_allocated;
=20
 static int __dn_setsockopt(struct socket *sock, int level, int optname=
, char __user *optval, unsigned int optlen, int flags);
 static int __dn_getsockopt(struct socket *sock, int level, int optname=
, char __user *optval, int __user *optlen, int flags);
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_dec=
net.c
index be3eb8e..28f8b5e 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -38,7 +38,7 @@ int decnet_log_martians =3D 1;
 int decnet_no_fc_max_cwnd =3D NSP_MIN_WINDOW;
=20
 /* Reasonable defaults, I hope, based on tcp's defaults */
-int sysctl_decnet_mem[3] =3D { 768 << 3, 1024 << 3, 1536 << 3 };
+long sysctl_decnet_mem[3] =3D { 768 << 3, 1024 << 3, 1536 << 3 };
 int sysctl_decnet_wmem[3] =3D { 4 * 1024, 16 * 1024, 128 * 1024 };
 int sysctl_decnet_rmem[3] =3D { 4 * 1024, 87380, 87380 * 2 };
=20
@@ -324,7 +324,7 @@ static ctl_table dn_table[] =3D {
 		.data =3D &sysctl_decnet_mem,
 		.maxlen =3D sizeof(sysctl_decnet_mem),
 		.mode =3D 0644,
-		.proc_handler =3D proc_dointvec,
+		.proc_handler =3D proc_doulongvec_minmax
 	},
 	{
 		.procname =3D "decnet_rmem",
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 4ae1f20..1b48eb1 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -59,13 +59,13 @@ static int sockstat_seq_show(struct seq_file *seq, =
void *v)
 	local_bh_enable();
=20
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
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d96c1da..e91911d 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -398,7 +398,7 @@ static struct ctl_table ipv4_table[] =3D {
 		.data		=3D &sysctl_tcp_mem,
 		.maxlen		=3D sizeof(sysctl_tcp_mem),
 		.mode		=3D 0644,
-		.proc_handler	=3D proc_dointvec
+		.proc_handler	=3D proc_doulongvec_minmax
 	},
 	{
 		.procname	=3D "tcp_wmem",
@@ -602,8 +602,7 @@ static struct ctl_table ipv4_table[] =3D {
 		.data		=3D &sysctl_udp_mem,
 		.maxlen		=3D sizeof(sysctl_udp_mem),
 		.mode		=3D 0644,
-		.proc_handler	=3D proc_dointvec_minmax,
-		.extra1		=3D &zero
+		.proc_handler	=3D proc_doulongvec_minmax,
 	},
 	{
 		.procname	=3D "udp_rmem_min",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1664a05..245603c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -282,7 +282,7 @@ int sysctl_tcp_fin_timeout __read_mostly =3D TCP_FI=
N_TIMEOUT;
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
=20
-int sysctl_tcp_mem[3] __read_mostly;
+long sysctl_tcp_mem[3] __read_mostly;
 int sysctl_tcp_wmem[3] __read_mostly;
 int sysctl_tcp_rmem[3] __read_mostly;
=20
@@ -290,7 +290,7 @@ EXPORT_SYMBOL(sysctl_tcp_mem);
 EXPORT_SYMBOL(sysctl_tcp_rmem);
 EXPORT_SYMBOL(sysctl_tcp_wmem);
=20
-atomic_t tcp_memory_allocated;	/* Current allocated memory. */
+atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
 EXPORT_SYMBOL(tcp_memory_allocated);
=20
 /*
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3357f69..6d8ab1c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -259,8 +259,11 @@ static void tcp_fixup_sndbuf(struct sock *sk)
 	int sndmem =3D tcp_sk(sk)->rx_opt.mss_clamp + MAX_TCP_HEADER + 16 +
 		     sizeof(struct sk_buff);
=20
-	if (sk->sk_sndbuf < 3 * sndmem)
-		sk->sk_sndbuf =3D min(3 * sndmem, sysctl_tcp_wmem[2]);
+	if (sk->sk_sndbuf < 3 * sndmem) {
+		sk->sk_sndbuf =3D 3 * sndmem;
+		if (sk->sk_sndbuf > sysctl_tcp_wmem[2])
+			sk->sk_sndbuf =3D sysctl_tcp_wmem[2];
+	}
 }
=20
 /* 2. Tuning advertised window (window_clamp, rcv_ssthresh)
@@ -396,7 +399,7 @@ static void tcp_clamp_window(struct sock *sk)
 	if (sk->sk_rcvbuf < sysctl_tcp_rmem[2] &&
 	    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK) &&
 	    !tcp_memory_pressure &&
-	    atomic_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
+	    atomic_long_read(&tcp_memory_allocated) < sysctl_tcp_mem[0]) {
 		sk->sk_rcvbuf =3D min(atomic_read(&sk->sk_rmem_alloc),
 				    sysctl_tcp_rmem[2]);
 	}
@@ -4861,7 +4864,7 @@ static int tcp_should_expand_sndbuf(struct sock *=
sk)
 		return 0;
=20
 	/* If we are under soft global TCP memory pressure, do not expand.  *=
/
-	if (atomic_read(&tcp_memory_allocated) >=3D sysctl_tcp_mem[0])
+	if (atomic_long_read(&tcp_memory_allocated) >=3D sysctl_tcp_mem[0])
 		return 0;
=20
 	/* If we filled the congestion window, do not expand.  */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 28cb2d7..5e0a3a5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -110,7 +110,7 @@
 struct udp_table udp_table __read_mostly;
 EXPORT_SYMBOL(udp_table);
=20
-int sysctl_udp_mem[3] __read_mostly;
+long sysctl_udp_mem[3] __read_mostly;
 EXPORT_SYMBOL(sysctl_udp_mem);
=20
 int sysctl_udp_rmem_min __read_mostly;
@@ -119,7 +119,7 @@ EXPORT_SYMBOL(sysctl_udp_rmem_min);
 int sysctl_udp_wmem_min __read_mostly;
 EXPORT_SYMBOL(sysctl_udp_wmem_min);
=20
-atomic_t udp_memory_allocated;
+atomic_long_t udp_memory_allocated;
 EXPORT_SYMBOL(udp_memory_allocated);
=20
 #define MAX_UDP_PORTS 65536
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 1ef29c7..e58f947 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -92,7 +92,7 @@ static struct sctp_af *sctp_af_v6_specific;
 struct kmem_cache *sctp_chunk_cachep __read_mostly;
 struct kmem_cache *sctp_bucket_cachep __read_mostly;
=20
-int sysctl_sctp_mem[3];
+long sysctl_sctp_mem[3];
 int sysctl_sctp_rmem[3];
 int sysctl_sctp_wmem[3];
=20
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e34ca9c..6bd5543 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -111,12 +111,12 @@ static void sctp_sock_migrate(struct sock *, stru=
ct sock *,
 static char *sctp_hmac_alg =3D SCTP_COOKIE_HMAC_ALG;
=20
 extern struct kmem_cache *sctp_bucket_cachep;
-extern int sysctl_sctp_mem[3];
+extern long sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
=20
 static int sctp_memory_pressure;
-static atomic_t sctp_memory_allocated;
+static atomic_long_t sctp_memory_allocated;
 struct percpu_counter sctp_sockets_allocated;
=20
 static void sctp_enter_memory_pressure(struct sock *sk)
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 832590b..50cb57f 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -54,7 +54,7 @@ static int sack_timer_max =3D 500;
 static int addr_scope_max =3D 3; /* check sctp_scope_policy_t in inclu=
de/net/sctp/constants.h for max entries */
 static int rwnd_scale_max =3D 16;
=20
-extern int sysctl_sctp_mem[3];
+extern long sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
=20
@@ -203,7 +203,7 @@ static ctl_table sctp_table[] =3D {
 		.data		=3D &sysctl_sctp_mem,
 		.maxlen		=3D sizeof(sysctl_sctp_mem),
 		.mode		=3D 0644,
-		.proc_handler	=3D proc_dointvec,
+		.proc_handler	=3D proc_doulongvec_minmax
 	},
 	{
 		.procname	=3D "sctp_rmem",


