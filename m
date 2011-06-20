From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 12/12] batman-adv: improved gateway tq-based
	selection
Date: Mon, 20 Jun 2011 12:17:05 +0200
Message-ID: <1308565025-21293-13-git-send-email-sven@narfation.org>
References: <1308565025-21293-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1308565025-21293-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>

If a client issues a DHCPREQUEST for renewal, the packet is dropped
if the old destination (the old gateway for the client) TQ is smaller
than the current best gateway TQ less GW_THRESHOLD

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_client.c |   94 ++++++++++++++++++++++++++++++++++++++-
 net/batman-adv/gateway_client.h |    3 +-
 net/batman-adv/main.h           |    3 +-
 net/batman-adv/soft-interface.c |   10 +++-
 4 files changed, 104 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 6381864..8b25b52 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -25,11 +25,17 @@
 #include "gateway_common.h"
 #include "hard-interface.h"
 #include "originator.h"
+#include "routing.h"
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/udp.h>
 #include <linux/if_vlan.h>
 
+/* This is the offset of the options field in a dhcp packet starting at
+ * the beginning of the dhcp header */
+#define DHCP_OPTIONS_OFFSET 240
+#define DHCP_REQUEST 3
+
 static void gw_node_free_ref(struct gw_node *gw_node)
 {
 	if (atomic_dec_and_test(&gw_node->refcount))
@@ -509,14 +515,75 @@ out:
 	return ret;
 }
 
-int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
+static bool is_type_dhcprequest(struct sk_buff *skb, int header_len)
+{
+	int ret = false;
+	unsigned char *p;
+	int pkt_len;
+
+	if (skb_linearize(skb) < 0)
+		goto out;
+
+	pkt_len = skb_headlen(skb);
+
+	if (pkt_len < header_len + DHCP_OPTIONS_OFFSET + 1)
+		goto out;
+
+	p = skb->data + header_len + DHCP_OPTIONS_OFFSET;
+	pkt_len -= header_len + DHCP_OPTIONS_OFFSET + 1;
+
+	/* Access the dhcp option lists. Each entry is made up by:
+	 * - octect 1: option type
+	 * - octect 2: option data len (only if type != 255 and 0)
+	 * - octect 3: option data */
+	while (*p != 255 && !ret) {
+		/* p now points to the first octect: option type */
+		if (*p == 53) {
+			/* type 53 is the message type option.
+			 * Jump the len octect and go to the data octect */
+			if (pkt_len < 2)
+				goto out;
+			p += 2;
+
+			/* check if the message type is what we need */
+			if (*p == DHCP_REQUEST)
+				ret = true;
+			break;
+		} else if (*p == 0) {
+			/* option type 0 (padding), just go forward */
+			if (pkt_len < 1)
+				goto out;
+			pkt_len--;
+			p++;
+		} else {
+			/* This is any other option. So we get the length... */
+			if (pkt_len < 1)
+				goto out;
+			pkt_len--;
+			p++;
+
+			/* ...and then we jump over the data */
+			if (pkt_len < *p)
+				goto out;
+			pkt_len -= *p;
+			p += (*p);
+		}
+	}
+out:
+	return ret;
+}
+
+int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb,
+		 struct orig_node *old_gw)
 {
 	struct ethhdr *ethhdr;
 	struct iphdr *iphdr;
 	struct ipv6hdr *ipv6hdr;
 	struct udphdr *udphdr;
 	struct gw_node *curr_gw;
+	struct neigh_node *neigh_curr = NULL, *neigh_old = NULL;
 	unsigned int header_len = 0;
+	int ret = 1;
 
 	if (atomic_read(&bat_priv->gw_mode) == GW_MODE_OFF)
 		return 0;
@@ -584,7 +651,30 @@ int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb)
 	if (!curr_gw)
 		return 0;
 
+	/* If old_gw != NULL then this packet is unicast.
+	 * So, at this point we have to check the message type: if it is a
+	 * DHCPREQUEST we have to decide whether to drop it or not */
+	if (old_gw && curr_gw->orig_node != old_gw) {
+		if (is_type_dhcprequest(skb, header_len)) {
+			/* If the dhcp packet has been sent to a different gw,
+			 * we have to evaluate whether the old gw is still
+			 * reliable enough */
+			neigh_curr = find_router(bat_priv, curr_gw->orig_node,
+						 NULL);
+			neigh_old = find_router(bat_priv, old_gw, NULL);
+			if (!neigh_curr || !neigh_old)
+				goto free_neigh;
+			if (neigh_curr->tq_avg - neigh_old->tq_avg <
+								GW_THRESHOLD)
+				ret = -1;
+		}
+	}
+free_neigh:
+	if (neigh_old)
+		neigh_node_free_ref(neigh_old);
+	if (neigh_curr)
+		neigh_node_free_ref(neigh_curr);
 	if (curr_gw)
 		gw_node_free_ref(curr_gw);
-	return 1;
+	return ret;
 }
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index 1ce8c60..b9b983c 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -31,6 +31,7 @@ void gw_node_update(struct bat_priv *bat_priv,
 void gw_node_delete(struct bat_priv *bat_priv, struct orig_node *orig_node);
 void gw_node_purge(struct bat_priv *bat_priv);
 int gw_client_seq_print_text(struct seq_file *seq, void *offset);
-int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb);
+int gw_is_target(struct bat_priv *bat_priv, struct sk_buff *skb,
+		 struct orig_node *old_gw);
 
 #endif /* _NET_BATMAN_ADV_GATEWAY_CLIENT_H_ */
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index f9e0e17..4f293b5 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -91,7 +91,6 @@ enum mesh_state {
 #define BCAST_QUEUE_LEN		256
 #define BATMAN_QUEUE_LEN	256
 
-
 enum uev_action {
 	UEV_ADD = 0,
 	UEV_DEL,
@@ -102,6 +101,8 @@ enum uev_type {
 	UEV_GW = 0
 };
 
+#define GW_THRESHOLD	50
+
 /*
  * Debug Messages
  */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 3371ece..2dcdbb7 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -30,6 +30,7 @@
 #include "gateway_common.h"
 #include "gateway_client.h"
 #include "bat_sysfs.h"
+#include "originator.h"
 #include <linux/slab.h>
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
@@ -561,6 +562,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	struct bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
 	struct softif_neigh *curr_softif_neigh = NULL;
+	struct orig_node *orig_node = NULL;
 	int data_len = skb->len, ret;
 	short vid = -1;
 	bool do_bcast = false;
@@ -595,8 +597,10 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	/* Register the client MAC in the transtable */
 	tt_local_add(soft_iface, ethhdr->h_source);
 
-	if (is_multicast_ether_addr(ethhdr->h_dest)) {
-		ret = gw_is_target(bat_priv, skb);
+	orig_node = transtable_search(bat_priv, ethhdr->h_dest);
+	if (is_multicast_ether_addr(ethhdr->h_dest) ||
+				(orig_node && orig_node->gw_flags)) {
+		ret = gw_is_target(bat_priv, skb, orig_node);
 
 		if (ret < 0)
 			goto dropped;
@@ -656,6 +660,8 @@ end:
 		softif_neigh_free_ref(curr_softif_neigh);
 	if (primary_if)
 		hardif_free_ref(primary_if);
+	if (orig_node)
+		orig_node_free_ref(orig_node);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.5.3
