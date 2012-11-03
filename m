From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 7/9] batman-adv: Distributed ARP Table - add compile option
Date: Sat,  3 Nov 2012 19:48:32 +0100
Message-ID: <1351968514-12357-8-git-send-email-ordex@autistici.org>
References: <1351968514-12357-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:49757 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab2KCStc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 14:49:32 -0400
In-Reply-To: <1351968514-12357-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes it possible to decide whether to include DAT within the
batman-adv binary or not.
It is extremely useful when the user wants to reduce the size of the resulting
module by cutting off any not needed feature.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/Kconfig                 | 14 ++++++--
 net/batman-adv/Makefile                |  2 +-
 net/batman-adv/debugfs.c               |  7 +++-
 net/batman-adv/distributed-arp-table.h | 65 ++++++++++++++++++++++++++++++++++
 net/batman-adv/types.h                 | 10 ++++++
 5 files changed, 94 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index e77f805..250e0b5 100644
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
@@ -16,7 +16,7 @@ config BATMAN_ADV
 
 config BATMAN_ADV_BLA
 	bool "Bridge Loop Avoidance"
-	depends on BATMAN_ADV
+	depends on BATMAN_ADV && INET
 	default y
 	help
 	  This option enables BLA (Bridge Loop Avoidance), a mechanism
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
index 7604159..e45e3b4 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -23,7 +23,7 @@ batman-adv-y += bat_iv_ogm.o
 batman-adv-y += bitarray.o
 batman-adv-$(CONFIG_BATMAN_ADV_BLA) += bridge_loop_avoidance.o
 batman-adv-y += debugfs.o
-batman-adv-y += distributed-arp-table.o
+batman-adv-$(CONFIG_BATMAN_ADV_DAT) += distributed-arp-table.o
 batman-adv-y += gateway_client.o
 batman-adv-y += gateway_common.o
 batman-adv-y += hard-interface.o
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index ebc5f4d..3f679cb 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -281,6 +281,7 @@ static int batadv_bla_backbone_table_open(struct inode *inode,
 
 #endif
 
+#ifdef CONFIG_BATMAN_ADV_DAT
 /**
  * batadv_dat_cache_open - Prepare file handler for reads from dat_chache
  * @inode: inode which was opened
@@ -291,7 +292,7 @@ static int batadv_dat_cache_open(struct inode *inode, struct file *file)
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
 	return single_open(file, batadv_dat_cache_seq_print_text, net_dev);
 }
-
+#endif
 
 static int batadv_transtable_local_open(struct inode *inode, struct file *file)
 {
@@ -332,7 +333,9 @@ static BATADV_DEBUGINFO(bla_claim_table, S_IRUGO, batadv_bla_claim_table_open);
 static BATADV_DEBUGINFO(bla_backbone_table, S_IRUGO,
 			batadv_bla_backbone_table_open);
 #endif
+#ifdef CONFIG_BATMAN_ADV_DAT
 static BATADV_DEBUGINFO(dat_cache, S_IRUGO, batadv_dat_cache_open);
+#endif
 static BATADV_DEBUGINFO(transtable_local, S_IRUGO,
 			batadv_transtable_local_open);
 static BATADV_DEBUGINFO(vis_data, S_IRUGO, batadv_vis_data_open);
@@ -345,7 +348,9 @@ static struct batadv_debuginfo *batadv_mesh_debuginfos[] = {
 	&batadv_debuginfo_bla_claim_table,
 	&batadv_debuginfo_bla_backbone_table,
 #endif
+#ifdef CONFIG_BATMAN_ADV_DAT
 	&batadv_debuginfo_dat_cache,
+#endif
 	&batadv_debuginfo_transtable_local,
 	&batadv_debuginfo_vis_data,
 	NULL,
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 01308ce..fdb3522 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -20,6 +20,8 @@
 #ifndef _NET_BATMAN_ADV_ARP_H_
 #define _NET_BATMAN_ADV_ARP_H_
 
+#ifdef CONFIG_BATMAN_ADV_DAT
+
 #include "types.h"
 #include "originator.h"
 
@@ -72,4 +74,67 @@ int batadv_dat_init(struct batadv_priv *bat_priv);
 void batadv_dat_free(struct batadv_priv *bat_priv);
 int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset);
 
+#else
+
+static inline bool
+batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
+				      struct sk_buff *skb)
+{
+	return false;
+}
+
+static inline bool
+batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
+				      struct sk_buff *skb, int hdr_size)
+{
+	return false;
+}
+
+static inline bool
+batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb)
+{
+	return false;
+}
+
+static inline bool
+batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
+				    struct sk_buff *skb, int hdr_size)
+{
+	return false;
+}
+
+static inline bool
+batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
+				 struct batadv_forw_packet *forw_packet)
+{
+	return false;
+}
+
+static inline void
+batadv_dat_init_orig_node_addr(struct batadv_orig_node *orig_node)
+{
+}
+
+static inline void batadv_dat_init_own_addr(struct batadv_priv *bat_priv,
+					    struct batadv_hard_iface *iface)
+{
+}
+
+static inline void batadv_arp_change_timeout(struct net_device *soft_iface,
+					     const char *name)
+{
+}
+
+static inline int batadv_dat_init(struct batadv_priv *bat_priv)
+{
+	return 0;
+}
+
+static inline void batadv_dat_free(struct batadv_priv *bat_priv)
+{
+}
+
+#endif /* CONFIG_BATMAN_ADV_DAT */
+
 #endif /* _NET_BATMAN_ADV_ARP_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 9ed1bb2..00d3093 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -28,6 +28,8 @@
 	(ETH_HLEN + max(sizeof(struct batadv_unicast_packet), \
 			sizeof(struct batadv_bcast_packet)))
 
+#ifdef CONFIG_BATMAN_ADV_DAT
+
 /* batadv_dat_addr_t is the type used for all DHT addresses. If it is changed,
  * BATADV_DAT_ADDR_MAX is changed as well.
  *
@@ -35,6 +37,8 @@
  */
 #define batadv_dat_addr_t uint16_t
 
+#endif /* CONFIG_BATMAN_ADV_DAT */
+
 /**
  * struct batadv_hard_iface_bat_iv - per hard interface B.A.T.M.A.N. IV data
  * @ogm_buff: buffer holding the OGM packet
@@ -80,7 +84,9 @@ struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
 	uint8_t primary_addr[ETH_ALEN];
 	struct batadv_neigh_node __rcu *router; /* rcu protected pointer */
+#ifdef CONFIG_BATMAN_ADV_DAT
 	batadv_dat_addr_t dat_addr;
+#endif
 	unsigned long *bcast_own;
 	uint8_t *bcast_own_sum;
 	unsigned long last_seen;
@@ -252,11 +258,13 @@ struct batadv_priv_vis {
  * @hash: hashtable representing the local ARP cache
  * @work: work queue callback item for cache purging
  */
+#ifdef CONFIG_BATMAN_ADV_DAT
 struct batadv_priv_dat {
 	batadv_dat_addr_t addr;
 	struct batadv_hashtable *hash;
 	struct delayed_work work;
 };
+#endif
 
 struct batadv_priv {
 	atomic_t mesh_state;
@@ -295,7 +303,9 @@ struct batadv_priv {
 	struct batadv_priv_gw gw;
 	struct batadv_priv_tt tt;
 	struct batadv_priv_vis vis;
+#ifdef CONFIG_BATMAN_ADV_DAT
 	struct batadv_priv_dat dat;
+#endif
 };
 
 struct batadv_socket_client {
-- 
1.7.12.4
