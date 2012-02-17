From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 08/10] batman-adv: convert batman iv algorithm to use dynamic infrastructure
Date: Fri, 17 Feb 2012 15:18:28 +0800
Message-ID: <1329463110-856-9-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm18-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.95]:34370 "HELO
	nm18-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751714Ab2BQHTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:19:41 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/bat_iv_ogm.c     |  179 ++++++++++++++++++++------------------
 net/batman-adv/bat_ogm.h        |   34 --------
 net/batman-adv/hard-interface.c |   10 +-
 net/batman-adv/main.c           |   12 +++
 net/batman-adv/routing.c        |    4 +-
 net/batman-adv/send.c           |    5 +-
 net/batman-adv/types.h          |   14 +++
 7 files changed, 129 insertions(+), 129 deletions(-)
 delete mode 100644 net/batman-adv/bat_ogm.h

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 1847efa..1c483a5 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -20,7 +20,6 @@
  */
 
 #include "main.h"
-#include "bat_ogm.h"
 #include "translation-table.h"
 #include "ring_buffer.h"
 #include "originator.h"
@@ -31,7 +30,7 @@
 #include "send.h"
 #include "bat_algo.h"
 
-void bat_ogm_init(struct hard_iface *hard_iface)
+static void bat_iv_ogm_init(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 
@@ -48,7 +47,7 @@ void bat_ogm_init(struct hard_iface *hard_iface)
 	batman_ogm_packet->ttvn = 0;
 }
 
-void bat_ogm_init_primary(struct hard_iface *hard_iface)
+static void bat_iv_ogm_init_primary(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 
@@ -57,7 +56,7 @@ void bat_ogm_init_primary(struct hard_iface *hard_iface)
 	batman_ogm_packet->header.ttl = TTL;
 }
 
-void bat_ogm_update_mac(struct hard_iface *hard_iface)
+static void bat_iv_ogm_update_mac(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 
@@ -69,7 +68,7 @@ void bat_ogm_update_mac(struct hard_iface *hard_iface)
 }
 
 /* when do we schedule our own ogm to be sent */
-static unsigned long bat_ogm_emit_send_time(const struct bat_priv *bat_priv)
+static unsigned long bat_iv_ogm_emit_send_time(const struct bat_priv *bat_priv)
 {
 	return jiffies + msecs_to_jiffies(
 		   atomic_read(&bat_priv->orig_interval) -
@@ -77,7 +76,7 @@ static unsigned long bat_ogm_emit_send_time(const struct bat_priv *bat_priv)
 }
 
 /* when do we schedule a ogm packet to be sent */
-static unsigned long bat_ogm_fwd_send_time(void)
+static unsigned long bat_iv_ogm_fwd_send_time(void)
 {
 	return jiffies + msecs_to_jiffies(random32() % (JITTER/2));
 }
@@ -90,8 +89,8 @@ static uint8_t hop_penalty(uint8_t tq, const struct bat_priv *bat_priv)
 }
 
 /* is there another aggregated packet here? */
-static int bat_ogm_aggr_packet(int buff_pos, int packet_len,
-			       int tt_num_changes)
+static int bat_iv_ogm_aggr_packet(int buff_pos, int packet_len,
+				  int tt_num_changes)
 {
 	int next_buff_pos = buff_pos + BATMAN_OGM_LEN + tt_len(tt_num_changes);
 
@@ -100,8 +99,8 @@ static int bat_ogm_aggr_packet(int buff_pos, int packet_len,
 }
 
 /* send a batman ogm to a given interface */
-static void bat_ogm_send_to_if(struct forw_packet *forw_packet,
-			       struct hard_iface *hard_iface)
+static void bat_iv_ogm_send_to_if(struct forw_packet *forw_packet,
+				  struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	char *fwd_str;
@@ -118,8 +117,8 @@ static void bat_ogm_send_to_if(struct forw_packet *forw_packet,
 	batman_ogm_packet = (struct batman_ogm_packet *)forw_packet->skb->data;
 
 	/* adjust all flags and log packets */
-	while (bat_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
-				   batman_ogm_packet->tt_num_changes)) {
+	while (bat_iv_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
+				      batman_ogm_packet->tt_num_changes)) {
 
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet */
@@ -158,7 +157,7 @@ static void bat_ogm_send_to_if(struct forw_packet *forw_packet,
 }
 
 /* send a batman ogm packet */
-void bat_ogm_emit(struct forw_packet *forw_packet)
+static void bat_iv_ogm_emit(struct forw_packet *forw_packet)
 {
 	struct hard_iface *hard_iface;
 	struct net_device *soft_iface;
@@ -217,7 +216,7 @@ void bat_ogm_emit(struct forw_packet *forw_packet)
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
-		bat_ogm_send_to_if(forw_packet, hard_iface);
+		bat_iv_ogm_send_to_if(forw_packet, hard_iface);
 	}
 	rcu_read_unlock();
 
@@ -227,13 +226,13 @@ out:
 }
 
 /* return true if new_packet can be aggregated with forw_packet */
-static bool bat_ogm_can_aggregate(const struct batman_ogm_packet
+static bool bat_iv_ogm_can_aggregate(const struct batman_ogm_packet
 							*new_batman_ogm_packet,
-				  struct bat_priv *bat_priv,
-				  int packet_len, unsigned long send_time,
-				  bool directlink,
-				  const struct hard_iface *if_incoming,
-				  const struct forw_packet *forw_packet)
+				     struct bat_priv *bat_priv,
+				     int packet_len, unsigned long send_time,
+				     bool directlink,
+				     const struct hard_iface *if_incoming,
+				     const struct forw_packet *forw_packet)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 	int aggregated_bytes = forw_packet->packet_len + packet_len;
@@ -307,11 +306,11 @@ out:
 }
 
 /* create a new aggregated packet and add this packet to it */
-static void bat_ogm_aggregate_new(const unsigned char *packet_buff,
-				  int packet_len, unsigned long send_time,
-				  bool direct_link,
-				  struct hard_iface *if_incoming,
-				  int own_packet)
+static void bat_iv_ogm_aggregate_new(const unsigned char *packet_buff,
+				     int packet_len, unsigned long send_time,
+				     bool direct_link,
+				     struct hard_iface *if_incoming,
+				     int own_packet)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct forw_packet *forw_packet_aggr;
@@ -386,9 +385,9 @@ out:
 }
 
 /* aggregate a new packet into the existing ogm packet */
-static void bat_ogm_aggregate(struct forw_packet *forw_packet_aggr,
-			      const unsigned char *packet_buff,
-			      int packet_len, bool direct_link)
+static void bat_iv_ogm_aggregate(struct forw_packet *forw_packet_aggr,
+				 const unsigned char *packet_buff,
+				 int packet_len, bool direct_link)
 {
 	unsigned char *skb_buff;
 
@@ -403,10 +402,10 @@ static void bat_ogm_aggregate(struct forw_packet *forw_packet_aggr,
 			(1 << forw_packet_aggr->num_packets);
 }
 
-static void bat_ogm_queue_add(struct bat_priv *bat_priv,
-			      unsigned char *packet_buff,
-			      int packet_len, struct hard_iface *if_incoming,
-			      int own_packet, unsigned long send_time)
+static void bat_iv_ogm_queue_add(struct bat_priv *bat_priv,
+				 unsigned char *packet_buff,
+				 int packet_len, struct hard_iface *if_incoming,
+				 int own_packet, unsigned long send_time)
 {
 	/**
 	 * _aggr -> pointer to the packet we want to aggregate with
@@ -426,11 +425,11 @@ static void bat_ogm_queue_add(struct bat_priv *bat_priv,
 	if ((atomic_read(&bat_priv->aggregated_ogms)) && (!own_packet)) {
 		hlist_for_each_entry(forw_packet_pos, tmp_node,
 				     &bat_priv->forw_bat_list, list) {
-			if (bat_ogm_can_aggregate(batman_ogm_packet,
-						  bat_priv, packet_len,
-						  send_time, direct_link,
-						  if_incoming,
-						  forw_packet_pos)) {
+			if (bat_iv_ogm_can_aggregate(batman_ogm_packet,
+						     bat_priv, packet_len,
+						     send_time, direct_link,
+						     if_incoming,
+						     forw_packet_pos)) {
 				forw_packet_aggr = forw_packet_pos;
 				break;
 			}
@@ -452,20 +451,20 @@ static void bat_ogm_queue_add(struct bat_priv *bat_priv,
 		    (atomic_read(&bat_priv->aggregated_ogms)))
 			send_time += msecs_to_jiffies(MAX_AGGREGATION_MS);
 
-		bat_ogm_aggregate_new(packet_buff, packet_len,
-				      send_time, direct_link,
-				      if_incoming, own_packet);
+		bat_iv_ogm_aggregate_new(packet_buff, packet_len,
+					 send_time, direct_link,
+					 if_incoming, own_packet);
 	} else {
-		bat_ogm_aggregate(forw_packet_aggr, packet_buff, packet_len,
-				  direct_link);
+		bat_iv_ogm_aggregate(forw_packet_aggr, packet_buff,
+				     packet_len, direct_link);
 		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
 	}
 }
 
-static void bat_ogm_forward(struct orig_node *orig_node,
-			    const struct ethhdr *ethhdr,
-			    struct batman_ogm_packet *batman_ogm_packet,
-			    int directlink, struct hard_iface *if_incoming)
+static void bat_iv_ogm_forward(struct orig_node *orig_node,
+			       const struct ethhdr *ethhdr,
+			       struct batman_ogm_packet *batman_ogm_packet,
+			       int directlink, struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *router;
@@ -524,12 +523,13 @@ static void bat_ogm_forward(struct orig_node *orig_node,
 	else
 		batman_ogm_packet->flags &= ~DIRECTLINK;
 
-	bat_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
-			  BATMAN_OGM_LEN + tt_len(tt_num_changes),
-			  if_incoming, 0, bat_ogm_fwd_send_time());
+	bat_iv_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
+			     BATMAN_OGM_LEN + tt_len(tt_num_changes),
+			     if_incoming, 0, bat_iv_ogm_fwd_send_time());
 }
 
-void bat_ogm_schedule(struct hard_iface *hard_iface, int tt_num_changes)
+static void bat_iv_ogm_schedule(struct hard_iface *hard_iface,
+				int tt_num_changes)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct batman_ogm_packet *batman_ogm_packet;
@@ -566,21 +566,22 @@ void bat_ogm_schedule(struct hard_iface *hard_iface, int tt_num_changes)
 	atomic_inc(&hard_iface->seqno);
 
 	slide_own_bcast_window(hard_iface);
-	bat_ogm_queue_add(bat_priv, hard_iface->packet_buff,
-			  hard_iface->packet_len, hard_iface, 1,
-			  bat_ogm_emit_send_time(bat_priv));
+	bat_iv_ogm_queue_add(bat_priv, hard_iface->packet_buff,
+			     hard_iface->packet_len, hard_iface, 1,
+			     bat_iv_ogm_emit_send_time(bat_priv));
 
 	if (primary_if)
 		hardif_free_ref(primary_if);
 }
 
-static void bat_ogm_orig_update(struct bat_priv *bat_priv,
-				struct orig_node *orig_node,
-				const struct ethhdr *ethhdr,
-				const struct batman_ogm_packet
+static void bat_iv_ogm_orig_update(struct bat_priv *bat_priv,
+				   struct orig_node *orig_node,
+				   const struct ethhdr *ethhdr,
+				   const struct batman_ogm_packet
 							*batman_ogm_packet,
-				struct hard_iface *if_incoming,
-				const unsigned char *tt_buff, int is_duplicate)
+				   struct hard_iface *if_incoming,
+				   const unsigned char *tt_buff,
+				   int is_duplicate)
 {
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node = NULL;
 	struct neigh_node *router = NULL;
@@ -715,10 +716,10 @@ out:
 		neigh_node_free_ref(router);
 }
 
-static int bat_ogm_calc_tq(struct orig_node *orig_node,
-			   struct orig_node *orig_neigh_node,
-			   struct batman_ogm_packet *batman_ogm_packet,
-			   struct hard_iface *if_incoming)
+static int bat_iv_ogm_calc_tq(struct orig_node *orig_node,
+			      struct orig_node *orig_neigh_node,
+			      struct batman_ogm_packet *batman_ogm_packet,
+			      struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct neigh_node *neigh_node = NULL, *tmp_neigh_node;
@@ -827,10 +828,10 @@ out:
  *  -1 the packet is old and has been received while the seqno window
  *     was protected. Caller should drop it.
  */
-static int bat_ogm_update_seqnos(const struct ethhdr *ethhdr,
-				 const struct batman_ogm_packet
+static int bat_iv_ogm_update_seqnos(const struct ethhdr *ethhdr,
+				    const struct batman_ogm_packet
 							*batman_ogm_packet,
-				 const struct hard_iface *if_incoming)
+				    const struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct orig_node *orig_node;
@@ -892,10 +893,10 @@ out:
 	return ret;
 }
 
-static void bat_ogm_process(const struct ethhdr *ethhdr,
-			    struct batman_ogm_packet *batman_ogm_packet,
-			    const unsigned char *tt_buff,
-			    struct hard_iface *if_incoming)
+static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
+			       struct batman_ogm_packet *batman_ogm_packet,
+			       const unsigned char *tt_buff,
+			       struct hard_iface *if_incoming)
 {
 	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct hard_iface *hard_iface;
@@ -1033,8 +1034,8 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 	if (!orig_node)
 		return;
 
-	is_duplicate = bat_ogm_update_seqnos(ethhdr, batman_ogm_packet,
-					     if_incoming);
+	is_duplicate = bat_iv_ogm_update_seqnos(ethhdr, batman_ogm_packet,
+						if_incoming);
 
 	if (is_duplicate == -1) {
 		bat_dbg(DBG_BATMAN, bat_priv,
@@ -1083,8 +1084,8 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 		goto out_neigh;
 	}
 
-	is_bidirectional = bat_ogm_calc_tq(orig_node, orig_neigh_node,
-					   batman_ogm_packet, if_incoming);
+	is_bidirectional = bat_iv_ogm_calc_tq(orig_node, orig_neigh_node,
+					      batman_ogm_packet, if_incoming);
 
 	bonding_save_primary(orig_node, orig_neigh_node, batman_ogm_packet);
 
@@ -1094,16 +1095,16 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 	    (!is_duplicate ||
 	     ((orig_node->last_real_seqno == batman_ogm_packet->seqno) &&
 	      (orig_node->last_ttl - 3 <= batman_ogm_packet->header.ttl))))
-		bat_ogm_orig_update(bat_priv, orig_node, ethhdr,
-				    batman_ogm_packet, if_incoming,
-				    tt_buff, is_duplicate);
+		bat_iv_ogm_orig_update(bat_priv, orig_node, ethhdr,
+				       batman_ogm_packet, if_incoming,
+				       tt_buff, is_duplicate);
 
 	/* is single hop (direct) neighbor */
 	if (is_single_hop_neigh) {
 
 		/* mark direct link on incoming interface */
-		bat_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
-				1, if_incoming);
+		bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
+				   1, if_incoming);
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
 			"rebroadcast neighbor packet with direct link flag\n");
@@ -1125,7 +1126,8 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
-	bat_ogm_forward(orig_node, ethhdr, batman_ogm_packet, 0, if_incoming);
+	bat_iv_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
+			   0, if_incoming);
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
@@ -1141,7 +1143,8 @@ out:
 	orig_node_free_ref(orig_node);
 }
 
-void bat_ogm_receive(struct hard_iface *if_incoming, struct sk_buff *skb)
+static void bat_iv_ogm_receive(struct hard_iface *if_incoming,
+			       struct sk_buff *skb)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
 	struct ethhdr *ethhdr;
@@ -1162,20 +1165,26 @@ void bat_ogm_receive(struct hard_iface *if_incoming, struct sk_buff *skb)
 
 		tt_buff = packet_buff + buff_pos + BATMAN_OGM_LEN;
 
-		bat_ogm_process(ethhdr, batman_ogm_packet,
-				tt_buff, if_incoming);
+		bat_iv_ogm_process(ethhdr, batman_ogm_packet,
+				   tt_buff, if_incoming);
 
 		buff_pos += BATMAN_OGM_LEN +
 				tt_len(batman_ogm_packet->tt_num_changes);
 
 		batman_ogm_packet = (struct batman_ogm_packet *)
 						(packet_buff + buff_pos);
-	} while (bat_ogm_aggr_packet(buff_pos, packet_len,
-				     batman_ogm_packet->tt_num_changes));
+	} while (bat_iv_ogm_aggr_packet(buff_pos, packet_len,
+					batman_ogm_packet->tt_num_changes));
 }
 
 static struct bat_algo_ops batman_iv __read_mostly = {
 	.name = "BATMAN IV",
+	.bat_ogm_init = bat_iv_ogm_init,
+	.bat_ogm_init_primary = bat_iv_ogm_init_primary,
+	.bat_ogm_update_mac = bat_iv_ogm_update_mac,
+	.bat_ogm_schedule = bat_iv_ogm_schedule,
+	.bat_ogm_emit = bat_iv_ogm_emit,
+	.bat_ogm_receive = bat_iv_ogm_receive,
 };
 
 int __init bat_iv_init(void)
diff --git a/net/batman-adv/bat_ogm.h b/net/batman-adv/bat_ogm.h
deleted file mode 100644
index 47edfde..0000000
--- a/net/batman-adv/bat_ogm.h
+++ /dev/null
@@ -1,34 +0,0 @@
-/*
- * Copyright (C) 2007-2011 B.A.T.M.A.N. contributors:
- *
- * Marek Lindner, Simon Wunderlich
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
- *
- */
-
-#ifndef _NET_BATMAN_ADV_OGM_H_
-#define _NET_BATMAN_ADV_OGM_H_
-
-#include "main.h"
-
-void bat_ogm_init(struct hard_iface *hard_iface);
-void bat_ogm_init_primary(struct hard_iface *hard_iface);
-void bat_ogm_update_mac(struct hard_iface *hard_iface);
-void bat_ogm_schedule(struct hard_iface *hard_iface, int tt_num_changes);
-void bat_ogm_emit(struct forw_packet *forw_packet);
-void bat_ogm_receive(struct hard_iface *if_incoming, struct sk_buff *skb);
-
-#endif /* _NET_BATMAN_ADV_OGM_H_ */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 68b667c..ff5ba40 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -28,7 +28,6 @@
 #include "bat_sysfs.h"
 #include "originator.h"
 #include "hash.h"
-#include "bat_ogm.h"
 
 #include <linux/if_arp.h>
 
@@ -147,7 +146,7 @@ static void primary_if_select(struct bat_priv *bat_priv,
 	if (!new_hard_iface)
 		return;
 
-	bat_ogm_init_primary(new_hard_iface);
+	bat_priv->bat_algo_ops->bat_ogm_init_primary(new_hard_iface);
 	primary_if_update_addr(bat_priv);
 }
 
@@ -233,7 +232,7 @@ static void hardif_activate_interface(struct hard_iface *hard_iface)
 
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
-	bat_ogm_update_mac(hard_iface);
+	bat_priv->bat_algo_ops->bat_ogm_update_mac(hard_iface);
 	hard_iface->if_status = IF_TO_BE_ACTIVATED;
 
 	/**
@@ -315,7 +314,7 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 	hard_iface->soft_iface = soft_iface;
 	bat_priv = netdev_priv(hard_iface->soft_iface);
 
-	bat_ogm_init(hard_iface);
+	bat_priv->bat_algo_ops->bat_ogm_init(hard_iface);
 
 	if (!hard_iface->packet_buff) {
 		bat_err(hard_iface->soft_iface, "Can't add interface packet "
@@ -535,9 +534,10 @@ static int hard_if_event(struct notifier_block *this,
 			goto hardif_put;
 
 		check_known_mac_addr(hard_iface->net_dev);
-		bat_ogm_update_mac(hard_iface);
 
 		bat_priv = netdev_priv(hard_iface->soft_iface);
+		bat_priv->bat_algo_ops->bat_ogm_update_mac(hard_iface);
+
 		primary_if = primary_if_get_selected(bat_priv);
 		if (!primary_if)
 			goto hardif_put;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 7c87a34..bcc2bdd 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -206,6 +206,18 @@ int bat_algo_register(struct bat_algo_ops *bat_algo_ops)
 		goto out;
 	}
 
+	/* all algorithms must implement all ops (for now) */
+	if (!bat_algo_ops->bat_ogm_init ||
+	    !bat_algo_ops->bat_ogm_init_primary ||
+	    !bat_algo_ops->bat_ogm_update_mac ||
+	    !bat_algo_ops->bat_ogm_schedule ||
+	    !bat_algo_ops->bat_ogm_emit ||
+	    !bat_algo_ops->bat_ogm_receive) {
+		pr_info("Routing algo '%s' does not implement required ops\n",
+			bat_algo_ops->name);
+		goto out;
+	}
+
 	INIT_HLIST_NODE(&bat_algo_ops->list);
 	hlist_add_head(&bat_algo_ops->list, &bat_algo_list);
 	ret = 0;
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 5bc41c8..b72d7f3 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -29,7 +29,6 @@
 #include "originator.h"
 #include "vis.h"
 #include "unicast.h"
-#include "bat_ogm.h"
 
 void slide_own_bcast_window(struct hard_iface *hard_iface)
 {
@@ -248,6 +247,7 @@ int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
 
 int recv_bat_ogm_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
 {
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct ethhdr *ethhdr;
 
 	/* drop packet if it has not necessary minimum size */
@@ -272,7 +272,7 @@ int recv_bat_ogm_packet(struct sk_buff *skb, struct hard_iface *hard_iface)
 	if (skb_linearize(skb) < 0)
 		return NET_RX_DROP;
 
-	bat_ogm_receive(hard_iface, skb);
+	bat_priv->bat_algo_ops->bat_ogm_receive(hard_iface, skb);
 
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index b00a0f5..019337e 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -28,7 +28,6 @@
 #include "vis.h"
 #include "gateway_common.h"
 #include "originator.h"
-#include "bat_ogm.h"
 
 static void send_outstanding_bcast_packet(struct work_struct *work);
 
@@ -168,7 +167,7 @@ void schedule_bat_ogm(struct hard_iface *hard_iface)
 	if (primary_if)
 		hardif_free_ref(primary_if);
 
-	bat_ogm_schedule(hard_iface, tt_num_changes);
+	bat_priv->bat_algo_ops->bat_ogm_schedule(hard_iface, tt_num_changes);
 }
 
 static void forw_packet_free(struct forw_packet *forw_packet)
@@ -318,7 +317,7 @@ void send_outstanding_bat_ogm_packet(struct work_struct *work)
 	if (atomic_read(&bat_priv->mesh_state) == MESH_DEACTIVATING)
 		goto out;
 
-	bat_ogm_emit(forw_packet);
+	bat_priv->bat_algo_ops->bat_ogm_emit(forw_packet);
 
 	/**
 	 * we have to have at least one packet in the queue
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d21ff2c..650ce5f 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -348,6 +348,20 @@ struct softif_neigh {
 struct bat_algo_ops {
 	struct hlist_node list;
 	char *name;
+	/* init OGM when hard-interface is enabled */
+	void (*bat_ogm_init)(struct hard_iface *hard_iface);
+	/* init primary OGM when primary interface is selected */
+	void (*bat_ogm_init_primary)(struct hard_iface *hard_iface);
+	/* init mac addresses of the OGM belonging to this hard-interface */
+	void (*bat_ogm_update_mac)(struct hard_iface *hard_iface);
+	/* prepare a new outgoing OGM for the send queue */
+	void (*bat_ogm_schedule)(struct hard_iface *hard_iface,
+				 int tt_num_changes);
+	/* send scheduled OGM */
+	void (*bat_ogm_emit)(struct forw_packet *forw_packet);
+	/* receive incoming OGM */
+	void (*bat_ogm_receive)(struct hard_iface *if_incoming,
+				struct sk_buff *skb);
 };
 
 #endif /* _NET_BATMAN_ADV_TYPES_H_ */
-- 
1.7.9
