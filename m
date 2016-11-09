From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 14/17] batman-adv: Remove dev_queue_xmit return code exception
Date: Wed,  9 Nov 2016 23:26:03 +0100
Message-ID: <20161109222606.29039-15-sw@simonwunderlich.de>
References: <20161109222606.29039-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55501 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754720AbcKIW0g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 17:26:36 -0500
In-Reply-To: <20161109222606.29039-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

No caller of batadv_send_skb_to_orig is expecting the results to be -1
(-EPERM) anymore when the skbuff was not consumed. They will instead expect
that the skbuff is always consumed. Having such return code filter is
therefore not needed anymore.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/send.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index b00aac7..9ea272e 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -64,8 +64,11 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work);
  * If neigh_node is NULL, then the packet is broadcasted using hard_iface,
  * otherwise it is sent as unicast to the given neighbor.
  *
- * Return: NET_TX_DROP in case of error or the result of dev_queue_xmit(skb)
- * otherwise
+ * Regardless of the return value, the skb is consumed.
+ *
+ * Return: A negative errno code is returned on a failure. A success does not
+ * guarantee the frame will be transmitted as it may be dropped due
+ * to congestion or traffic shaping.
  */
 int batadv_send_skb_packet(struct sk_buff *skb,
 			   struct batadv_hard_iface *hard_iface,
@@ -73,7 +76,6 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 {
 	struct batadv_priv *bat_priv;
 	struct ethhdr *ethhdr;
-	int ret;
 
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
@@ -111,15 +113,8 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 	/* dev_queue_xmit() returns a negative result on error.	 However on
 	 * congestion and traffic shaping, it drops and returns NET_XMIT_DROP
 	 * (which is > 0). This will not be treated as an error.
-	 *
-	 * a negative value cannot be returned because it could be interepreted
-	 * as not consumed skb by callers of batadv_send_skb_to_orig.
 	 */
-	ret = dev_queue_xmit(skb);
-	if (ret < 0)
-		ret = NET_XMIT_DROP;
-
-	return ret;
+	return dev_queue_xmit(skb);
 send_skb_err:
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
-- 
2.10.1
