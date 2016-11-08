From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 04/17] batman-adv: Add wrapper for ARP reply
	creation
Date: Tue,  8 Nov 2016 17:45:13 +0100
Message-ID: <20161108164526.7518-5-sw@simonwunderlich.de>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20161108164526.7518-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
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

From: Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>

Removing duplicate code.

Signed-off-by: Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/distributed-arp-table.c | 67 ++++++++++++++++++++--------------
 1 file changed, 40 insertions(+), 27 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index cbb4f32..49576c5 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -949,6 +949,41 @@ static unsigned short batadv_dat_get_vid(struct sk_buff *skb, int *hdr_size)
 }
 
 /**
+ * batadv_dat_arp_create_reply - create an ARP Reply
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ip_src: ARP sender IP
+ * @ip_dst: ARP target IP
+ * @hw_src: Ethernet source and ARP sender MAC
+ * @hw_dst: Ethernet destination and ARP target MAC
+ * @vid: VLAN identifier (optional, set to zero otherwise)
+ *
+ * Creates an ARP Reply from the given values, optionally encapsulated in a
+ * VLAN header.
+ *
+ * Return: An skb containing an ARP Reply.
+ */
+static struct sk_buff *
+batadv_dat_arp_create_reply(struct batadv_priv *bat_priv, __be32 ip_src,
+			    __be32 ip_dst, u8 *hw_src, u8 *hw_dst,
+			    unsigned short vid)
+{
+	struct sk_buff *skb;
+
+	skb = arp_create(ARPOP_REPLY, ETH_P_ARP, ip_dst, bat_priv->soft_iface,
+			 ip_src, hw_dst, hw_src, hw_dst);
+	if (!skb)
+		return NULL;
+
+	skb_reset_mac_header(skb);
+
+	if (vid & BATADV_VLAN_HAS_TAG)
+		skb = vlan_insert_tag(skb, htons(ETH_P_8021Q),
+				      vid & VLAN_VID_MASK);
+
+	return skb;
+}
+
+/**
  * batadv_dat_snoop_outgoing_arp_request - snoop the ARP request and try to
  * answer using DAT
  * @bat_priv: the bat priv with all the soft interface information
@@ -1005,20 +1040,12 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 			goto out;
 		}
 
-		skb_new = arp_create(ARPOP_REPLY, ETH_P_ARP, ip_src,
-				     bat_priv->soft_iface, ip_dst, hw_src,
-				     dat_entry->mac_addr, hw_src);
+		skb_new = batadv_dat_arp_create_reply(bat_priv, ip_dst, ip_src,
+						      dat_entry->mac_addr,
+						      hw_src, vid);
 		if (!skb_new)
 			goto out;
 
-		if (vid & BATADV_VLAN_HAS_TAG) {
-			skb_new = vlan_insert_tag(skb_new, htons(ETH_P_8021Q),
-						  vid & VLAN_VID_MASK);
-			if (!skb_new)
-				goto out;
-		}
-
-		skb_reset_mac_header(skb_new);
 		skb_new->protocol = eth_type_trans(skb_new,
 						   bat_priv->soft_iface);
 		bat_priv->stats.rx_packets++;
@@ -1081,25 +1108,11 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	if (!dat_entry)
 		goto out;
 
-	skb_new = arp_create(ARPOP_REPLY, ETH_P_ARP, ip_src,
-			     bat_priv->soft_iface, ip_dst, hw_src,
-			     dat_entry->mac_addr, hw_src);
-
+	skb_new = batadv_dat_arp_create_reply(bat_priv, ip_dst, ip_src,
+					      dat_entry->mac_addr, hw_src, vid);
 	if (!skb_new)
 		goto out;
 
-	/* the rest of the TX path assumes that the mac_header offset pointing
-	 * to the inner Ethernet header has been set, therefore reset it now.
-	 */
-	skb_reset_mac_header(skb_new);
-
-	if (vid & BATADV_VLAN_HAS_TAG) {
-		skb_new = vlan_insert_tag(skb_new, htons(ETH_P_8021Q),
-					  vid & VLAN_VID_MASK);
-		if (!skb_new)
-			goto out;
-	}
-
 	/* To preserve backwards compatibility, the node has choose the outgoing
 	 * format based on the incoming request packet type. The assumption is
 	 * that a node not using the 4addr packet format doesn't support it.
-- 
2.10.1
