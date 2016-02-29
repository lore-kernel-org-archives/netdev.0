From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 06/15] batman-adv: OGMv2 - implement originators logic
Date: Mon, 29 Feb 2016 19:05:59 +0800
Message-ID: <1456743968-17562-7-git-send-email-a@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:15150 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753661AbcB2LIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:08:52 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Add the support for recognising new originators in the
network and rebroadcast their OGMs.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_v_elp.c |  41 +---
 net/batman-adv/bat_v_ogm.c | 556 ++++++++++++++++++++++++++++++++++++++++++++-
 net/batman-adv/bat_v_ogm.h |   4 +
 net/batman-adv/main.h      |   2 +
 net/batman-adv/types.h     |   4 +
 5 files changed, 566 insertions(+), 41 deletions(-)

diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index dac88fad2697..fac5aee7ce05 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -37,8 +37,8 @@
 #include <linux/workqueue.h>
 
 #include "bat_algo.h"
+#include "bat_v_ogm.h"
 #include "hard-interface.h"
-#include "hash.h"
 #include "originator.h"
 #include "packet.h"
 #include "routing.h"
@@ -196,45 +196,6 @@ void batadv_v_elp_primary_iface_set(struct batadv_hard_iface *primary_iface)
 }
 
 /**
- * batadv_v_ogm_orig_get - retrieve and possibly create an originator node
- * @bat_priv: the bat priv with all the soft interface information
- * @addr: the address of the originator
- *
- * Return: the orig_node corresponding to the specified address. If such object
- * does not exist it is allocated here. In case of allocation failure returns
- * NULL.
- */
-static struct batadv_orig_node *
-batadv_v_ogm_orig_get(struct batadv_priv *bat_priv,
-		      const u8 *addr)
-{
-	struct batadv_orig_node *orig_node;
-	int hash_added;
-
-	orig_node = batadv_orig_hash_find(bat_priv, addr);
-	if (orig_node)
-		return orig_node;
-
-	orig_node = batadv_orig_node_new(bat_priv, addr);
-	if (!orig_node)
-		return NULL;
-
-	hash_added = batadv_hash_add(bat_priv->orig_hash, batadv_compare_orig,
-				     batadv_choose_orig, orig_node,
-				     &orig_node->hash_entry);
-	if (hash_added != 0) {
-		/* orig_node->refcounter is initialised to 2 by
-		 * batadv_orig_node_new()
-		 */
-		batadv_orig_node_put(orig_node);
-		batadv_orig_node_put(orig_node);
-		orig_node = NULL;
-	}
-
-	return orig_node;
-}
-
-/**
  * batadv_v_elp_neigh_update - update an ELP neighbour node
  * @bat_priv: the bat priv with all the soft interface information
  * @neigh_addr: the neighbour interface address
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 23932f9b85ec..22dda0e079a5 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -26,6 +26,7 @@
 #include <linux/if_ether.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/random.h>
 #include <linux/rculist.h>
@@ -38,12 +39,52 @@
 #include <linux/workqueue.h>
 
 #include "hard-interface.h"
+#include "hash.h"
+#include "originator.h"
 #include "packet.h"
 #include "routing.h"
 #include "send.h"
 #include "translation-table.h"
 
 /**
+ * batadv_v_ogm_orig_get - retrieve and possibly create an originator node
+ * @bat_priv: the bat priv with all the soft interface information
+ * @addr: the address of the originator
+ *
+ * Return: the orig_node corresponding to the specified address. If such object
+ * does not exist it is allocated here. In case of allocation failure returns
+ * NULL.
+ */
+struct batadv_orig_node *batadv_v_ogm_orig_get(struct batadv_priv *bat_priv,
+					       const u8 *addr)
+{
+	struct batadv_orig_node *orig_node;
+	int hash_added;
+
+	orig_node = batadv_orig_hash_find(bat_priv, addr);
+	if (orig_node)
+		return orig_node;
+
+	orig_node = batadv_orig_node_new(bat_priv, addr);
+	if (!orig_node)
+		return NULL;
+
+	hash_added = batadv_hash_add(bat_priv->orig_hash, batadv_compare_orig,
+				     batadv_choose_orig, orig_node,
+				     &orig_node->hash_entry);
+	if (hash_added != 0) {
+		/* orig_node->refcounter is initialised to 2 by
+		 * batadv_orig_node_new()
+		 */
+		batadv_orig_node_put(orig_node);
+		batadv_orig_node_put(orig_node);
+		orig_node = NULL;
+	}
+
+	return orig_node;
+}
+
+/**
  * batadv_v_ogm_start_timer - restart the OGM sending timer
  * @bat_priv: the bat priv with all the soft interface information
  */
@@ -193,6 +234,500 @@ void batadv_v_ogm_primary_iface_set(struct batadv_hard_iface *primary_iface)
 }
 
 /**
+ * batadv_v_ogm_orig_update - update the originator status based on the received
+ *  OGM
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: the originator to update
+ * @neigh_node: the neighbour the OGM has been received from (to update)
+ * @ogm2: the received OGM
+ * @if_outgoing: the interface where this OGM is going to be forwarded through
+ */
+static void
+batadv_v_ogm_orig_update(struct batadv_priv *bat_priv,
+			 struct batadv_orig_node *orig_node,
+			 struct batadv_neigh_node *neigh_node,
+			 const struct batadv_ogm2_packet *ogm2,
+			 struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_neigh_ifinfo *router_ifinfo = NULL, *neigh_ifinfo = NULL;
+	struct batadv_neigh_node *router = NULL;
+	s32 neigh_seq_diff;
+	u32 neigh_last_seqno;
+	u32 router_last_seqno;
+	u32 router_throughput, neigh_throughput;
+
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Searching and updating originator entry of received packet\n");
+
+	/* if this neighbor already is our next hop there is nothing
+	 * to change
+	 */
+	router = batadv_orig_router_get(orig_node, if_outgoing);
+	if (router == neigh_node)
+		goto out;
+
+	/* don't consider neighbours with worse throughput.
+	 * also switch route if this seqno is BATADV_V_MAX_ORIGDIFF newer than
+	 * the last received seqno from our best next hop.
+	 */
+	if (router) {
+		router_ifinfo = batadv_neigh_ifinfo_get(router, if_outgoing);
+		neigh_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
+
+		/* if these are not allocated, something is wrong. */
+		if (!router_ifinfo || !neigh_ifinfo)
+			goto out;
+
+		neigh_last_seqno = neigh_ifinfo->bat_v.last_seqno;
+		router_last_seqno = router_ifinfo->bat_v.last_seqno;
+		neigh_seq_diff = neigh_last_seqno - router_last_seqno;
+		router_throughput = router_ifinfo->bat_v.throughput;
+		neigh_throughput = neigh_ifinfo->bat_v.throughput;
+
+		if ((neigh_seq_diff < BATADV_OGM_MAX_ORIGDIFF) &&
+		    (router_throughput >= neigh_throughput))
+			goto out;
+	}
+
+	batadv_update_route(bat_priv, orig_node, if_outgoing, neigh_node);
+
+out:
+	if (router_ifinfo)
+		batadv_neigh_ifinfo_put(router_ifinfo);
+	if (neigh_ifinfo)
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
+	if (router)
+		batadv_neigh_node_put(router);
+}
+
+/**
+ * batadv_v_forward_penalty - apply a penalty to the throughput metric forwarded
+ *  with B.A.T.M.A.N. V OGMs
+ * @bat_priv: the bat priv with all the soft interface information
+ * @if_incoming: the interface where the OGM has been received
+ * @if_outgoing: the interface where the OGM has to be forwarded to
+ * @throughput: the current throughput
+ *
+ * Apply a penalty on the current throughput metric value based on the
+ * characteristic of the interface where the OGM has been received. The return
+ * value is computed as follows:
+ * - throughput * 50%          if the incoming and outgoing interface are the
+ *                             same WiFi interface and the throughput is above
+ *                             1MBit/s
+ * - throughput                if the outgoing interface is the default
+ *                             interface (i.e. this OGM is processed for the
+ *                             internal table and not forwarded)
+ * - throughput * hop penalty  otherwise
+ *
+ * Return: the penalised throughput metric.
+ */
+static u32 batadv_v_forward_penalty(struct batadv_priv *bat_priv,
+				    struct batadv_hard_iface *if_incoming,
+				    struct batadv_hard_iface *if_outgoing,
+				    u32 throughput)
+{
+	int hop_penalty = atomic_read(&bat_priv->hop_penalty);
+	int hop_penalty_max = BATADV_TQ_MAX_VALUE;
+
+	/* Don't apply hop penalty in default originator table. */
+	if (if_outgoing == BATADV_IF_DEFAULT)
+		return throughput;
+
+	/* Forwarding on the same WiFi interface cuts the throughput in half
+	 * due to the store & forward characteristics of WIFI.
+	 * Very low throughput values are the exception.
+	 */
+	if ((throughput > 10) &&
+	    (if_incoming == if_outgoing) &&
+	    (batadv_is_wifi_netdev(if_incoming->net_dev)))
+		return throughput / 2;
+
+	/* hop penalty of 255 equals 100% */
+	return throughput * (hop_penalty_max - hop_penalty) / hop_penalty_max;
+}
+
+/**
+ * batadv_v_ogm_forward - forward an OGM to the given outgoing interface
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ogm_received: previously received OGM to be forwarded
+ * @throughput: throughput to announce, may vary per outgoing interface
+ * @if_incoming: the interface on which this OGM was received on
+ * @if_outgoing: the interface to which the OGM has to be forwarded to
+ *
+ * Forward an OGM to an interface after having altered the throughput metric and
+ * the TTL value contained in it. The original OGM isn't modified.
+ */
+static void batadv_v_ogm_forward(struct batadv_priv *bat_priv,
+				 const struct batadv_ogm2_packet *ogm_received,
+				 u32 throughput,
+				 struct batadv_hard_iface *if_incoming,
+				 struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_ogm2_packet *ogm_forward;
+	unsigned char *skb_buff;
+	struct sk_buff *skb;
+	size_t packet_len;
+	u16 tvlv_len;
+
+	if (ogm_received->ttl <= 1) {
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "ttl exceeded\n");
+		return;
+	}
+
+	tvlv_len = ntohs(ogm_received->tvlv_len);
+
+	packet_len = BATADV_OGM2_HLEN + tvlv_len;
+	skb = netdev_alloc_skb_ip_align(if_outgoing->net_dev,
+					ETH_HLEN + packet_len);
+	if (!skb)
+		return;
+
+	skb_reserve(skb, ETH_HLEN);
+	skb_buff = skb_put(skb, packet_len);
+	memcpy(skb_buff, ogm_received, packet_len);
+
+	/* apply forward penalty */
+	ogm_forward = (struct batadv_ogm2_packet *)skb_buff;
+	ogm_forward->throughput = htonl(throughput);
+	ogm_forward->ttl--;
+
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Forwarding OGM2 packet on %s: throughput %u, ttl %u, received via %s\n",
+		   if_outgoing->net_dev->name, throughput, ogm_forward->ttl,
+		   if_incoming->net_dev->name);
+
+	batadv_v_ogm_send_to_if(skb, if_outgoing);
+}
+
+/**
+ * batadv_v_ogm_metric_update - update route metric based on OGM
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ogm2: OGM2 structure
+ * @orig_node: Originator structure for which the OGM has been received
+ * @neigh_node: the neigh_node through with the OGM has been received
+ * @if_incoming: the interface where this packet was received
+ * @if_outgoing: the interface for which the packet should be considered
+ *
+ * Return:
+ *  1  if the OGM is new,
+ *  0  if it is not new but valid,
+ *  <0 on error (e.g. old OGM)
+ */
+static int batadv_v_ogm_metric_update(struct batadv_priv *bat_priv,
+				      const struct batadv_ogm2_packet *ogm2,
+				      struct batadv_orig_node *orig_node,
+				      struct batadv_neigh_node *neigh_node,
+				      struct batadv_hard_iface *if_incoming,
+				      struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
+	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL;
+	bool protection_started = false;
+	int ret = -EINVAL;
+	u32 path_throughput;
+	s32 seq_diff;
+
+	orig_ifinfo = batadv_orig_ifinfo_new(orig_node, if_outgoing);
+	if (!orig_ifinfo)
+		goto out;
+
+	seq_diff = ntohl(ogm2->seqno) - orig_ifinfo->last_real_seqno;
+
+	if (!hlist_empty(&orig_node->neigh_list) &&
+	    batadv_window_protected(bat_priv, seq_diff,
+				    BATADV_OGM_MAX_AGE,
+				    &orig_ifinfo->batman_seqno_reset,
+				    &protection_started)) {
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Drop packet: packet within window protection time from %pM\n",
+			   ogm2->orig);
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Last reset: %ld, %ld\n",
+			   orig_ifinfo->batman_seqno_reset, jiffies);
+		goto out;
+	}
+
+	/* drop packets with old seqnos, however accept the first packet after
+	 * a host has been rebooted.
+	 */
+	if ((seq_diff < 0) && !protection_started)
+		goto out;
+
+	neigh_node->last_seen = jiffies;
+
+	orig_node->last_seen = jiffies;
+
+	orig_ifinfo->last_real_seqno = ntohl(ogm2->seqno);
+	orig_ifinfo->last_ttl = ogm2->ttl;
+
+	neigh_ifinfo = batadv_neigh_ifinfo_new(neigh_node, if_outgoing);
+	if (!neigh_ifinfo)
+		goto out;
+
+	path_throughput = batadv_v_forward_penalty(bat_priv, if_incoming,
+						   if_outgoing,
+						   ntohl(ogm2->throughput));
+	neigh_ifinfo->bat_v.throughput = path_throughput;
+	neigh_ifinfo->bat_v.last_seqno = ntohl(ogm2->seqno);
+	neigh_ifinfo->last_ttl = ogm2->ttl;
+
+	if (seq_diff > 0 || protection_started)
+		ret = 1;
+	else
+		ret = 0;
+out:
+	if (orig_ifinfo)
+		batadv_orig_ifinfo_put(orig_ifinfo);
+	if (neigh_ifinfo)
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
+
+	return ret;
+}
+
+/**
+ * batadv_v_ogm_route_update - update routes based on OGM
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ethhdr: the Ethernet header of the OGM2
+ * @ogm2: OGM2 structure
+ * @orig_node: Originator structure for which the OGM has been received
+ * @neigh_node: the neigh_node through with the OGM has been received
+ * @if_incoming: the interface where this packet was received
+ * @if_outgoing: the interface for which the packet should be considered
+ */
+static void batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
+				      const struct ethhdr *ethhdr,
+				      const struct batadv_ogm2_packet *ogm2,
+				      struct batadv_orig_node *orig_node,
+				      struct batadv_neigh_node *neigh_node,
+				      struct batadv_hard_iface *if_incoming,
+				      struct batadv_hard_iface *if_outgoing)
+{
+	struct batadv_neigh_node *router = NULL;
+	struct batadv_neigh_ifinfo *neigh_ifinfo = NULL;
+	struct batadv_orig_node *orig_neigh_node = NULL;
+	struct batadv_orig_ifinfo *orig_ifinfo = NULL;
+	struct batadv_neigh_node *orig_neigh_router = NULL;
+
+	neigh_ifinfo = batadv_neigh_ifinfo_get(neigh_node, if_outgoing);
+	if (!neigh_ifinfo)
+		goto out;
+
+	orig_neigh_node = batadv_v_ogm_orig_get(bat_priv, ethhdr->h_source);
+	if (!orig_neigh_node)
+		goto out;
+
+	orig_neigh_router = batadv_orig_router_get(orig_neigh_node,
+						   if_outgoing);
+
+	/* drop packet if sender is not a direct neighbor and if we
+	 * don't route towards it
+	 */
+	router = batadv_orig_router_get(orig_node, if_outgoing);
+	if (router && router->orig_node != orig_node && !orig_neigh_router) {
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Drop packet: OGM via unknown neighbor!\n");
+		goto out;
+	}
+
+	if (router)
+		batadv_neigh_node_put(router);
+
+	/* Update routes, and check if the OGM is from the best next hop */
+	batadv_v_ogm_orig_update(bat_priv, orig_node, neigh_node, ogm2,
+				 if_outgoing);
+
+	orig_ifinfo = batadv_orig_ifinfo_new(orig_node, if_outgoing);
+	if (!orig_ifinfo)
+		goto out;
+
+	/* don't forward the same seqno twice on one interface */
+	if (orig_ifinfo->last_seqno_forwarded == ntohl(ogm2->seqno))
+		goto out;
+
+	/* acquire possibly updated router */
+	router = batadv_orig_router_get(orig_node, if_outgoing);
+
+	/* strict rule: forward packets coming from the best next hop only */
+	if (neigh_node != router)
+		goto out;
+
+	/* only forward for specific interface, not for the default one. */
+	if (if_outgoing != BATADV_IF_DEFAULT) {
+		orig_ifinfo->last_seqno_forwarded = ntohl(ogm2->seqno);
+		batadv_v_ogm_forward(bat_priv, ogm2,
+				     neigh_ifinfo->bat_v.throughput,
+				     if_incoming, if_outgoing);
+	}
+
+out:
+	if (orig_ifinfo)
+		batadv_orig_ifinfo_put(orig_ifinfo);
+	if (router)
+		batadv_neigh_node_put(router);
+	if (orig_neigh_router)
+		batadv_neigh_node_put(orig_neigh_router);
+	if (orig_neigh_node)
+		batadv_orig_node_put(orig_neigh_node);
+	if (neigh_ifinfo)
+		batadv_neigh_ifinfo_put(neigh_ifinfo);
+}
+
+/**
+ * batadv_v_ogm_process_per_outif - process a batman v OGM for an outgoing if
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ethhdr: the Ethernet header of the OGM2
+ * @ogm2: OGM2 structure
+ * @orig_node: Originator structure for which the OGM has been received
+ * @neigh_node: the neigh_node through with the OGM has been received
+ * @if_incoming: the interface where this packet was received
+ * @if_outgoing: the interface for which the packet should be considered
+ */
+static void
+batadv_v_ogm_process_per_outif(struct batadv_priv *bat_priv,
+			       const struct ethhdr *ethhdr,
+			       const struct batadv_ogm2_packet *ogm2,
+			       struct batadv_orig_node *orig_node,
+			       struct batadv_neigh_node *neigh_node,
+			       struct batadv_hard_iface *if_incoming,
+			       struct batadv_hard_iface *if_outgoing)
+{
+	int seqno_age;
+
+	/* first, update the metric with according sanity checks */
+	seqno_age = batadv_v_ogm_metric_update(bat_priv, ogm2, orig_node,
+					       neigh_node, if_incoming,
+					       if_outgoing);
+
+	/* outdated sequence numbers are to be discarded */
+	if (seqno_age < 0)
+		return;
+
+	/* only unknown & newer OGMs contain TVLVs we are interested in */
+	if ((seqno_age > 0) && (if_outgoing == BATADV_IF_DEFAULT))
+		batadv_tvlv_containers_process(bat_priv, true, orig_node,
+					       NULL, NULL,
+					       (unsigned char *)(ogm2 + 1),
+					       ntohs(ogm2->tvlv_len));
+
+	/* if the metric update went through, update routes if needed */
+	batadv_v_ogm_route_update(bat_priv, ethhdr, ogm2, orig_node,
+				  neigh_node, if_incoming, if_outgoing);
+}
+
+/**
+ * batadv_v_ogm_aggr_packet - checks if there is another OGM aggregated
+ * @buff_pos: current position in the skb
+ * @packet_len: total length of the skb
+ * @tvlv_len: tvlv length of the previously considered OGM
+ *
+ * Return: true if there is enough space for another OGM, false otherwise.
+ */
+static bool batadv_v_ogm_aggr_packet(int buff_pos, int packet_len,
+				     __be16 tvlv_len)
+{
+	int next_buff_pos = 0;
+
+	next_buff_pos += buff_pos + BATADV_OGM2_HLEN;
+	next_buff_pos += ntohs(tvlv_len);
+
+	return (next_buff_pos <= packet_len) &&
+	       (next_buff_pos <= BATADV_MAX_AGGREGATION_BYTES);
+}
+
+/**
+ * batadv_v_ogm_process - process an incoming batman v OGM
+ * @skb: the skb containing the OGM
+ * @ogm_offset: offset to the OGM which should be processed (for aggregates)
+ * @if_incoming: the interface where this packet was receved
+ */
+static void batadv_v_ogm_process(const struct sk_buff *skb, int ogm_offset,
+				 struct batadv_hard_iface *if_incoming)
+{
+	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
+	struct ethhdr *ethhdr;
+	struct batadv_orig_node *orig_node = NULL;
+	struct batadv_hardif_neigh_node *hardif_neigh = NULL;
+	struct batadv_neigh_node *neigh_node = NULL;
+	struct batadv_hard_iface *hard_iface;
+	struct batadv_ogm2_packet *ogm_packet;
+	u32 ogm_throughput, link_throughput, path_throughput;
+
+	ethhdr = eth_hdr(skb);
+	ogm_packet = (struct batadv_ogm2_packet *)(skb->data + ogm_offset);
+
+	ogm_throughput = ntohl(ogm_packet->throughput);
+
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Received OGM2 packet via NB: %pM, IF: %s [%pM] (from OG: %pM, seqno %u, troughput %u, TTL %u, V %u, tvlv_len %u)\n",
+		   ethhdr->h_source, if_incoming->net_dev->name,
+		   if_incoming->net_dev->dev_addr, ogm_packet->orig,
+		   ntohl(ogm_packet->seqno), ogm_throughput, ogm_packet->ttl,
+		   ogm_packet->version, ntohs(ogm_packet->tvlv_len));
+
+	/* If the troughput metric is 0, immediately drop the packet. No need to
+	 * create orig_node / neigh_node for an unusable route.
+	 */
+	if (ogm_throughput == 0) {
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Drop packet: originator packet with troughput metric of 0\n");
+		return;
+	}
+
+	/* require ELP packets be to received from this neighbor first */
+	hardif_neigh = batadv_hardif_neigh_get(if_incoming, ethhdr->h_source);
+	if (!hardif_neigh) {
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "Drop packet: OGM via unknown neighbor!\n");
+		goto out;
+	}
+
+	orig_node = batadv_v_ogm_orig_get(bat_priv, ogm_packet->orig);
+	if (!orig_node)
+		return;
+
+	neigh_node = batadv_neigh_node_new(orig_node, if_incoming,
+					   ethhdr->h_source);
+	if (!neigh_node)
+		goto out;
+
+	/* Update the received throughput metric to match the link
+	 * characteristic:
+	 *  - If this OGM traveled one hop so far (emitted by single hop
+	 *    neighbor) the path throughput metric equals the link throughput.
+	 *  - For OGMs traversing more than hop the path throughput metric is
+	 *    the smaller of the path throughput and the link throughput.
+	 */
+	link_throughput = ewma_throughput_read(&hardif_neigh->bat_v.throughput);
+	path_throughput = min_t(u32, link_throughput, ogm_throughput);
+	ogm_packet->throughput = htonl(path_throughput);
+
+	batadv_v_ogm_process_per_outif(bat_priv, ethhdr, ogm_packet, orig_node,
+				       neigh_node, if_incoming,
+				       BATADV_IF_DEFAULT);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->if_status != BATADV_IF_ACTIVE)
+			continue;
+
+		if (hard_iface->soft_iface != bat_priv->soft_iface)
+			continue;
+
+		batadv_v_ogm_process_per_outif(bat_priv, ethhdr, ogm_packet,
+					       orig_node, neigh_node,
+					       if_incoming, hard_iface);
+	}
+	rcu_read_unlock();
+out:
+	if (orig_node)
+		batadv_orig_node_put(orig_node);
+	if (neigh_node)
+		batadv_neigh_node_put(neigh_node);
+	if (hardif_neigh)
+		batadv_hardif_neigh_put(hardif_neigh);
+}
+
+/**
  * batadv_v_ogm_packet_recv - OGM2 receiving handler
  * @skb: the received OGM
  * @if_incoming: the interface where this OGM has been received
@@ -206,6 +741,9 @@ int batadv_v_ogm_packet_recv(struct sk_buff *skb,
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batadv_ogm2_packet *ogm_packet;
 	struct ethhdr *ethhdr = eth_hdr(skb);
+	int ogm_offset;
+	u8 *packet_pos;
+	int ret = NET_RX_DROP;
 
 	/* did we receive a OGM2 packet on an interface that does not have
 	 * B.A.T.M.A.N. V enabled ?
@@ -228,8 +766,24 @@ int batadv_v_ogm_packet_recv(struct sk_buff *skb,
 	batadv_add_counter(bat_priv, BATADV_CNT_MGMT_RX_BYTES,
 			   skb->len + ETH_HLEN);
 
+	ogm_offset = 0;
+	ogm_packet = (struct batadv_ogm2_packet *)skb->data;
+
+	while (batadv_v_ogm_aggr_packet(ogm_offset, skb_headlen(skb),
+					ogm_packet->tvlv_len)) {
+		batadv_v_ogm_process(skb, ogm_offset, if_incoming);
+
+		ogm_offset += BATADV_OGM2_HLEN;
+		ogm_offset += ntohs(ogm_packet->tvlv_len);
+
+		packet_pos = skb->data + ogm_offset;
+		ogm_packet = (struct batadv_ogm2_packet *)packet_pos;
+	}
+
+	ret = NET_RX_SUCCESS;
 	consume_skb(skb);
-	return NET_RX_SUCCESS;
+
+	return ret;
 }
 
 /**
diff --git a/net/batman-adv/bat_v_ogm.h b/net/batman-adv/bat_v_ogm.h
index d9f178cedcd2..d849c75ada0e 100644
--- a/net/batman-adv/bat_v_ogm.h
+++ b/net/batman-adv/bat_v_ogm.h
@@ -18,6 +18,8 @@
 #ifndef _BATMAN_ADV_BATADV_V_OGM_H_
 #define _BATMAN_ADV_BATADV_V_OGM_H_
 
+#include <linux/types.h>
+
 struct batadv_hard_iface;
 struct batadv_priv;
 struct sk_buff;
@@ -25,6 +27,8 @@ struct sk_buff;
 int batadv_v_ogm_init(struct batadv_priv *bat_priv);
 void batadv_v_ogm_free(struct batadv_priv *bat_priv);
 int batadv_v_ogm_iface_enable(struct batadv_hard_iface *hard_iface);
+struct batadv_orig_node *batadv_v_ogm_orig_get(struct batadv_priv *bat_priv,
+					       const u8 *addr);
 void batadv_v_ogm_primary_iface_set(struct batadv_hard_iface *primary_iface);
 int batadv_v_ogm_packet_recv(struct sk_buff *skb,
 			     struct batadv_hard_iface *if_incoming);
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index fa0b067e589d..2e795446208f 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -63,6 +63,8 @@
 
 /* B.A.T.M.A.N. V */
 #define BATADV_ELP_MAX_AGE 64
+#define BATADV_OGM_MAX_ORIGDIFF 5
+#define BATADV_OGM_MAX_AGE 64
 
 /* number of OGMs sent with the last tt diff */
 #define BATADV_TT_OGM_APPEND_MAX 3
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index e213ccdd4c6c..cf55cd0586b5 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -149,6 +149,7 @@ struct batadv_hard_iface {
  * @router: router that should be used to reach this originator
  * @last_real_seqno: last and best known sequence number
  * @last_ttl: ttl of last received packet
+ * @last_seqno_forwarded: seqno of the OGM which was forwarded last
  * @batman_seqno_reset: time when the batman seqno window was reset
  * @refcount: number of contexts the object is used
  * @rcu: struct used for freeing in an RCU-safe manner
@@ -159,6 +160,7 @@ struct batadv_orig_ifinfo {
 	struct batadv_neigh_node __rcu *router; /* rcu protected pointer */
 	u32 last_real_seqno;
 	u8 last_ttl;
+	u32 last_seqno_forwarded;
 	unsigned long batman_seqno_reset;
 	struct kref refcount;
 	struct rcu_head rcu;
@@ -448,9 +450,11 @@ struct batadv_neigh_ifinfo_bat_iv {
  * struct batadv_neigh_ifinfo_bat_v - neighbor information per outgoing
  *  interface for B.A.T.M.A.N. V
  * @throughput: last throughput metric received from originator via this neigh
+ * @last_seqno: last sequence number known for this neighbor
  */
 struct batadv_neigh_ifinfo_bat_v {
 	u32 throughput;
+	u32 last_seqno;
 };
 
 /**
-- 
2.7.2
