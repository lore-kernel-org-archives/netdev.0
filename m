From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 1/6] batman-adv: free nf_bridge member on locally delivered skb
Date: Thu, 19 Dec 2013 01:15:27 +0100
Message-ID: <1387412132-889-2-git-send-email-antonio@meshcoding.com>
References: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:20792 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab3LSAR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:17:56 -0500
In-Reply-To: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an interface enslaved into batman-adv is a bridge (or a
virtual interface built on top of a bridge) the nf_bridge
member of the skbs reaching the soft-interface is filled
with the state about "netfilter bridge" operations.

Then, if one of such skbs is locally delivered, the nf_bridge
member should be cleaned up to avoid that the old state
could mess up with other "netfilter bridge" operations when
entering a second bridge.
This is needed because batman-adv is an encapsulation
protocol.

However at the moment skb->nf_bridge is not released at all
leading to bogus "netfilter bridge" behaviours.
Fix this by releasing skb->nf_bridge before an skb gets
delivered to the upper layer in interface_rx().

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/soft-interface.c |  8 ++++++++
 net/batman-adv/soft-interface.h | 16 ++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 36f0508..59b7397 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -392,6 +392,14 @@ void batadv_interface_rx(struct net_device *soft_iface,
 				  vid))
 		goto dropped;
 
+	/* Clean the netfilter state before delivering the skb.
+	 * This packet may have traversed a bridge when it was encapsulated into
+	 * the batman header. Now that the header has been removed, the
+	 * netfilter state must be cleaned up to avoid to mess up with a
+	 * possible second bridge
+	 */
+	batadv_nf_bridge_skb_free(skb);
+
 	netif_rx(skb);
 	goto out;
 
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 06fc91f..21b8573 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -33,4 +33,20 @@ void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *softif_vlan);
 struct batadv_softif_vlan *batadv_softif_vlan_get(struct batadv_priv *bat_priv,
 						  unsigned short vid);
 
+#ifdef CONFIG_BRIDGE_NETFILTER
+/**
+ * batadv_nf_bridge_skb_free - clean the NF bridge data in an skb
+ * @skb: the skb which nf data has to be free'd
+ */
+static inline void batadv_nf_bridge_skb_free(struct sk_buff *skb)
+{
+	nf_bridge_put(skb->nf_bridge);
+	skb->nf_bridge = NULL;
+}
+#else
+static inline void batadv_nf_bridge_skb_free(struct sk_buff *skb)
+{
+}
+#endif /* CONFIG_BRIDGE_NETFILTER */
+
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
-- 
1.8.5.1
