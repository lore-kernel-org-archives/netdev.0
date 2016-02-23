From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 08/20] batman-adv: Rename batadv_backbone_gw *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:11 +0800
Message-ID: <1456207703-903-9-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:36463 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757093AbcBWGLN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:11:13 -0500
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
 net/batman-adv/bridge_loop_avoidance.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index b7167cf3e907..ce2d0701fb59 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -159,12 +159,11 @@ static void batadv_backbone_gw_release(struct kref *ref)
 }
 
 /**
- * batadv_backbone_gw_free_ref - decrement the backbone gw refcounter and
- *  possibly release it
+ * batadv_backbone_gw_put - decrement the backbone gw refcounter and possibly
+ *  release it
  * @backbone_gw: backbone gateway to be free'd
  */
-static void
-batadv_backbone_gw_free_ref(struct batadv_bla_backbone_gw *backbone_gw)
+static void batadv_backbone_gw_put(struct batadv_bla_backbone_gw *backbone_gw)
 {
 	kref_put(&backbone_gw->refcount, batadv_backbone_gw_release);
 }
@@ -180,7 +179,7 @@ static void batadv_claim_release(struct kref *ref)
 
 	claim = container_of(ref, struct batadv_bla_claim, refcount);
 
-	batadv_backbone_gw_free_ref(claim->backbone_gw);
+	batadv_backbone_gw_put(claim->backbone_gw);
 	kfree_rcu(claim, rcu);
 }
 
@@ -524,7 +523,7 @@ batadv_bla_update_own_backbone_gw(struct batadv_priv *bat_priv,
 		return;
 
 	backbone_gw->lasttime = jiffies;
-	batadv_backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_put(backbone_gw);
 }
 
 /**
@@ -573,7 +572,7 @@ static void batadv_bla_answer_request(struct batadv_priv *bat_priv,
 
 	/* finally, send an announcement frame */
 	batadv_bla_send_announce(bat_priv, backbone_gw);
-	batadv_backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_put(backbone_gw);
 }
 
 /**
@@ -682,7 +681,7 @@ static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
 		spin_lock_bh(&claim->backbone_gw->crc_lock);
 		claim->backbone_gw->crc ^= crc16(0, claim->addr, ETH_ALEN);
 		spin_unlock_bh(&claim->backbone_gw->crc_lock);
-		batadv_backbone_gw_free_ref(claim->backbone_gw);
+		batadv_backbone_gw_put(claim->backbone_gw);
 	}
 	/* set (new) backbone gw */
 	kref_get(&backbone_gw->refcount);
@@ -783,7 +782,7 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv, u8 *an_addr,
 		}
 	}
 
-	batadv_backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_put(backbone_gw);
 	return 1;
 }
 
@@ -854,7 +853,7 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 		   claim_addr, BATADV_PRINT_VID(vid), backbone_gw->orig);
 
 	batadv_bla_del_claim(bat_priv, claim_addr, vid);
-	batadv_backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_put(backbone_gw);
 	return 1;
 }
 
@@ -891,7 +890,7 @@ static int batadv_handle_claim(struct batadv_priv *bat_priv,
 
 	/* TODO: we could call something like tt_local_del() here. */
 
-	batadv_backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_put(backbone_gw);
 	return 1;
 }
 
@@ -1154,7 +1153,7 @@ purge_now:
 			batadv_bla_del_backbone_claims(backbone_gw);
 
 			hlist_del_rcu(&backbone_gw->hash_entry);
-			batadv_backbone_gw_free_ref(backbone_gw);
+			batadv_backbone_gw_put(backbone_gw);
 		}
 		spin_unlock_bh(list_lock);
 	}
@@ -1571,7 +1570,7 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 	if (!backbone_gw)
 		return 0;
 
-	batadv_backbone_gw_free_ref(backbone_gw);
+	batadv_backbone_gw_put(backbone_gw);
 	return 1;
 }
 
-- 
2.7.1
