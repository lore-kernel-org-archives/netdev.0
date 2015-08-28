From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 01/10] batman-adv: move hardif refcount inc to batadv_neigh_node_new()
Date: Fri, 28 Aug 2015 11:12:27 +0200
Message-ID: <1440753156-7808-2-git-send-email-antonio__9694.84494203261$1440753279$gmane$org@meshcoding.com>
References: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:17493 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbbH1JNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 05:13:52 -0400
In-Reply-To: <1440753156-7808-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

The batadv_neigh_node cleanup function 'batadv_neigh_node_free_rcu()'
takes care of reducing the hardif refcounter, hence it's only logical
to assume the creating function of that same object
'batadv_neigh_node_new()' takes care of increasing the same refcounter.

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Acked-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 6 ------
 net/batman-adv/originator.c | 6 ++++++
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 5c12200..b9b8b33 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -303,12 +303,6 @@ batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
 	if (!neigh_node)
 		goto out;
 
-	if (!atomic_inc_not_zero(&hard_iface->refcount)) {
-		kfree(neigh_node);
-		neigh_node = NULL;
-		goto out;
-	}
-
 	neigh_node->orig_node = orig_neigh;
 	neigh_node->if_incoming = hard_iface;
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 610620a..f8317c1 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -461,6 +461,12 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 	if (!neigh_node)
 		goto out;
 
+	if (!atomic_inc_not_zero(&hard_iface->refcount)) {
+		kfree(neigh_node);
+		neigh_node = NULL;
+		goto out;
+	}
+
 	INIT_HLIST_NODE(&neigh_node->list);
 	INIT_HLIST_HEAD(&neigh_node->ifinfo_list);
 	spin_lock_init(&neigh_node->ifinfo_lock);
-- 
2.5.0
