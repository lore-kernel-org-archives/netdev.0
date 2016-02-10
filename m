From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 15/21] batman-adv: Convert batadv_neigh_ifinfo to kref
Date: Wed, 10 Feb 2016 23:57:21 +0800
Message-ID: <1455119847-5862-16-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:27558 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752558AbcBJQS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:18:28 -0500
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
 net/batman-adv/originator.c | 17 ++++++++++-------
 net/batman-adv/types.h      |  2 +-
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 7710595ffc42..1c50abe52c6d 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -172,11 +172,14 @@ err:
 /**
  * batadv_neigh_ifinfo_release - release neigh_ifinfo from lists and queue for
  *  free after rcu grace period
- * @neigh_ifinfo: the neigh_ifinfo object to release
+ * @ref: kref pointer of the neigh_ifinfo
  */
-static void
-batadv_neigh_ifinfo_release(struct batadv_neigh_ifinfo *neigh_ifinfo)
+static void batadv_neigh_ifinfo_release(struct kref *ref)
 {
+	struct batadv_neigh_ifinfo *neigh_ifinfo;
+
+	neigh_ifinfo = container_of(ref, struct batadv_neigh_ifinfo, refcount);
+
 	if (neigh_ifinfo->if_outgoing != BATADV_IF_DEFAULT)
 		batadv_hardif_free_ref(neigh_ifinfo->if_outgoing);
 
@@ -190,8 +193,7 @@ batadv_neigh_ifinfo_release(struct batadv_neigh_ifinfo *neigh_ifinfo)
  */
 void batadv_neigh_ifinfo_free_ref(struct batadv_neigh_ifinfo *neigh_ifinfo)
 {
-	if (atomic_dec_and_test(&neigh_ifinfo->refcount))
-		batadv_neigh_ifinfo_release(neigh_ifinfo);
+	kref_put(&neigh_ifinfo->refcount, batadv_neigh_ifinfo_release);
 }
 
 /**
@@ -405,7 +407,7 @@ batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
 		if (tmp_neigh_ifinfo->if_outgoing != if_outgoing)
 			continue;
 
-		if (!atomic_inc_not_zero(&tmp_neigh_ifinfo->refcount))
+		if (!kref_get_unless_zero(&tmp_neigh_ifinfo->refcount))
 			continue;
 
 		neigh_ifinfo = tmp_neigh_ifinfo;
@@ -450,7 +452,8 @@ batadv_neigh_ifinfo_new(struct batadv_neigh_node *neigh,
 	}
 
 	INIT_HLIST_NODE(&neigh_ifinfo->list);
-	atomic_set(&neigh_ifinfo->refcount, 2);
+	kref_init(&neigh_ifinfo->refcount);
+	kref_get(&neigh_ifinfo->refcount);
 	neigh_ifinfo->if_outgoing = if_outgoing;
 
 	hlist_add_head_rcu(&neigh_ifinfo->list, &neigh->ifinfo_list);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 17f97ff5b4d1..81d9f8d6c54b 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -420,7 +420,7 @@ struct batadv_neigh_ifinfo {
 	struct batadv_hard_iface *if_outgoing;
 	struct batadv_neigh_ifinfo_bat_iv bat_iv;
 	u8 last_ttl;
-	atomic_t refcount;
+	struct kref refcount;
 	struct rcu_head rcu;
 };
 
-- 
2.7.1
