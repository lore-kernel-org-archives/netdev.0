From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 07/17] batman-adv: Check hard_iface refcnt when receiving skb
Date: Wed, 11 May 2016 03:29:55 +0800
Message-ID: <1462908605-27412-8-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:28824 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472AbcEJTbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:31:08 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The receive function may start processing an incoming packet while the
hard_iface is shut down in a different context. All called functions called
with the batadv_hard_iface object belonging to the incoming interface would
have to check whether the reference counter is still > 0.

This is rather error-prone because this check can be forgotten easily.
Instead check the reference counter when receiving the object to make sure
that all called functions have a valid reference.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 78c05a91ae6f..c8d8bc78a518 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -401,11 +401,19 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	hard_iface = container_of(ptype, struct batadv_hard_iface,
 				  batman_adv_ptype);
+
+	/* Prevent processing a packet received on an interface which is getting
+	 * shut down otherwise the packet may trigger de-reference errors
+	 * further down in the receive path.
+	 */
+	if (!kref_get_unless_zero(&hard_iface->refcount))
+		goto err_out;
+
 	skb = skb_share_check(skb, GFP_ATOMIC);
 
 	/* skb was released by skb_share_check() */
 	if (!skb)
-		goto err_out;
+		goto err_put;
 
 	/* packet should hold at least type and version */
 	if (unlikely(!pskb_may_pull(skb, 2)))
@@ -448,6 +456,8 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	if (ret == NET_RX_DROP)
 		kfree_skb(skb);
 
+	batadv_hardif_put(hard_iface);
+
 	/* return NET_RX_SUCCESS in any case as we
 	 * most probably dropped the packet for
 	 * routing-logical reasons.
@@ -456,6 +466,8 @@ int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 err_free:
 	kfree_skb(skb);
+err_put:
+	batadv_hardif_put(hard_iface);
 err_out:
 	return NET_RX_DROP;
 }
-- 
2.8.2
