From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 2/8] batman-adv: Avoid recursive call_rcu for batadv_nc_node
Date: Sun, 17 Jan 2016 13:24:35 +0800
Message-ID: <1453008281-15396-3-git-send-email-a__32529.1609777652$1453008479$gmane$org@unstable.cc>
References: <1453008281-15396-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:10896 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbcAQF0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2016 00:26:46 -0500
In-Reply-To: <1453008281-15396-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batadv_nc_node_free_ref function uses call_rcu to delay the free of the
batadv_nc_node object until no (already started) rcu_read_lock is enabled
anymore. This makes sure that no context is still trying to access the
object which should be removed. But batadv_nc_node also contains a
reference to orig_node which must be removed.

The reference drop of orig_node was done in the call_rcu function
batadv_nc_node_free_rcu but should actually be done in the
batadv_nc_node_release function to avoid nested call_rcus. This is
important because rcu_barrier (e.g. batadv_softif_free or batadv_exit) will
not detect the inner call_rcu as relevant for its execution. Otherwise this
barrier will most likely be inserted in the queue before the callback of
the first call_rcu was executed. The caller of rcu_barrier will therefore
continue to run before the inner call_rcu callback finished.

Fixes: d56b1705e28c ("batman-adv: network coding - detect coding nodes and remove these after timeout")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/network-coding.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index c98b0ab85449..cc63b44f0d2e 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -203,28 +203,25 @@ void batadv_nc_init_orig(struct batadv_orig_node *orig_node)
 }
 
 /**
- * batadv_nc_node_free_rcu - rcu callback to free an nc node and remove
- *  its refcount on the orig_node
- * @rcu: rcu pointer of the nc node
+ * batadv_nc_node_release - release nc_node from lists and queue for free after
+ *  rcu grace period
+ * @nc_node: the nc node to free
  */
-static void batadv_nc_node_free_rcu(struct rcu_head *rcu)
+static void batadv_nc_node_release(struct batadv_nc_node *nc_node)
 {
-	struct batadv_nc_node *nc_node;
-
-	nc_node = container_of(rcu, struct batadv_nc_node, rcu);
 	batadv_orig_node_free_ref(nc_node->orig_node);
-	kfree(nc_node);
+	kfree_rcu(nc_node, rcu);
 }
 
 /**
- * batadv_nc_node_free_ref - decrements the nc node refcounter and possibly
- * frees it
+ * batadv_nc_node_free_ref - decrement the nc node refcounter and possibly
+ *  release it
  * @nc_node: the nc node to free
  */
 static void batadv_nc_node_free_ref(struct batadv_nc_node *nc_node)
 {
 	if (atomic_dec_and_test(&nc_node->refcount))
-		call_rcu(&nc_node->rcu, batadv_nc_node_free_rcu);
+		batadv_nc_node_release(nc_node);
 }
 
 /**
-- 
2.7.0
