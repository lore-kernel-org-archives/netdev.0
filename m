From: Ingo Molnar <mingo@elte.hu>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 12:31:32 +0100
Message-ID: <20081229113132.GA17317@elte.hu>
References: <9929d2390812250225w19bcd2f7n11357ff26de78c52@mail.gmail.com> <20081225112658.GA7260@gondor.apana.org.au> <1230300535.9487.292.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com> <1230410308.9487.295.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com> <1230544927.16718.12.camel@twins> <20081229103154.GA9691@gondor.apana.org.au> <20081229103735.GA9763@gondor.apana.org.au> <20081229112858.GA16385@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:53449 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070AbYL2Lbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 06:31:55 -0500
Content-Disposition: inline
In-Reply-To: <20081229112858.GA16385@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> * Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > On Mon, Dec 29, 2008 at 09:31:54PM +1100, Herbert Xu wrote:
> > >
> > > You also need to patch the other places where we use that percpu
> > > counter from process context, e.g., for /proc/net/tcp.
> > 
> > In fact, it looks like just about every spot in the original
> > changeset (dd24c00191d5e4a1ae896aafe33c6b8095ab4bd1) may be run
> > from process context.  So you might be better off making BH-disabling
> > variants of the percpu counter ops.
> 
> i got the splat further below with Peter's workaround applied.

so i'm trying the (partly manual) temporary revert below. The deadlock 
warning triggers very frequently so it masks a lot of other potential 
problems so i needed some quick solution. Can test any other patch as 
well.

	Ingo

--------------->
>From 71b9aceb2b5a1d0e4c6ed5ad0967f45184b6d2f8 Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 29 Dec 2008 12:27:09 +0100
Subject: [PATCH] Revert "net: Use a percpu_counter for orphan_count"

This reverts commit dd24c00191d5e4a1ae896aafe33c6b8095ab4bd1.

Conflicts:

	net/ipv4/inet_connection_sock.c

Lockdep splat as per:

    http://lkml.org/lkml/2008/12/29/50
---
 include/net/sock.h              |    2 +-
 include/net/tcp.h               |    2 +-
 net/dccp/dccp.h                 |    2 +-
 net/dccp/proto.c                |   16 ++++++----------
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/proc.c                 |    2 +-
 net/ipv4/tcp.c                  |   12 +++++-------
 net/ipv4/tcp_timer.c            |    2 +-
 8 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5a3a151..a2a3890 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -666,7 +666,7 @@ struct proto {
 	unsigned int		obj_size;
 	int			slab_flags;
 
-	struct percpu_counter	*orphan_count;
+	atomic_t		*orphan_count;
 
 	struct request_sock_ops	*rsk_prot;
 	struct timewait_sock_ops *twsk_prot;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 218235d..a64e5da 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -46,7 +46,7 @@
 
 extern struct inet_hashinfo tcp_hashinfo;
 
-extern struct percpu_counter tcp_orphan_count;
+extern atomic_t tcp_orphan_count;
 extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 #define MAX_TCP_HEADER	(128 + MAX_HEADER)
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 0bc4c9a..3fd16e8 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -49,7 +49,7 @@ extern int dccp_debug;
 
 extern struct inet_hashinfo dccp_hashinfo;
 
-extern struct percpu_counter dccp_orphan_count;
+extern atomic_t dccp_orphan_count;
 
 extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d5c2bac..959da85 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -40,7 +40,8 @@ DEFINE_SNMP_STAT(struct dccp_mib, dccp_statistics) __read_mostly;
 
 EXPORT_SYMBOL_GPL(dccp_statistics);
 
-struct percpu_counter dccp_orphan_count;
+atomic_t dccp_orphan_count = ATOMIC_INIT(0);
+
 EXPORT_SYMBOL_GPL(dccp_orphan_count);
 
 struct inet_hashinfo dccp_hashinfo;
@@ -964,7 +965,7 @@ adjudge_to_death:
 	state = sk->sk_state;
 	sock_hold(sk);
 	sock_orphan(sk);
-	percpu_counter_inc(sk->sk_prot->orphan_count);
+	atomic_inc(sk->sk_prot->orphan_count);
 
 	/*
 	 * It is the last release_sock in its life. It will remove backlog.
@@ -1028,21 +1029,18 @@ static int __init dccp_init(void)
 {
 	unsigned long goal;
 	int ehash_order, bhash_order, i;
-	int rc;
+	int rc = -ENOBUFS;
 
 	BUILD_BUG_ON(sizeof(struct dccp_skb_cb) >
 		     FIELD_SIZEOF(struct sk_buff, cb));
-	rc = percpu_counter_init(&dccp_orphan_count, 0);
-	if (rc)
-		goto out;
-	rc = -ENOBUFS;
+
 	inet_hashinfo_init(&dccp_hashinfo);
 	dccp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("dccp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
 				  SLAB_HWCACHE_ALIGN, NULL);
 	if (!dccp_hashinfo.bind_bucket_cachep)
-		goto out_free_percpu;
+		goto out;
 
 	/*
 	 * Size and allocate the main established and bind bucket
@@ -1135,8 +1133,6 @@ out_free_dccp_ehash:
 out_free_bind_bucket_cachep:
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
 	dccp_hashinfo.bind_bucket_cachep = NULL;
-out_free_percpu:
-	percpu_counter_destroy(&dccp_orphan_count);
 	goto out;
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c7cda1c..2ebfd9e 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -562,7 +562,7 @@ void inet_csk_destroy_sock(struct sock *sk)
 
 	sk_refcnt_debug_release(sk);
 
-	percpu_counter_dec(sk->sk_prot->orphan_count);
+	atomic_dec(sk->sk_prot->orphan_count);
 	sock_put(sk);
 }
 
@@ -633,7 +633,7 @@ void inet_csk_listen_stop(struct sock *sk)
 
 		acc_req = req->dl_next;
 
-		percpu_counter_inc(sk->sk_prot->orphan_count);
+		atomic_inc(sk->sk_prot->orphan_count);
 
 		local_bh_disable();
 		bh_lock_sock(child);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 614958b..4944b47 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -54,7 +54,7 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
 		   sock_prot_inuse_get(net, &tcp_prot),
-		   (int)percpu_counter_sum_positive(&tcp_orphan_count),
+		   atomic_read(&tcp_orphan_count),
 		   tcp_death_row.tw_count,
 		   (int)percpu_counter_sum_positive(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1f3d529..82b9425 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -277,7 +277,8 @@
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
-struct percpu_counter tcp_orphan_count;
+atomic_t tcp_orphan_count = ATOMIC_INIT(0);
+
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
 int sysctl_tcp_mem[3] __read_mostly;
@@ -1836,7 +1837,7 @@ adjudge_to_death:
 	state = sk->sk_state;
 	sock_hold(sk);
 	sock_orphan(sk);
-	percpu_counter_inc(sk->sk_prot->orphan_count);
+	atomic_inc(sk->sk_prot->orphan_count);
 
 	/* It is the last release_sock in its life. It will remove backlog. */
 	release_sock(sk);
@@ -1887,11 +1888,9 @@ adjudge_to_death:
 		}
 	}
 	if (sk->sk_state != TCP_CLOSE) {
-		int orphan_count = percpu_counter_read_positive(
-						sk->sk_prot->orphan_count);
-
 		sk_mem_reclaim(sk);
-		if (tcp_too_many_orphans(sk, orphan_count)) {
+		if (tcp_too_many_orphans(sk,
+				atomic_read(sk->sk_prot->orphan_count))) {
 			if (net_ratelimit())
 				printk(KERN_INFO "TCP: too many of orphaned "
 				       "sockets\n");
@@ -2790,7 +2789,6 @@ void __init tcp_init(void)
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
 	percpu_counter_init(&tcp_sockets_allocated, 0);
-	percpu_counter_init(&tcp_orphan_count, 0);
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 0170e91..076030c 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -65,7 +65,7 @@ static void tcp_write_err(struct sock *sk)
 static int tcp_out_of_resources(struct sock *sk, int do_reset)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int orphans = percpu_counter_read_positive(&tcp_orphan_count);
+	int orphans = atomic_read(&tcp_orphan_count);
 
 	/* If peer does not open window for long time, or did not transmit
 	 * anything for long time, penalize it. */
