From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/8] netfilter: connlimit: move lock array out of struct connlimit_data
Date: Sat,  5 Apr 2014 18:03:44 +0200
Message-ID: <1396713830-4009-3-git-send-email-pablo@netfilter.org>
References: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Eric points out that the locks can be global.
Moreover, both Jesper and Eric note that using only 32 locks increases
false sharing as only two cache lines are used.

This increases locks to 256 (16 cache lines assuming 64byte cacheline and
4 bytes per spinlock).

Suggested-by: Jesper Dangaard Brouer <brouer@redhat.com>
Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c |   25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index a6e129e..fbc66bb 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -32,8 +32,14 @@
 #include <net/netfilter/nf_conntrack_tuple.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
-#define CONNLIMIT_SLOTS		32
-#define CONNLIMIT_LOCK_SLOTS	32
+#define CONNLIMIT_SLOTS		256U
+
+#ifdef CONFIG_LOCKDEP
+#define CONNLIMIT_LOCK_SLOTS	8U
+#else
+#define CONNLIMIT_LOCK_SLOTS	256U
+#endif
+
 #define CONNLIMIT_GC_MAX_NODES	8
 
 /* we will save the tuples of all connections we care about */
@@ -49,10 +55,11 @@ struct xt_connlimit_rb {
 	union nf_inet_addr addr; /* search key */
 };
 
+static spinlock_t xt_connlimit_locks[CONNLIMIT_LOCK_SLOTS] __cacheline_aligned_in_smp;
+
 struct xt_connlimit_data {
 	struct rb_root climit_root4[CONNLIMIT_SLOTS];
 	struct rb_root climit_root6[CONNLIMIT_SLOTS];
-	spinlock_t		locks[CONNLIMIT_LOCK_SLOTS];
 };
 
 static u_int32_t connlimit_rnd __read_mostly;
@@ -297,11 +304,11 @@ static int count_them(struct net *net,
 		root = &data->climit_root4[hash];
 	}
 
-	spin_lock_bh(&data->locks[hash % CONNLIMIT_LOCK_SLOTS]);
+	spin_lock_bh(&xt_connlimit_locks[hash % CONNLIMIT_LOCK_SLOTS]);
 
 	count = count_tree(net, root, tuple, addr, mask, family);
 
-	spin_unlock_bh(&data->locks[hash % CONNLIMIT_LOCK_SLOTS]);
+	spin_unlock_bh(&xt_connlimit_locks[hash % CONNLIMIT_LOCK_SLOTS]);
 
 	return count;
 }
@@ -377,9 +384,6 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 		return -ENOMEM;
 	}
 
-	for (i = 0; i < CONNLIMIT_LOCK_SLOTS; ++i)
-		spin_lock_init(&info->data->locks[i]);
-
 	for (i = 0; i < ARRAY_SIZE(info->data->climit_root4); ++i)
 		info->data->climit_root4[i] = RB_ROOT;
 	for (i = 0; i < ARRAY_SIZE(info->data->climit_root6); ++i)
@@ -435,11 +439,14 @@ static struct xt_match connlimit_mt_reg __read_mostly = {
 
 static int __init connlimit_mt_init(void)
 {
-	int ret;
+	int ret, i;
 
 	BUILD_BUG_ON(CONNLIMIT_LOCK_SLOTS > CONNLIMIT_SLOTS);
 	BUILD_BUG_ON((CONNLIMIT_SLOTS % CONNLIMIT_LOCK_SLOTS) != 0);
 
+	for (i = 0; i < CONNLIMIT_LOCK_SLOTS; ++i)
+		spin_lock_init(&xt_connlimit_locks[i]);
+
 	connlimit_conn_cachep = kmem_cache_create("xt_connlimit_conn",
 					   sizeof(struct xt_connlimit_conn),
 					   0, 0, NULL);
-- 
1.7.10.4

