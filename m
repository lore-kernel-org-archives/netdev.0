From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH v3] netfilter: nf_conntrack: use safer way to lock all buckets
Date: Mon, 18 Jan 2016 19:23:51 -0500
Message-ID: <1453163031-31443-1-git-send-email-sasha.levin@oracle.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When we need to lock all buckets in the connection hashtable we'd attempt to
lock 1024 spinlocks, which is way more preemption levels than supported by
the kernel. Furthermore, this behavior was hidden by checking if lockdep is
enabled, and if it was - use only 8 buckets(!).

Fix this by using a global lock and synchronize all buckets on it when we
need to lock them all. This is pretty heavyweight, but is only done when we
need to resize the hashtable, and that doesn't happen often enough (or at all).

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/net/netfilter/nf_conntrack_core.h |    8 +++---
 net/netfilter/nf_conntrack_core.c         |   39 +++++++++++++++++++++--------
 net/netfilter/nf_conntrack_helper.c       |    2 +-
 net/netfilter/nf_conntrack_netlink.c      |    2 +-
 net/netfilter/nfnetlink_cttimeout.c       |    4 +--
 5 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 788ef58..62e17d1 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -79,12 +79,10 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l3proto *l3proto,
             const struct nf_conntrack_l4proto *proto);
 
-#ifdef CONFIG_LOCKDEP
-# define CONNTRACK_LOCKS 8
-#else
-# define CONNTRACK_LOCKS 1024
-#endif
+#define CONNTRACK_LOCKS 1024
+
 extern spinlock_t nf_conntrack_locks[CONNTRACK_LOCKS];
+void nf_conntrack_lock(spinlock_t *lock);
 
 extern spinlock_t nf_conntrack_expect_lock;
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 3cb3cb8..6101fdc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -64,8 +64,24 @@ __cacheline_aligned_in_smp spinlock_t nf_conntrack_locks[CONNTRACK_LOCKS];
 EXPORT_SYMBOL_GPL(nf_conntrack_locks);
 
 __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
+
 EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
 
+static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
+static __read_mostly bool nf_conntrack_locks_all;
+
+void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
+{
+	spin_lock(lock);
+	while (unlikely(nf_conntrack_locks_all)) {
+		spin_unlock(lock);
+		spin_lock(&nf_conntrack_locks_all_lock);
+		spin_unlock(&nf_conntrack_locks_all_lock);
+		spin_lock(lock);
+	}
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_lock);
+
 static void nf_conntrack_double_unlock(unsigned int h1, unsigned int h2)
 {
 	h1 %= CONNTRACK_LOCKS;
@@ -82,12 +98,12 @@ static bool nf_conntrack_double_lock(struct net *net, unsigned int h1,
 	h1 %= CONNTRACK_LOCKS;
 	h2 %= CONNTRACK_LOCKS;
 	if (h1 <= h2) {
-		spin_lock(&nf_conntrack_locks[h1]);
+		nf_conntrack_lock(&nf_conntrack_locks[h1]);
 		if (h1 != h2)
 			spin_lock_nested(&nf_conntrack_locks[h2],
 					 SINGLE_DEPTH_NESTING);
 	} else {
-		spin_lock(&nf_conntrack_locks[h2]);
+		nf_conntrack_lock(&nf_conntrack_locks[h2]);
 		spin_lock_nested(&nf_conntrack_locks[h1],
 				 SINGLE_DEPTH_NESTING);
 	}
@@ -102,16 +118,19 @@ static void nf_conntrack_all_lock(void)
 {
 	int i;
 
-	for (i = 0; i < CONNTRACK_LOCKS; i++)
-		spin_lock_nested(&nf_conntrack_locks[i], i);
+	spin_lock(&nf_conntrack_locks_all_lock);
+	nf_conntrack_locks_all = true;
+
+	for (i = 0; i < CONNTRACK_LOCKS; i++) {
+		spin_lock(&nf_conntrack_locks[i]);
+		spin_unlock(&nf_conntrack_locks[i]);
+	}
 }
 
 static void nf_conntrack_all_unlock(void)
 {
-	int i;
-
-	for (i = 0; i < CONNTRACK_LOCKS; i++)
-		spin_unlock(&nf_conntrack_locks[i]);
+	nf_conntrack_locks_all = false;
+	spin_unlock(&nf_conntrack_locks_all_lock);
 }
 
 unsigned int nf_conntrack_htable_size __read_mostly;
@@ -757,7 +776,7 @@ restart:
 	hash = hash_bucket(_hash, net);
 	for (; i < net->ct.htable_size; i++) {
 		lockp = &nf_conntrack_locks[hash % CONNTRACK_LOCKS];
-		spin_lock(lockp);
+		nf_conntrack_lock(lockp);
 		if (read_seqcount_retry(&net->ct.generation, sequence)) {
 			spin_unlock(lockp);
 			goto restart;
@@ -1382,7 +1401,7 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	for (; *bucket < net->ct.htable_size; (*bucket)++) {
 		lockp = &nf_conntrack_locks[*bucket % CONNTRACK_LOCKS];
 		local_bh_disable();
-		spin_lock(lockp);
+		nf_conntrack_lock(lockp);
 		if (*bucket < net->ct.htable_size) {
 			hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], hnnode) {
 				if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index bd9d315..3b40ec5 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -425,7 +425,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
 	}
 	local_bh_disable();
 	for (i = 0; i < net->ct.htable_size; i++) {
-		spin_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
+		nf_conntrack_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
 		if (i < net->ct.htable_size) {
 			hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
 				unhelp(h, me);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index dbb1bb3..355e855 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -840,7 +840,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	for (; cb->args[0] < net->ct.htable_size; cb->args[0]++) {
 restart:
 		lockp = &nf_conntrack_locks[cb->args[0] % CONNTRACK_LOCKS];
-		spin_lock(lockp);
+		nf_conntrack_lock(lockp);
 		if (cb->args[0] >= net->ct.htable_size) {
 			spin_unlock(lockp);
 			goto out;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 5d010f2..94837d2 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -307,12 +307,12 @@ static void ctnl_untimeout(struct net *net, struct ctnl_timeout *timeout)
 
 	local_bh_disable();
 	for (i = 0; i < net->ct.htable_size; i++) {
-		spin_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
+		nf_conntrack_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
 		if (i < net->ct.htable_size) {
 			hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
 				untimeout(h, timeout);
 		}
-		spin_unlock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
+		nf_conntrack_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
 	}
 	local_bh_enable();
 }
-- 
1.7.10.4

