From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 11/24] net: rbridge: Add rbr_node management function
Date: Wed, 24 Sep 2014 17:52:07 +0200
Message-ID: <1411573940-14079-12-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:52506 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753016AbaIXP6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:11 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rbr_node are used to save distant Rbridges information
they are use by local Rbridge to take routing decision
this patch add get/put/free/find/del  function to rbr_node to
avoid freeing a rbr_node that is still in use for routing

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/rbridge/rbr.c         | 34 ++++++++++++++++++++++++++++++++++
 net/bridge/rbridge/rbr_private.h | 26 ++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index 8d6d37e..1df8f8d 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -93,3 +93,37 @@ int set_treeroot(struct rbr *rbr, uint16_t treeroot)
  set_tree_root_fail:
 	return ENOENT;
 }
+
+struct rbr_node *rbr_find_node(struct rbr *rbr, __u16 nickname)
+{
+	struct rbr_node *rbr_node;
+	if (unlikely(!VALID_NICK(nickname)))
+		return NULL;
+	rbr_node = rcu_dereference(rbr->rbr_nodes[nickname]);
+	rbr_node_get(rbr_node);
+
+	return rbr_node;
+}
+
+static void rbr_del_node(struct rbr *rbr, uint16_t nickname)
+{
+	struct rbr_node *rbr_node;
+
+	if (likely(VALID_NICK(nickname))) {
+		rbr_node = rbr->rbr_nodes[nickname];
+		if (likely(rbr_node != NULL)) {
+			rcu_assign_pointer(rbr->rbr_nodes[nickname], NULL);
+			rbr_node_put(rbr_node);
+		}
+	}
+}
+
+static void rbr_del_all(struct rbr *rbr)
+{
+	unsigned int i;
+
+	for (i = RBRIDGE_NICKNAME_MIN; i < RBRIDGE_NICKNAME_MAX; i++) {
+		if (likely(rbr->rbr_nodes[i] != NULL))
+			rbr_del_node(rbr, i);
+	}
+}
diff --git a/net/bridge/rbridge/rbr_private.h b/net/bridge/rbridge/rbr_private.h
index f21e4a5..68485d3 100644
--- a/net/bridge/rbridge/rbr_private.h
+++ b/net/bridge/rbridge/rbr_private.h
@@ -44,6 +44,32 @@ struct rbr {
 	struct net_bridge *br;	/* back pointer */
 };
 
+static inline void rbr_node_free(struct rbr_node *rbr_node)
+{
+	if (likely(rbr_node != NULL)) {
+		if (rbr_node->rbr_ni != NULL)
+			kfree(rbr_node->rbr_ni);
+		kfree(rbr_node);
+	}
+}
+
+static inline void rbr_node_get(struct rbr_node *rbr_node)
+{
+	if (likely(rbr_node != NULL))
+		atomic_inc(&rbr_node->refs);
+}
+
+static inline void rbr_node_put(struct rbr_node *rbr_node)
+{
+	if (rbr_node) {
+		if (unlikely(atomic_dec_and_test(&rbr_node->refs)))
+			rbr_node_free(rbr_node);
+	}
+}
+
+int set_treeroot(struct rbr *rbr, uint16_t treeroot);
+struct rbr_node *rbr_find_node(struct rbr *rbr, __u16 nickname);
+
 /* Access the adjacency nick list at the end of rbr_nickinfo */
 #define	RBR_NI_ADJNICKSPTR(v) ((uint16_t *)((struct rbr_nickinfo *)(v)+1))
 #define	RBR_NI_ADJNICK(v, n) (RBR_NI_ADJNICKSPTR(v)[(n)])
-- 
1.9.1
