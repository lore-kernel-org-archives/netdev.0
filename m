From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH net] batman-adv: check incoming packet type for bla
Date: Fri,  6 Jul 2012 00:48:34 +0200
Message-ID: <1341528514-27906-2-git-send-email-ordex@autistici.org>
References: <1341528514-27906-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:36374 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933143Ab2GEWsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 18:48:36 -0400
In-Reply-To: <1341528514-27906-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

If the gateway functionality is used, some broadcast packets (DHCP
requests) may be transmitted as unicast packets. As the bridge loop
avoidance code now only considers the payload Ethernet destination,
it may drop the DHCP request for clients which are claimed by other
backbone gateways, because it falsely infers from the broadcast address
that the right backbone gateway should havehandled the broadcast.

Fix this by checking and delegating the batman-adv packet type used
for transmission.

Reported-by: Guido Iribarren <guidoiribarren@buenosaireslibre.org>
Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
---
 net/batman-adv/bridge_loop_avoidance.c |   15 +++++++++++----
 net/batman-adv/bridge_loop_avoidance.h |    5 +++--
 net/batman-adv/soft-interface.c        |    6 +++++-
 3 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 8bf9751..c5863f4 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1351,6 +1351,7 @@ void bla_free(struct bat_priv *bat_priv)
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  * @vid: the VLAN ID of the frame
+ * @is_bcast: the packet came in a broadcast packet type.
  *
  * bla_rx avoidance checks if:
  *  * we have to race for a claim
@@ -1361,7 +1362,8 @@ void bla_free(struct bat_priv *bat_priv)
  * process the skb.
  *
  */
-int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
+int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid,
+	   bool is_bcast)
 {
 	struct ethhdr *ethhdr;
 	struct claim search_claim, *claim = NULL;
@@ -1380,7 +1382,7 @@ int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 
 	if (unlikely(atomic_read(&bat_priv->bla_num_requests)))
 		/* don't allow broadcasts while requests are in flight */
-		if (is_multicast_ether_addr(ethhdr->h_dest))
+		if (is_multicast_ether_addr(ethhdr->h_dest) && is_bcast)
 			goto handled;
 
 	memcpy(search_claim.addr, ethhdr->h_source, ETH_ALEN);
@@ -1406,8 +1408,13 @@ int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid)
 	}
 
 	/* if it is a broadcast ... */
-	if (is_multicast_ether_addr(ethhdr->h_dest)) {
-		/* ... drop it. the responsible gateway is in charge. */
+	if (is_multicast_ether_addr(ethhdr->h_dest) && is_bcast) {
+		/* ... drop it. the responsible gateway is in charge.
+		 *
+		 * We need to check is_bcast because with the gateway
+		 * feature, broadcasts (like DHCP requests) may be sent
+		 * using a unicast packet type.
+		 */
 		goto handled;
 	} else {
 		/* seems the client considers us as its best gateway.
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index e39f93a..dc5227b 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -23,7 +23,8 @@
 #define _NET_BATMAN_ADV_BLA_H_
 
 #ifdef CONFIG_BATMAN_ADV_BLA
-int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
+int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid,
+	   bool is_bcast);
 int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
 int bla_is_backbone_gw(struct sk_buff *skb,
 		       struct orig_node *orig_node, int hdr_size);
@@ -41,7 +42,7 @@ void bla_free(struct bat_priv *bat_priv);
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
 
 static inline int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb,
-			 short vid)
+			 short vid, bool is_bcast)
 {
 	return 0;
 }
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 6e2530b..a0ec0e4 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -256,7 +256,11 @@ void interface_rx(struct net_device *soft_iface,
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
+	struct batman_header *batadv_header = (struct batman_header *)skb->data;
 	short vid __maybe_unused = -1;
+	bool is_bcast;
+
+	is_bcast = (batadv_header->packet_type == BAT_BCAST);
 
 	/* check if enough space is available for pulling, and pull */
 	if (!pskb_may_pull(skb, hdr_size))
@@ -302,7 +306,7 @@ void interface_rx(struct net_device *soft_iface,
 	/* Let the bridge loop avoidance check the packet. If will
 	 * not handle it, we can safely push it up.
 	 */
-	if (bla_rx(bat_priv, skb, vid))
+	if (bla_rx(bat_priv, skb, vid, is_bcast))
 		goto out;
 
 	netif_rx(skb);
-- 
1.7.9.4
