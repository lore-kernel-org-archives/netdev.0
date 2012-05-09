From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 11/14] batman-adv: Adding hard_iface specific sysfs wrapper macros for UINT
Date: Wed,  9 May 2012 13:12:53 +0200
Message-ID: <1336561976-16088-12-git-send-email-ordex@autistici.org>
References: <1336561976-16088-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Linus Luessing <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:52797 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758056Ab2EILMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 07:12:50 -0400
In-Reply-To: <1336561976-16088-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Luessing <linus.luessing@web.de>

This allows us to easily add a sysfs parameter for an unsigned int
later, which is not for a batman mesh interface (e.g. bat0), but for a
common interface instead. It allows reading and writing an atomic_t in
hard_iface (instead of bat_priv compared to the mesh variant).

Developed by Linus during a 6 months trainee study period in Ascom
(Switzerland) AG.

Signed-off-by: Linus Luessing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |   61 +++++++++++++++++++++++--------------------
 net/batman-adv/bat_sysfs.c  |   43 ++++++++++++++++++++++++++++++
 net/batman-adv/packet.h     |    1 +
 3 files changed, 76 insertions(+), 29 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a0fe1de..cc160c0 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -507,11 +507,10 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 			       const struct ethhdr *ethhdr,
 			       struct batman_ogm_packet *batman_ogm_packet,
 			       bool is_single_hop_neigh,
+			       bool is_from_best_next_hop,
 			       struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct neigh_node *router;
-	uint8_t in_tq, in_ttl, tq_avg = 0;
 	uint8_t tt_num_changes;
 
 	if (batman_ogm_packet->header.ttl <= 1) {
@@ -519,41 +518,31 @@ static void bat_iv_ogm_forward(struct orig_node *orig_node,
 		return;
 	}
 
-	router = orig_node_get_router(orig_node);
+	if (!is_from_best_next_hop) {
+		/**
+		* Mark the forwarded packet when it is not coming from our best
+		* next hop. We still need to forward the packet for our neighbor
+		* link quality detection to work in case the packet originated
+		* from a single hop neighbor. Otherwise we can simply drop the
+		* ogm.
+		*/
+		if (is_single_hop_neigh)
+			batman_ogm_packet->flags |= NOT_BEST_NEXT_HOP;
+		else
+			return;
+	}
 
-	in_tq = batman_ogm_packet->tq;
-	in_ttl = batman_ogm_packet->header.ttl;
 	tt_num_changes = batman_ogm_packet->tt_num_changes;
 
 	batman_ogm_packet->header.ttl--;
 	memcpy(batman_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
 
-	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcast
-	 * of our best tq value */
-	if (router && router->tq_avg != 0) {
-
-		/* rebroadcast ogm of best ranking neighbor as is */
-		if (!compare_eth(router->addr, ethhdr->h_source)) {
-			batman_ogm_packet->tq = router->tq_avg;
-
-			if (router->last_ttl)
-				batman_ogm_packet->header.ttl =
-					router->last_ttl - 1;
-		}
-
-		tq_avg = router->tq_avg;
-	}
-
-	if (router)
-		neigh_node_free_ref(router);
-
 	/* apply hop penalty */
 	batman_ogm_packet->tq = hop_penalty(batman_ogm_packet->tq, bat_priv);
 
 	bat_dbg(DBG_BATMAN, bat_priv,
-		"Forwarding packet: tq_orig: %i, tq_avg: %i, tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
-		in_tq, tq_avg, batman_ogm_packet->tq, in_ttl - 1,
-		batman_ogm_packet->header.ttl);
+		"Forwarding packet: tq: %i, ttl: %i\n",
+		batman_ogm_packet->tq, batman_ogm_packet->header.ttl);
 
 	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
 	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
@@ -949,6 +938,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	int is_my_addr = 0, is_my_orig = 0, is_my_oldorig = 0;
 	int is_broadcast = 0, is_bidirectional;
 	bool is_single_hop_neigh = false;
+	bool is_from_best_next_hop = false;
 	int is_duplicate;
 	uint32_t if_incoming_seqno;
 
@@ -1070,6 +1060,13 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 		return;
 	}
 
+	if (batman_ogm_packet->flags & NOT_BEST_NEXT_HOP) {
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"Drop packet: ignoring all packets not forwarded from "
+			"the best next hop (sender: %pM)\n", ethhdr->h_source);
+		return;
+	}
+
 	orig_node = get_orig_node(bat_priv, batman_ogm_packet->orig);
 	if (!orig_node)
 		return;
@@ -1094,6 +1091,10 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	if (router)
 		router_router = orig_node_get_router(router->orig_node);
 
+	if ((router && router->tq_avg != 0) &&
+	    (compare_eth(router->addr, ethhdr->h_source)))
+		is_from_best_next_hop = true;
+
 	/* avoid temporary routing loops */
 	if (router && router_router &&
 	    (compare_eth(router->addr, batman_ogm_packet->prev_sender)) &&
@@ -1144,7 +1145,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 
 		/* mark direct link on incoming interface */
 		bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-				   is_single_hop_neigh, if_incoming);
+				   is_single_hop_neigh, is_from_best_next_hop,
+				   if_incoming);
 
 		bat_dbg(DBG_BATMAN, bat_priv,
 			"Forwarding packet: rebroadcast neighbor packet with direct link flag\n");
@@ -1167,7 +1169,8 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
 	bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-			   is_single_hop_neigh, if_incoming);
+			   is_single_hop_neigh, is_from_best_next_hop,
+			   if_incoming);
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 913299d..5bc7b66 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -117,6 +117,49 @@ ssize_t show_##_name(struct kobject *kobj,				\
 	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
 
 
+#define BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)		\
+ssize_t store_##_name(struct kobject *kobj, struct attribute *attr,	\
+		      char *buff, size_t count)				\
+{									\
+	struct net_device *net_dev = kobj_to_netdev(kobj);		\
+	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);	\
+	ssize_t length;							\
+									\
+	if (!hard_iface)						\
+		return 0;						\
+									\
+	length = __store_uint_attr(buff, count, _min, _max, _post_func,	\
+				   attr, &hard_iface->_name, net_dev);	\
+									\
+	hardif_free_ref(hard_iface);					\
+	return length;							\
+}
+
+#define BAT_ATTR_HIF_SHOW_UINT(_name)					\
+ssize_t show_##_name(struct kobject *kobj,				\
+		     struct attribute *attr, char *buff)		\
+{									\
+	struct net_device *net_dev = kobj_to_netdev(kobj);		\
+	struct hard_iface *hard_iface = hardif_get_by_netdev(net_dev);	\
+	ssize_t length;							\
+									\
+	if (!hard_iface)						\
+		return 0;						\
+									\
+	length = sprintf(buff, "%i\n", atomic_read(&hard_iface->_name));\
+									\
+	hardif_free_ref(hard_iface);					\
+	return length;							\
+}
+
+/* Use this, if you are going to set [name] in hard_iface to an
+ * unsigned integer value*/
+#define BAT_ATTR_HIF_UINT(_name, _mode, _min, _max, _post_func)		\
+	static BAT_ATTR_HIF_STORE_UINT(_name, _min, _max, _post_func)	\
+	static BAT_ATTR_HIF_SHOW_UINT(_name)				\
+	static BAT_ATTR(_name, _mode, show_##_name, store_##_name)
+
+
 static int store_bool_attr(char *buff, size_t count,
 			   struct net_device *net_dev,
 			   const char *attr_name, atomic_t *attr)
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index f54969c..0ee1af7 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -39,6 +39,7 @@ enum bat_packettype {
 #define COMPAT_VERSION 14
 
 enum batman_iv_flags {
+	NOT_BEST_NEXT_HOP   = 1 << 3,
 	PRIMARIES_FIRST_HOP = 1 << 4,
 	VIS_SERVER	    = 1 << 5,
 	DIRECTLINK	    = 1 << 6
-- 
1.7.9.4
