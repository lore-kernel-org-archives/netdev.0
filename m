From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 2/4] batman-adv: fix neigh reference imbalance
Date: Sat, 10 May 2014 17:35:08 +0200
Message-ID: <1399736110-22333-3-git-send-email-antonio@meshcoding.com>
References: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:30574 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaEJPgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 11:36:32 -0400
In-Reply-To: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

When an interface is removed from batman-adv, the orig_ifinfo of a
orig_node may be removed without releasing the router first.
This will prevent the reference for the neighbor pointed at by the
orig_ifinfo->router to be released, and this leak may result in
reference leaks for the interface used by this neighbor. Fix that.

This is a regression introduced by
7351a4822d42827ba0110677c0cbad88a3d52585
("batman-adv: split out router from orig_node").

Reported-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index ffd9dfb..a43da69 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -501,12 +501,17 @@ batadv_neigh_node_get(const struct batadv_orig_node *orig_node,
 static void batadv_orig_ifinfo_free_rcu(struct rcu_head *rcu)
 {
 	struct batadv_orig_ifinfo *orig_ifinfo;
+	struct batadv_neigh_node *router;
 
 	orig_ifinfo = container_of(rcu, struct batadv_orig_ifinfo, rcu);
 
 	if (orig_ifinfo->if_outgoing != BATADV_IF_DEFAULT)
 		batadv_hardif_free_ref_now(orig_ifinfo->if_outgoing);
 
+	/* this is the last reference to this object */
+	router = rcu_dereference_protected(orig_ifinfo->router, true);
+	if (router)
+		batadv_neigh_node_free_ref_now(router);
 	kfree(orig_ifinfo);
 }
 
-- 
1.8.5.5
