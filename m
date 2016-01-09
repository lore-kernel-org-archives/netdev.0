From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 09/16] batman-adv: Less checks in batadv_tvlv_unicast_send()
Date: Sat,  9 Jan 2016 21:20:14 +0800
Message-ID: <1452345621-15908-10-git-send-email-a@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Elfring <elfring@users.sourceforge.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:37112 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755263AbcAINWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:22:47 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>

* Let us return directly if a call of the batadv_orig_hash_find() function
  returned a null pointer.

* Omit the initialisation for the variable "skb" at the beginning.

* Replace an assignment by a call of the kfree_skb() function
  and delete the affected variable "ret" then.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 5b678f3471fc..4b5d61fbadb1 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1143,15 +1143,14 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 	struct batadv_unicast_tvlv_packet *unicast_tvlv_packet;
 	struct batadv_tvlv_hdr *tvlv_hdr;
 	struct batadv_orig_node *orig_node;
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
 	unsigned char *tvlv_buff;
 	unsigned int tvlv_len;
 	ssize_t hdr_len = sizeof(*unicast_tvlv_packet);
-	bool ret = false;
 
 	orig_node = batadv_orig_hash_find(bat_priv, dst);
 	if (!orig_node)
-		goto out;
+		return;
 
 	tvlv_len = sizeof(*tvlv_hdr) + tvlv_value_len;
 
@@ -1180,14 +1179,10 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 	tvlv_buff += sizeof(*tvlv_hdr);
 	memcpy(tvlv_buff, tvlv_value, tvlv_value_len);
 
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
-		ret = true;
-
-out:
-	if (!ret)
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) == NET_XMIT_DROP)
 		kfree_skb(skb);
-	if (orig_node)
-		batadv_orig_node_free_ref(orig_node);
+out:
+	batadv_orig_node_free_ref(orig_node);
 }
 
 /**
-- 
2.7.0
