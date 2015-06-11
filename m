From: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] batman:Make the function
	batadv_reroute_unicast packet bool
Date: Thu, 11 Jun 2015 10:41:49 -0400
Message-ID: <1434033709-4121-1-git-send-email-xerofoify@gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

This makes the function batadv_reroute_unicast_packet bool now
due to this particular function only returning either one or
zero as its return value.

Signed-off-by: Nicholas Krause <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/batman-adv/routing.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index da83982..fd2d1d4 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -677,8 +677,8 @@ out:
 	return ret;
 }
 
-static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
-				     struct sk_buff *skb, int hdr_len) {
+static bool batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
+				      struct sk_buff *skb, int hdr_len) {
 	struct batadv_unicast_packet *unicast_packet;
 	struct batadv_hard_iface *primary_if;
 	struct batadv_orig_node *orig_node;
@@ -689,11 +689,11 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 
 	/* check if there is enough data before accessing it */
 	if (!pskb_may_pull(skb, hdr_len + ETH_HLEN))
-		return 0;
+		return false;
 
 	/* create a copy of the skb (in case of for re-routing) to modify it. */
 	if (skb_cow(skb, sizeof(*unicast_packet)) < 0)
-		return 0;
+		return false;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 	vid = batadv_get_vid(skb, hdr_len);
@@ -717,7 +717,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 		 * table. If not, let the packet go untouched anyway because
 		 * there is nothing the node can do
 		 */
-		return 1;
+		return true;
 	}
 
 	/* retrieve the TTVN known by this node for the packet destination. This
@@ -733,7 +733,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 		 * not be possible to deliver it
 		 */
 		if (!orig_node)
-			return 0;
+			return false;
 
 		curr_ttvn = (uint8_t)atomic_read(&orig_node->last_ttvn);
 		batadv_orig_node_free_ref(orig_node);
@@ -744,7 +744,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	 */
 	is_old_ttvn = batadv_seq_before(unicast_packet->ttvn, curr_ttvn);
 	if (!is_old_ttvn)
-		return 1;
+		return true;
 
 	old_ttvn = unicast_packet->ttvn;
 	/* the packet was forged based on outdated network information. Its
@@ -757,7 +757,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 				       "Rerouting unicast packet to %pM (dst=%pM): TTVN mismatch old_ttvn=%u new_ttvn=%u\n",
 				       unicast_packet->dest, ethhdr->h_dest,
 				       old_ttvn, curr_ttvn);
-		return 1;
+		return true;
 	}
 
 	/* the packet has not been re-routed: either the destination is
@@ -765,14 +765,14 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	 * it is possible to drop the packet
 	 */
 	if (!batadv_is_my_client(bat_priv, ethhdr->h_dest, vid))
-		return 0;
+		return false;
 
 	/* update the header in order to let the packet be delivered to this
 	 * node's soft interface
 	 */
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (!primary_if)
-		return 0;
+		return false;
 
 	ether_addr_copy(unicast_packet->dest, primary_if->net_dev->dev_addr);
 
@@ -780,7 +780,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 
 	unicast_packet->ttvn = curr_ttvn;
 
-	return 1;
+	return true;
 }
 
 /**
-- 
2.1.4
