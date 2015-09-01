From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 13/21] net: rbridge: add basic trill frame handling function
Date: Tue,  1 Sep 2015 17:43:08 +0200
Message-ID: <1441122196-11662-14-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:57663 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752741AbbIAPxm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 11:53:42 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if trill is not enabled pass frame directly to the old handling functio=
n
if trill is enabled
frames from access port:
- destination is another access port -> deliver directly
- unknown or not an access port -> encapsulate (TODO)
frames from trunk port:
- 0x22F3 protocol -> trill frame -> TRILL handling process (TODO)
- desintation is localhost consume frame

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
Suggested-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
---
 include/linux/etherdevice.h | 17 +++++++++
 net/bridge/rbr.c            | 92 +++++++++++++++++++++++++++++++++++++=
++++++++
 2 files changed, 109 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 9012f87..fc3173e 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -58,6 +58,10 @@ int eth_gro_complete(struct sk_buff *skb, int nhoff)=
;
 /* Reserved Ethernet Addresses per IEEE 802.1Q */
 static const u8 eth_reserved_addr_base[ETH_ALEN] __aligned(2) =3D
 { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
+#ifdef CONFIG_TRILL
+static const u8 eth_reserved_addr_all_rbridge[ETH_ALEN] __aligned(2) =3D=
 {
+0x01, 0x80, 0xc2, 0x00, 0x00, 0x40};
+#endif
=20
 /**
  * is_link_local_ether_addr - Determine if given Ethernet address is l=
ink-local
@@ -447,4 +451,17 @@ static inline int eth_skb_pad(struct sk_buff *skb)
 	return skb_put_padto(skb, ETH_ZLEN);
 }
=20
+#ifdef CONFIG_TRILL
+/**
+ * is_all_rbr_address - check if it is a specific Rbridge brodcast mac=
 address
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * returns true if it is a RBridge brodcast address 01:80:C2:00:00:40
+ */
+static inline bool is_all_rbr_address(const u8 *addr)
+{
+	return ether_addr_equal(addr, eth_reserved_addr_all_rbridge);
+}
+#endif
+
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/net/bridge/rbr.c b/net/bridge/rbr.c
index 67842fe..fdff167 100644
--- a/net/bridge/rbr.c
+++ b/net/bridge/rbr.c
@@ -13,6 +13,7 @@
  */
 #include "br_private.h"
 #include "rbr_private.h"
+#include <linux/netfilter_bridge.h>
 static void rbr_del_all(struct rbr *rbr);
=20
 static struct rbr *add_rbr(struct net_bridge *br)
@@ -121,3 +122,94 @@ static void rbr_del_all(struct rbr *rbr)
 			rbr_del_node(rbr, i);
 	}
 }
+
+/* handling function hook allow handling
+ * a frame upon reception called via
+ * br_handle_frame_hook =3D rbr_handle_frame
+ * in  br.c
+ * Return NULL if skb is handled
+ * note: already called with rcu_read_lock
+ */
+rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
+{
+	struct net_bridge *br;
+	struct net_bridge_port *p;
+	struct sk_buff *skb =3D *pskb;
+	u16 vid =3D 0;
+
+	p =3D br_port_get_rcu(skb->dev);
+	br =3D p->br;
+	if (!br || !br->rbr)
+		goto drop_no_stat;
+
+	if (unlikely(skb->pkt_type =3D=3D PACKET_LOOPBACK))
+		return RX_HANDLER_PASS;
+	skb =3D skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		return RX_HANDLER_CONSUMED;
+	if (unlikely(!is_valid_ether_addr(eth_hdr(skb)->h_source))) {
+		pr_warn_ratelimited("rbr_handle_frame: invalid src address\n");
+		goto drop;
+	}
+	if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb, &vid))
+		goto drop;
+	/* do not handle any BPDU from the moment */
+	if (is_all_rbr_address((const u8 *)&eth_hdr(skb)->h_dest)) {
+		br_fdb_update(br, p, eth_hdr(skb)->h_source, vid, false);
+		/* BPDU has to be dropped */
+		goto drop_no_stat;
+	}
+	/* DROP if port is in disable state */
+	if (p->trill_flag & TRILL_FLAG_DISABLE)
+		goto drop;
+	/* ACCESS port encapsulate packets */
+	if (p->trill_flag & TRILL_FLAG_ACCESS) {
+		/* check if destination is connected on the same bridge */
+		struct net_bridge_fdb_entry *dst;
+
+		dst =3D __br_fdb_get(br, eth_hdr(skb)->h_dest, vid);
+		if (likely(dst)) {
+			if (dst->dst->trill_flag & TRILL_FLAG_ACCESS) {
+				br_deliver(dst->dst, skb);
+				return RX_HANDLER_CONSUMED;
+			}
+		}
+
+		/* if packet is from access port and trill is enabled and dest
+		 * is not an access port or is unknown, encaps it
+		 */
+		/* TODO */
+		return RX_HANDLER_CONSUMED;
+	}
+	if (p->trill_flag & TRILL_FLAG_TRUNK) {
+		/* packet is from trunk port and trill is enabled */
+		if (eth_hdr(skb)->h_proto =3D=3D htons(ETH_P_TRILL)) {
+			/* Packet is from trunk port, decapsulate
+			 * if destined to access port
+			 * or trill forward to next hop
+			 */
+			/* TODO */
+			return RX_HANDLER_CONSUMED;
+		}
+		/* packet is destinated to localhost */
+		if (ether_addr_equal(p->br->dev->dev_addr,
+				     eth_hdr(skb)->h_dest)) {
+			skb->pkt_type =3D PACKET_HOST;
+			NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, NULL, skb,
+				skb->dev, NULL,
+				br_handle_frame_finish);
+			return RX_HANDLER_CONSUMED;
+		}
+
+		/* packet is not from trill  we don't handle
+		 * such packet from the moment
+		 */
+	}
+
+ drop:
+	if (br->dev)
+		br->dev->stats.rx_dropped++;
+ drop_no_stat:
+	kfree_skb(skb);
+	return RX_HANDLER_CONSUMED;
+}
--=20
2.1.4
