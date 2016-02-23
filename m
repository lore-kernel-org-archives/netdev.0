From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 06/20] batman-adv: Rename batadv_orig_ifinfo *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:09 +0800
Message-ID: <1456207703-903-7-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:23973 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757041AbcBWGLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:11:08 -0500
In-Reply-To: <1456207703-903-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batman-adv source code is the only place in the kernel which uses the
*_free_ref naming scheme for the *_put functions. Changing it to *_put
makes it more consistent and makes it easier to understand the connection
to the *_get functions.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c     |  4 ++--
 net/batman-adv/network-coding.c |  2 +-
 net/batman-adv/originator.c     | 10 +++++-----
 net/batman-adv/originator.h     |  2 +-
 net/batman-adv/routing.c        |  8 ++++----
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 7566cf6614f5..ba48fb2818fc 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1368,7 +1368,7 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 out:
 	spin_unlock_bh(&orig_node->bat_iv.ogm_cnt_lock);
 	batadv_orig_node_put(orig_node);
-	batadv_orig_ifinfo_free_ref(orig_ifinfo);
+	batadv_orig_ifinfo_put(orig_ifinfo);
 	return ret;
 }
 
@@ -1514,7 +1514,7 @@ batadv_iv_ogm_process_per_outif(const struct sk_buff *skb, int ogm_offset,
 					  ogm_packet, if_incoming,
 					  if_outgoing, dup_status);
 	}
-	batadv_orig_ifinfo_free_ref(orig_ifinfo);
+	batadv_orig_ifinfo_put(orig_ifinfo);
 
 	/* only forward for specific interface, not for the default one. */
 	if (if_outgoing == BATADV_IF_DEFAULT)
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 8b367659f1ae..9180ff114a26 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -772,7 +772,7 @@ static bool batadv_can_nc_with_orig(struct batadv_priv *bat_priv,
 
 	last_ttl = orig_ifinfo->last_ttl;
 	last_real_seqno = orig_ifinfo->last_real_seqno;
-	batadv_orig_ifinfo_free_ref(orig_ifinfo);
+	batadv_orig_ifinfo_put(orig_ifinfo);
 
 	if (last_real_seqno != ntohl(ogm_packet->seqno))
 		return false;
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 7965fe5947fb..605641536c82 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -743,11 +743,11 @@ static void batadv_orig_ifinfo_release(struct kref *ref)
 }
 
 /**
- * batadv_orig_ifinfo_free_ref - decrement the refcounter and possibly release
+ * batadv_orig_ifinfo_put - decrement the refcounter and possibly release
  *  the orig_ifinfo
  * @orig_ifinfo: the orig_ifinfo object to release
  */
-void batadv_orig_ifinfo_free_ref(struct batadv_orig_ifinfo *orig_ifinfo)
+void batadv_orig_ifinfo_put(struct batadv_orig_ifinfo *orig_ifinfo)
 {
 	kref_put(&orig_ifinfo->refcount, batadv_orig_ifinfo_release);
 }
@@ -799,7 +799,7 @@ static void batadv_orig_node_release(struct kref *ref)
 	hlist_for_each_entry_safe(orig_ifinfo, node_tmp,
 				  &orig_node->ifinfo_list, list) {
 		hlist_del_rcu(&orig_ifinfo->list);
-		batadv_orig_ifinfo_free_ref(orig_ifinfo);
+		batadv_orig_ifinfo_put(orig_ifinfo);
 	}
 	spin_unlock_bh(&orig_node->neigh_list_lock);
 
@@ -1012,10 +1012,10 @@ batadv_purge_orig_ifinfo(struct batadv_priv *bat_priv,
 		ifinfo_purged = true;
 
 		hlist_del_rcu(&orig_ifinfo->list);
-		batadv_orig_ifinfo_free_ref(orig_ifinfo);
+		batadv_orig_ifinfo_put(orig_ifinfo);
 		if (orig_node->last_bonding_candidate == orig_ifinfo) {
 			orig_node->last_bonding_candidate = NULL;
-			batadv_orig_ifinfo_free_ref(orig_ifinfo);
+			batadv_orig_ifinfo_put(orig_ifinfo);
 		}
 	}
 
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index b4fe82804fc4..adbe7aa749a9 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -69,7 +69,7 @@ batadv_orig_ifinfo_get(struct batadv_orig_node *orig_node,
 struct batadv_orig_ifinfo *
 batadv_orig_ifinfo_new(struct batadv_orig_node *orig_node,
 		       struct batadv_hard_iface *if_outgoing);
-void batadv_orig_ifinfo_free_ref(struct batadv_orig_ifinfo *orig_ifinfo);
+void batadv_orig_ifinfo_put(struct batadv_orig_ifinfo *orig_ifinfo);
 
 int batadv_orig_seq_print_text(struct seq_file *seq, void *offset);
 int batadv_orig_hardif_seq_print_text(struct seq_file *seq, void *offset);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 9107f69873ea..4dd646a52f1a 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -107,7 +107,7 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
 	spin_lock_bh(&orig_node->neigh_list_lock);
 	rcu_assign_pointer(orig_ifinfo->router, neigh_node);
 	spin_unlock_bh(&orig_node->neigh_list_lock);
-	batadv_orig_ifinfo_free_ref(orig_ifinfo);
+	batadv_orig_ifinfo_put(orig_ifinfo);
 
 	/* decrease refcount of previous best neighbor */
 	if (curr_router)
@@ -548,13 +548,13 @@ next:
 			batadv_neigh_node_put(cand_router);
 			cand_router = NULL;
 		}
-		batadv_orig_ifinfo_free_ref(cand);
+		batadv_orig_ifinfo_put(cand);
 	}
 	rcu_read_unlock();
 
 	/* last_bonding_candidate is reset below, remove the old reference. */
 	if (orig_node->last_bonding_candidate)
-		batadv_orig_ifinfo_free_ref(orig_node->last_bonding_candidate);
+		batadv_orig_ifinfo_put(orig_node->last_bonding_candidate);
 
 	/* After finding candidates, handle the three cases:
 	 * 1) there is a next candidate, use that
@@ -567,7 +567,7 @@ next:
 		/* remove references to first candidate, we don't need it. */
 		if (first_candidate) {
 			batadv_neigh_node_put(first_candidate_router);
-			batadv_orig_ifinfo_free_ref(first_candidate);
+			batadv_orig_ifinfo_put(first_candidate);
 		}
 		router = next_candidate_router;
 		orig_node->last_bonding_candidate = next_candidate;
-- 
2.7.1
