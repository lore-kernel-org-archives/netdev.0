From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/15] batman-adv: introduce packet type handler array for incoming packets
Date: Wed, 25 Apr 2012 15:27:07 +0200
Message-ID: <1335360431-30027-12-git-send-email-ordex@autistici.org>
References: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:39030 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757309Ab2DYN01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 09:26:27 -0400
In-Reply-To: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The packet handler array replaces the growing switch statement, thus
dealing with incoming packets in a more efficient way. It also adds
to possibility to register packet handlers on the fly.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c |  114 ------------------------------------
 net/batman-adv/main.c           |  123 +++++++++++++++++++++++++++++++++++++++
 net/batman-adv/main.h           |    6 ++
 3 files changed, 129 insertions(+), 114 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 1393939..b49bf0d 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -33,12 +33,6 @@
 
 #include <linux/if_arp.h>
 
-
-static int batman_skb_recv(struct sk_buff *skb,
-			   struct net_device *dev,
-			   struct packet_type *ptype,
-			   struct net_device *orig_dev);
-
 void hardif_free_rcu(struct rcu_head *rcu)
 {
 	struct hard_iface *hard_iface;
@@ -554,114 +548,6 @@ out:
 	return NOTIFY_DONE;
 }
 
-/* incoming packets with the batman ethertype received on any active hard
- * interface */
-static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
-			   struct packet_type *ptype,
-			   struct net_device *orig_dev)
-{
-	struct bat_priv *bat_priv;
-	struct batman_ogm_packet *batman_ogm_packet;
-	struct hard_iface *hard_iface;
-	int ret;
-
-	hard_iface = container_of(ptype, struct hard_iface, batman_adv_ptype);
-	skb = skb_share_check(skb, GFP_ATOMIC);
-
-	/* skb was released by skb_share_check() */
-	if (!skb)
-		goto err_out;
-
-	/* packet should hold at least type and version */
-	if (unlikely(!pskb_may_pull(skb, 2)))
-		goto err_free;
-
-	/* expect a valid ethernet header here. */
-	if (unlikely(skb->mac_len != ETH_HLEN || !skb_mac_header(skb)))
-		goto err_free;
-
-	if (!hard_iface->soft_iface)
-		goto err_free;
-
-	bat_priv = netdev_priv(hard_iface->soft_iface);
-
-	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
-		goto err_free;
-
-	/* discard frames on not active interfaces */
-	if (hard_iface->if_status != IF_ACTIVE)
-		goto err_free;
-
-	batman_ogm_packet = (struct batman_ogm_packet *)skb->data;
-
-	if (batman_ogm_packet->header.version != COMPAT_VERSION) {
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"Drop packet: incompatible batman version (%i)\n",
-			batman_ogm_packet->header.version);
-		goto err_free;
-	}
-
-	/* all receive handlers return whether they received or reused
-	 * the supplied skb. if not, we have to free the skb. */
-
-	switch (batman_ogm_packet->header.packet_type) {
-		/* batman originator packet */
-	case BAT_IV_OGM:
-		ret = recv_bat_ogm_packet(skb, hard_iface);
-		break;
-
-		/* batman icmp packet */
-	case BAT_ICMP:
-		ret = recv_icmp_packet(skb, hard_iface);
-		break;
-
-		/* unicast packet */
-	case BAT_UNICAST:
-	case BAT_UNICAST_4ADDR:
-		ret = recv_unicast_packet(skb, hard_iface);
-		break;
-
-		/* fragmented unicast packet */
-	case BAT_UNICAST_FRAG:
-		ret = recv_ucast_frag_packet(skb, hard_iface);
-		break;
-
-		/* broadcast packet */
-	case BAT_BCAST:
-		ret = recv_bcast_packet(skb, hard_iface);
-		break;
-
-		/* vis packet */
-	case BAT_VIS:
-		ret = recv_vis_packet(skb, hard_iface);
-		break;
-		/* Translation table query (request or response) */
-	case BAT_TT_QUERY:
-		ret = recv_tt_query(skb, hard_iface);
-		break;
-		/* Roaming advertisement */
-	case BAT_ROAM_ADV:
-		ret = recv_roam_adv(skb, hard_iface);
-		break;
-	default:
-		ret = NET_RX_DROP;
-	}
-
-	if (ret == NET_RX_DROP)
-		kfree_skb(skb);
-
-	/* return NET_RX_SUCCESS in any case as we
-	 * most probably dropped the packet for
-	 * routing-logical reasons. */
-
-	return NET_RX_SUCCESS;
-
-err_free:
-	kfree_skb(skb);
-err_out:
-	return NET_RX_DROP;
-}
-
 /* This function returns true if the interface represented by ifindex is a
  * 802.11 wireless device */
 bool is_wifi_iface(int ifindex)
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 7913272..87af1a3 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -39,6 +39,7 @@
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
  * list traversals just rcu-locked */
 struct list_head hardif_list;
+static int (*recv_packet_handler[256])(struct sk_buff *, struct hard_iface *);
 char bat_routing_algo[20] = "BATMAN IV";
 static struct hlist_head bat_algo_list;
 
@@ -46,11 +47,15 @@ unsigned char broadcast_addr[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
 struct workqueue_struct *bat_event_workqueue;
 
+static void recv_handler_init(void);
+
 static int __init batman_init(void)
 {
 	INIT_LIST_HEAD(&hardif_list);
 	INIT_HLIST_HEAD(&bat_algo_list);
 
+	recv_handler_init();
+
 	bat_iv_init();
 
 	/* the name should not be longer than 10 chars - see
@@ -179,6 +184,124 @@ int is_my_mac(const uint8_t *addr)
 	return 0;
 }
 
+static int recv_unhandled_packet(struct sk_buff *skb,
+				 struct hard_iface *recv_if)
+{
+	return NET_RX_DROP;
+}
+
+/* incoming packets with the batman ethertype received on any active hard
+ * interface
+ */
+int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
+		    struct packet_type *ptype, struct net_device *orig_dev)
+{
+	struct bat_priv *bat_priv;
+	struct batman_ogm_packet *batman_ogm_packet;
+	struct hard_iface *hard_iface;
+	uint8_t idx;
+	int ret;
+
+	hard_iface = container_of(ptype, struct hard_iface, batman_adv_ptype);
+	skb = skb_share_check(skb, GFP_ATOMIC);
+
+	/* skb was released by skb_share_check() */
+	if (!skb)
+		goto err_out;
+
+	/* packet should hold at least type and version */
+	if (unlikely(!pskb_may_pull(skb, 2)))
+		goto err_free;
+
+	/* expect a valid ethernet header here. */
+	if (unlikely(skb->mac_len != ETH_HLEN || !skb_mac_header(skb)))
+		goto err_free;
+
+	if (!hard_iface->soft_iface)
+		goto err_free;
+
+	bat_priv = netdev_priv(hard_iface->soft_iface);
+
+	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
+		goto err_free;
+
+	/* discard frames on not active interfaces */
+	if (hard_iface->if_status != IF_ACTIVE)
+		goto err_free;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)skb->data;
+
+	if (batman_ogm_packet->header.version != COMPAT_VERSION) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: incompatible batman version (%i)\n",
+			batman_ogm_packet->header.version);
+		goto err_free;
+	}
+
+	/* all receive handlers return whether they received or reused
+	 * the supplied skb. if not, we have to free the skb.
+	 */
+	idx = batman_ogm_packet->header.packet_type;
+	ret = (*recv_packet_handler[idx])(skb, hard_iface);
+
+	if (ret == NET_RX_DROP)
+		kfree_skb(skb);
+
+	/* return NET_RX_SUCCESS in any case as we
+	 * most probably dropped the packet for
+	 * routing-logical reasons.
+	 */
+	return NET_RX_SUCCESS;
+
+err_free:
+	kfree_skb(skb);
+err_out:
+	return NET_RX_DROP;
+}
+
+static void recv_handler_init(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(recv_packet_handler); i++)
+		recv_packet_handler[i] = recv_unhandled_packet;
+
+	/* batman originator packet */
+	recv_packet_handler[BAT_IV_OGM] = recv_bat_ogm_packet;
+	/* batman icmp packet */
+	recv_packet_handler[BAT_ICMP] = recv_icmp_packet;
+	/* unicast with 4 addresses packet */
+	recv_packet_handler[BAT_UNICAST_4ADDR] = recv_unicast_packet;
+	/* unicast packet */
+	recv_packet_handler[BAT_UNICAST] = recv_unicast_packet;
+	/* fragmented unicast packet */
+	recv_packet_handler[BAT_UNICAST_FRAG] = recv_ucast_frag_packet;
+	/* broadcast packet */
+	recv_packet_handler[BAT_BCAST] = recv_bcast_packet;
+	/* vis packet */
+	recv_packet_handler[BAT_VIS] = recv_vis_packet;
+	/* Translation table query (request or response) */
+	recv_packet_handler[BAT_TT_QUERY] = recv_tt_query;
+	/* Roaming advertisement */
+	recv_packet_handler[BAT_ROAM_ADV] = recv_roam_adv;
+}
+
+int recv_handler_register(uint8_t packet_type,
+			  int (*recv_handler)(struct sk_buff *,
+					      struct hard_iface *))
+{
+	if (recv_packet_handler[packet_type] != &recv_unhandled_packet)
+		return -EBUSY;
+
+	recv_packet_handler[packet_type] = recv_handler;
+	return 0;
+}
+
+void recv_handler_unregister(uint8_t packet_type)
+{
+	recv_packet_handler[packet_type] = recv_unhandled_packet;
+}
+
 static struct bat_algo_ops *bat_algo_get(char *name)
 {
 	struct bat_algo_ops *bat_algo_ops = NULL, *bat_algo_ops_tmp;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index c11c8df..69b5173 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -168,6 +168,12 @@ void mesh_free(struct net_device *soft_iface);
 void inc_module_count(void);
 void dec_module_count(void);
 int is_my_mac(const uint8_t *addr);
+int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
+		    struct packet_type *ptype, struct net_device *orig_dev);
+int recv_handler_register(uint8_t packet_type,
+			  int (*recv_handler)(struct sk_buff *,
+					      struct hard_iface *));
+void recv_handler_unregister(uint8_t packet_type);
 int bat_algo_register(struct bat_algo_ops *bat_algo_ops);
 int bat_algo_select(struct bat_priv *bat_priv, char *name);
 int bat_algo_seq_print_text(struct seq_file *seq, void *offset);
-- 
1.7.9.4
