From: kaber@trash.net
Subject: [PATCH 06/17] netfilter: nf_conntrack: per_cpu untracking
Date: Tue, 15 Jun 2010 17:38:32 +0200
Message-ID: <1276616323-20880-7-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42173 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250Ab0FOP3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:54 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

NOTRACK makes all cpus share a cache line on nf_conntrack_untracked
twice per packet, slowing down performance.

This patch converts it to a per_cpu variable.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack.h |    5 +--
 net/netfilter/nf_conntrack_core.c    |   36 ++++++++++++++++++++++++---------
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 3bc38c7..84a4b6f 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -261,11 +261,10 @@ extern s16 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			       u32 seq);
 
 /* Fake conntrack entry for untracked connections */
+DECLARE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 static inline struct nf_conn *nf_ct_untracked_get(void)
 {
-	extern struct nf_conn nf_conntrack_untracked;
-
-	return &nf_conntrack_untracked;
+	return &__raw_get_cpu_var(nf_conntrack_untracked);
 }
 extern void nf_ct_untracked_status_or(unsigned long bits);
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 6c1da21..9c66141 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -62,8 +62,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
 unsigned int nf_conntrack_max __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_max);
 
-struct nf_conn nf_conntrack_untracked;
-EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
+DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
+EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
 static int nf_conntrack_hash_rnd_initted;
 static unsigned int nf_conntrack_hash_rnd;
@@ -1183,10 +1183,21 @@ static void nf_ct_release_dying_list(struct net *net)
 	spin_unlock_bh(&nf_conntrack_lock);
 }
 
+static int untrack_refs(void)
+{
+	int cnt = 0, cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct nf_conn *ct = &per_cpu(nf_conntrack_untracked, cpu);
+
+		cnt += atomic_read(&ct->ct_general.use) - 1;
+	}
+	return cnt;
+}
+
 static void nf_conntrack_cleanup_init_net(void)
 {
-	/* wait until all references to nf_conntrack_untracked are dropped */
-	while (atomic_read(&nf_conntrack_untracked.ct_general.use) > 1)
+	while (untrack_refs() > 0)
 		schedule();
 
 	nf_conntrack_helper_fini();
@@ -1323,14 +1334,17 @@ module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
 
 void nf_ct_untracked_status_or(unsigned long bits)
 {
-	nf_conntrack_untracked.status |= bits;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		per_cpu(nf_conntrack_untracked, cpu).status |= bits;
 }
 EXPORT_SYMBOL_GPL(nf_ct_untracked_status_or);
 
 static int nf_conntrack_init_init_net(void)
 {
 	int max_factor = 8;
-	int ret;
+	int ret, cpu;
 
 	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
 	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
@@ -1369,10 +1383,12 @@ static int nf_conntrack_init_init_net(void)
 		goto err_extend;
 #endif
 	/* Set up fake conntrack: to never be deleted, not in any hashes */
-#ifdef CONFIG_NET_NS
-	nf_conntrack_untracked.ct_net = &init_net;
-#endif
-	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
+	for_each_possible_cpu(cpu) {
+		struct nf_conn *ct = &per_cpu(nf_conntrack_untracked, cpu);
+
+		write_pnet(&ct->ct_net, &init_net);
+		atomic_set(&ct->ct_general.use, 1);
+	}
 	/*  - and look it like as a confirmed connection */
 	nf_ct_untracked_status_or(IPS_CONFIRMED | IPS_UNTRACKED);
 	return 0;
-- 
1.7.0.4

