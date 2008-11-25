From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: Use a percpu_counter for orphan_count
Date: Wed, 26 Nov 2008 00:09:30 +0100
Message-ID: <492C85AA.9080205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080806000306070307070308"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:59890 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbYKYXJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 18:09:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080806000306070307070308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

Here is the second patch, after one for sockets_allocated

Thank you

[PATCH] net: Use a percpu_counter for orphan_count

Instead of using one atomic_t per protocol, use a percpu_counter
for "orphan_count", to reduce cache line contention on
heavy duty network servers. 

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/sock.h              |    2 +-
 include/net/tcp.h               |    2 +-
 net/dccp/dccp.h                 |    2 +-
 net/dccp/proto.c                |   16 ++++++++++------
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/proc.c                 |    2 +-
 net/ipv4/tcp.c                  |   12 +++++++-----
 net/ipv4/tcp_timer.c            |    2 +-
 8 files changed, 24 insertions(+), 18 deletions(-)

--------------080806000306070307070308
Content-Type: text/plain;
 name="orphan.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="orphan.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index a2a3890..5a3a151 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -666,7 +666,7 @@ struct proto {
 	unsigned int		obj_size;
 	int			slab_flags;
 
-	atomic_t		*orphan_count;
+	struct percpu_counter	*orphan_count;
 
 	struct request_sock_ops	*rsk_prot;
 	struct timewait_sock_ops *twsk_prot;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 723fc1b..2c60d8b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -46,7 +46,7 @@
 
 extern struct inet_hashinfo tcp_hashinfo;
 
-extern atomic_t tcp_orphan_count;
+extern struct percpu_counter tcp_orphan_count;
 extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 #define MAX_TCP_HEADER	(128 + MAX_HEADER)
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 031ce35..33a1127 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -49,7 +49,7 @@ extern int dccp_debug;
 
 extern struct inet_hashinfo dccp_hashinfo;
 
-extern atomic_t dccp_orphan_count;
+extern struct percpu_counter dccp_orphan_count;
 
 extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index ea85c42..db225f9 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -40,8 +40,7 @@ DEFINE_SNMP_STAT(struct dccp_mib, dccp_statistics) __read_mostly;
 
 EXPORT_SYMBOL_GPL(dccp_statistics);
 
-atomic_t dccp_orphan_count = ATOMIC_INIT(0);
-
+struct percpu_counter dccp_orphan_count;
 EXPORT_SYMBOL_GPL(dccp_orphan_count);
 
 struct inet_hashinfo dccp_hashinfo;
@@ -1000,7 +999,7 @@ adjudge_to_death:
 	state = sk->sk_state;
 	sock_hold(sk);
 	sock_orphan(sk);
-	atomic_inc(sk->sk_prot->orphan_count);
+	percpu_counter_inc(sk->sk_prot->orphan_count);
 
 	/*
 	 * It is the last release_sock in its life. It will remove backlog.
@@ -1064,18 +1063,21 @@ static int __init dccp_init(void)
 {
 	unsigned long goal;
 	int ehash_order, bhash_order, i;
-	int rc = -ENOBUFS;
+	int rc;
 
 	BUILD_BUG_ON(sizeof(struct dccp_skb_cb) >
 		     FIELD_SIZEOF(struct sk_buff, cb));
-
+	rc = percpu_counter_init(&dccp_orphan_count, 0);
+	if (rc)
+		goto out;
+	rc = -ENOBUFS;
 	inet_hashinfo_init(&dccp_hashinfo);
 	dccp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("dccp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
 				  SLAB_HWCACHE_ALIGN, NULL);
 	if (!dccp_hashinfo.bind_bucket_cachep)
-		goto out;
+		goto out_free_percpu;
 
 	/*
 	 * Size and allocate the main established and bind bucket
@@ -1168,6 +1170,8 @@ out_free_dccp_ehash:
 out_free_bind_bucket_cachep:
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
 	dccp_hashinfo.bind_bucket_cachep = NULL;
+out_free_percpu:
+	percpu_counter_destroy(&dccp_orphan_count);
 	goto out;
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 05af807..1ccdbba 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -561,7 +561,7 @@ void inet_csk_destroy_sock(struct sock *sk)
 
 	sk_refcnt_debug_release(sk);
 
-	atomic_dec(sk->sk_prot->orphan_count);
+	percpu_counter_dec(sk->sk_prot->orphan_count);
 	sock_put(sk);
 }
 
@@ -641,7 +641,7 @@ void inet_csk_listen_stop(struct sock *sk)
 
 		sock_orphan(child);
 
-		atomic_inc(sk->sk_prot->orphan_count);
+		percpu_counter_inc(sk->sk_prot->orphan_count);
 
 		inet_csk_destroy_sock(child);
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 4944b47..614958b 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -54,7 +54,7 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %d\n",
 		   sock_prot_inuse_get(net, &tcp_prot),
-		   atomic_read(&tcp_orphan_count),
+		   (int)percpu_counter_sum_positive(&tcp_orphan_count),
 		   tcp_death_row.tw_count,
 		   (int)percpu_counter_sum_positive(&tcp_sockets_allocated),
 		   atomic_read(&tcp_memory_allocated));
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e6fade9..0192434 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -277,8 +277,7 @@
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
-atomic_t tcp_orphan_count = ATOMIC_INIT(0);
-
+struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
 int sysctl_tcp_mem[3] __read_mostly;
@@ -1837,7 +1836,7 @@ adjudge_to_death:
 	state = sk->sk_state;
 	sock_hold(sk);
 	sock_orphan(sk);
-	atomic_inc(sk->sk_prot->orphan_count);
+	percpu_counter_inc(sk->sk_prot->orphan_count);
 
 	/* It is the last release_sock in its life. It will remove backlog. */
 	release_sock(sk);
@@ -1888,9 +1887,11 @@ adjudge_to_death:
 		}
 	}
 	if (sk->sk_state != TCP_CLOSE) {
+		int orphan_count = percpu_counter_read_positive(
+						sk->sk_prot->orphan_count);
+
 		sk_mem_reclaim(sk);
-		if (tcp_too_many_orphans(sk,
-				atomic_read(sk->sk_prot->orphan_count))) {
+		if (tcp_too_many_orphans(sk, orphan_count)) {
 			if (net_ratelimit())
 				printk(KERN_INFO "TCP: too many of orphaned "
 				       "sockets\n");
@@ -2689,6 +2690,7 @@ void __init tcp_init(void)
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
 	percpu_counter_init(&tcp_sockets_allocated, 0);
+	percpu_counter_init(&tcp_orphan_count, 0);
 	tcp_hashinfo.bind_bucket_cachep =
 		kmem_cache_create("tcp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 3df339e..cc4e6d2 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -65,7 +65,7 @@ static void tcp_write_err(struct sock *sk)
 static int tcp_out_of_resources(struct sock *sk, int do_reset)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int orphans = atomic_read(&tcp_orphan_count);
+	int orphans = percpu_counter_read_positive(&tcp_orphan_count);
 
 	/* If peer does not open window for long time, or did not transmit
 	 * anything for long time, penalize it. */

--------------080806000306070307070308--
