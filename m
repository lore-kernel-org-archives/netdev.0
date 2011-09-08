From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 4/7] batman-adv: agglomerate all batman iv
	ogm sending functions in the batman iv file
Date: Thu,  8 Sep 2011 18:40:48 +0200
Message-ID: <1315500051-1122-5-git-send-email-lindner_marek@yahoo.de>
References: <1315500051-1122-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1315500051-1122-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

In the process the batman iv OGM aggregation code could be merged
into the batman iv code base which makes the separate aggregation
files superfluous.

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/Makefile         |    1 -
 net/batman-adv/aggregation.c    |  266 ---------------------
 net/batman-adv/aggregation.h    |   42 ----
 net/batman-adv/bat_iv_ogm.c     |  502 ++++++++++++++++++++++++++++++++++++++-
 net/batman-adv/bat_ogm.h        |    2 +
 net/batman-adv/hard-interface.c |    2 +-
 net/batman-adv/send.c           |  297 ++----------------------
 net/batman-adv/send.h           |    9 +-
 8 files changed, 522 insertions(+), 599 deletions(-)
 delete mode 100644 net/batman-adv/aggregation.c
 delete mode 100644 net/batman-adv/aggregation.h

diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 3293598..ce68611 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -19,7 +19,6 @@
 #
 
 obj-$(CONFIG_BATMAN_ADV) += batman-adv.o
-batman-adv-y += aggregation.o
 batman-adv-y += bat_debugfs.o
 batman-adv-y += bat_iv_ogm.o
 batman-adv-y += bat_sysfs.o
diff --git a/net/batman-adv/aggregation.c b/net/batman-adv/aggregation.c
deleted file mode 100644
index 4716c93..0000000
--- a/net/batman-adv/aggregation.c
+++ /dev/null
@@ -1,266 +0,0 @@
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
-#include "main.h"
-#include "translation-table.h"
-#include "aggregation.h"
-#include "send.h"
-#include "routing.h"
-#include "hard-interface.h"
-
-/* return true if new_packet can be aggregated with forw_packet */
-static bool can_aggregate_with(const struct batman_ogm_packet
-							*new_batman_ogm_packet,
-			       struct bat_priv *bat_priv,
-			       int packet_len,
-			       unsigned long send_time,
-			       bool directlink,
-			       const struct hard_iface *if_incoming,
-			       const struct forw_packet *forw_packet)
-{
-	struct batman_ogm_packet *batman_ogm_packet =
-			(struct batman_ogm_packet *)forw_packet->skb->data;
-	int aggregated_bytes = forw_packet->packet_len + packet_len;
-	struct hard_iface *primary_if = NULL;
-	bool res = false;
-
-	/**
-	 * we can aggregate the current packet to this aggregated packet
-	 * if:
-	 *
-	 * - the send time is within our MAX_AGGREGATION_MS time
-	 * - the resulting packet wont be bigger than
-	 *   MAX_AGGREGATION_BYTES
-	 */
-
-	if (time_before(send_time, forw_packet->send_time) &&
-	    time_after_eq(send_time + msecs_to_jiffies(MAX_AGGREGATION_MS),
-					forw_packet->send_time) &&
-	    (aggregated_bytes <= MAX_AGGREGATION_BYTES)) {
-
-		/**
-		 * check aggregation compatibility
-		 * -> direct link packets are broadcasted on
-		 *    their interface only
-		 * -> aggregate packet if the current packet is
-		 *    a "global" packet as well as the base
-		 *    packet
-		 */
-
-		primary_if = primary_if_get_selected(bat_priv);
-		if (!primary_if)
-			goto out;
-
-		/* packets without direct link flag and high TTL
-		 * are flooded through the net  */
-		if ((!directlink) &&
-		    (!(batman_ogm_packet->flags & DIRECTLINK)) &&
-		    (batman_ogm_packet->ttl != 1) &&
-
-		    /* own packets originating non-primary
-		     * interfaces leave only that interface */
-		    ((!forw_packet->own) ||
-		     (forw_packet->if_incoming == primary_if))) {
-			res = true;
-			goto out;
-		}
-
-		/* if the incoming packet is sent via this one
-		 * interface only - we still can aggregate */
-		if ((directlink) &&
-		    (new_batman_ogm_packet->ttl == 1) &&
-		    (forw_packet->if_incoming == if_incoming) &&
-
-		    /* packets from direct neighbors or
-		     * own secondary interface packets
-		     * (= secondary interface packets in general) */
-		    (batman_ogm_packet->flags & DIRECTLINK ||
-		     (forw_packet->own &&
-		      forw_packet->if_incoming != primary_if))) {
-			res = true;
-			goto out;
-		}
-	}
-
-out:
-	if (primary_if)
-		hardif_free_ref(primary_if);
-	return res;
-}
-
-/* create a new aggregated packet and add this packet to it */
-static void new_aggregated_packet(const unsigned char *packet_buff,
-				  int packet_len, unsigned long send_time,
-				  bool direct_link,
-				  struct hard_iface *if_incoming,
-				  int own_packet)
-{
-	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct forw_packet *forw_packet_aggr;
-	unsigned char *skb_buff;
-
-	if (!atomic_inc_not_zero(&if_incoming->refcount))
-		return;
-
-	/* own packet should always be scheduled */
-	if (!own_packet) {
-		if (!atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
-			bat_dbg(DBG_BATMAN, bat_priv,
-				"batman packet queue full\n");
-			goto out;
-		}
-	}
-
-	forw_packet_aggr = kmalloc(sizeof(*forw_packet_aggr), GFP_ATOMIC);
-	if (!forw_packet_aggr) {
-		if (!own_packet)
-			atomic_inc(&bat_priv->batman_queue_left);
-		goto out;
-	}
-
-	if ((atomic_read(&bat_priv->aggregated_ogms)) &&
-	    (packet_len < MAX_AGGREGATION_BYTES))
-		forw_packet_aggr->skb = dev_alloc_skb(MAX_AGGREGATION_BYTES +
-						      sizeof(struct ethhdr));
-	else
-		forw_packet_aggr->skb = dev_alloc_skb(packet_len +
-						      sizeof(struct ethhdr));
-
-	if (!forw_packet_aggr->skb) {
-		if (!own_packet)
-			atomic_inc(&bat_priv->batman_queue_left);
-		kfree(forw_packet_aggr);
-		goto out;
-	}
-	skb_reserve(forw_packet_aggr->skb, sizeof(struct ethhdr));
-
-	INIT_HLIST_NODE(&forw_packet_aggr->list);
-
-	skb_buff = skb_put(forw_packet_aggr->skb, packet_len);
-	forw_packet_aggr->packet_len = packet_len;
-	memcpy(skb_buff, packet_buff, packet_len);
-
-	forw_packet_aggr->own = own_packet;
-	forw_packet_aggr->if_incoming = if_incoming;
-	forw_packet_aggr->num_packets = 0;
-	forw_packet_aggr->direct_link_flags = NO_FLAGS;
-	forw_packet_aggr->send_time = send_time;
-
-	/* save packet direct link flag status */
-	if (direct_link)
-		forw_packet_aggr->direct_link_flags |= 1;
-
-	/* add new packet to packet list */
-	spin_lock_bh(&bat_priv->forw_bat_list_lock);
-	hlist_add_head(&forw_packet_aggr->list, &bat_priv->forw_bat_list);
-	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
-
-	/* start timer for this packet */
-	INIT_DELAYED_WORK(&forw_packet_aggr->delayed_work,
-			  send_outstanding_bat_packet);
-	queue_delayed_work(bat_event_workqueue,
-			   &forw_packet_aggr->delayed_work,
-			   send_time - jiffies);
-
-	return;
-out:
-	hardif_free_ref(if_incoming);
-}
-
-/* aggregate a new packet into the existing aggregation */
-static void aggregate(struct forw_packet *forw_packet_aggr,
-		      const unsigned char *packet_buff, int packet_len,
-		      bool direct_link)
-{
-	unsigned char *skb_buff;
-
-	skb_buff = skb_put(forw_packet_aggr->skb, packet_len);
-	memcpy(skb_buff, packet_buff, packet_len);
-	forw_packet_aggr->packet_len += packet_len;
-	forw_packet_aggr->num_packets++;
-
-	/* save packet direct link flag status */
-	if (direct_link)
-		forw_packet_aggr->direct_link_flags |=
-			(1 << forw_packet_aggr->num_packets);
-}
-
-void add_bat_packet_to_list(struct bat_priv *bat_priv,
-			    unsigned char *packet_buff, int packet_len,
-			    struct hard_iface *if_incoming, int own_packet,
-			    unsigned long send_time)
-{
-	/**
-	 * _aggr -> pointer to the packet we want to aggregate with
-	 * _pos -> pointer to the position in the queue
-	 */
-	struct forw_packet *forw_packet_aggr = NULL, *forw_packet_pos = NULL;
-	struct hlist_node *tmp_node;
-	struct batman_ogm_packet *batman_ogm_packet;
-	bool direct_link;
-
-	batman_ogm_packet = (struct batman_ogm_packet *)packet_buff;
-	direct_link = batman_ogm_packet->flags & DIRECTLINK ? 1 : 0;
-
-	/* find position for the packet in the forward queue */
-	spin_lock_bh(&bat_priv->forw_bat_list_lock);
-	/* own packets are not to be aggregated */
-	if ((atomic_read(&bat_priv->aggregated_ogms)) && (!own_packet)) {
-		hlist_for_each_entry(forw_packet_pos, tmp_node,
-				     &bat_priv->forw_bat_list, list) {
-			if (can_aggregate_with(batman_ogm_packet,
-					       bat_priv,
-					       packet_len,
-					       send_time,
-					       direct_link,
-					       if_incoming,
-					       forw_packet_pos)) {
-				forw_packet_aggr = forw_packet_pos;
-				break;
-			}
-		}
-	}
-
-	/* nothing to aggregate with - either aggregation disabled or no
-	 * suitable aggregation packet found */
-	if (!forw_packet_aggr) {
-		/* the following section can run without the lock */
-		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
-
-		/**
-		 * if we could not aggregate this packet with one of the others
-		 * we hold it back for a while, so that it might be aggregated
-		 * later on
-		 */
-		if ((!own_packet) &&
-		    (atomic_read(&bat_priv->aggregated_ogms)))
-			send_time += msecs_to_jiffies(MAX_AGGREGATION_MS);
-
-		new_aggregated_packet(packet_buff, packet_len,
-				      send_time, direct_link,
-				      if_incoming, own_packet);
-	} else {
-		aggregate(forw_packet_aggr,
-			  packet_buff, packet_len,
-			  direct_link);
-		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
-	}
-}
diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
deleted file mode 100644
index 7a92e4c..0000000
--- a/net/batman-adv/aggregation.h
+++ /dev/null
@@ -1,42 +0,0 @@
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
-#ifndef _NET_BATMAN_ADV_AGGREGATION_H_
-#define _NET_BATMAN_ADV_AGGREGATION_H_
-
-#include "main.h"
-
-/* is there another aggregated packet here? */
-static inline int aggregated_packet(int buff_pos, int packet_len,
-				    int tt_num_changes)
-{
-	int next_buff_pos = buff_pos + BATMAN_OGM_LEN + tt_len(tt_num_changes);
-
-	return (next_buff_pos <= packet_len) &&
-		(next_buff_pos <= MAX_AGGREGATION_BYTES);
-}
-
-void add_bat_packet_to_list(struct bat_priv *bat_priv,
-			    unsigned char *packet_buff, int packet_len,
-			    struct hard_iface *if_incoming, int own_packet,
-			    unsigned long send_time);
-
-#endif /* _NET_BATMAN_ADV_AGGREGATION_H_ */
diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 468bd5e..3512e25 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -67,6 +67,27 @@ void bat_ogm_update_mac(struct hard_iface *hard_iface)
 	       hard_iface->net_dev->dev_addr, ETH_ALEN);
 }
 
+/* when do we schedule our own ogm to be sent */
+static unsigned long bat_ogm_emit_send_time(const struct bat_priv *bat_priv)
+{
+	return jiffies + msecs_to_jiffies(
+		   atomic_read(&bat_priv->orig_interval) -
+		   JITTER + (random32() % 2*JITTER));
+}
+
+/* when do we schedule a ogm packet to be sent */
+static unsigned long bat_ogm_fwd_send_time(void)
+{
+	return jiffies + msecs_to_jiffies(random32() % (JITTER/2));
+}
+
+/* apply hop penalty for a normal link */
+static uint8_t hop_penalty(uint8_t tq, const struct bat_priv *bat_priv)
+{
+	int hop_penalty = atomic_read(&bat_priv->hop_penalty);
+	return (tq * (TQ_MAX_VALUE - hop_penalty)) / (TQ_MAX_VALUE);
+}
+
 /* is there another aggregated packet here? */
 static int bat_ogm_aggr_packet(int buff_pos, int packet_len,
 			       int tt_num_changes)
@@ -77,6 +98,480 @@ static int bat_ogm_aggr_packet(int buff_pos, int packet_len,
 		(next_buff_pos <= MAX_AGGREGATION_BYTES);
 }
 
+/* send a batman ogm to a given interface */
+static void bat_ogm_send_to_if(struct forw_packet *forw_packet,
+			       struct hard_iface *hard_iface)
+{
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	char *fwd_str;
+	uint8_t packet_num;
+	int16_t buff_pos;
+	struct batman_ogm_packet *batman_ogm_packet;
+	struct sk_buff *skb;
+
+	if (hard_iface->if_status != IF_ACTIVE)
+		return;
+
+	packet_num = 0;
+	buff_pos = 0;
+	batman_ogm_packet = (struct batman_ogm_packet *)forw_packet->skb->data;
+
+	/* adjust all flags and log packets */
+	while (bat_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
+				   batman_ogm_packet->tt_num_changes)) {
+
+		/* we might have aggregated direct link packets with an
+		 * ordinary base packet */
+		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
+		    (forw_packet->if_incoming == hard_iface))
+			batman_ogm_packet->flags |= DIRECTLINK;
+		else
+			batman_ogm_packet->flags &= ~DIRECTLINK;
+
+		fwd_str = (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
+							    "Sending own" :
+							    "Forwarding"));
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d,"
+			" IDF %s, ttvn %d) on interface %s [%pM]\n",
+			fwd_str, (packet_num > 0 ? "aggregated " : ""),
+			batman_ogm_packet->orig,
+			ntohl(batman_ogm_packet->seqno),
+			batman_ogm_packet->tq, batman_ogm_packet->ttl,
+			(batman_ogm_packet->flags & DIRECTLINK ?
+			 "on" : "off"),
+			batman_ogm_packet->ttvn, hard_iface->net_dev->name,
+			hard_iface->net_dev->dev_addr);
+
+		buff_pos += BATMAN_OGM_LEN +
+				tt_len(batman_ogm_packet->tt_num_changes);
+		packet_num++;
+		batman_ogm_packet = (struct batman_ogm_packet *)
+					(forw_packet->skb->data + buff_pos);
+	}
+
+	/* create clone because function is called more than once */
+	skb = skb_clone(forw_packet->skb, GFP_ATOMIC);
+	if (skb)
+		send_skb_packet(skb, hard_iface, broadcast_addr);
+}
+
+/* send a batman ogm packet */
+void bat_ogm_emit(struct forw_packet *forw_packet)
+{
+	struct hard_iface *hard_iface;
+	struct net_device *soft_iface;
+	struct bat_priv *bat_priv;
+	struct hard_iface *primary_if = NULL;
+	struct batman_ogm_packet *batman_ogm_packet;
+	unsigned char directlink;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)
+						(forw_packet->skb->data);
+	directlink = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
+
+	if (!forw_packet->if_incoming) {
+		pr_err("Error - can't forward packet: incoming iface not "
+		       "specified\n");
+		goto out;
+	}
+
+	soft_iface = forw_packet->if_incoming->soft_iface;
+	bat_priv = netdev_priv(soft_iface);
+
+	if (forw_packet->if_incoming->if_status != IF_ACTIVE)
+		goto out;
+
+	primary_if = primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	/* multihomed peer assumed */
+	/* non-primary OGMs are only broadcasted on their interface */
+	if ((directlink && (batman_ogm_packet->ttl == 1)) ||
+	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
+
+		/* FIXME: what about aggregated packets ? */
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"%s packet (originator %pM, seqno %d, TTL %d) "
+			"on interface %s [%pM]\n",
+			(forw_packet->own ? "Sending own" : "Forwarding"),
+			batman_ogm_packet->orig,
+			ntohl(batman_ogm_packet->seqno),
+			batman_ogm_packet->ttl,
+			forw_packet->if_incoming->net_dev->name,
+			forw_packet->if_incoming->net_dev->dev_addr);
+
+		/* skb is only used once and than forw_packet is free'd */
+		send_skb_packet(forw_packet->skb, forw_packet->if_incoming,
+				broadcast_addr);
+		forw_packet->skb = NULL;
+
+		goto out;
+	}
+
+	/* broadcast on every interface */
+	rcu_read_lock();
+	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
+		if (hard_iface->soft_iface != soft_iface)
+			continue;
+
+		bat_ogm_send_to_if(forw_packet, hard_iface);
+	}
+	rcu_read_unlock();
+
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+}
+
+/* return true if new_packet can be aggregated with forw_packet */
+static bool bat_ogm_can_aggregate(const struct batman_ogm_packet
+							*new_batman_ogm_packet,
+				  struct bat_priv *bat_priv,
+				  int packet_len, unsigned long send_time,
+				  bool directlink,
+				  const struct hard_iface *if_incoming,
+				  const struct forw_packet *forw_packet)
+{
+	struct batman_ogm_packet *batman_ogm_packet;
+	int aggregated_bytes = forw_packet->packet_len + packet_len;
+	struct hard_iface *primary_if = NULL;
+	bool res = false;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)forw_packet->skb->data;
+
+	/**
+	 * we can aggregate the current packet to this aggregated packet
+	 * if:
+	 *
+	 * - the send time is within our MAX_AGGREGATION_MS time
+	 * - the resulting packet wont be bigger than
+	 *   MAX_AGGREGATION_BYTES
+	 */
+
+	if (time_before(send_time, forw_packet->send_time) &&
+	    time_after_eq(send_time + msecs_to_jiffies(MAX_AGGREGATION_MS),
+					forw_packet->send_time) &&
+	    (aggregated_bytes <= MAX_AGGREGATION_BYTES)) {
+
+		/**
+		 * check aggregation compatibility
+		 * -> direct link packets are broadcasted on
+		 *    their interface only
+		 * -> aggregate packet if the current packet is
+		 *    a "global" packet as well as the base
+		 *    packet
+		 */
+
+		primary_if = primary_if_get_selected(bat_priv);
+		if (!primary_if)
+			goto out;
+
+		/* packets without direct link flag and high TTL
+		 * are flooded through the net  */
+		if ((!directlink) &&
+		    (!(batman_ogm_packet->flags & DIRECTLINK)) &&
+		    (batman_ogm_packet->ttl != 1) &&
+
+		    /* own packets originating non-primary
+		     * interfaces leave only that interface */
+		    ((!forw_packet->own) ||
+		     (forw_packet->if_incoming == primary_if))) {
+			res = true;
+			goto out;
+		}
+
+		/* if the incoming packet is sent via this one
+		 * interface only - we still can aggregate */
+		if ((directlink) &&
+		    (new_batman_ogm_packet->ttl == 1) &&
+		    (forw_packet->if_incoming == if_incoming) &&
+
+		    /* packets from direct neighbors or
+		     * own secondary interface packets
+		     * (= secondary interface packets in general) */
+		    (batman_ogm_packet->flags & DIRECTLINK ||
+		     (forw_packet->own &&
+		      forw_packet->if_incoming != primary_if))) {
+			res = true;
+			goto out;
+		}
+	}
+
+out:
+	if (primary_if)
+		hardif_free_ref(primary_if);
+	return res;
+}
+
+/* create a new aggregated packet and add this packet to it */
+static void bat_ogm_aggregate_new(const unsigned char *packet_buff,
+				  int packet_len, unsigned long send_time,
+				  bool direct_link,
+				  struct hard_iface *if_incoming,
+				  int own_packet)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct forw_packet *forw_packet_aggr;
+	unsigned char *skb_buff;
+
+	if (!atomic_inc_not_zero(&if_incoming->refcount))
+		return;
+
+	/* own packet should always be scheduled */
+	if (!own_packet) {
+		if (!atomic_dec_not_zero(&bat_priv->batman_queue_left)) {
+			bat_dbg(DBG_BATMAN, bat_priv,
+				"batman packet queue full\n");
+			goto out;
+		}
+	}
+
+	forw_packet_aggr = kmalloc(sizeof(*forw_packet_aggr), GFP_ATOMIC);
+	if (!forw_packet_aggr) {
+		if (!own_packet)
+			atomic_inc(&bat_priv->batman_queue_left);
+		goto out;
+	}
+
+	if ((atomic_read(&bat_priv->aggregated_ogms)) &&
+	    (packet_len < MAX_AGGREGATION_BYTES))
+		forw_packet_aggr->skb = dev_alloc_skb(MAX_AGGREGATION_BYTES +
+						      sizeof(struct ethhdr));
+	else
+		forw_packet_aggr->skb = dev_alloc_skb(packet_len +
+						      sizeof(struct ethhdr));
+
+	if (!forw_packet_aggr->skb) {
+		if (!own_packet)
+			atomic_inc(&bat_priv->batman_queue_left);
+		kfree(forw_packet_aggr);
+		goto out;
+	}
+	skb_reserve(forw_packet_aggr->skb, sizeof(struct ethhdr));
+
+	INIT_HLIST_NODE(&forw_packet_aggr->list);
+
+	skb_buff = skb_put(forw_packet_aggr->skb, packet_len);
+	forw_packet_aggr->packet_len = packet_len;
+	memcpy(skb_buff, packet_buff, packet_len);
+
+	forw_packet_aggr->own = own_packet;
+	forw_packet_aggr->if_incoming = if_incoming;
+	forw_packet_aggr->num_packets = 0;
+	forw_packet_aggr->direct_link_flags = NO_FLAGS;
+	forw_packet_aggr->send_time = send_time;
+
+	/* save packet direct link flag status */
+	if (direct_link)
+		forw_packet_aggr->direct_link_flags |= 1;
+
+	/* add new packet to packet list */
+	spin_lock_bh(&bat_priv->forw_bat_list_lock);
+	hlist_add_head(&forw_packet_aggr->list, &bat_priv->forw_bat_list);
+	spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+
+	/* start timer for this packet */
+	INIT_DELAYED_WORK(&forw_packet_aggr->delayed_work,
+			  send_outstanding_bat_ogm_packet);
+	queue_delayed_work(bat_event_workqueue,
+			   &forw_packet_aggr->delayed_work,
+			   send_time - jiffies);
+
+	return;
+out:
+	hardif_free_ref(if_incoming);
+}
+
+/* aggregate a new packet into the existing ogm packet */
+static void bat_ogm_aggregate(struct forw_packet *forw_packet_aggr,
+			      const unsigned char *packet_buff,
+			      int packet_len, bool direct_link)
+{
+	unsigned char *skb_buff;
+
+	skb_buff = skb_put(forw_packet_aggr->skb, packet_len);
+	memcpy(skb_buff, packet_buff, packet_len);
+	forw_packet_aggr->packet_len += packet_len;
+	forw_packet_aggr->num_packets++;
+
+	/* save packet direct link flag status */
+	if (direct_link)
+		forw_packet_aggr->direct_link_flags |=
+			(1 << forw_packet_aggr->num_packets);
+}
+
+static void bat_ogm_queue_add(struct bat_priv *bat_priv,
+			      unsigned char *packet_buff,
+			      int packet_len, struct hard_iface *if_incoming,
+			      int own_packet, unsigned long send_time)
+{
+	/**
+	 * _aggr -> pointer to the packet we want to aggregate with
+	 * _pos -> pointer to the position in the queue
+	 */
+	struct forw_packet *forw_packet_aggr = NULL, *forw_packet_pos = NULL;
+	struct hlist_node *tmp_node;
+	struct batman_ogm_packet *batman_ogm_packet;
+	bool direct_link;
+
+	batman_ogm_packet = (struct batman_ogm_packet *)packet_buff;
+	direct_link = batman_ogm_packet->flags & DIRECTLINK ? 1 : 0;
+
+	/* find position for the packet in the forward queue */
+	spin_lock_bh(&bat_priv->forw_bat_list_lock);
+	/* own packets are not to be aggregated */
+	if ((atomic_read(&bat_priv->aggregated_ogms)) && (!own_packet)) {
+		hlist_for_each_entry(forw_packet_pos, tmp_node,
+				     &bat_priv->forw_bat_list, list) {
+			if (bat_ogm_can_aggregate(batman_ogm_packet,
+						  bat_priv, packet_len,
+						  send_time, direct_link,
+						  if_incoming,
+						  forw_packet_pos)) {
+				forw_packet_aggr = forw_packet_pos;
+				break;
+			}
+		}
+	}
+
+	/* nothing to aggregate with - either aggregation disabled or no
+	 * suitable aggregation packet found */
+	if (!forw_packet_aggr) {
+		/* the following section can run without the lock */
+		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+
+		/**
+		 * if we could not aggregate this packet with one of the others
+		 * we hold it back for a while, so that it might be aggregated
+		 * later on
+		 */
+		if ((!own_packet) &&
+		    (atomic_read(&bat_priv->aggregated_ogms)))
+			send_time += msecs_to_jiffies(MAX_AGGREGATION_MS);
+
+		bat_ogm_aggregate_new(packet_buff, packet_len,
+				      send_time, direct_link,
+				      if_incoming, own_packet);
+	} else {
+		bat_ogm_aggregate(forw_packet_aggr, packet_buff, packet_len,
+				  direct_link);
+		spin_unlock_bh(&bat_priv->forw_bat_list_lock);
+	}
+}
+
+static void bat_ogm_forward(struct orig_node *orig_node,
+			    const struct ethhdr *ethhdr,
+			    struct batman_ogm_packet *batman_ogm_packet,
+			    int directlink, struct hard_iface *if_incoming)
+{
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct neigh_node *router;
+	uint8_t in_tq, in_ttl, tq_avg = 0;
+	uint8_t tt_num_changes;
+
+	if (batman_ogm_packet->ttl <= 1) {
+		bat_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
+		return;
+	}
+
+	router = orig_node_get_router(orig_node);
+
+	in_tq = batman_ogm_packet->tq;
+	in_ttl = batman_ogm_packet->ttl;
+	tt_num_changes = batman_ogm_packet->tt_num_changes;
+
+	batman_ogm_packet->ttl--;
+	memcpy(batman_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
+
+	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcast
+	 * of our best tq value */
+	if (router && router->tq_avg != 0) {
+
+		/* rebroadcast ogm of best ranking neighbor as is */
+		if (!compare_eth(router->addr, ethhdr->h_source)) {
+			batman_ogm_packet->tq = router->tq_avg;
+
+			if (router->last_ttl)
+				batman_ogm_packet->ttl = router->last_ttl - 1;
+		}
+
+		tq_avg = router->tq_avg;
+	}
+
+	if (router)
+		neigh_node_free_ref(router);
+
+	/* apply hop penalty */
+	batman_ogm_packet->tq = hop_penalty(batman_ogm_packet->tq, bat_priv);
+
+	bat_dbg(DBG_BATMAN, bat_priv,
+		"Forwarding packet: tq_orig: %i, tq_avg: %i, "
+		"tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
+		in_tq, tq_avg, batman_ogm_packet->tq, in_ttl - 1,
+		batman_ogm_packet->ttl);
+
+	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
+	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
+
+	/* switch of primaries first hop flag when forwarding */
+	batman_ogm_packet->flags &= ~PRIMARIES_FIRST_HOP;
+	if (directlink)
+		batman_ogm_packet->flags |= DIRECTLINK;
+	else
+		batman_ogm_packet->flags &= ~DIRECTLINK;
+
+	bat_ogm_queue_add(bat_priv, (unsigned char *)batman_ogm_packet,
+			  BATMAN_OGM_LEN + tt_len(tt_num_changes),
+			  if_incoming, 0, bat_ogm_fwd_send_time());
+}
+
+void bat_ogm_schedule(struct hard_iface *hard_iface, int tt_num_changes)
+{
+	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
+	struct batman_ogm_packet *batman_ogm_packet;
+	struct hard_iface *primary_if;
+	int vis_server;
+
+	vis_server = atomic_read(&bat_priv->vis_mode);
+	primary_if = primary_if_get_selected(bat_priv);
+
+	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
+
+	/* change sequence number to network order */
+	batman_ogm_packet->seqno =
+			htonl((uint32_t)atomic_read(&hard_iface->seqno));
+
+	batman_ogm_packet->ttvn = atomic_read(&bat_priv->ttvn);
+	batman_ogm_packet->tt_crc = htons((uint16_t)
+						atomic_read(&bat_priv->tt_crc));
+	if (tt_num_changes >= 0)
+		batman_ogm_packet->tt_num_changes = tt_num_changes;
+
+	if (vis_server == VIS_TYPE_SERVER_SYNC)
+		batman_ogm_packet->flags |= VIS_SERVER;
+	else
+		batman_ogm_packet->flags &= ~VIS_SERVER;
+
+	if ((hard_iface == primary_if) &&
+	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_SERVER))
+		batman_ogm_packet->gw_flags =
+				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
+	else
+		batman_ogm_packet->gw_flags = NO_FLAGS;
+
+	atomic_inc(&hard_iface->seqno);
+
+	slide_own_bcast_window(hard_iface);
+	bat_ogm_queue_add(bat_priv, hard_iface->packet_buff,
+			  hard_iface->packet_len, hard_iface, 1,
+			  bat_ogm_emit_send_time(bat_priv));
+
+	if (primary_if)
+		hardif_free_ref(primary_if);
+}
+
 static void bat_ogm_orig_update(struct bat_priv *bat_priv,
 				struct orig_node *orig_node,
 				const struct ethhdr *ethhdr,
@@ -605,8 +1100,8 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 	if (is_single_hop_neigh) {
 
 		/* mark direct link on incoming interface */
-		schedule_forward_packet(orig_node, ethhdr, batman_ogm_packet,
-					1, if_incoming);
+		bat_ogm_forward(orig_node, ethhdr, batman_ogm_packet,
+				1, if_incoming);
 
 		bat_dbg(DBG_BATMAN, bat_priv, "Forwarding packet: "
 			"rebroadcast neighbor packet with direct link flag\n");
@@ -628,8 +1123,7 @@ static void bat_ogm_process(const struct ethhdr *ethhdr,
 
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Forwarding packet: rebroadcast originator packet\n");
-	schedule_forward_packet(orig_node, ethhdr, batman_ogm_packet,
-				0, if_incoming);
+	bat_ogm_forward(orig_node, ethhdr, batman_ogm_packet, 0, if_incoming);
 
 out_neigh:
 	if ((orig_neigh_node) && (!is_single_hop_neigh))
diff --git a/net/batman-adv/bat_ogm.h b/net/batman-adv/bat_ogm.h
index 7809b92..69329c1 100644
--- a/net/batman-adv/bat_ogm.h
+++ b/net/batman-adv/bat_ogm.h
@@ -27,6 +27,8 @@
 void bat_ogm_init(struct hard_iface *hard_iface);
 void bat_ogm_init_primary(struct hard_iface *hard_iface);
 void bat_ogm_update_mac(struct hard_iface *hard_iface);
+void bat_ogm_schedule(struct hard_iface *hard_iface, int tt_num_changes);
+void bat_ogm_emit(struct forw_packet *forw_packet);
 void bat_ogm_receive(const struct ethhdr *ethhdr, unsigned char *packet_buff,
 		     int packet_len, struct hard_iface *if_incoming);
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 2a15582..0cc0f04 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -360,7 +360,7 @@ int hardif_enable_interface(struct hard_iface *hard_iface,
 			hard_iface->net_dev->name);
 
 	/* begin scheduling originator messages on that interface */
-	schedule_own_packet(hard_iface);
+	schedule_bat_ogm(hard_iface);
 
 out:
 	return 0;
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 40a5fcd..8a684eb 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -26,33 +26,12 @@
 #include "soft-interface.h"
 #include "hard-interface.h"
 #include "vis.h"
-#include "aggregation.h"
 #include "gateway_common.h"
 #include "originator.h"
+#include "bat_ogm.h"
 
 static void send_outstanding_bcast_packet(struct work_struct *work);
 
-/* apply hop penalty for a normal link */
-static uint8_t hop_penalty(uint8_t tq, const struct bat_priv *bat_priv)
-{
-	int hop_penalty = atomic_read(&bat_priv->hop_penalty);
-	return (tq * (TQ_MAX_VALUE - hop_penalty)) / (TQ_MAX_VALUE);
-}
-
-/* when do we schedule our own packet to be sent */
-static unsigned long own_send_time(const struct bat_priv *bat_priv)
-{
-	return jiffies + msecs_to_jiffies(
-		   atomic_read(&bat_priv->orig_interval) -
-		   JITTER + (random32() % 2*JITTER));
-}
-
-/* when do we schedule a forwarded packet to be sent */
-static unsigned long forward_send_time(void)
-{
-	return jiffies + msecs_to_jiffies(random32() % (JITTER/2));
-}
-
 /* send out an already prepared packet to the given address via the
  * specified batman interface */
 int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
@@ -99,133 +78,6 @@ send_skb_err:
 	return NET_XMIT_DROP;
 }
 
-/* Send a packet to a given interface */
-static void send_packet_to_if(struct forw_packet *forw_packet,
-			      struct hard_iface *hard_iface)
-{
-	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
-	char *fwd_str;
-	uint8_t packet_num;
-	int16_t buff_pos;
-	struct batman_ogm_packet *batman_ogm_packet;
-	struct sk_buff *skb;
-
-	if (hard_iface->if_status != IF_ACTIVE)
-		return;
-
-	packet_num = 0;
-	buff_pos = 0;
-	batman_ogm_packet = (struct batman_ogm_packet *)forw_packet->skb->data;
-
-	/* adjust all flags and log packets */
-	while (aggregated_packet(buff_pos,
-				 forw_packet->packet_len,
-				 batman_ogm_packet->tt_num_changes)) {
-
-		/* we might have aggregated direct link packets with an
-		 * ordinary base packet */
-		if ((forw_packet->direct_link_flags & (1 << packet_num)) &&
-		    (forw_packet->if_incoming == hard_iface))
-			batman_ogm_packet->flags |= DIRECTLINK;
-		else
-			batman_ogm_packet->flags &= ~DIRECTLINK;
-
-		fwd_str = (packet_num > 0 ? "Forwarding" : (forw_packet->own ?
-							    "Sending own" :
-							    "Forwarding"));
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"%s %spacket (originator %pM, seqno %d, TQ %d, TTL %d,"
-			" IDF %s, ttvn %d) on interface %s [%pM]\n",
-			fwd_str, (packet_num > 0 ? "aggregated " : ""),
-			batman_ogm_packet->orig,
-			ntohl(batman_ogm_packet->seqno),
-			batman_ogm_packet->tq, batman_ogm_packet->ttl,
-			(batman_ogm_packet->flags & DIRECTLINK ?
-			 "on" : "off"),
-			batman_ogm_packet->ttvn, hard_iface->net_dev->name,
-			hard_iface->net_dev->dev_addr);
-
-		buff_pos += BATMAN_OGM_LEN +
-				tt_len(batman_ogm_packet->tt_num_changes);
-		packet_num++;
-		batman_ogm_packet = (struct batman_ogm_packet *)
-					(forw_packet->skb->data + buff_pos);
-	}
-
-	/* create clone because function is called more than once */
-	skb = skb_clone(forw_packet->skb, GFP_ATOMIC);
-	if (skb)
-		send_skb_packet(skb, hard_iface, broadcast_addr);
-}
-
-/* send a batman packet */
-static void send_packet(struct forw_packet *forw_packet)
-{
-	struct hard_iface *hard_iface;
-	struct net_device *soft_iface;
-	struct bat_priv *bat_priv;
-	struct hard_iface *primary_if = NULL;
-	struct batman_ogm_packet *batman_ogm_packet =
-			(struct batman_ogm_packet *)(forw_packet->skb->data);
-	unsigned char directlink;
-
-	directlink = (batman_ogm_packet->flags & DIRECTLINK ? 1 : 0);
-
-	if (!forw_packet->if_incoming) {
-		pr_err("Error - can't forward packet: incoming iface not "
-		       "specified\n");
-		goto out;
-	}
-
-	soft_iface = forw_packet->if_incoming->soft_iface;
-	bat_priv = netdev_priv(soft_iface);
-
-	if (forw_packet->if_incoming->if_status != IF_ACTIVE)
-		goto out;
-
-	primary_if = primary_if_get_selected(bat_priv);
-	if (!primary_if)
-		goto out;
-
-	/* multihomed peer assumed */
-	/* non-primary OGMs are only broadcasted on their interface */
-	if ((directlink && (batman_ogm_packet->ttl == 1)) ||
-	    (forw_packet->own && (forw_packet->if_incoming != primary_if))) {
-
-		/* FIXME: what about aggregated packets ? */
-		bat_dbg(DBG_BATMAN, bat_priv,
-			"%s packet (originator %pM, seqno %d, TTL %d) "
-			"on interface %s [%pM]\n",
-			(forw_packet->own ? "Sending own" : "Forwarding"),
-			batman_ogm_packet->orig,
-			ntohl(batman_ogm_packet->seqno),
-			batman_ogm_packet->ttl,
-			forw_packet->if_incoming->net_dev->name,
-			forw_packet->if_incoming->net_dev->dev_addr);
-
-		/* skb is only used once and than forw_packet is free'd */
-		send_skb_packet(forw_packet->skb, forw_packet->if_incoming,
-				broadcast_addr);
-		forw_packet->skb = NULL;
-
-		goto out;
-	}
-
-	/* broadcast on every interface */
-	rcu_read_lock();
-	list_for_each_entry_rcu(hard_iface, &hardif_list, list) {
-		if (hard_iface->soft_iface != soft_iface)
-			continue;
-
-		send_packet_to_if(forw_packet, hard_iface);
-	}
-	rcu_read_unlock();
-
-out:
-	if (primary_if)
-		hardif_free_ref(primary_if);
-}
-
 static void realloc_packet_buffer(struct hard_iface *hard_iface,
 				  int new_len)
 {
@@ -245,11 +97,10 @@ static void realloc_packet_buffer(struct hard_iface *hard_iface,
 }
 
 /* when calling this function (hard_iface == primary_if) has to be true */
-static void prepare_packet_buffer(struct bat_priv *bat_priv,
+static int prepare_packet_buffer(struct bat_priv *bat_priv,
 				  struct hard_iface *hard_iface)
 {
 	int new_len;
-	struct batman_ogm_packet *batman_ogm_packet;
 
 	new_len = BATMAN_OGM_LEN +
 		  tt_len((uint8_t)atomic_read(&bat_priv->tt_local_changes));
@@ -260,45 +111,34 @@ static void prepare_packet_buffer(struct bat_priv *bat_priv,
 		new_len = BATMAN_OGM_LEN;
 
 	realloc_packet_buffer(hard_iface, new_len);
-	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
 
 	atomic_set(&bat_priv->tt_crc, tt_local_crc(bat_priv));
 
 	/* reset the sending counter */
 	atomic_set(&bat_priv->tt_ogm_append_cnt, TT_OGM_APPEND_MAX);
 
-	batman_ogm_packet->tt_num_changes = tt_changes_fill_buffer(bat_priv,
-				hard_iface->packet_buff + BATMAN_OGM_LEN,
-				hard_iface->packet_len - BATMAN_OGM_LEN);
-
+	return tt_changes_fill_buffer(bat_priv,
+				      hard_iface->packet_buff + BATMAN_OGM_LEN,
+				      hard_iface->packet_len - BATMAN_OGM_LEN);
 }
 
-static void reset_packet_buffer(struct bat_priv *bat_priv,
+static int reset_packet_buffer(struct bat_priv *bat_priv,
 				struct hard_iface *hard_iface)
 {
-	struct batman_ogm_packet *batman_ogm_packet;
-
 	realloc_packet_buffer(hard_iface, BATMAN_OGM_LEN);
-
-	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
-	batman_ogm_packet->tt_num_changes = 0;
+	return 0;
 }
 
-void schedule_own_packet(struct hard_iface *hard_iface)
+void schedule_bat_ogm(struct hard_iface *hard_iface)
 {
 	struct bat_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct hard_iface *primary_if;
-	unsigned long send_time;
-	struct batman_ogm_packet *batman_ogm_packet;
-	int vis_server;
+	int tt_num_changes = -1;
 
 	if ((hard_iface->if_status == IF_NOT_IN_USE) ||
 	    (hard_iface->if_status == IF_TO_BE_REMOVED))
 		return;
 
-	vis_server = atomic_read(&bat_priv->vis_mode);
-	primary_if = primary_if_get_selected(bat_priv);
-
 	/**
 	 * the interface gets activated here to avoid race conditions between
 	 * the moment of activating the interface in
@@ -309,125 +149,26 @@ void schedule_own_packet(struct hard_iface *hard_iface)
 	if (hard_iface->if_status == IF_TO_BE_ACTIVATED)
 		hard_iface->if_status = IF_ACTIVE;
 
+	primary_if = primary_if_get_selected(bat_priv);
+
 	if (hard_iface == primary_if) {
 		/* if at least one change happened */
 		if (atomic_read(&bat_priv->tt_local_changes) > 0) {
 			tt_commit_changes(bat_priv);
-			prepare_packet_buffer(bat_priv, hard_iface);
+			tt_num_changes = prepare_packet_buffer(bat_priv,
+							       hard_iface);
 		}
 
 		/* if the changes have been sent often enough */
 		if (!atomic_dec_not_zero(&bat_priv->tt_ogm_append_cnt))
-			reset_packet_buffer(bat_priv, hard_iface);
+			tt_num_changes = reset_packet_buffer(bat_priv,
+							     hard_iface);
 	}
 
-	/**
-	 * NOTE: packet_buff might just have been re-allocated in
-	 * prepare_packet_buffer() or in reset_packet_buffer()
-	 */
-	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
-
-	/* change sequence number to network order */
-	batman_ogm_packet->seqno =
-			htonl((uint32_t)atomic_read(&hard_iface->seqno));
-
-	batman_ogm_packet->ttvn = atomic_read(&bat_priv->ttvn);
-	batman_ogm_packet->tt_crc = htons((uint16_t)
-						atomic_read(&bat_priv->tt_crc));
-
-	if (vis_server == VIS_TYPE_SERVER_SYNC)
-		batman_ogm_packet->flags |= VIS_SERVER;
-	else
-		batman_ogm_packet->flags &= ~VIS_SERVER;
-
-	if ((hard_iface == primary_if) &&
-	    (atomic_read(&bat_priv->gw_mode) == GW_MODE_SERVER))
-		batman_ogm_packet->gw_flags =
-				(uint8_t)atomic_read(&bat_priv->gw_bandwidth);
-	else
-		batman_ogm_packet->gw_flags = NO_FLAGS;
-
-	atomic_inc(&hard_iface->seqno);
-
-	slide_own_bcast_window(hard_iface);
-	send_time = own_send_time(bat_priv);
-	add_bat_packet_to_list(bat_priv,
-			       hard_iface->packet_buff,
-			       hard_iface->packet_len,
-			       hard_iface, 1, send_time);
-
 	if (primary_if)
 		hardif_free_ref(primary_if);
-}
-
-void schedule_forward_packet(struct orig_node *orig_node,
-			     const struct ethhdr *ethhdr,
-			     struct batman_ogm_packet *batman_ogm_packet,
-			     int directlink,
-			     struct hard_iface *if_incoming)
-{
-	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	struct neigh_node *router;
-	uint8_t in_tq, in_ttl, tq_avg = 0;
-	unsigned long send_time;
-	uint8_t tt_num_changes;
-
-	if (batman_ogm_packet->ttl <= 1) {
-		bat_dbg(DBG_BATMAN, bat_priv, "ttl exceeded\n");
-		return;
-	}
-
-	router = orig_node_get_router(orig_node);
-
-	in_tq = batman_ogm_packet->tq;
-	in_ttl = batman_ogm_packet->ttl;
-	tt_num_changes = batman_ogm_packet->tt_num_changes;
-
-	batman_ogm_packet->ttl--;
-	memcpy(batman_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
-
-	/* rebroadcast tq of our best ranking neighbor to ensure the rebroadcast
-	 * of our best tq value */
-	if (router && router->tq_avg != 0) {
-
-		/* rebroadcast ogm of best ranking neighbor as is */
-		if (!compare_eth(router->addr, ethhdr->h_source)) {
-			batman_ogm_packet->tq = router->tq_avg;
-
-			if (router->last_ttl)
-				batman_ogm_packet->ttl = router->last_ttl - 1;
-		}
-
-		tq_avg = router->tq_avg;
-	}
-
-	if (router)
-		neigh_node_free_ref(router);
-
-	/* apply hop penalty */
-	batman_ogm_packet->tq = hop_penalty(batman_ogm_packet->tq, bat_priv);
-
-	bat_dbg(DBG_BATMAN, bat_priv,
-		"Forwarding packet: tq_orig: %i, tq_avg: %i, "
-		"tq_forw: %i, ttl_orig: %i, ttl_forw: %i\n",
-		in_tq, tq_avg, batman_ogm_packet->tq, in_ttl - 1,
-		batman_ogm_packet->ttl);
-
-	batman_ogm_packet->seqno = htonl(batman_ogm_packet->seqno);
-	batman_ogm_packet->tt_crc = htons(batman_ogm_packet->tt_crc);
-
-	/* switch of primaries first hop flag when forwarding */
-	batman_ogm_packet->flags &= ~PRIMARIES_FIRST_HOP;
-	if (directlink)
-		batman_ogm_packet->flags |= DIRECTLINK;
-	else
-		batman_ogm_packet->flags &= ~DIRECTLINK;
 
-	send_time = forward_send_time();
-	add_bat_packet_to_list(bat_priv,
-			       (unsigned char *)batman_ogm_packet,
-			       BATMAN_OGM_LEN + tt_len(tt_num_changes),
-			       if_incoming, 0, send_time);
+	bat_ogm_schedule(hard_iface, tt_num_changes);
 }
 
 static void forw_packet_free(struct forw_packet *forw_packet)
@@ -561,7 +302,7 @@ out:
 	atomic_inc(&bat_priv->bcast_queue_left);
 }
 
-void send_outstanding_bat_packet(struct work_struct *work)
+void send_outstanding_bat_ogm_packet(struct work_struct *work)
 {
 	struct delayed_work *delayed_work =
 		container_of(work, struct delayed_work, work);
@@ -577,7 +318,7 @@ void send_outstanding_bat_packet(struct work_struct *work)
 	if (atomic_read(&bat_priv->mesh_state) == MESH_DEACTIVATING)
 		goto out;
 
-	send_packet(forw_packet);
+	bat_ogm_emit(forw_packet);
 
 	/**
 	 * we have to have at least one packet in the queue
@@ -585,7 +326,7 @@ void send_outstanding_bat_packet(struct work_struct *work)
 	 * shutting down
 	 */
 	if (forw_packet->own)
-		schedule_own_packet(forw_packet->if_incoming);
+		schedule_bat_ogm(forw_packet->if_incoming);
 
 out:
 	/* don't count own packet */
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 8a22d84..c8ca3ef 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -24,15 +24,10 @@
 
 int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 		    const uint8_t *dst_addr);
-void schedule_own_packet(struct hard_iface *hard_iface);
-void schedule_forward_packet(struct orig_node *orig_node,
-			     const struct ethhdr *ethhdr,
-			     struct batman_ogm_packet *batman_ogm_packet,
-			     int directlink,
-			     struct hard_iface *if_outgoing);
+void schedule_bat_ogm(struct hard_iface *hard_iface);
 int add_bcast_packet_to_list(struct bat_priv *bat_priv,
 			     const struct sk_buff *skb, unsigned long delay);
-void send_outstanding_bat_packet(struct work_struct *work);
+void send_outstanding_bat_ogm_packet(struct work_struct *work);
 void purge_outstanding_packets(struct bat_priv *bat_priv,
 			       const struct hard_iface *hard_iface);
 
-- 
1.7.5.4
