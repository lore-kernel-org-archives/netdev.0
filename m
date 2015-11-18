From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 01/14] net: better skb->sender_cpu and skb->napi_id cohabitation
Date: Wed, 18 Nov 2015 06:30:50 -0800
Message-ID: <1447857063-618-2-git-send-email-edumazet@google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35501 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932745AbbKRObN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:13 -0500
Received: by pacej9 with SMTP id ej9so46594117pac.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:12 -0800 (PST)
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->sender_cpu and skb->napi_id share a common storage,
and we had various bugs about this.

We had to call skb_sender_cpu_clear() in some places to
not leave a prior skb->napi_id and fool netdev_pick_tx()

As suggested by Alexei, we could split the space so that
these errors can not happen.

0 value being reserved as the common (not initialized) value,
let's reserve [1 .. NR_CPUS] range for valid sender_cpu,
and [NR_CPUS+1 .. ~0U] for valid napi_id.

This will allow proper busy polling support over tunnels.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Suggested-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/skbuff.h |  3 ---
 net/core/dev.c         | 33 ++++++++++++++++-----------------
 2 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4355129fff91..c9c394bf0771 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1082,9 +1082,6 @@ static inline void skb_copy_hash(struct sk_buff *to, const struct sk_buff *from)
 
 static inline void skb_sender_cpu_clear(struct sk_buff *skb)
 {
-#ifdef CONFIG_XPS
-	skb->sender_cpu = 0;
-#endif
 }
 
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
diff --git a/net/core/dev.c b/net/core/dev.c
index ae00b894e675..2582c24a75c6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -182,7 +182,7 @@ EXPORT_SYMBOL(dev_base_lock);
 /* protects napi_hash addition/deletion and napi_gen_id */
 static DEFINE_SPINLOCK(napi_hash_lock);
 
-static unsigned int napi_gen_id;
+static unsigned int napi_gen_id = NR_CPUS;
 static DEFINE_HASHTABLE(napi_hash, 8);
 
 static seqcount_t devnet_rename_seq;
@@ -3021,7 +3021,9 @@ struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 	int queue_index = 0;
 
 #ifdef CONFIG_XPS
-	if (skb->sender_cpu == 0)
+	u32 sender_cpu = skb->sender_cpu - 1;
+
+	if (sender_cpu >= (u32)NR_CPUS)
 		skb->sender_cpu = raw_smp_processor_id() + 1;
 #endif
 
@@ -4676,25 +4678,22 @@ EXPORT_SYMBOL_GPL(napi_by_id);
 
 void napi_hash_add(struct napi_struct *napi)
 {
-	if (!test_and_set_bit(NAPI_STATE_HASHED, &napi->state)) {
+	if (test_and_set_bit(NAPI_STATE_HASHED, &napi->state))
+		return;
 
-		spin_lock(&napi_hash_lock);
+	spin_lock(&napi_hash_lock);
 
-		/* 0 is not a valid id, we also skip an id that is taken
-		 * we expect both events to be extremely rare
-		 */
-		napi->napi_id = 0;
-		while (!napi->napi_id) {
-			napi->napi_id = ++napi_gen_id;
-			if (napi_by_id(napi->napi_id))
-				napi->napi_id = 0;
-		}
+	/* 0..NR_CPUS+1 range is reserved for sender_cpu use */
+	do {
+		if (unlikely(++napi_gen_id < NR_CPUS + 1))
+			napi_gen_id = NR_CPUS + 1;
+	} while (napi_by_id(napi_gen_id));
+	napi->napi_id = napi_gen_id;
 
-		hlist_add_head_rcu(&napi->napi_hash_node,
-			&napi_hash[napi->napi_id % HASH_SIZE(napi_hash)]);
+	hlist_add_head_rcu(&napi->napi_hash_node,
+			   &napi_hash[napi->napi_id % HASH_SIZE(napi_hash)]);
 
-		spin_unlock(&napi_hash_lock);
-	}
+	spin_unlock(&napi_hash_lock);
 }
 EXPORT_SYMBOL_GPL(napi_hash_add);
 
-- 
2.6.0.rc2.230.g3dd15c0
