From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 02/21] batman-adv: add seqno maximum age and protection start flag parameters
Date: Wed, 10 Feb 2016 23:57:08 +0800
Message-ID: <1455119847-5862-3-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:33479 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751538AbcBJP77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 10:59:59 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

To allow future use of the window protected function with different
maximum sequence numbers, add a parameter to set this value which
was previously hardcoded. Another parameter added for future use is a
flag to return whether the protection window has started.

While at it, also fix the kerneldoc.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c |  3 ++-
 net/batman-adv/main.h       |  3 +++
 net/batman-adv/routing.c    | 13 ++++++++++---
 net/batman-adv/routing.h    |  3 ++-
 4 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 3266bcb5bb06..23ce90e21a40 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1315,7 +1315,8 @@ batadv_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
 	/* signalize caller that the packet is to be dropped. */
 	if (!hlist_empty(&orig_node->neigh_list) &&
 	    batadv_window_protected(bat_priv, seq_diff,
-				    &orig_ifinfo->batman_seqno_reset)) {
+				    BATADV_TQ_LOCAL_WINDOW_SIZE,
+				    &orig_ifinfo->batman_seqno_reset, NULL)) {
 		ret = BATADV_PROTECTED;
 		goto out;
 	}
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index a7dc41a2709b..32dfc9e578af 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -35,6 +35,9 @@
 /* Time To Live of broadcast messages */
 #define BATADV_TTL 50
 
+/* maximum sequence number age of broadcast messages */
+#define BATADV_BCAST_MAX_AGE 64
+
 /* purge originators after time in seconds if no valid packet comes in
  * -> TODO: check influence on BATADV_TQ_LOCAL_WINDOW_SIZE
  */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index f4b60b1fb50e..1c8b35df50cf 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -146,23 +146,29 @@ out:
  * @bat_priv: the bat priv with all the soft interface information
  * @seq_num_diff: difference between the current/received sequence number and
  *  the last sequence number
+ * @seq_old_max_diff: maximum age of sequence number not considered as restart
  * @last_reset: jiffies timestamp of the last reset, will be updated when reset
  *  is detected
+ * @protection_started: is set to true if the protection window was started,
+ *   doesn't change otherwise.
  *
  * Return:
  *  0 if the packet is to be accepted.
  *  1 if the packet is to be ignored.
  */
 int batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
-			    unsigned long *last_reset)
+			    s32 seq_old_max_diff, unsigned long *last_reset,
+			    bool *protection_started)
 {
-	if (seq_num_diff <= -BATADV_TQ_LOCAL_WINDOW_SIZE ||
+	if (seq_num_diff <= -seq_old_max_diff ||
 	    seq_num_diff >= BATADV_EXPECTED_SEQNO_RANGE) {
 		if (!batadv_has_timed_out(*last_reset,
 					  BATADV_RESET_PROTECTION_MS))
 			return 1;
 
 		*last_reset = jiffies;
+		if (protection_started)
+			*protection_started = true;
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
 			   "old packet received, start protection\n");
 	}
@@ -1073,7 +1079,8 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 
 	/* check whether the packet is old and the host just restarted. */
 	if (batadv_window_protected(bat_priv, seq_diff,
-				    &orig_node->bcast_seqno_reset))
+				    BATADV_BCAST_MAX_AGE,
+				    &orig_node->bcast_seqno_reset, NULL))
 		goto spin_unlock;
 
 	/* mark broadcast in flood history, update window position
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index c776e9655b9b..02a5caa84127 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -52,6 +52,7 @@ batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
 		   struct batadv_hard_iface *recv_if);
 int batadv_window_protected(struct batadv_priv *bat_priv, s32 seq_num_diff,
-			    unsigned long *last_reset);
+			    s32 seq_old_max_diff, unsigned long *last_reset,
+			    bool *protection_started);
 
 #endif /* _NET_BATMAN_ADV_ROUTING_H_ */
-- 
2.7.1
