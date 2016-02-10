From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 13/21] batman-adv: Convert batadv_tvlv_handler to kref
Date: Wed, 10 Feb 2016 23:57:19 +0800
Message-ID: <1455119847-5862-14-git-send-email-a__10241.7457885624$1455121138$gmane$org@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:44886 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752248AbcBJQSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:18:04 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batman-adv uses a self-written reference implementation which is just based
on atomic_t. This is less obvious when reading the code than kref and
therefore increases the change that the reference counting will be missed.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.c  | 24 ++++++++++++++++++------
 net/batman-adv/types.h |  2 +-
 2 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 4b6c2589fa34..568c5503f637 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -625,15 +625,27 @@ __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr)
 }
 
 /**
- * batadv_tvlv_handler_free_ref - decrement the tvlv handler refcounter and
- *  possibly free it
+ * batadv_tvlv_handler_release - release tvlv handler from lists and queue for
+ *  free after rcu grace period
+ * @ref: kref pointer of the tvlv
+ */
+static void batadv_tvlv_handler_release(struct kref *ref)
+{
+	struct batadv_tvlv_handler *tvlv_handler;
+
+	tvlv_handler = container_of(ref, struct batadv_tvlv_handler, refcount);
+	kfree_rcu(tvlv_handler, rcu);
+}
+
+/**
+ * batadv_tvlv_handler_free_ref - decrement the tvlv container refcounter and
+ *  possibly release it
  * @tvlv_handler: the tvlv handler to free
  */
 static void
 batadv_tvlv_handler_free_ref(struct batadv_tvlv_handler *tvlv_handler)
 {
-	if (atomic_dec_and_test(&tvlv_handler->refcount))
-		kfree_rcu(tvlv_handler, rcu);
+	kref_put(&tvlv_handler->refcount, batadv_tvlv_handler_release);
 }
 
 /**
@@ -659,7 +671,7 @@ static struct batadv_tvlv_handler
 		if (tvlv_handler_tmp->version != version)
 			continue;
 
-		if (!atomic_inc_not_zero(&tvlv_handler_tmp->refcount))
+		if (!kref_get_unless_zero(&tvlv_handler_tmp->refcount))
 			continue;
 
 		tvlv_handler = tvlv_handler_tmp;
@@ -1112,7 +1124,7 @@ void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
 	tvlv_handler->type = type;
 	tvlv_handler->version = version;
 	tvlv_handler->flags = flags;
-	atomic_set(&tvlv_handler->refcount, 1);
+	kref_init(&tvlv_handler->refcount);
 	INIT_HLIST_NODE(&tvlv_handler->list);
 
 	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index c55925bb34af..f89dd977f348 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -1293,7 +1293,7 @@ struct batadv_tvlv_handler {
 	u8 type;
 	u8 version;
 	u8 flags;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
