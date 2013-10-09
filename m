From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/16] batman-adv: remove vis functionality
Date: Wed,  9 Oct 2013 21:32:50 +0200
Message-ID: <1381347174-3629-13-git-send-email-antonio@meshcoding.com>
References: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:11571 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966Ab3JITnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:43:03 -0400
In-Reply-To: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>

This is replaced by a userspace program, we don't need this
functionality to bloat the kernel.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 Documentation/ABI/testing/sysfs-class-net-mesh |  11 -
 Documentation/networking/batman-adv.txt        |  50 +-
 net/batman-adv/Makefile                        |   1 -
 net/batman-adv/bat_iv_ogm.c                    |   8 -
 net/batman-adv/debugfs.c                       |   9 -
 net/batman-adv/hard-interface.c                |   9 -
 net/batman-adv/main.c                          |  11 -
 net/batman-adv/main.h                          |   2 -
 net/batman-adv/packet.h                        |  21 +-
 net/batman-adv/routing.c                       |  51 --
 net/batman-adv/routing.h                       |   2 -
 net/batman-adv/send.c                          |   1 -
 net/batman-adv/soft-interface.c                |   1 -
 net/batman-adv/sysfs.c                         |  72 --
 net/batman-adv/types.h                         |  84 ---
 net/batman-adv/vis.c                           | 938 -------------------------
 net/batman-adv/vis.h                           |  36 -
 17 files changed, 3 insertions(+), 1304 deletions(-)
 delete mode 100644 net/batman-adv/vis.c
 delete mode 100644 net/batman-adv/vis.h

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index bdcd8b4..f00a69b 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -88,14 +88,3 @@ Contact:        Marek Lindner <lindner_marek@yahoo.de>
 Description:
                 Defines the routing procotol this mesh instance
                 uses to find the optimal paths through the mesh.
-
-What:           /sys/class/net/<mesh_iface>/mesh/vis_mode
-Date:           May 2010
-Contact:        Marek Lindner <lindner_marek@yahoo.de>
-Description:
-                Each batman node only maintains information about its
-                own local neighborhood, therefore generating graphs
-                showing the topology of the entire mesh is not easily
-                feasible without having a central instance to collect
-                the local topologies from all nodes. This file allows
-                to activate the collecting (server) mode.
diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index c1d8204..897d1f4 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -69,8 +69,7 @@ folder:
 # aggregated_ogms        gw_bandwidth           log_level
 # ap_isolation           gw_mode                orig_interval
 # bonding                gw_sel_class           routing_algo
-# bridge_loop_avoidance  hop_penalty            vis_mode
-# fragmentation
+# bridge_loop_avoidance  hop_penalty            fragmentation
 
 
 There is a special folder for debugging information:
@@ -78,7 +77,7 @@ There is a special folder for debugging information:
 # ls /sys/kernel/debug/batman_adv/bat0/
 # bla_backbone_table  log                 transtable_global
 # bla_claim_table     originators         transtable_local
-# gateways            socket              vis_data
+# gateways            socket
 
 Some of the files contain all sort of status information  regard-
 ing  the  mesh  network.  For  example, you can view the table of
@@ -127,51 +126,6 @@ ously assigned to interfaces now used by batman advanced, e.g.
 # ifconfig eth0 0.0.0.0
 
 
-VISUALIZATION
--------------
-
-If you want topology visualization, at least one mesh  node  must
-be configured as VIS-server:
-
-# echo "server" > /sys/class/net/bat0/mesh/vis_mode
-
-Each  node  is  either configured as "server" or as "client" (de-
-fault: "client").  Clients send their topology data to the server
-next to them, and server synchronize with other servers. If there
-is no server configured (default) within the  mesh,  no  topology
-information   will  be  transmitted.  With  these  "synchronizing
-servers", there can be 1 or more vis servers sharing the same (or
-at least very similar) data.
-
-When  configured  as  server,  you can get a topology snapshot of
-your mesh:
-
-# cat /sys/kernel/debug/batman_adv/bat0/vis_data
-
-This raw output is intended to be easily parsable and convertable
-with  other tools. Have a look at the batctl README if you want a
-vis output in dot or json format for instance and how those  out-
-puts could then be visualised in an image.
-
-The raw format consists of comma separated values per entry where
-each entry is giving information about a  certain  source  inter-
-face.  Each  entry can/has to have the following values:
--> "mac" - mac address of an originator's source interface
-           (each line begins with it)
--> "TQ mac  value"  -  src mac's link quality towards mac address
-                       of a neighbor originator's interface which
-                       is being used for routing
--> "TT mac" - TT announced by source mac
--> "PRIMARY" - this  is a primary interface
--> "SEC mac" - secondary mac address of source
-               (requires preceding PRIMARY)
-
-The TQ value has a range from 4 to 255 with 255 being  the  best.
-The TT entries are showing which hosts are connected to the mesh
-via bat0 or being bridged into the mesh network.  The PRIMARY/SEC
-values are only applied on primary interfaces
-
-
 LOGGING/DEBUGGING
 -----------------
 
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 489bb36..8ddbfe6 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -38,4 +38,3 @@ batman-adv-y += soft-interface.o
 batman-adv-y += sysfs.o
 batman-adv-y += translation-table.o
 batman-adv-y += unicast.o
-batman-adv-y += vis.o
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 871ba67..97b42d3 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -687,11 +687,9 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct batadv_hard_iface *primary_if;
 	int *ogm_buff_len = &hard_iface->bat_iv.ogm_buff_len;
-	int vis_server;
 	uint32_t seqno;
 	uint16_t tvlv_len = 0;
 
-	vis_server = atomic_read(&bat_priv->vis_mode);
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (hard_iface == primary_if) {
@@ -712,11 +710,6 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	batadv_ogm_packet->seqno = htonl(seqno);
 	atomic_inc(&hard_iface->bat_iv.ogm_seqno);
 
-	if (vis_server == BATADV_VIS_TYPE_SERVER_SYNC)
-		batadv_ogm_packet->flags |= BATADV_VIS_SERVER;
-	else
-		batadv_ogm_packet->flags &= ~BATADV_VIS_SERVER;
-
 	batadv_iv_ogm_slide_own_bcast_window(hard_iface);
 	batadv_iv_ogm_queue_add(bat_priv, hard_iface->bat_iv.ogm_buff,
 				hard_iface->bat_iv.ogm_buff_len, hard_iface, 1,
@@ -790,7 +783,6 @@ batadv_iv_ogm_orig_update(struct batadv_priv *bat_priv,
 
 	rcu_read_unlock();
 
-	orig_node->flags = batadv_ogm_packet->flags;
 	neigh_node->last_seen = jiffies;
 
 	spin_lock_bh(&neigh_node->lq_update_lock);
diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index f186a55..049a7a2 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -28,7 +28,6 @@
 #include "gateway_common.h"
 #include "gateway_client.h"
 #include "soft-interface.h"
-#include "vis.h"
 #include "icmp_socket.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
@@ -300,12 +299,6 @@ static int batadv_transtable_local_open(struct inode *inode, struct file *file)
 	return single_open(file, batadv_tt_local_seq_print_text, net_dev);
 }
 
-static int batadv_vis_data_open(struct inode *inode, struct file *file)
-{
-	struct net_device *net_dev = (struct net_device *)inode->i_private;
-	return single_open(file, batadv_vis_seq_print_text, net_dev);
-}
-
 struct batadv_debuginfo {
 	struct attribute attr;
 	const struct file_operations fops;
@@ -356,7 +349,6 @@ static BATADV_DEBUGINFO(dat_cache, S_IRUGO, batadv_dat_cache_open);
 #endif
 static BATADV_DEBUGINFO(transtable_local, S_IRUGO,
 			batadv_transtable_local_open);
-static BATADV_DEBUGINFO(vis_data, S_IRUGO, batadv_vis_data_open);
 #ifdef CONFIG_BATMAN_ADV_NC
 static BATADV_DEBUGINFO(nc_nodes, S_IRUGO, batadv_nc_nodes_open);
 #endif
@@ -373,7 +365,6 @@ static struct batadv_debuginfo *batadv_mesh_debuginfos[] = {
 	&batadv_debuginfo_dat_cache,
 #endif
 	&batadv_debuginfo_transtable_local,
-	&batadv_debuginfo_vis_data,
 #ifdef CONFIG_BATMAN_ADV_NC
 	&batadv_debuginfo_nc_nodes,
 #endif
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index c478e6b..eeb6671 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -194,22 +194,13 @@ out:
 static void batadv_primary_if_update_addr(struct batadv_priv *bat_priv,
 					  struct batadv_hard_iface *oldif)
 {
-	struct batadv_vis_packet *vis_packet;
 	struct batadv_hard_iface *primary_if;
-	struct sk_buff *skb;
 
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
 		goto out;
 
 	batadv_dat_init_own_addr(bat_priv, primary_if);
-
-	skb = bat_priv->vis.my_info->skb_packet;
-	vis_packet = (struct batadv_vis_packet *)skb->data;
-	memcpy(vis_packet->vis_orig, primary_if->net_dev->dev_addr, ETH_ALEN);
-	memcpy(vis_packet->sender_orig,
-	       primary_if->net_dev->dev_addr, ETH_ALEN);
-
 	batadv_bla_update_orig_address(bat_priv, primary_if, oldif);
 out:
 	if (primary_if)
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index fc55acb..43dc92e 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -38,7 +38,6 @@
 #include "distributed-arp-table.h"
 #include "unicast.h"
 #include "gateway_common.h"
-#include "vis.h"
 #include "hash.h"
 #include "bat_algo.h"
 #include "network-coding.h"
@@ -112,8 +111,6 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->tt.roam_list_lock);
 	spin_lock_init(&bat_priv->tt.last_changeset_lock);
 	spin_lock_init(&bat_priv->gw.list_lock);
-	spin_lock_init(&bat_priv->vis.hash_lock);
-	spin_lock_init(&bat_priv->vis.list_lock);
 	spin_lock_init(&bat_priv->tvlv.container_list_lock);
 	spin_lock_init(&bat_priv->tvlv.handler_list_lock);
 
@@ -137,10 +134,6 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	batadv_tt_local_add(soft_iface, soft_iface->dev_addr,
 			    BATADV_NULL_IFINDEX);
 
-	ret = batadv_vis_init(bat_priv);
-	if (ret < 0)
-		goto err;
-
 	ret = batadv_bla_init(bat_priv);
 	if (ret < 0)
 		goto err;
@@ -173,8 +166,6 @@ void batadv_mesh_free(struct net_device *soft_iface)
 
 	batadv_purge_outstanding_packets(bat_priv, NULL);
 
-	batadv_vis_quit(bat_priv);
-
 	batadv_gw_node_purge(bat_priv);
 	batadv_nc_mesh_free(bat_priv);
 	batadv_dat_free(bat_priv);
@@ -412,8 +403,6 @@ static void batadv_recv_handler_init(void)
 	batadv_rx_handler[BATADV_UNICAST_FRAG] = batadv_recv_ucast_frag_packet;
 	/* broadcast packet */
 	batadv_rx_handler[BATADV_BCAST] = batadv_recv_bcast_packet;
-	/* vis packet */
-	batadv_rx_handler[BATADV_VIS] = batadv_recv_vis_packet;
 	/* unicast tvlv packet */
 	batadv_rx_handler[BATADV_UNICAST_TVLV] = batadv_recv_unicast_tvlv;
 }
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 397722f..e11c2ec 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -86,8 +86,6 @@
 /* numbers of originator to contact for any PUT/GET DHT operation */
 #define BATADV_DAT_CANDIDATES_NUM 3
 
-#define BATADV_VIS_INTERVAL 5000	/* 5 seconds */
-
 /* how much worse secondary interfaces may be to be considered as bonding
  * candidates
  */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index ab3084f..87fcf2e 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -29,7 +29,6 @@ enum batadv_packettype {
 	BATADV_ICMP		= 0x02,
 	BATADV_UNICAST		= 0x03,
 	BATADV_BCAST		= 0x04,
-	BATADV_VIS		= 0x05,
 	BATADV_UNICAST_FRAG	= 0x06,
 	BATADV_UNICAST_4ADDR	= 0x09,
 	BATADV_CODED		= 0x0a,
@@ -56,7 +55,6 @@ enum batadv_subtype {
 enum batadv_iv_flags {
 	BATADV_NOT_BEST_NEXT_HOP   = BIT(3),
 	BATADV_PRIMARIES_FIRST_HOP = BIT(4),
-	BATADV_VIS_SERVER	   = BIT(5),
 	BATADV_DIRECTLINK	   = BIT(6),
 };
 
@@ -69,12 +67,6 @@ enum batadv_icmp_packettype {
 	BATADV_PARAMETER_PROBLEM       = 12,
 };
 
-/* vis defines */
-enum batadv_vis_packettype {
-	BATADV_VIS_TYPE_SERVER_SYNC   = 0,
-	BATADV_VIS_TYPE_CLIENT_UPDATE = 1,
-};
-
 /* fragmentation defines */
 enum batadv_unicast_frag_flags {
 	BATADV_UNI_FRAG_HEAD	  = BIT(0),
@@ -161,7 +153,7 @@ struct batadv_header {
  */
 struct batadv_ogm_packet {
 	struct batadv_header header;
-	uint8_t  flags;    /* 0x40: DIRECTLINK flag, 0x20 VIS_SERVER flag... */
+	uint8_t  flags;    /* 0x40: DIRECTLINK flag ... */
 	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
 	uint8_t  prev_sender[ETH_ALEN];
@@ -257,17 +249,6 @@ struct batadv_bcast_packet {
 
 #pragma pack()
 
-struct batadv_vis_packet {
-	struct batadv_header header;
-	uint8_t  vis_type;	 /* which type of vis-participant sent this? */
-	__be32   seqno;		 /* sequence number */
-	uint8_t  entries;	 /* number of entries behind this struct */
-	uint8_t  reserved;
-	uint8_t  vis_orig[ETH_ALEN];	/* originator reporting its neighbors */
-	uint8_t  target_orig[ETH_ALEN]; /* who should receive this packet */
-	uint8_t  sender_orig[ETH_ALEN]; /* who sent or forwarded this packet */
-};
-
 /**
  * struct batadv_coded_packet - network coded packet
  * @header: common batman packet header and ttl of first included packet
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index a5bf8ff..2a9318b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -25,7 +25,6 @@
 #include "icmp_socket.h"
 #include "translation-table.h"
 #include "originator.h"
-#include "vis.h"
 #include "unicast.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
@@ -1168,53 +1167,3 @@ out:
 		batadv_orig_node_free_ref(orig_node);
 	return ret;
 }
-
-int batadv_recv_vis_packet(struct sk_buff *skb,
-			   struct batadv_hard_iface *recv_if)
-{
-	struct batadv_vis_packet *vis_packet;
-	struct ethhdr *ethhdr;
-	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
-	int hdr_size = sizeof(*vis_packet);
-
-	/* keep skb linear */
-	if (skb_linearize(skb) < 0)
-		return NET_RX_DROP;
-
-	if (unlikely(!pskb_may_pull(skb, hdr_size)))
-		return NET_RX_DROP;
-
-	vis_packet = (struct batadv_vis_packet *)skb->data;
-	ethhdr = eth_hdr(skb);
-
-	/* not for me */
-	if (!batadv_is_my_mac(bat_priv, ethhdr->h_dest))
-		return NET_RX_DROP;
-
-	/* ignore own packets */
-	if (batadv_is_my_mac(bat_priv, vis_packet->vis_orig))
-		return NET_RX_DROP;
-
-	if (batadv_is_my_mac(bat_priv, vis_packet->sender_orig))
-		return NET_RX_DROP;
-
-	switch (vis_packet->vis_type) {
-	case BATADV_VIS_TYPE_SERVER_SYNC:
-		batadv_receive_server_sync_packet(bat_priv, vis_packet,
-						  skb_headlen(skb));
-		break;
-
-	case BATADV_VIS_TYPE_CLIENT_UPDATE:
-		batadv_receive_client_update_packet(bat_priv, vis_packet,
-						    skb_headlen(skb));
-		break;
-
-	default:	/* ignore unknown packet */
-		break;
-	}
-
-	/* We take a copy of the data in the packet, so we should
-	 * always free the skbuf.
-	 */
-	return NET_RX_DROP;
-}
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 0a7983b..b3f53d4 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -34,8 +34,6 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 				  struct batadv_hard_iface *recv_if);
 int batadv_recv_bcast_packet(struct sk_buff *skb,
 			     struct batadv_hard_iface *recv_if);
-int batadv_recv_vis_packet(struct sk_buff *skb,
-			   struct batadv_hard_iface *recv_if);
 int batadv_recv_tt_query(struct sk_buff *skb,
 			 struct batadv_hard_iface *recv_if);
 int batadv_recv_roam_adv(struct sk_buff *skb,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 0266edd..81d69fb 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -24,7 +24,6 @@
 #include "translation-table.h"
 #include "soft-interface.h"
 #include "hard-interface.h"
-#include "vis.h"
 #include "gateway_common.h"
 #include "originator.h"
 #include "network-coding.h"
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 84623a9..25e6004 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -469,7 +469,6 @@ static int batadv_softif_init_late(struct net_device *dev)
 	atomic_set(&bat_priv->distributed_arp_table, 1);
 #endif
 	atomic_set(&bat_priv->ap_isolation, 0);
-	atomic_set(&bat_priv->vis_mode, BATADV_VIS_TYPE_CLIENT_UPDATE);
 	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
 	atomic_set(&bat_priv->gw_sel_class, 20);
 	atomic_set(&bat_priv->gw.bandwidth_down, 100);
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index fbc1c25..869eb46 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -26,7 +26,6 @@
 #include "hard-interface.h"
 #include "gateway_common.h"
 #include "gateway_client.h"
-#include "vis.h"
 
 static struct net_device *batadv_kobj_to_netdev(struct kobject *obj)
 {
@@ -231,74 +230,6 @@ __batadv_store_uint_attr(const char *buff, size_t count,
 	return ret;
 }
 
-static ssize_t batadv_show_vis_mode(struct kobject *kobj,
-				    struct attribute *attr, char *buff)
-{
-	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
-	int vis_mode = atomic_read(&bat_priv->vis_mode);
-	const char *mode;
-
-	if (vis_mode == BATADV_VIS_TYPE_CLIENT_UPDATE)
-		mode = "client";
-	else
-		mode = "server";
-
-	return sprintf(buff, "%s\n", mode);
-}
-
-static ssize_t batadv_store_vis_mode(struct kobject *kobj,
-				     struct attribute *attr, char *buff,
-				     size_t count)
-{
-	struct net_device *net_dev = batadv_kobj_to_netdev(kobj);
-	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	unsigned long val;
-	int ret, vis_mode_tmp = -1;
-	const char *old_mode, *new_mode;
-
-	ret = kstrtoul(buff, 10, &val);
-
-	if (((count == 2) && (!ret) &&
-	     (val == BATADV_VIS_TYPE_CLIENT_UPDATE)) ||
-	    (strncmp(buff, "client", 6) == 0) ||
-	    (strncmp(buff, "off", 3) == 0))
-		vis_mode_tmp = BATADV_VIS_TYPE_CLIENT_UPDATE;
-
-	if (((count == 2) && (!ret) &&
-	     (val == BATADV_VIS_TYPE_SERVER_SYNC)) ||
-	    (strncmp(buff, "server", 6) == 0))
-		vis_mode_tmp = BATADV_VIS_TYPE_SERVER_SYNC;
-
-	if (vis_mode_tmp < 0) {
-		if (buff[count - 1] == '\n')
-			buff[count - 1] = '\0';
-
-		batadv_info(net_dev,
-			    "Invalid parameter for 'vis mode' setting received: %s\n",
-			    buff);
-		return -EINVAL;
-	}
-
-	if (atomic_read(&bat_priv->vis_mode) == vis_mode_tmp)
-		return count;
-
-	if (atomic_read(&bat_priv->vis_mode) == BATADV_VIS_TYPE_CLIENT_UPDATE)
-		old_mode =  "client";
-	else
-		old_mode = "server";
-
-	if (vis_mode_tmp == BATADV_VIS_TYPE_CLIENT_UPDATE)
-		new_mode =  "client";
-	else
-		new_mode = "server";
-
-	batadv_info(net_dev, "Changing vis mode from: %s to: %s\n", old_mode,
-		    new_mode);
-
-	atomic_set(&bat_priv->vis_mode, (unsigned int)vis_mode_tmp);
-	return count;
-}
-
 static ssize_t batadv_show_bat_algo(struct kobject *kobj,
 				    struct attribute *attr, char *buff)
 {
@@ -431,8 +362,6 @@ BATADV_ATTR_SIF_BOOL(distributed_arp_table, S_IRUGO | S_IWUSR,
 #endif
 BATADV_ATTR_SIF_BOOL(fragmentation, S_IRUGO | S_IWUSR, batadv_update_min_mtu);
 BATADV_ATTR_SIF_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
-static BATADV_ATTR(vis_mode, S_IRUGO | S_IWUSR, batadv_show_vis_mode,
-		   batadv_store_vis_mode);
 static BATADV_ATTR(routing_algo, S_IRUGO, batadv_show_bat_algo, NULL);
 static BATADV_ATTR(gw_mode, S_IRUGO | S_IWUSR, batadv_show_gw_mode,
 		   batadv_store_gw_mode);
@@ -463,7 +392,6 @@ static struct batadv_attribute *batadv_mesh_attrs[] = {
 #endif
 	&batadv_attr_fragmentation,
 	&batadv_attr_ap_isolation,
-	&batadv_attr_vis_mode,
 	&batadv_attr_routing_algo,
 	&batadv_attr_gw_mode,
 	&batadv_attr_orig_interval,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e98915a..8fbd89d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -99,7 +99,6 @@ struct batadv_hard_iface {
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
  * @batman_seqno_reset: time when the batman seqno window was reset
- * @flags: for now only VIS_SERVER flag
  * @capabilities: announced capabilities of this originator
  * @last_ttvn: last seen translation table version number
  * @tt_crc: CRC of the translation table
@@ -147,7 +146,6 @@ struct batadv_orig_node {
 	unsigned long last_seen;
 	unsigned long bcast_seqno_reset;
 	unsigned long batman_seqno_reset;
-	uint8_t flags;
 	uint8_t capabilities;
 	atomic_t last_ttvn;
 	uint32_t tt_crc;
@@ -462,24 +460,6 @@ struct batadv_priv_tvlv {
 };
 
 /**
- * struct batadv_priv_vis - per mesh interface vis data
- * @send_list: list of batadv_vis_info packets to sent
- * @hash: hash table containing vis data from other nodes in the network
- * @hash_lock: lock protecting the hash table
- * @list_lock: lock protecting my_info::recv_list
- * @work: work queue callback item for vis packet sending
- * @my_info: holds this node's vis data sent on a regular basis
- */
-struct batadv_priv_vis {
-	struct list_head send_list;
-	struct batadv_hashtable *hash;
-	spinlock_t hash_lock; /* protects hash */
-	spinlock_t list_lock; /* protects my_info::recv_list */
-	struct delayed_work work;
-	struct batadv_vis_info *my_info;
-};
-
-/**
  * struct batadv_priv_dat - per mesh interface DAT private data
  * @addr: node DAT address
  * @hash: hashtable representing the local ARP cache
@@ -536,7 +516,6 @@ struct batadv_priv_nc {
  *  enabled
  * @distributed_arp_table: bool indicating whether distributed ARP table is
  *  enabled
- * @vis_mode: vis operation: client or server (see batadv_vis_packettype)
  * @gw_mode: gateway operation: off, client or server (see batadv_gw_modes)
  * @gw_sel_class: gateway selection class (applies if gw_mode client)
  * @orig_interval: OGM broadcast interval in milliseconds
@@ -563,7 +542,6 @@ struct batadv_priv_nc {
  * @gw: gateway data
  * @tt: translation table data
  * @tvlv: type-version-length-value data
- * @vis: vis data
  * @dat: distributed arp table data
  * @network_coding: bool indicating whether network coding is enabled
  * @batadv_priv_nc: network coding data
@@ -583,7 +561,6 @@ struct batadv_priv {
 #ifdef CONFIG_BATMAN_ADV_DAT
 	atomic_t distributed_arp_table;
 #endif
-	atomic_t vis_mode;
 	atomic_t gw_mode;
 	atomic_t gw_sel_class;
 	atomic_t orig_interval;
@@ -615,7 +592,6 @@ struct batadv_priv {
 	struct batadv_priv_gw gw;
 	struct batadv_priv_tt tt;
 	struct batadv_priv_tvlv tvlv;
-	struct batadv_priv_vis vis;
 #ifdef CONFIG_BATMAN_ADV_DAT
 	struct batadv_priv_dat dat;
 #endif
@@ -910,66 +886,6 @@ struct batadv_frag_packet_list_entry {
 };
 
 /**
- * struct batadv_vis_info - local data for vis information
- * @first_seen: timestamp used for purging stale vis info entries
- * @recv_list: List of server-neighbors we have received this packet from. This
- *  packet should not be re-forward to them again. List elements are struct
- *  batadv_vis_recvlist_node
- * @send_list: list of packets to be forwarded
- * @refcount: number of contexts the object is used
- * @hash_entry: hlist node for batadv_priv_vis::hash
- * @bat_priv: pointer to soft_iface this orig node belongs to
- * @skb_packet: contains the vis packet
- */
-struct batadv_vis_info {
-	unsigned long first_seen;
-	struct list_head recv_list;
-	struct list_head send_list;
-	struct kref refcount;
-	struct hlist_node hash_entry;
-	struct batadv_priv *bat_priv;
-	struct sk_buff *skb_packet;
-} __packed;
-
-/**
- * struct batadv_vis_info_entry - contains link information for vis
- * @src: source MAC of the link, all zero for local TT entry
- * @dst: destination MAC of the link, client mac address for local TT entry
- * @quality: transmission quality of the link, or 0 for local TT entry
- */
-struct batadv_vis_info_entry {
-	uint8_t  src[ETH_ALEN];
-	uint8_t  dest[ETH_ALEN];
-	uint8_t  quality;
-} __packed;
-
-/**
- * struct batadv_vis_recvlist_node - list entry for batadv_vis_info::recv_list
- * @list: list node for batadv_vis_info::recv_list
- * @mac: MAC address of the originator from where the vis_info was received
- */
-struct batadv_vis_recvlist_node {
-	struct list_head list;
-	uint8_t mac[ETH_ALEN];
-};
-
-/**
- * struct batadv_vis_if_list_entry - auxiliary data for vis data generation
- * @addr: MAC address of the interface
- * @primary: true if this interface is the primary interface
- * @list: list node the interface list
- *
- * While scanning for vis-entries of a particular vis-originator
- * this list collects its interfaces to create a subgraph/cluster
- * out of them later
- */
-struct batadv_vis_if_list_entry {
-	uint8_t addr[ETH_ALEN];
-	bool primary;
-	struct hlist_node list;
-};
-
-/**
  * struct batadv_algo_ops - mesh algorithm callbacks
  * @list: list node for the batadv_algo_list
  * @name: name of the algorithm
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
deleted file mode 100644
index d8ea31a..0000000
--- a/net/batman-adv/vis.c
+++ /dev/null
@@ -1,938 +0,0 @@
-/* Copyright (C) 2008-2013 B.A.T.M.A.N. contributors:
- *
- * Simon Wunderlich
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
- */
-
-#include "main.h"
-#include "send.h"
-#include "translation-table.h"
-#include "vis.h"
-#include "soft-interface.h"
-#include "hard-interface.h"
-#include "hash.h"
-#include "originator.h"
-
-#define BATADV_MAX_VIS_PACKET_SIZE 1000
-
-/* hash class keys */
-static struct lock_class_key batadv_vis_hash_lock_class_key;
-
-/* free the info */
-static void batadv_free_info(struct kref *ref)
-{
-	struct batadv_vis_info *info;
-	struct batadv_priv *bat_priv;
-	struct batadv_vis_recvlist_node *entry, *tmp;
-
-	info = container_of(ref, struct batadv_vis_info, refcount);
-	bat_priv = info->bat_priv;
-
-	list_del_init(&info->send_list);
-	spin_lock_bh(&bat_priv->vis.list_lock);
-	list_for_each_entry_safe(entry, tmp, &info->recv_list, list) {
-		list_del(&entry->list);
-		kfree(entry);
-	}
-
-	spin_unlock_bh(&bat_priv->vis.list_lock);
-	kfree_skb(info->skb_packet);
-	kfree(info);
-}
-
-/* Compare two vis packets, used by the hashing algorithm */
-static int batadv_vis_info_cmp(const struct hlist_node *node, const void *data2)
-{
-	const struct batadv_vis_info *d1, *d2;
-	const struct batadv_vis_packet *p1, *p2;
-
-	d1 = container_of(node, struct batadv_vis_info, hash_entry);
-	d2 = data2;
-	p1 = (struct batadv_vis_packet *)d1->skb_packet->data;
-	p2 = (struct batadv_vis_packet *)d2->skb_packet->data;
-	return batadv_compare_eth(p1->vis_orig, p2->vis_orig);
-}
-
-/* hash function to choose an entry in a hash table of given size
- * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
- */
-static uint32_t batadv_vis_info_choose(const void *data, uint32_t size)
-{
-	const struct batadv_vis_info *vis_info = data;
-	const struct batadv_vis_packet *packet;
-	const unsigned char *key;
-	uint32_t hash = 0;
-	size_t i;
-
-	packet = (struct batadv_vis_packet *)vis_info->skb_packet->data;
-	key = packet->vis_orig;
-	for (i = 0; i < ETH_ALEN; i++) {
-		hash += key[i];
-		hash += (hash << 10);
-		hash ^= (hash >> 6);
-	}
-
-	hash += (hash << 3);
-	hash ^= (hash >> 11);
-	hash += (hash << 15);
-
-	return hash % size;
-}
-
-static struct batadv_vis_info *
-batadv_vis_hash_find(struct batadv_priv *bat_priv, const void *data)
-{
-	struct batadv_hashtable *hash = bat_priv->vis.hash;
-	struct hlist_head *head;
-	struct batadv_vis_info *vis_info, *vis_info_tmp = NULL;
-	uint32_t index;
-
-	if (!hash)
-		return NULL;
-
-	index = batadv_vis_info_choose(data, hash->size);
-	head = &hash->table[index];
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(vis_info, head, hash_entry) {
-		if (!batadv_vis_info_cmp(&vis_info->hash_entry, data))
-			continue;
-
-		vis_info_tmp = vis_info;
-		break;
-	}
-	rcu_read_unlock();
-
-	return vis_info_tmp;
-}
-
-/* insert interface to the list of interfaces of one originator, if it
- * does not already exist in the list
- */
-static void batadv_vis_data_insert_interface(const uint8_t *interface,
-					     struct hlist_head *if_list,
-					     bool primary)
-{
-	struct batadv_vis_if_list_entry *entry;
-
-	hlist_for_each_entry(entry, if_list, list) {
-		if (batadv_compare_eth(entry->addr, interface))
-			return;
-	}
-
-	/* it's a new address, add it to the list */
-	entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
-	if (!entry)
-		return;
-	memcpy(entry->addr, interface, ETH_ALEN);
-	entry->primary = primary;
-	hlist_add_head(&entry->list, if_list);
-}
-
-static void batadv_vis_data_read_prim_sec(struct seq_file *seq,
-					  const struct hlist_head *if_list)
-{
-	struct batadv_vis_if_list_entry *entry;
-
-	hlist_for_each_entry(entry, if_list, list) {
-		if (entry->primary)
-			seq_puts(seq, "PRIMARY, ");
-		else
-			seq_printf(seq,  "SEC %pM, ", entry->addr);
-	}
-}
-
-/* read an entry  */
-static ssize_t
-batadv_vis_data_read_entry(struct seq_file *seq,
-			   const struct batadv_vis_info_entry *entry,
-			   const uint8_t *src, bool primary)
-{
-	if (primary && entry->quality == 0)
-		return seq_printf(seq, "TT %pM, ", entry->dest);
-	else if (batadv_compare_eth(entry->src, src))
-		return seq_printf(seq, "TQ %pM %d, ", entry->dest,
-				  entry->quality);
-
-	return 0;
-}
-
-static void
-batadv_vis_data_insert_interfaces(struct hlist_head *list,
-				  struct batadv_vis_packet *packet,
-				  struct batadv_vis_info_entry *entries)
-{
-	int i;
-
-	for (i = 0; i < packet->entries; i++) {
-		if (entries[i].quality == 0)
-			continue;
-
-		if (batadv_compare_eth(entries[i].src, packet->vis_orig))
-			continue;
-
-		batadv_vis_data_insert_interface(entries[i].src, list, false);
-	}
-}
-
-static void batadv_vis_data_read_entries(struct seq_file *seq,
-					 struct hlist_head *list,
-					 struct batadv_vis_packet *packet,
-					 struct batadv_vis_info_entry *entries)
-{
-	int i;
-	struct batadv_vis_if_list_entry *entry;
-
-	hlist_for_each_entry(entry, list, list) {
-		seq_printf(seq, "%pM,", entry->addr);
-
-		for (i = 0; i < packet->entries; i++)
-			batadv_vis_data_read_entry(seq, &entries[i],
-						   entry->addr, entry->primary);
-
-		/* add primary/secondary records */
-		if (batadv_compare_eth(entry->addr, packet->vis_orig))
-			batadv_vis_data_read_prim_sec(seq, list);
-
-		seq_puts(seq, "\n");
-	}
-}
-
-static void batadv_vis_seq_print_text_bucket(struct seq_file *seq,
-					     const struct hlist_head *head)
-{
-	struct batadv_vis_info *info;
-	struct batadv_vis_packet *packet;
-	uint8_t *entries_pos;
-	struct batadv_vis_info_entry *entries;
-	struct batadv_vis_if_list_entry *entry;
-	struct hlist_node *n;
-
-	HLIST_HEAD(vis_if_list);
-
-	hlist_for_each_entry_rcu(info, head, hash_entry) {
-		packet = (struct batadv_vis_packet *)info->skb_packet->data;
-		entries_pos = (uint8_t *)packet + sizeof(*packet);
-		entries = (struct batadv_vis_info_entry *)entries_pos;
-
-		batadv_vis_data_insert_interface(packet->vis_orig, &vis_if_list,
-						 true);
-		batadv_vis_data_insert_interfaces(&vis_if_list, packet,
-						  entries);
-		batadv_vis_data_read_entries(seq, &vis_if_list, packet,
-					     entries);
-
-		hlist_for_each_entry_safe(entry, n, &vis_if_list, list) {
-			hlist_del(&entry->list);
-			kfree(entry);
-		}
-	}
-}
-
-int batadv_vis_seq_print_text(struct seq_file *seq, void *offset)
-{
-	struct batadv_hard_iface *primary_if;
-	struct hlist_head *head;
-	struct net_device *net_dev = (struct net_device *)seq->private;
-	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	struct batadv_hashtable *hash = bat_priv->vis.hash;
-	uint32_t i;
-	int ret = 0;
-	int vis_server = atomic_read(&bat_priv->vis_mode);
-
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
-	if (vis_server == BATADV_VIS_TYPE_CLIENT_UPDATE)
-		goto out;
-
-	spin_lock_bh(&bat_priv->vis.hash_lock);
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-		batadv_vis_seq_print_text_bucket(seq, head);
-	}
-	spin_unlock_bh(&bat_priv->vis.hash_lock);
-
-out:
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
-	return ret;
-}
-
-/* add the info packet to the send list, if it was not
- * already linked in.
- */
-static void batadv_send_list_add(struct batadv_priv *bat_priv,
-				 struct batadv_vis_info *info)
-{
-	if (list_empty(&info->send_list)) {
-		kref_get(&info->refcount);
-		list_add_tail(&info->send_list, &bat_priv->vis.send_list);
-	}
-}
-
-/* delete the info packet from the send list, if it was
- * linked in.
- */
-static void batadv_send_list_del(struct batadv_vis_info *info)
-{
-	if (!list_empty(&info->send_list)) {
-		list_del_init(&info->send_list);
-		kref_put(&info->refcount, batadv_free_info);
-	}
-}
-
-/* tries to add one entry to the receive list. */
-static void batadv_recv_list_add(struct batadv_priv *bat_priv,
-				 struct list_head *recv_list, const char *mac)
-{
-	struct batadv_vis_recvlist_node *entry;
-
-	entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
-	if (!entry)
-		return;
-
-	memcpy(entry->mac, mac, ETH_ALEN);
-	spin_lock_bh(&bat_priv->vis.list_lock);
-	list_add_tail(&entry->list, recv_list);
-	spin_unlock_bh(&bat_priv->vis.list_lock);
-}
-
-/* returns 1 if this mac is in the recv_list */
-static int batadv_recv_list_is_in(struct batadv_priv *bat_priv,
-				  const struct list_head *recv_list,
-				  const char *mac)
-{
-	const struct batadv_vis_recvlist_node *entry;
-
-	spin_lock_bh(&bat_priv->vis.list_lock);
-	list_for_each_entry(entry, recv_list, list) {
-		if (batadv_compare_eth(entry->mac, mac)) {
-			spin_unlock_bh(&bat_priv->vis.list_lock);
-			return 1;
-		}
-	}
-	spin_unlock_bh(&bat_priv->vis.list_lock);
-	return 0;
-}
-
-/* try to add the packet to the vis_hash. return NULL if invalid (e.g. too old,
- * broken.. ).	vis hash must be locked outside.  is_new is set when the packet
- * is newer than old entries in the hash.
- */
-static struct batadv_vis_info *
-batadv_add_packet(struct batadv_priv *bat_priv,
-		  struct batadv_vis_packet *vis_packet, int vis_info_len,
-		  int *is_new, int make_broadcast)
-{
-	struct batadv_vis_info *info, *old_info;
-	struct batadv_vis_packet *search_packet, *old_packet;
-	struct batadv_vis_info search_elem;
-	struct batadv_vis_packet *packet;
-	struct sk_buff *tmp_skb;
-	int hash_added;
-	size_t len;
-	size_t max_entries;
-
-	*is_new = 0;
-	/* sanity check */
-	if (!bat_priv->vis.hash)
-		return NULL;
-
-	/* see if the packet is already in vis_hash */
-	search_elem.skb_packet = dev_alloc_skb(sizeof(*search_packet));
-	if (!search_elem.skb_packet)
-		return NULL;
-	len = sizeof(*search_packet);
-	tmp_skb = search_elem.skb_packet;
-	search_packet = (struct batadv_vis_packet *)skb_put(tmp_skb, len);
-
-	memcpy(search_packet->vis_orig, vis_packet->vis_orig, ETH_ALEN);
-	old_info = batadv_vis_hash_find(bat_priv, &search_elem);
-	kfree_skb(search_elem.skb_packet);
-
-	if (old_info) {
-		tmp_skb = old_info->skb_packet;
-		old_packet = (struct batadv_vis_packet *)tmp_skb->data;
-		if (!batadv_seq_after(ntohl(vis_packet->seqno),
-				      ntohl(old_packet->seqno))) {
-			if (old_packet->seqno == vis_packet->seqno) {
-				batadv_recv_list_add(bat_priv,
-						     &old_info->recv_list,
-						     vis_packet->sender_orig);
-				return old_info;
-			} else {
-				/* newer packet is already in hash. */
-				return NULL;
-			}
-		}
-		/* remove old entry */
-		batadv_hash_remove(bat_priv->vis.hash, batadv_vis_info_cmp,
-				   batadv_vis_info_choose, old_info);
-		batadv_send_list_del(old_info);
-		kref_put(&old_info->refcount, batadv_free_info);
-	}
-
-	info = kmalloc(sizeof(*info), GFP_ATOMIC);
-	if (!info)
-		return NULL;
-
-	len = sizeof(*packet) + vis_info_len;
-	info->skb_packet = netdev_alloc_skb_ip_align(NULL, len + ETH_HLEN);
-	if (!info->skb_packet) {
-		kfree(info);
-		return NULL;
-	}
-	info->skb_packet->priority = TC_PRIO_CONTROL;
-	skb_reserve(info->skb_packet, ETH_HLEN);
-	packet = (struct batadv_vis_packet *)skb_put(info->skb_packet, len);
-
-	kref_init(&info->refcount);
-	INIT_LIST_HEAD(&info->send_list);
-	INIT_LIST_HEAD(&info->recv_list);
-	info->first_seen = jiffies;
-	info->bat_priv = bat_priv;
-	memcpy(packet, vis_packet, len);
-
-	/* initialize and add new packet. */
-	*is_new = 1;
-
-	/* Make it a broadcast packet, if required */
-	if (make_broadcast)
-		memcpy(packet->target_orig, batadv_broadcast_addr, ETH_ALEN);
-
-	/* repair if entries is longer than packet. */
-	max_entries = vis_info_len / sizeof(struct batadv_vis_info_entry);
-	if (packet->entries > max_entries)
-		packet->entries = max_entries;
-
-	batadv_recv_list_add(bat_priv, &info->recv_list, packet->sender_orig);
-
-	/* try to add it */
-	hash_added = batadv_hash_add(bat_priv->vis.hash, batadv_vis_info_cmp,
-				     batadv_vis_info_choose, info,
-				     &info->hash_entry);
-	if (hash_added != 0) {
-		/* did not work (for some reason) */
-		kref_put(&info->refcount, batadv_free_info);
-		info = NULL;
-	}
-
-	return info;
-}
-
-/* handle the server sync packet, forward if needed. */
-void batadv_receive_server_sync_packet(struct batadv_priv *bat_priv,
-				       struct batadv_vis_packet *vis_packet,
-				       int vis_info_len)
-{
-	struct batadv_vis_info *info;
-	int is_new, make_broadcast;
-	int vis_server = atomic_read(&bat_priv->vis_mode);
-
-	make_broadcast = (vis_server == BATADV_VIS_TYPE_SERVER_SYNC);
-
-	spin_lock_bh(&bat_priv->vis.hash_lock);
-	info = batadv_add_packet(bat_priv, vis_packet, vis_info_len,
-				 &is_new, make_broadcast);
-	if (!info)
-		goto end;
-
-	/* only if we are server ourselves and packet is newer than the one in
-	 * hash.
-	 */
-	if (vis_server == BATADV_VIS_TYPE_SERVER_SYNC && is_new)
-		batadv_send_list_add(bat_priv, info);
-end:
-	spin_unlock_bh(&bat_priv->vis.hash_lock);
-}
-
-/* handle an incoming client update packet and schedule forward if needed. */
-void batadv_receive_client_update_packet(struct batadv_priv *bat_priv,
-					 struct batadv_vis_packet *vis_packet,
-					 int vis_info_len)
-{
-	struct batadv_vis_info *info;
-	struct batadv_vis_packet *packet;
-	int is_new;
-	int vis_server = atomic_read(&bat_priv->vis_mode);
-	int are_target = 0;
-
-	/* clients shall not broadcast. */
-	if (is_broadcast_ether_addr(vis_packet->target_orig))
-		return;
-
-	/* Are we the target for this VIS packet? */
-	if (vis_server == BATADV_VIS_TYPE_SERVER_SYNC	&&
-	    batadv_is_my_mac(bat_priv, vis_packet->target_orig))
-		are_target = 1;
-
-	spin_lock_bh(&bat_priv->vis.hash_lock);
-	info = batadv_add_packet(bat_priv, vis_packet, vis_info_len,
-				 &is_new, are_target);
-
-	if (!info)
-		goto end;
-	/* note that outdated packets will be dropped at this point. */
-
-	packet = (struct batadv_vis_packet *)info->skb_packet->data;
-
-	/* send only if we're the target server or ... */
-	if (are_target && is_new) {
-		packet->vis_type = BATADV_VIS_TYPE_SERVER_SYNC;	/* upgrade! */
-		batadv_send_list_add(bat_priv, info);
-
-		/* ... we're not the recipient (and thus need to forward). */
-	} else if (!batadv_is_my_mac(bat_priv, packet->target_orig)) {
-		batadv_send_list_add(bat_priv, info);
-	}
-
-end:
-	spin_unlock_bh(&bat_priv->vis.hash_lock);
-}
-
-/* Walk the originators and find the VIS server with the best tq. Set the packet
- * address to its address and return the best_tq.
- *
- * Must be called with the originator hash locked
- */
-static int batadv_find_best_vis_server(struct batadv_priv *bat_priv,
-				       struct batadv_vis_info *info)
-{
-	struct batadv_hashtable *hash = bat_priv->orig_hash;
-	struct batadv_neigh_node *router;
-	struct hlist_head *head;
-	struct batadv_orig_node *orig_node;
-	struct batadv_vis_packet *packet;
-	int best_tq = -1;
-	uint32_t i;
-
-	packet = (struct batadv_vis_packet *)info->skb_packet->data;
-
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			router = batadv_orig_node_get_router(orig_node);
-			if (!router)
-				continue;
-
-			if ((orig_node->flags & BATADV_VIS_SERVER) &&
-			    (router->tq_avg > best_tq)) {
-				best_tq = router->tq_avg;
-				memcpy(packet->target_orig, orig_node->orig,
-				       ETH_ALEN);
-			}
-			batadv_neigh_node_free_ref(router);
-		}
-		rcu_read_unlock();
-	}
-
-	return best_tq;
-}
-
-/* Return true if the vis packet is full. */
-static bool batadv_vis_packet_full(const struct batadv_vis_info *info)
-{
-	const struct batadv_vis_packet *packet;
-	size_t num;
-
-	packet = (struct batadv_vis_packet *)info->skb_packet->data;
-	num = BATADV_MAX_VIS_PACKET_SIZE / sizeof(struct batadv_vis_info_entry);
-
-	if (num < packet->entries + 1)
-		return true;
-	return false;
-}
-
-/* generates a packet of own vis data,
- * returns 0 on success, -1 if no packet could be generated
- */
-static int batadv_generate_vis_packet(struct batadv_priv *bat_priv)
-{
-	struct batadv_hashtable *hash = bat_priv->orig_hash;
-	struct hlist_head *head;
-	struct batadv_orig_node *orig_node;
-	struct batadv_neigh_node *router;
-	struct batadv_vis_info *info = bat_priv->vis.my_info;
-	struct batadv_vis_packet *packet;
-	struct batadv_vis_info_entry *entry;
-	struct batadv_tt_common_entry *tt_common_entry;
-	uint8_t *packet_pos;
-	int best_tq = -1;
-	uint32_t i;
-
-	info->first_seen = jiffies;
-	packet = (struct batadv_vis_packet *)info->skb_packet->data;
-	packet->vis_type = atomic_read(&bat_priv->vis_mode);
-
-	memcpy(packet->target_orig, batadv_broadcast_addr, ETH_ALEN);
-	packet->header.ttl = BATADV_TTL;
-	packet->seqno = htonl(ntohl(packet->seqno) + 1);
-	packet->entries = 0;
-	packet->reserved = 0;
-	skb_trim(info->skb_packet, sizeof(*packet));
-
-	if (packet->vis_type == BATADV_VIS_TYPE_CLIENT_UPDATE) {
-		best_tq = batadv_find_best_vis_server(bat_priv, info);
-
-		if (best_tq < 0)
-			return best_tq;
-	}
-
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			router = batadv_orig_node_get_router(orig_node);
-			if (!router)
-				continue;
-
-			if (!batadv_compare_eth(router->addr, orig_node->orig))
-				goto next;
-
-			if (router->if_incoming->if_status != BATADV_IF_ACTIVE)
-				goto next;
-
-			if (router->tq_avg < 1)
-				goto next;
-
-			/* fill one entry into buffer. */
-			packet_pos = skb_put(info->skb_packet, sizeof(*entry));
-			entry = (struct batadv_vis_info_entry *)packet_pos;
-			memcpy(entry->src,
-			       router->if_incoming->net_dev->dev_addr,
-			       ETH_ALEN);
-			memcpy(entry->dest, orig_node->orig, ETH_ALEN);
-			entry->quality = router->tq_avg;
-			packet->entries++;
-
-next:
-			batadv_neigh_node_free_ref(router);
-
-			if (batadv_vis_packet_full(info))
-				goto unlock;
-		}
-		rcu_read_unlock();
-	}
-
-	hash = bat_priv->tt.local_hash;
-
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(tt_common_entry, head,
-					 hash_entry) {
-			packet_pos = skb_put(info->skb_packet, sizeof(*entry));
-			entry = (struct batadv_vis_info_entry *)packet_pos;
-			memset(entry->src, 0, ETH_ALEN);
-			memcpy(entry->dest, tt_common_entry->addr, ETH_ALEN);
-			entry->quality = 0; /* 0 means TT */
-			packet->entries++;
-
-			if (batadv_vis_packet_full(info))
-				goto unlock;
-		}
-		rcu_read_unlock();
-	}
-
-	return 0;
-
-unlock:
-	rcu_read_unlock();
-	return 0;
-}
-
-/* free old vis packets. Must be called with this vis_hash_lock
- * held
- */
-static void batadv_purge_vis_packets(struct batadv_priv *bat_priv)
-{
-	uint32_t i;
-	struct batadv_hashtable *hash = bat_priv->vis.hash;
-	struct hlist_node *node_tmp;
-	struct hlist_head *head;
-	struct batadv_vis_info *info;
-
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		hlist_for_each_entry_safe(info, node_tmp,
-					  head, hash_entry) {
-			/* never purge own data. */
-			if (info == bat_priv->vis.my_info)
-				continue;
-
-			if (batadv_has_timed_out(info->first_seen,
-						 BATADV_VIS_TIMEOUT)) {
-				hlist_del(&info->hash_entry);
-				batadv_send_list_del(info);
-				kref_put(&info->refcount, batadv_free_info);
-			}
-		}
-	}
-}
-
-static void batadv_broadcast_vis_packet(struct batadv_priv *bat_priv,
-					struct batadv_vis_info *info)
-{
-	struct batadv_hashtable *hash = bat_priv->orig_hash;
-	struct hlist_head *head;
-	struct batadv_orig_node *orig_node;
-	struct batadv_vis_packet *packet;
-	struct sk_buff *skb;
-	uint32_t i, res;
-
-
-	packet = (struct batadv_vis_packet *)info->skb_packet->data;
-
-	/* send to all routers in range. */
-	for (i = 0; i < hash->size; i++) {
-		head = &hash->table[i];
-
-		rcu_read_lock();
-		hlist_for_each_entry_rcu(orig_node, head, hash_entry) {
-			/* if it's a vis server and reachable, send it. */
-			if (!(orig_node->flags & BATADV_VIS_SERVER))
-				continue;
-
-			/* don't send it if we already received the packet from
-			 * this node.
-			 */
-			if (batadv_recv_list_is_in(bat_priv, &info->recv_list,
-						   orig_node->orig))
-				continue;
-
-			memcpy(packet->target_orig, orig_node->orig, ETH_ALEN);
-			skb = skb_clone(info->skb_packet, GFP_ATOMIC);
-			if (!skb)
-				continue;
-
-			res = batadv_send_skb_to_orig(skb, orig_node, NULL);
-			if (res == NET_XMIT_DROP)
-				kfree_skb(skb);
-		}
-		rcu_read_unlock();
-	}
-}
-
-static void batadv_unicast_vis_packet(struct batadv_priv *bat_priv,
-				      struct batadv_vis_info *info)
-{
-	struct batadv_orig_node *orig_node;
-	struct sk_buff *skb;
-	struct batadv_vis_packet *packet;
-
-	packet = (struct batadv_vis_packet *)info->skb_packet->data;
-
-	orig_node = batadv_orig_hash_find(bat_priv, packet->target_orig);
-	if (!orig_node)
-		goto out;
-
-	skb = skb_clone(info->skb_packet, GFP_ATOMIC);
-	if (!skb)
-		goto out;
-
-	if (batadv_send_skb_to_orig(skb, orig_node, NULL) == NET_XMIT_DROP)
-		kfree_skb(skb);
-
-out:
-	if (orig_node)
-		batadv_orig_node_free_ref(orig_node);
-}
-
-/* only send one vis packet. called from batadv_send_vis_packets() */
-static void batadv_send_vis_packet(struct batadv_priv *bat_priv,
-				   struct batadv_vis_info *info)
-{
-	struct batadv_hard_iface *primary_if;
-	struct batadv_vis_packet *packet;
-
-	primary_if = batadv_primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
-	packet = (struct batadv_vis_packet *)info->skb_packet->data;
-	if (packet->header.ttl < 2) {
-		pr_debug("Error - can't send vis packet: ttl exceeded\n");
-		goto out;
-	}
-
-	memcpy(packet->sender_orig, primary_if->net_dev->dev_addr, ETH_ALEN);
-	packet->header.ttl--;
-
-	if (is_broadcast_ether_addr(packet->target_orig))
-		batadv_broadcast_vis_packet(bat_priv, info);
-	else
-		batadv_unicast_vis_packet(bat_priv, info);
-	packet->header.ttl++; /* restore TTL */
-
-out:
-	if (primary_if)
-		batadv_hardif_free_ref(primary_if);
-}
-
-/* called from timer; send (and maybe generate) vis packet. */
-static void batadv_send_vis_packets(struct work_struct *work)
-{
-	struct delayed_work *delayed_work;
-	struct batadv_priv *bat_priv;
-	struct batadv_priv_vis *priv_vis;
-	struct batadv_vis_info *info;
-
-	delayed_work = container_of(work, struct delayed_work, work);
-	priv_vis = container_of(delayed_work, struct batadv_priv_vis, work);
-	bat_priv = container_of(priv_vis, struct batadv_priv, vis);
-	spin_lock_bh(&bat_priv->vis.hash_lock);
-	batadv_purge_vis_packets(bat_priv);
-
-	if (batadv_generate_vis_packet(bat_priv) == 0) {
-		/* schedule if generation was successful */
-		batadv_send_list_add(bat_priv, bat_priv->vis.my_info);
-	}
-
-	while (!list_empty(&bat_priv->vis.send_list)) {
-		info = list_first_entry(&bat_priv->vis.send_list,
-					typeof(*info), send_list);
-
-		kref_get(&info->refcount);
-		spin_unlock_bh(&bat_priv->vis.hash_lock);
-
-		batadv_send_vis_packet(bat_priv, info);
-
-		spin_lock_bh(&bat_priv->vis.hash_lock);
-		batadv_send_list_del(info);
-		kref_put(&info->refcount, batadv_free_info);
-	}
-	spin_unlock_bh(&bat_priv->vis.hash_lock);
-
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis.work,
-			   msecs_to_jiffies(BATADV_VIS_INTERVAL));
-}
-
-/* init the vis server. this may only be called when if_list is already
- * initialized (e.g. bat0 is initialized, interfaces have been added)
- */
-int batadv_vis_init(struct batadv_priv *bat_priv)
-{
-	struct batadv_vis_packet *packet;
-	int hash_added;
-	unsigned int len;
-	unsigned long first_seen;
-	struct sk_buff *tmp_skb;
-
-	if (bat_priv->vis.hash)
-		return 0;
-
-	spin_lock_bh(&bat_priv->vis.hash_lock);
-
-	bat_priv->vis.hash = batadv_hash_new(256);
-	if (!bat_priv->vis.hash) {
-		pr_err("Can't initialize vis_hash\n");
-		goto err;
-	}
-
-	batadv_hash_set_lock_class(bat_priv->vis.hash,
-				   &batadv_vis_hash_lock_class_key);
-
-	bat_priv->vis.my_info = kmalloc(BATADV_MAX_VIS_PACKET_SIZE, GFP_ATOMIC);
-	if (!bat_priv->vis.my_info)
-		goto err;
-
-	len = sizeof(*packet) + BATADV_MAX_VIS_PACKET_SIZE + ETH_HLEN;
-	bat_priv->vis.my_info->skb_packet = netdev_alloc_skb_ip_align(NULL,
-								      len);
-	if (!bat_priv->vis.my_info->skb_packet)
-		goto free_info;
-
-	bat_priv->vis.my_info->skb_packet->priority = TC_PRIO_CONTROL;
-	skb_reserve(bat_priv->vis.my_info->skb_packet, ETH_HLEN);
-	tmp_skb = bat_priv->vis.my_info->skb_packet;
-	packet = (struct batadv_vis_packet *)skb_put(tmp_skb, sizeof(*packet));
-
-	/* prefill the vis info */
-	first_seen = jiffies - msecs_to_jiffies(BATADV_VIS_INTERVAL);
-	bat_priv->vis.my_info->first_seen = first_seen;
-	INIT_LIST_HEAD(&bat_priv->vis.my_info->recv_list);
-	INIT_LIST_HEAD(&bat_priv->vis.my_info->send_list);
-	kref_init(&bat_priv->vis.my_info->refcount);
-	bat_priv->vis.my_info->bat_priv = bat_priv;
-	packet->header.version = BATADV_COMPAT_VERSION;
-	packet->header.packet_type = BATADV_VIS;
-	packet->header.ttl = BATADV_TTL;
-	packet->seqno = 0;
-	packet->reserved = 0;
-	packet->entries = 0;
-
-	INIT_LIST_HEAD(&bat_priv->vis.send_list);
-
-	hash_added = batadv_hash_add(bat_priv->vis.hash, batadv_vis_info_cmp,
-				     batadv_vis_info_choose,
-				     bat_priv->vis.my_info,
-				     &bat_priv->vis.my_info->hash_entry);
-	if (hash_added != 0) {
-		pr_err("Can't add own vis packet into hash\n");
-		/* not in hash, need to remove it manually. */
-		kref_put(&bat_priv->vis.my_info->refcount, batadv_free_info);
-		goto err;
-	}
-
-	spin_unlock_bh(&bat_priv->vis.hash_lock);
-
-	INIT_DELAYED_WORK(&bat_priv->vis.work, batadv_send_vis_packets);
-	queue_delayed_work(batadv_event_workqueue, &bat_priv->vis.work,
-			   msecs_to_jiffies(BATADV_VIS_INTERVAL));
-
-	return 0;
-
-free_info:
-	kfree(bat_priv->vis.my_info);
-	bat_priv->vis.my_info = NULL;
-err:
-	spin_unlock_bh(&bat_priv->vis.hash_lock);
-	batadv_vis_quit(bat_priv);
-	return -ENOMEM;
-}
-
-/* Decrease the reference count on a hash item info */
-static void batadv_free_info_ref(struct hlist_node *node, void *arg)
-{
-	struct batadv_vis_info *info;
-
-	info = container_of(node, struct batadv_vis_info, hash_entry);
-	batadv_send_list_del(info);
-	kref_put(&info->refcount, batadv_free_info);
-}
-
-/* shutdown vis-server */
-void batadv_vis_quit(struct batadv_priv *bat_priv)
-{
-	if (!bat_priv->vis.hash)
-		return;
-
-	cancel_delayed_work_sync(&bat_priv->vis.work);
-
-	spin_lock_bh(&bat_priv->vis.hash_lock);
-	/* properly remove, kill timers ... */
-	batadv_hash_delete(bat_priv->vis.hash, batadv_free_info_ref, NULL);
-	bat_priv->vis.hash = NULL;
-	bat_priv->vis.my_info = NULL;
-	spin_unlock_bh(&bat_priv->vis.hash_lock);
-}
diff --git a/net/batman-adv/vis.h b/net/batman-adv/vis.h
deleted file mode 100644
index ad92b0e..0000000
--- a/net/batman-adv/vis.h
+++ /dev/null
@@ -1,36 +0,0 @@
-/* Copyright (C) 2008-2013 B.A.T.M.A.N. contributors:
- *
- * Simon Wunderlich, Marek Lindner
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
- * General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
- * 02110-1301, USA
- */
-
-#ifndef _NET_BATMAN_ADV_VIS_H_
-#define _NET_BATMAN_ADV_VIS_H_
-
-/* timeout of vis packets in milliseconds */
-#define BATADV_VIS_TIMEOUT		200000
-
-int batadv_vis_seq_print_text(struct seq_file *seq, void *offset);
-void batadv_receive_server_sync_packet(struct batadv_priv *bat_priv,
-				       struct batadv_vis_packet *vis_packet,
-				       int vis_info_len);
-void batadv_receive_client_update_packet(struct batadv_priv *bat_priv,
-					 struct batadv_vis_packet *vis_packet,
-					 int vis_info_len);
-int batadv_vis_init(struct batadv_priv *bat_priv);
-void batadv_vis_quit(struct batadv_priv *bat_priv);
-
-#endif /* _NET_BATMAN_ADV_VIS_H_ */
-- 
1.8.3.2
