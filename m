From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 10/21] net: rbridge: add rbr_node management function
Date: Tue,  1 Sep 2015 17:43:05 +0200
Message-ID: <1441122196-11662-11-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56207 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752364AbbIAPxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:43 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
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
 net/bridge/rbr.c         | 35 +++++++++++++++++++++++++++++++++++
 net/bridge/rbr_private.h | 23 +++++++++++++++++++++++
 2 files changed, 58 insertions(+)

diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index 31e72ef..718deb3 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -83,3 +83,38 @@ int set_treeroot(struct rbr *rbr, uint16_t treeroot)
  set_tree_root_fail:
 	return -ENOENT;
 }
+
+struct rbr_node *rbr_find_node(struct rbr *rbr, __u16 nickname)
+{
+	struct rbr_node *rbr_node;
+
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
+		if (likely(rbr_node)) {
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
+		if (likely(rbr->rbr_nodes[i]))
+			rbr_del_node(rbr, i);
+	}
+}
diff --git a/net/bridge/rbr_private.h b/net/bridge/rbr_private.h
index 9166a8b..186e454 100644
--- a/net/bridge/rbr_private.h
+++ b/net/bridge/rbr_private.h
@@ -44,7 +44,30 @@ struct rbr {
 	struct net_bridge *br;	/* back pointer */
 };
 
+static inline void rbr_node_free(struct rbr_node *rbr_node)
+{
+	if (likely(rbr_node)) {
+		kfree(rbr_node->rbr_ni);
+		kfree(rbr_node);
+	}
+}
+
+static inline void rbr_node_get(struct rbr_node *rbr_node)
+{
+	if (likely(rbr_node))
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
 int set_treeroot(struct rbr *rbr, uint16_t treeroot);
+struct rbr_node *rbr_find_node(struct rbr *rbr, __u16 nickname);
 
 /* Access the adjacency nick list at the end of rbr_nickinfo */
 #define	RBR_NI_ADJNICKSPTR(v) ((u16 *)((struct rbr_nickinfo *)(v) + 1))
-- 
2.1.4
