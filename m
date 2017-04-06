From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 08/19] batman-adv: prevent multiple ARP replies sent by gateways if dat enabled
Date: Thu,  6 Apr 2017 16:07:30 +0200
Message-ID: <20170406140741.30745-9-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Andreas Pape <APape@phoenixcontact.com>,
        Andreas Pape <apape@phoenixcontact.com>,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32948 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935015AbdDFOHt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:49 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Pape <APape@phoenixcontact.com>

If dat is enabled it must be made sure that only the backbone gw which has
claimed the remote destination for the ARP request answers the ARP request
directly if the MAC address is known due to the local dat table. This
prevents multiple ARP replies in a common backbone if more than one
gateway already knows the remote mac searched for in the ARP request.

Signed-off-by: Andreas Pape <apape@phoenixcontact.com>
Acked-by: Simon Wunderlich <sw@simonwunderlich.de>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 49 ++++++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h | 11 ++++++++
 net/batman-adv/distributed-arp-table.c | 15 +++++++++++
 3 files changed, 75 insertions(+)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 7332d284b0fc..546e66ecfabd 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -2449,3 +2449,52 @@ int batadv_bla_backbone_dump(struct sk_buff *msg, struct netlink_callback *cb)
 
 	return ret;
 }
+
+#ifdef CONFIG_BATMAN_ADV_DAT
+/**
+ * batadv_bla_check_claim - check if address is claimed
+ *
+ * @bat_priv: the bat priv with all the soft interface information
+ * @addr: mac address of which the claim status is checked
+ * @vid: the VLAN ID
+ *
+ * addr is checked if this address is claimed by the local device itself.
+ *
+ * Return: true if bla is disabled or the mac is claimed by the device,
+ * false if the device addr is already claimed by another gateway
+ */
+bool batadv_bla_check_claim(struct batadv_priv *bat_priv,
+			    u8 *addr, unsigned short vid)
+{
+	struct batadv_bla_claim search_claim;
+	struct batadv_bla_claim *claim = NULL;
+	struct batadv_hard_iface *primary_if = NULL;
+	bool ret = true;
+
+	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
+		return ret;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		return ret;
+
+	/* First look if the mac address is claimed */
+	ether_addr_copy(search_claim.addr, addr);
+	search_claim.vid = vid;
+
+	claim = batadv_claim_hash_find(bat_priv, &search_claim);
+
+	/* If there is a claim and we are not owner of the claim,
+	 * return false.
+	 */
+	if (claim) {
+		if (!batadv_compare_eth(claim->backbone_gw->orig,
+					primary_if->net_dev->dev_addr))
+			ret = false;
+		batadv_claim_put(claim);
+	}
+
+	batadv_hardif_put(primary_if);
+	return ret;
+}
+#endif
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index e157986bd01c..234775748b8e 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -69,6 +69,10 @@ void batadv_bla_status_update(struct net_device *net_dev);
 int batadv_bla_init(struct batadv_priv *bat_priv);
 void batadv_bla_free(struct batadv_priv *bat_priv);
 int batadv_bla_claim_dump(struct sk_buff *msg, struct netlink_callback *cb);
+#ifdef CONFIG_BATMAN_ADV_DAT
+bool batadv_bla_check_claim(struct batadv_priv *bat_priv, u8 *addr,
+			    unsigned short vid);
+#endif
 #define BATADV_BLA_CRC_INIT	0
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
 
@@ -145,6 +149,13 @@ static inline int batadv_bla_backbone_dump(struct sk_buff *msg,
 	return -EOPNOTSUPP;
 }
 
+static inline
+bool batadv_bla_check_claim(struct batadv_priv *bat_priv, u8 *addr,
+			    unsigned short vid)
+{
+	return true;
+}
+
 #endif /* ifdef CONFIG_BATMAN_ADV_BLA */
 
 #endif /* ifndef _NET_BATMAN_ADV_BLA_H_ */
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 4f643fdb5bc6..28cfa53837e1 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -43,6 +43,7 @@
 #include <linux/workqueue.h>
 #include <net/arp.h>
 
+#include "bridge_loop_avoidance.h"
 #include "hard-interface.h"
 #include "hash.h"
 #include "log.h"
@@ -1040,6 +1041,20 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 			goto out;
 		}
 
+		/* If BLA is enabled, only send ARP replies if we have claimed
+		 * the destination for the ARP request or if no one else of
+		 * the backbone gws belonging to our backbone has claimed the
+		 * destination.
+		 */
+		if (!batadv_bla_check_claim(bat_priv,
+					    dat_entry->mac_addr, vid)) {
+			batadv_dbg(BATADV_DBG_DAT, bat_priv,
+				   "Device %pM claimed by another backbone gw. Don't send ARP reply!",
+				   dat_entry->mac_addr);
+			ret = true;
+			goto out;
+		}
+
 		skb_new = batadv_dat_arp_create_reply(bat_priv, ip_dst, ip_src,
 						      dat_entry->mac_addr,
 						      hw_src, vid);
-- 
2.11.0
