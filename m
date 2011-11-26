From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: [PATCH 04/10] batman-adv: refactoring gateway
	handling code
Date: Sat, 26 Nov 2011 22:26:46 +0800
Message-ID: <1322317612-7770-5-git-send-email-lindner_marek@yahoo.de>
References: <1322317612-7770-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1322317612-7770-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
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

Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Acked-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_client.c |  157 ++++++++++++++++++++++++---------------
 net/batman-adv/gateway_client.h |    5 +-
 net/batman-adv/soft-interface.c |   43 +++++++----
 3 files changed, 128 insertions(+), 77 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 619fb73..9373a14 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -25,6 +25,7 @@
 #include "gateway_common.h"
 #include "hard-interface.h"
 #include "originator.h"
+#include "translation-table.h"
 #include "routing.h"
 #include <linux/ip.h>
 #include <linux/ipv6.h>
@@ -572,108 +573,142 @@ out:
 	return ret;
 }
 
-int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb,
-		 struct orig_node *old_gw)
+bool gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len)
 {
 	struct ethhdr *ethhdr;
 	struct iphdr *iphdr;
 	struct ipv6hdr *ipv6hdr;
 	struct udphdr *udphdr;
-	struct gw_node *curr_gw;
-	struct neigh_node *neigh_curr = NULL, *neigh_old = NULL;
-	unsigned int header_len = 0;
-	int ret = 1;
-
-	if (atomic_read(&bat_priv->gw_mode) == GW_MODE_OFF)
-		return 0;
 
 	/* check for ethernet header */
-	if (!pskb_may_pull(skb, header_len + ETH_HLEN))
-		return 0;
+	if (!pskb_may_pull(skb, *header_len + ETH_HLEN))
+		return false;
 	ethhdr = (struct ethhdr *)skb->data;
-	header_len += ETH_HLEN;
+	*header_len += ETH_HLEN;
 
 	/* check for initial vlan header */
 	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
-		if (!pskb_may_pull(skb, header_len + VLAN_HLEN))
-			return 0;
+		if (!pskb_may_pull(skb, *header_len + VLAN_HLEN))
+			return false;
 		ethhdr = (struct ethhdr *)(skb->data + VLAN_HLEN);
-		header_len += VLAN_HLEN;
+		*header_len += VLAN_HLEN;
 	}
 
 	/* check for ip header */
 	switch (ntohs(ethhdr->h_proto)) {
 	case ETH_P_IP:
-		if (!pskb_may_pull(skb, header_len + sizeof(*iphdr)))
-			return 0;
-		iphdr = (struct iphdr *)(skb->data + header_len);
-		header_len += iphdr->ihl * 4;
+		if (!pskb_may_pull(skb, *header_len + sizeof(*iphdr)))
+			return false;
+		iphdr = (struct iphdr *)(skb->data + *header_len);
+		*header_len += iphdr->ihl * 4;
 
 		/* check for udp header */
 		if (iphdr->protocol != IPPROTO_UDP)
-			return 0;
+			return false;
 
 		break;
 	case ETH_P_IPV6:
-		if (!pskb_may_pull(skb, header_len + sizeof(*ipv6hdr)))
-			return 0;
-		ipv6hdr = (struct ipv6hdr *)(skb->data + header_len);
-		header_len += sizeof(*ipv6hdr);
+		if (!pskb_may_pull(skb, *header_len + sizeof(*ipv6hdr)))
+			return false;
+		ipv6hdr = (struct ipv6hdr *)(skb->data + *header_len);
+		*header_len += sizeof(*ipv6hdr);
 
 		/* check for udp header */
 		if (ipv6hdr->nexthdr != IPPROTO_UDP)
-			return 0;
+			return false;
 
 		break;
 	default:
-		return 0;
+		return false;
 	}
 
-	if (!pskb_may_pull(skb, header_len + sizeof(*udphdr)))
-		return 0;
-	udphdr = (struct udphdr *)(skb->data + header_len);
-	header_len += sizeof(*udphdr);
+	if (!pskb_may_pull(skb, *header_len + sizeof(*udphdr)))
+		return false;
+	udphdr = (struct udphdr *)(skb->data + *header_len);
+	*header_len += sizeof(*udphdr);
 
 	/* check for bootp port */
 	if ((ntohs(ethhdr->h_proto) == ETH_P_IP) &&
 	     (ntohs(udphdr->dest) != 67))
-		return 0;
+		return false;
 
 	if ((ntohs(ethhdr->h_proto) == ETH_P_IPV6) &&
 	    (ntohs(udphdr->dest) != 547))
-		return 0;
-
-	if (atomic_read(&bat_priv->gw_mode) == GW_MODE_SERVER)
-		return -1;
-
-	curr_gw = gw_get_selected_gw_node(bat_priv);
-	if (!curr_gw)
-		return 0;
-
-	/* If old_gw != NULL then this packet is unicast.
-	 * So, at this point we have to check the message type: if it is a
-	 * DHCPREQUEST we have to decide whether to drop it or not */
-	if (old_gw && curr_gw->orig_node != old_gw) {
-		if (is_type_dhcprequest(skb, header_len)) {
-			/* If the dhcp packet has been sent to a different gw,
-			 * we have to evaluate whether the old gw is still
-			 * reliable enough */
-			neigh_curr = find_router(bat_priv, curr_gw->orig_node,
-						 NULL);
-			neigh_old = find_router(bat_priv, old_gw, NULL);
-			if (!neigh_curr || !neigh_old)
-				goto free_neigh;
-			if (neigh_curr->tq_avg - neigh_old->tq_avg <
-								GW_THRESHOLD)
-				ret = -1;
-		}
+		return false;
+
+	return true;
+}
+
+bool gw_out_of_range(struct bat_priv *bat_priv,
+		     struct sk_buff *skb, struct ethhdr *ethhdr)
+{
+	struct neigh_node *neigh_curr = NULL, *neigh_old = NULL;
+	struct orig_node *orig_dst_node = NULL;
+	struct gw_node *curr_gw = NULL;
+	bool ret, out_of_range = false;
+	unsigned int header_len = 0;
+	uint8_t curr_tq_avg;
+
+	ret = gw_is_dhcp_target(skb, &header_len);
+	if (!ret)
+		goto out;
+
+	orig_dst_node = transtable_search(bat_priv, ethhdr->h_source,
+					  ethhdr->h_dest);
+	if (!orig_dst_node)
+		goto out;
+
+	if (!orig_dst_node->gw_flags)
+		goto out;
+
+	ret = is_type_dhcprequest(skb, header_len);
+	if (!ret)
+		goto out;
+
+	switch (atomic_read(&bat_priv->gw_mode)) {
+	case GW_MODE_SERVER:
+		/* If we are a GW then we are our best GW. We can artificially
+		 * set the tq towards ourself as the maximum value */
+		curr_tq_avg = TQ_MAX_VALUE;
+		break;
+	case GW_MODE_CLIENT:
+		curr_gw = gw_get_selected_gw_node(bat_priv);
+		if (!curr_gw)
+			goto out;
+
+		/* packet is going to our gateway */
+		if (curr_gw->orig_node == orig_dst_node)
+			goto out;
+
+		/* If the dhcp packet has been sent to a different gw,
+		 * we have to evaluate whether the old gw is still
+		 * reliable enough */
+		neigh_curr = find_router(bat_priv, curr_gw->orig_node, NULL);
+		if (!neigh_curr)
+			goto out;
+
+		curr_tq_avg = neigh_curr->tq_avg;
+		break;
+	case GW_MODE_OFF:
+	default:
+		goto out;
 	}
-free_neigh:
+
+	neigh_old = find_router(bat_priv, orig_dst_node, NULL);
+	if (!!neigh_old)
+		goto out;
+
+	if (curr_tq_avg - neigh_old->tq_avg > GW_THRESHOLD)
+		out_of_range = true;
+
+out:
+	if (orig_dst_node)
+		orig_node_free_ref(orig_dst_node);
+	if (curr_gw)
+		gw_node_free_ref(curr_gw);
 	if (neigh_old)
 		neigh_node_free_ref(neigh_old);
 	if (neigh_curr)
 		neigh_node_free_ref(neigh_curr);
-	if (curr_gw)
-		gw_node_free_ref(curr_gw);
-	return ret;
+	return out_of_range;
 }
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index b9b983c..e1edba0 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -31,7 +31,8 @@ void gw_node_update(struct bat_priv *bat_priv,
 void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_node);
 void gw_node_purge(struct bat_priv *bat_priv);
 int gw_client_seq_print_text(struct seq_file *seq, void *offset);
-int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb,
-		 struct orig_node *old_gw);
+bool gw_is_dhcp_target(struct sk_buff *skb, unsigned int *header_len);
+bool gw_out_of_range(struct bat_priv *bat_priv,
+		     struct sk_buff *skb, struct ethhdr *ethhdr);
 
 #endif /* _NET_BATMAN_ADV_GATEWAY_CLIENT_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index f9cc957..45297c8 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -563,10 +563,10 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	struct bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
 	struct softif_neigh *curr_softif_neigh = NULL;
-	struct orig_node *orig_node = NULL;
+	unsigned int header_len = 0;
 	int data_len = skb->len, ret;
 	short vid = -1;
-	bool do_bcast;
+	bool do_bcast = false;
 
 	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
 		goto dropped;
@@ -598,17 +598,28 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	/* Register the client MAC in the transtable */
 	tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
 
-	orig_node = transtable_search(bat_priv, ethhdr->h_source,
-				      ethhdr->h_dest);
-	do_bcast = is_multicast_ether_addr(ethhdr->h_dest);
-	if (do_bcast || (orig_node && orig_node->gw_flags)) {
-		ret = gw_is_target(bat_priv, skb, orig_node);
+	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+		do_bcast = true;
 
-		if (ret < 0)
-			goto dropped;
-
-		if (ret)
-			do_bcast = false;
+		switch (atomic_read(&bat_priv->gw_mode)) {
+		case GW_MODE_SERVER:
+			/* gateway servers should not send dhcp
+			 * requests into the mesh */
+			ret = gw_is_dhcp_target(skb, &header_len);
+			if (ret)
+				goto dropped;
+			break;
+		case GW_MODE_CLIENT:
+			/* gateway clients should send dhcp requests
+			 * via unicast to their gateway */
+			ret = gw_is_dhcp_target(skb, &header_len);
+			if (ret)
+				do_bcast = false;
+			break;
+		case GW_MODE_OFF:
+		default:
+			break;
+		}
 	}
 
 	/* ethernet packet should be broadcasted */
@@ -644,6 +655,12 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 
 	/* unicast packet */
 	} else {
+		if (atomic_read(&bat_priv->gw_mode) != GW_MODE_OFF) {
+			ret = gw_out_of_range(bat_priv, skb, ethhdr);
+			if (ret)
+				goto dropped;
+		}
+
 		ret = unicast_send_skb(skb, bat_priv);
 		if (ret != 0)
 			goto dropped_freed;
@@ -662,8 +679,6 @@ end:
 		softif_neigh_free_ref(curr_softif_neigh);
 	if (primary_if)
 		hardif_free_ref(primary_if);
-	if (orig_node)
-		orig_node_free_ref(orig_node);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.5.4
