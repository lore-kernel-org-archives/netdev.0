From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/15] batman-adv: Distributed ARP Table - add compile option
Date: Sun, 29 Apr 2012 10:57:40 +0200
Message-ID: <1335689867-8017-9-git-send-email-ordex@autistici.org>
References: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58015 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab2D2I4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 04:56:53 -0400
In-Reply-To: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes it possible to decide whether to include DAT within the
batman-adv binary or not.
It is extremely useful when the user wants to reduce the size of the resulting
module by cutting off any not needed feature.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/Kconfig                 |   12 +++++++-
 net/batman-adv/Makefile                |    2 +-
 net/batman-adv/distributed-arp-table.h |   52 ++++++++++++++++++++++++++++++++
 net/batman-adv/types.h                 |    8 +++++
 4 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index b25e20f..250e0b5 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -4,7 +4,7 @@
 
 config BATMAN_ADV
 	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
-	depends on NET && INET
+	depends on NET
 	select CRC16
         default n
 	help
@@ -25,6 +25,16 @@ config BATMAN_ADV_BLA
 	  more than one mesh node in the same LAN, you can safely remove
 	  this feature and save some space.
 
+config BATMAN_ADV_DAT
+	bool "Distributed ARP Table"
+	depends on BATMAN_ADV && INET
+	default n
+	help
+	  This option enables DAT (Distributed ARP Table), a DHT based
+	  mechanism that increases ARP reliability on sparse wireless
+	  mesh networks. If you think that your network does not need
+	  this option you can safely remove it and save some space.
+
 config BATMAN_ADV_DEBUG
 	bool "B.A.T.M.A.N. debugging"
 	depends on BATMAN_ADV
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 84955b3..ad002cd 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -24,7 +24,7 @@ batman-adv-y += bat_iv_ogm.o
 batman-adv-y += bat_sysfs.o
 batman-adv-y += bitarray.o
 batman-adv-$(CONFIG_BATMAN_ADV_BLA) += bridge_loop_avoidance.o
-batman-adv-y += distributed-arp-table.o
+batman-adv-$(CONFIG_BATMAN_ADV_DAT) += distributed-arp-table.o
 batman-adv-y += gateway_client.o
 batman-adv-y += gateway_common.o
 batman-adv-y += hard-interface.o
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 34689fa..dbc3788 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -22,6 +22,8 @@
 #ifndef _NET_BATMAN_ADV_ARP_H_
 #define _NET_BATMAN_ADV_ARP_H_
 
+#ifdef CONFIG_BATMAN_ADV_DAT
+
 #include "types.h"
 #include "originator.h"
 
@@ -85,4 +87,54 @@ static inline void dat_init_own_dht_addr(struct bat_priv *bat_priv,
 					    DAT_ADDR_MAX);
 }
 
+#else
+
+static inline bool dat_snoop_outgoing_arp_request(struct bat_priv *bat_priv,
+						  struct sk_buff *skb)
+{
+	return false;
+}
+
+static inline bool dat_snoop_incoming_arp_request(struct bat_priv *bat_priv,
+						  struct sk_buff *skb,
+						  int hdr_size)
+{
+	return false;
+}
+
+static inline bool dat_snoop_outgoing_arp_reply(struct bat_priv *bat_priv,
+						struct sk_buff *skb)
+{
+	return false;
+}
+
+static inline bool dat_snoop_incoming_arp_reply(struct bat_priv *bat_priv,
+						struct sk_buff *skb,
+						int hdr_size)
+{
+	return false;
+}
+
+static inline bool dat_drop_broadcast_packet(struct bat_priv *bat_priv,
+					     struct forw_packet *forw_packet)
+{
+	return false;
+}
+
+static inline void dat_init_orig_node_dht_addr(struct orig_node *orig_node)
+{
+}
+
+static inline void dat_init_own_dht_addr(struct bat_priv *bat_priv,
+					 struct hard_iface *primary_if)
+{
+}
+
+static inline void arp_change_timeout(struct net_device *soft_iface,
+				      const char *name)
+{
+}
+
+#endif /* CONFIG_BATMAN_ADV_DAT */
+
 #endif /* _NET_BATMAN_ADV_ARP_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 61e2d78..2b8ffcb 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -27,6 +27,8 @@
 #include "packet.h"
 #include "bitarray.h"
 
+#ifdef CONFIG_BATMAN_ADV_DAT
+
 /* dat_addr_t is the type used for all DHT addresses. If it is changed,
  * DAT_ADDR_MAX is changed as well.
  *
@@ -34,6 +36,8 @@
  */
 #define dat_addr_t uint16_t
 
+#endif /* CONFIG_BATMAN_ADV_DAT */
+
 #define BAT_HEADER_LEN (ETH_HLEN + \
 	((sizeof(struct unicast_packet) > sizeof(struct bcast_packet) ? \
 	 sizeof(struct unicast_packet) : \
@@ -74,7 +78,9 @@ struct hard_iface {
 struct orig_node {
 	uint8_t orig[ETH_ALEN];
 	uint8_t primary_addr[ETH_ALEN];
+#ifdef CONFIG_BATMAN_ADV_DAT
 	dat_addr_t dht_addr;
+#endif
 	struct neigh_node __rcu *router; /* rcu protected pointer */
 	unsigned long *bcast_own;
 	uint8_t *bcast_own_sum;
@@ -229,7 +235,9 @@ struct bat_priv {
 	struct gw_node __rcu *curr_gw;  /* rcu protected pointer */
 	atomic_t gw_reselect;
 	struct hard_iface __rcu *primary_if;  /* rcu protected pointer */
+#ifdef CONFIG_BATMAN_ADV_DAT
 	dat_addr_t dht_addr;
+#endif
 	struct vis_info *my_vis_info;
 	struct bat_algo_ops *bat_algo_ops;
 };
-- 
1.7.9.4
