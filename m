From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 01/12] net: dsa: rework skb->protocol override helpers
Date: Sun, 24 Aug 2014 11:44:18 -0700
Message-ID: <1408905869-10471-2-git-send-email-f.fainelli@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:55131 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbaHXSpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 14:45:03 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so18915030pde.4
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 11:45:03 -0700 (PDT)
In-Reply-To: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA currently maintains one helper function per tagging protocol that
does not insert a real ethertype in the Ethernet frame:
netdev_uses_dsa_tags() and netdev_uses_trailer_tags().

This patch reworks the logic to introduce two helper functions that
makes the DSA tagging protocol checking more scalable to the addition of
new tagging protocols.

The first helper function returns whether a DSA-enabled device is using
a non-ethertype protocol, while the second helper does return the actual
protocol value we should override skb->protocol with.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
New patch in v3

 include/linux/netdevice.h | 16 +++++++---------
 include/net/dsa.h         | 11 ++++++-----
 net/ethernet/eth.c        |  7 ++-----
 3 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7e2b0b8b5cd7..c0a033b0037c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1781,23 +1781,21 @@ void dev_net_set(struct net_device *dev, struct net *net)
 #endif
 }
 
-static inline bool netdev_uses_dsa_tags(struct net_device *dev)
+static inline bool netdev_uses_dsa_tagging(struct net_device *dev)
 {
-#ifdef CONFIG_NET_DSA_TAG_DSA
+#ifdef CONFIG_NET_DSA
 	if (dev->dsa_ptr != NULL)
-		return dsa_uses_dsa_tags(dev->dsa_ptr);
+		return dsa_protocol_is_tagged(dev->dsa_ptr);
 #endif
-
-	return 0;
+	return false;
 }
 
-static inline bool netdev_uses_trailer_tags(struct net_device *dev)
+static inline __be16 netdev_dsa_tag_protocol(struct net_device *dev)
 {
-#ifdef CONFIG_NET_DSA_TAG_TRAILER
+#ifdef CONFIG_NET_DSA
 	if (dev->dsa_ptr != NULL)
-		return dsa_uses_trailer_tags(dev->dsa_ptr);
+		return dsa_tag_protocol(dev->dsa_ptr);
 #endif
-
 	return 0;
 }
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 6efce384451e..36a397bfbd2e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -192,15 +192,16 @@ static inline void *ds_to_priv(struct dsa_switch *ds)
  * networking receive path to make sure that received frames get
  * the right ->protocol assigned to them when one of those tag
  * formats is in use.
+ *
+ * ETH_P_EDSA is the only real ethertype currently supported
  */
-static inline bool dsa_uses_dsa_tags(struct dsa_switch_tree *dst)
+static inline bool dsa_protocol_is_tagged(struct dsa_switch_tree *dst)
 {
-	return !!(dst->tag_protocol == htons(ETH_P_DSA));
+	return dst->tag_protocol != ETH_P_EDSA;
 }
 
-static inline bool dsa_uses_trailer_tags(struct dsa_switch_tree *dst)
+static inline __be16 dsa_tag_protocol(struct dsa_switch_tree *dst)
 {
-	return !!(dst->tag_protocol == htons(ETH_P_TRAILER));
+	return dst->tag_protocol;
 }
-
 #endif
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index f405e0592407..4ca8e489bc3d 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -181,11 +181,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 * variants has been configured on the receiving interface,
 	 * and if so, set skb->protocol without looking at the packet.
 	 */
-	if (unlikely(netdev_uses_dsa_tags(dev)))
-		return htons(ETH_P_DSA);
-
-	if (unlikely(netdev_uses_trailer_tags(dev)))
-		return htons(ETH_P_TRAILER);
+	if (unlikely(netdev_uses_dsa_tagging(dev)))
+		return netdev_dsa_tag_protocol(dev);
 
 	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
 		return eth->h_proto;
-- 
1.9.1
