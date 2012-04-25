From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/15] batman-adv: register batman ogm receive function during protocol init
Date: Wed, 25 Apr 2012 15:27:08 +0200
Message-ID: <1335360431-30027-13-git-send-email-ordex@autistici.org>
References: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:38990 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757396Ab2DYN02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 09:26:28 -0400
In-Reply-To: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The B.A.T.M.A.N. IV OGM receive function still was hard-coded although
it is a routing protocol specific function. This patch takes advantage
of the dynamic packet handler registration to remove the hard-coded
function calls.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   31 +++++++++++++++++++++++++++----
 net/batman-adv/main.c       |    5 +----
 net/batman-adv/routing.c    |   22 ++++++++++------------
 net/batman-adv/routing.h    |    4 +++-
 net/batman-adv/types.h      |    3 ---
 5 files changed, 41 insertions(+), 24 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index cd8f473..e0aaf8c 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1155,13 +1155,18 @@ out:
 	orig_node_free_ref(orig_node);
 }
 
-static void bat_iv_ogm_receive(struct hard_iface *if_incoming,
-			       struct sk_buff *skb)
+static int bat_iv_ogm_receive(struct sk_buff *skb,
+			      struct hard_iface *if_incoming)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 	struct ethhdr *ethhdr;
 	int buff_pos = 0, packet_len;
 	unsigned char *tt_buff, *packet_buff;
+	bool ret;
+
+	ret = check_management_packet(skb, if_incoming, BATMAN_OGM_HLEN);
+	if (!ret)
+		return NET_RX_DROP;
 
 	packet_len = skb_headlen(skb);
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
@@ -1187,6 +1192,9 @@ static void bat_iv_ogm_receive(struct hard_iface *if_incoming,
 						(packet_buff + buff_pos);
 	} while (bat_iv_ogm_aggr_packet(buff_pos, packet_len,
 					batman_ogm_packet->tt_num_changes));
+
+	kfree_skb(skb);
+	return NET_RX_SUCCESS;
 }
 
 static struct bat_algo_ops batman_iv __read_mostly = {
@@ -1197,10 +1205,25 @@ static struct bat_algo_ops batman_iv __read_mostly = {
 	.bat_ogm_update_mac = bat_iv_ogm_update_mac,
 	.bat_ogm_schedule = bat_iv_ogm_schedule,
 	.bat_ogm_emit = bat_iv_ogm_emit,
-	.bat_ogm_receive = bat_iv_ogm_receive,
 };
 
 int __init bat_iv_init(void)
 {
-	return bat_algo_register(&batman_iv);
+	int ret;
+
+	/* batman originator packet */
+	ret = recv_handler_register(BAT_IV_OGM, bat_iv_ogm_receive);
+	if (ret < 0)
+		goto out;
+
+	ret = bat_algo_register(&batman_iv);
+	if (ret < 0)
+		goto handler_unregister;
+
+	goto out;
+
+handler_unregister:
+	recv_handler_unregister(BAT_IV_OGM);
+out:
+	return ret;
 }
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 87af1a3..7a3bfae 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -266,8 +266,6 @@ static void recv_handler_init(void)
 	for (i = 0; i < ARRAY_SIZE(recv_packet_handler); i++)
 		recv_packet_handler[i] = recv_unhandled_packet;
 
-	/* batman originator packet */
-	recv_packet_handler[BAT_IV_OGM] = recv_bat_ogm_packet;
 	/* batman icmp packet */
 	recv_packet_handler[BAT_ICMP] = recv_icmp_packet;
 	/* unicast with 4 addresses packet */
@@ -336,8 +334,7 @@ int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
 	    !bat_algo_ops->bat_primary_iface_set ||
 	    !bat_algo_ops->bat_ogm_update_mac ||
 	    !bat_algo_ops->bat_ogm_schedule ||
-	    !bat_algo_ops->bat_ogm_emit ||
-	    !bat_algo_ops->bat_ogm_receive) {
+	    !bat_algo_ops->bat_ogm_emit) {
 		pr_info("Routing algo '%s' does not implement required ops\n",
 			bat_algo_ops->name);
 		goto out;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 5f19bbb..83f8115 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -248,37 +248,35 @@ int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
 	return 0;
 }
 
-int recv_bat_ogm_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
+bool check_management_packet(struct sk_buff *skb,
+			     struct hard_iface *hard_iface,
+			     int header_len)
 {
-	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct ethhdr *ethhdr;
 
 	/* drop packet if it has not necessary minimum size */
-	if (unlikely(!pskb_may_pull(skb, BATMAN_OGM_HLEN)))
-		return NET_RX_DROP;
+	if (unlikely(!pskb_may_pull(skb, header_len)))
+		return false;
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
 	/* packet with broadcast indication but unicast recipient */
 	if (!is_broadcast_ether_addr(ethhdr->h_dest))
-		return NET_RX_DROP;
+		return false;
 
 	/* packet with broadcast sender address */
 	if (is_broadcast_ether_addr(ethhdr->h_source))
-		return NET_RX_DROP;
+		return false;
 
 	/* create a copy of the skb, if needed, to modify it. */
 	if (skb_cow(skb, 0) < 0)
-		return NET_RX_DROP;
+		return false;
 
 	/* keep skb linear */
 	if (skb_linearize(skb) < 0)
-		return NET_RX_DROP;
+		return false;
 
-	bat_priv->bat_algo_ops->bat_ogm_receive(hard_iface, skb);
-
-	kfree_skb(skb);
-	return NET_RX_SUCCESS;
+	return true;
 }
 
 static int recv_my_icmp_packet(struct bat_priv *bat_priv,
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 3d729cb..d6bbbeb 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -23,6 +23,9 @@
 #define _NET_BATMAN_ADV_ROUTING_H_
 
 void slide_own_bcast_window(struct hard_iface *hard_iface);
+bool check_management_packet(struct sk_buff *skb,
+			     struct hard_iface *hard_iface,
+			     int header_len);
 void update_route(struct bat_priv *bat_priv, struct orig_node *orig_node,
 		  struct neigh_node *neigh_node);
 int recv_icmp_packet(struct sk_buff *skb, struct hard_iface *recv_if);
@@ -30,7 +33,6 @@ int recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_ucast_frag_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_vis_packet(struct sk_buff *skb, struct hard_iface *recv_if);
-int recv_bat_ogm_packet(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if);
 int recv_roam_adv(struct sk_buff *skb, struct hard_iface *recv_if);
 struct neigh_node *find_router(struct bat_priv *bat_priv,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 2b8ffcb..ed6db5c 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -407,9 +407,6 @@ struct bat_algo_ops {
 				 int tt_num_changes);
 	/* send scheduled OGM */
 	void (*bat_ogm_emit)(struct forw_packet *forw_packet);
-	/* receive incoming OGM */
-	void (*bat_ogm_receive)(struct hard_iface *if_incoming,
-				struct sk_buff *skb);
 };
 
 struct dht_candidate {
-- 
1.7.9.4
