From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 36/38] netfilter: connlimit: use keyed locks
Date: Mon, 17 Mar 2014 13:42:56 +0100
Message-ID: <1395060178-11833-37-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59544 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933184AbaCQMnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:51 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

connlimit currently suffers from spinlock contention, example for
4-core system with rps enabled:

+  20.84%   ksoftirqd/2  [kernel.kallsyms] [k] _raw_spin_lock_bh
+  20.76%   ksoftirqd/1  [kernel.kallsyms] [k] _raw_spin_lock_bh
+  20.42%   ksoftirqd/0  [kernel.kallsyms] [k] _raw_spin_lock_bh
+   6.07%   ksoftirqd/2  [nf_conntrack]    [k] ____nf_conntrack_find
+   6.07%   ksoftirqd/1  [nf_conntrack]    [k] ____nf_conntrack_find
+   5.97%   ksoftirqd/0  [nf_conntrack]    [k] ____nf_conntrack_find
+   2.47%   ksoftirqd/2  [nf_conntrack]    [k] hash_conntrack_raw
+   2.45%   ksoftirqd/0  [nf_conntrack]    [k] hash_conntrack_raw
+   2.44%   ksoftirqd/1  [nf_conntrack]    [k] hash_conntrack_raw

May allow parallel lookup/insert/delete if the entry is hashed to
another slot.  With patch:

+  20.95%  ksoftirqd/0  [nf_conntrack] [k] ____nf_conntrack_find
+  20.50%  ksoftirqd/1  [nf_conntrack] [k] ____nf_conntrack_find
+  20.27%  ksoftirqd/2  [nf_conntrack] [k] ____nf_conntrack_find
+   5.76%  ksoftirqd/1  [nf_conntrack] [k] hash_conntrack_raw
+   5.39%  ksoftirqd/2  [nf_conntrack] [k] hash_conntrack_raw
+   5.35%  ksoftirqd/0  [nf_conntrack] [k] hash_conntrack_raw
+   2.00%  ksoftirqd/1  [kernel.kallsyms] [k] __rcu_read_unlock

Improved rx processing rate from ~35kpps to ~50 kpps.

Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c |   26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index a8eaabb..ad290cc 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -31,6 +31,9 @@
 #include <net/netfilter/nf_conntrack_tuple.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
+#define CONNLIMIT_SLOTS	256
+#define CONNLIMIT_LOCK_SLOTS	32
+
 /* we will save the tuples of all connections we care about */
 struct xt_connlimit_conn {
 	struct hlist_node		node;
@@ -39,8 +42,8 @@ struct xt_connlimit_conn {
 };
 
 struct xt_connlimit_data {
-	struct hlist_head	iphash[256];
-	spinlock_t		lock;
+	struct hlist_head	iphash[CONNLIMIT_SLOTS];
+	spinlock_t		locks[CONNLIMIT_LOCK_SLOTS];
 };
 
 static u_int32_t connlimit_rnd __read_mostly;
@@ -48,7 +51,8 @@ static struct kmem_cache *connlimit_conn_cachep __read_mostly;
 
 static inline unsigned int connlimit_iphash(__be32 addr)
 {
-	return jhash_1word((__force __u32)addr, connlimit_rnd) & 0xFF;
+	return jhash_1word((__force __u32)addr,
+			    connlimit_rnd) % CONNLIMIT_SLOTS;
 }
 
 static inline unsigned int
@@ -61,7 +65,8 @@ connlimit_iphash6(const union nf_inet_addr *addr,
 	for (i = 0; i < ARRAY_SIZE(addr->ip6); ++i)
 		res.ip6[i] = addr->ip6[i] & mask->ip6[i];
 
-	return jhash2((u32 *)res.ip6, ARRAY_SIZE(res.ip6), connlimit_rnd) & 0xFF;
+	return jhash2((u32 *)res.ip6, ARRAY_SIZE(res.ip6),
+		       connlimit_rnd) % CONNLIMIT_SLOTS;
 }
 
 static inline bool already_closed(const struct nf_conn *conn)
@@ -183,7 +188,7 @@ static int count_them(struct net *net,
 
 	hhead = &data->iphash[hash];
 
-	spin_lock_bh(&data->lock);
+	spin_lock_bh(&data->locks[hash % CONNLIMIT_LOCK_SLOTS]);
 	count = count_hlist(net, hhead, tuple, addr, mask, family, &addit);
 	if (addit) {
 		if (add_hlist(hhead, tuple, addr))
@@ -191,7 +196,7 @@ static int count_them(struct net *net,
 		else
 			count = -ENOMEM;
 	}
-	spin_unlock_bh(&data->lock);
+	spin_unlock_bh(&data->locks[hash % CONNLIMIT_LOCK_SLOTS]);
 
 	return count;
 }
@@ -227,7 +232,6 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	connections = count_them(net, info->data, tuple_ptr, &addr,
 	                         &info->mask, par->family);
-
 	if (connections < 0)
 		/* kmalloc failed, drop it entirely */
 		goto hotdrop;
@@ -268,7 +272,9 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 		return -ENOMEM;
 	}
 
-	spin_lock_init(&info->data->lock);
+	for (i = 0; i < ARRAY_SIZE(info->data->locks); ++i)
+		spin_lock_init(&info->data->locks[i]);
+
 	for (i = 0; i < ARRAY_SIZE(info->data->iphash); ++i)
 		INIT_HLIST_HEAD(&info->data->iphash[i]);
 
@@ -309,6 +315,10 @@ static struct xt_match connlimit_mt_reg __read_mostly = {
 static int __init connlimit_mt_init(void)
 {
 	int ret;
+
+	BUILD_BUG_ON(CONNLIMIT_LOCK_SLOTS > CONNLIMIT_SLOTS);
+	BUILD_BUG_ON((CONNLIMIT_SLOTS % CONNLIMIT_LOCK_SLOTS) != 0);
+
 	connlimit_conn_cachep = kmem_cache_create("xt_connlimit_conn",
 					   sizeof(struct xt_connlimit_conn),
 					   0, 0, NULL);
-- 
1.7.10.4
