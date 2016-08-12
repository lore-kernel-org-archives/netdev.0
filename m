From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 17/19] batman-adv: Remove orig_node reference handling from send_skb_unicast
Date: Fri, 12 Aug 2016 10:56:53 +0200
Message-ID: <1470992215-11009-18-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:35006 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbcHLI5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 04:57:49 -0400
In-Reply-To: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The function batadv_send_skb_unicast is not acquiring a reference for an
orig_node nor removing it from any datastructure. It still reduces the
reference counter for an object which is still in the hands of the caller.

This is confusing and can lead in the future to problems in the reference
handling of the caller function.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Linus Lüssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/send.c           | 25 +++++++++++++++++--------
 net/batman-adv/soft-interface.c |  3 +++
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 33d8bd1..8d4e1f5 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -315,8 +315,7 @@ out:
  *
  * Wrap the given skb into a batman-adv unicast or unicast-4addr header
  * depending on whether BATADV_UNICAST or BATADV_UNICAST_4ADDR was supplied
- * as packet_type. Then send this frame to the given orig_node and release a
- * reference to this orig_node.
+ * as packet_type. Then send this frame to the given orig_node.
  *
  * Return: NET_XMIT_DROP in case of error or NET_XMIT_SUCCESS otherwise.
  */
@@ -370,8 +369,6 @@ int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
 		ret = NET_XMIT_SUCCESS;
 
 out:
-	if (orig_node)
-		batadv_orig_node_put(orig_node);
 	if (ret == NET_XMIT_DROP)
 		kfree_skb(skb);
 	return ret;
@@ -403,6 +400,7 @@ int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct batadv_orig_node *orig_node;
 	u8 *src, *dst;
+	int ret;
 
 	src = ethhdr->h_source;
 	dst = ethhdr->h_dest;
@@ -414,8 +412,13 @@ int batadv_send_skb_via_tt_generic(struct batadv_priv *bat_priv,
 	}
 	orig_node = batadv_transtable_search(bat_priv, src, dst, vid);
 
-	return batadv_send_skb_unicast(bat_priv, skb, packet_type,
-				       packet_subtype, orig_node, vid);
+	ret = batadv_send_skb_unicast(bat_priv, skb, packet_type,
+				      packet_subtype, orig_node, vid);
+
+	if (orig_node)
+		batadv_orig_node_put(orig_node);
+
+	return ret;
 }
 
 /**
@@ -433,10 +436,16 @@ int batadv_send_skb_via_gw(struct batadv_priv *bat_priv, struct sk_buff *skb,
 			   unsigned short vid)
 {
 	struct batadv_orig_node *orig_node;
+	int ret;
 
 	orig_node = batadv_gw_get_selected_orig(bat_priv);
-	return batadv_send_skb_unicast(bat_priv, skb, BATADV_UNICAST_4ADDR,
-				       BATADV_P_DATA, orig_node, vid);
+	ret = batadv_send_skb_unicast(bat_priv, skb, BATADV_UNICAST_4ADDR,
+				      BATADV_P_DATA, orig_node, vid);
+
+	if (orig_node)
+		batadv_orig_node_put(orig_node);
+
+	return ret;
 }
 
 /**
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 216ac03..e508bf5 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -57,6 +57,7 @@
 #include "hard-interface.h"
 #include "multicast.h"
 #include "network-coding.h"
+#include "originator.h"
 #include "packet.h"
 #include "send.h"
 #include "sysfs.h"
@@ -377,6 +378,8 @@ dropped:
 dropped_freed:
 	batadv_inc_counter(bat_priv, BATADV_CNT_TX_DROPPED);
 end:
+	if (mcast_single_orig)
+		batadv_orig_node_put(mcast_single_orig);
 	if (primary_if)
 		batadv_hardif_put(primary_if);
 	return NETDEV_TX_OK;
-- 
2.8.1
