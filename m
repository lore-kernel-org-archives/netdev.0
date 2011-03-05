From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 13/28] batman-adv: Correct rcu refcounting for softif_neigh
Date: Sat,  5 Mar 2011 13:28:27 +0100
Message-ID: <1299328122-21468-14-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36302 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753285Ab1CEM3w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:29:52 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

It might be possible that 2 threads access the same data in the same
rcu grace period. The first thread calls call_rcu() to decrement the
refcount and free the data while the second thread increases the
refcount to use the data. To avoid this race condition all refcount
operations have to be atomic.

Reported-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/soft-interface.c |   31 +++++++++++++++----------------
 net/batman-adv/types.h          |    2 +-
 2 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 7e37077..152beaa 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -76,20 +76,18 @@ int my_skb_head_push(struct sk_buff *skb, unsigned int len)
 	return 0;
 }
 
-static void softif_neigh_free_ref(struct kref *refcount)
+static void softif_neigh_free_rcu(struct rcu_head *rcu)
 {
 	struct softif_neigh *softif_neigh;
 
-	softif_neigh = container_of(refcount, struct softif_neigh, refcount);
+	softif_neigh = container_of(rcu, struct softif_neigh, rcu);
 	kfree(softif_neigh);
 }
 
-static void softif_neigh_free_rcu(struct rcu_head *rcu)
+static void softif_neigh_free_ref(struct softif_neigh *softif_neigh)
 {
-	struct softif_neigh *softif_neigh;
-
-	softif_neigh = container_of(rcu, struct softif_neigh, rcu);
-	kref_put(&softif_neigh->refcount, softif_neigh_free_ref);
+	if (atomic_dec_and_test(&softif_neigh->refcount))
+		call_rcu(&softif_neigh->rcu, softif_neigh_free_rcu);
 }
 
 void softif_neigh_purge(struct bat_priv *bat_priv)
@@ -116,11 +114,10 @@ void softif_neigh_purge(struct bat_priv *bat_priv)
 				 softif_neigh->addr, softif_neigh->vid);
 			softif_neigh_tmp = bat_priv->softif_neigh;
 			bat_priv->softif_neigh = NULL;
-			kref_put(&softif_neigh_tmp->refcount,
-				 softif_neigh_free_ref);
+			softif_neigh_free_ref(softif_neigh_tmp);
 		}
 
-		call_rcu(&softif_neigh->rcu, softif_neigh_free_rcu);
+		softif_neigh_free_ref(softif_neigh);
 	}
 
 	spin_unlock_bh(&bat_priv->softif_neigh_lock);
@@ -141,8 +138,11 @@ static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
 		if (softif_neigh->vid != vid)
 			continue;
 
+		if (!atomic_inc_not_zero(&softif_neigh->refcount))
+			continue;
+
 		softif_neigh->last_seen = jiffies;
-		goto found;
+		goto out;
 	}
 
 	softif_neigh = kzalloc(sizeof(struct softif_neigh), GFP_ATOMIC);
@@ -152,15 +152,14 @@ static struct softif_neigh *softif_neigh_get(struct bat_priv *bat_priv,
 	memcpy(softif_neigh->addr, addr, ETH_ALEN);
 	softif_neigh->vid = vid;
 	softif_neigh->last_seen = jiffies;
-	kref_init(&softif_neigh->refcount);
+	/* initialize with 2 - caller decrements counter by one */
+	atomic_set(&softif_neigh->refcount, 2);
 
 	INIT_HLIST_NODE(&softif_neigh->list);
 	spin_lock_bh(&bat_priv->softif_neigh_lock);
 	hlist_add_head_rcu(&softif_neigh->list, &bat_priv->softif_neigh_list);
 	spin_unlock_bh(&bat_priv->softif_neigh_lock);
 
-found:
-	kref_get(&softif_neigh->refcount);
 out:
 	rcu_read_unlock();
 	return softif_neigh;
@@ -264,7 +263,7 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 			 softif_neigh->addr, softif_neigh->vid);
 		softif_neigh_tmp = bat_priv->softif_neigh;
 		bat_priv->softif_neigh = softif_neigh;
-		kref_put(&softif_neigh_tmp->refcount, softif_neigh_free_ref);
+		softif_neigh_free_ref(softif_neigh_tmp);
 		/* we need to hold the additional reference */
 		goto err;
 	}
@@ -282,7 +281,7 @@ static void softif_batman_recv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 out:
-	kref_put(&softif_neigh->refcount, softif_neigh_free_ref);
+	softif_neigh_free_ref(softif_neigh);
 err:
 	kfree_skb(skb);
 	return;
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index cfbeb45..96f7c22 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -268,7 +268,7 @@ struct softif_neigh {
 	uint8_t addr[ETH_ALEN];
 	unsigned long last_seen;
 	short vid;
-	struct kref refcount;
+	atomic_t refcount;
 	struct rcu_head rcu;
 };
 
-- 
1.7.2.3

