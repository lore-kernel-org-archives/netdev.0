From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 15/24] net: rbridge: Add basic trill frame handling function
Date: Wed, 24 Sep 2014 17:52:11 +0200
Message-ID: <1411573940-14079-16-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:60457 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbaIXQDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:12 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
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
 net/bridge/rbridge/rbr.c | 100 +++++++++++++++++++++++++++++++++++++++=
++++++++
 1 file changed, 100 insertions(+)

diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
index edd1e7c..4b41d4c 100644
--- a/net/bridge/rbridge/rbr.c
+++ b/net/bridge/rbridge/rbr.c
@@ -129,3 +129,103 @@ static void rbr_del_all(struct rbr *rbr)
 			rbr_del_node(rbr, i);
 	}
 }
+
+/* handling function hook allow handling
+ * a frame upon reception called via
+ * br_handle_frame_hook =3D rbr_handle_frame
+ * in  br.c
+ * Return NULL if skb is handled
+ * note: already called with rcu_read_lock (preempt_disabled)
+ */
+rx_handler_result_t rbr_handle_frame(struct sk_buff **pskb)
+{
+	struct net_bridge *br;
+	struct net_bridge_port *p;
+	struct sk_buff *skb =3D *pskb;
+	u16 vid =3D 0;
+
+	p =3D br_port_get_rcu(skb->dev);
+	if (unlikely(!p))
+		goto drop_no_stat;
+	br =3D p->br;
+
+	/* if trill is not enabled, handle by bridge */
+	if (br->trill_enabled =3D=3D BR_NO_TRILL) {
+		goto handle_by_bridge;
+	} else {
+		if (unlikely(skb->pkt_type =3D=3D PACKET_LOOPBACK))
+			return RX_HANDLER_PASS;
+		skb =3D skb_share_check(skb, GFP_ATOMIC);
+		if (!skb)
+			return RX_HANDLER_CONSUMED;
+		if (unlikely(!is_valid_ether_addr(eth_hdr(skb)->h_source))) {
+			pr_warn_ratelimited
+			    ("rbr_handle_frame:invalid src address\n");
+			goto drop;
+		}
+		if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb, &vid))
+			goto drop;
+		/* do not handle any BPDU from the moment */
+		if (is_all_rbr_address((const u8 *)&eth_hdr(skb)->h_dest)) {
+			br_fdb_update(br, p, eth_hdr(skb)->h_source, vid, false);
+			/* BPDU has to be dropped */
+			goto drop_no_stat;
+		}
+		/* DROP if port is in disable state */
+		if (p->trill_flag & TRILL_FLAG_DISABLE)
+			goto drop;
+
+		/* ACCESS port encapsulate packets */
+		if (p->trill_flag & TRILL_FLAG_ACCESS) {
+			/* check if destination is connected on the same bridge */
+			struct net_bridge_fdb_entry *dst;
+			dst =3D __br_fdb_get(br, eth_hdr(skb)->h_dest, vid);
+			if (likely(dst)) {
+				if (dst->dst->trill_flag & TRILL_FLAG_ACCESS) {
+					br_deliver(dst->dst, skb);
+					return RX_HANDLER_CONSUMED;
+				}
+			}
+			/* if packet is from access port and trill is enabled and dest
+			 * is not an access port or is unknown, encaps it
+			 */
+			/* TODO */
+			return RX_HANDLER_CONSUMED;
+		}
+		if (p->trill_flag & TRILL_FLAG_TRUNK) {
+			/* packet is from trunk port and trill is enabled */
+			if (eth_hdr(skb)->h_proto =3D=3D
+			    __constant_htons(ETH_P_TRILL)) {
+				/*
+				 * Packet is from trunk port, decapsulate if destined to access po=
rt
+				 * or trill forward to next hop
+				 */
+				/* TODO */
+				return RX_HANDLER_CONSUMED;
+			} else {
+				/* packet is destinated to localhost */
+				if (ether_addr_equal(p->br->dev->dev_addr,
+							eth_hdr(skb)->h_dest)) {
+					skb->pkt_type =3D PACKET_HOST;
+					br_handle_frame_finish(skb);
+					return RX_HANDLER_CONSUMED;
+				}
+				/*
+				 * packet is not from trill  we don't handle
+				 * such packet from the moment
+				 */
+
+			}
+		}
+	}
+
+ drop:
+	if (br->dev)
+		br->dev->stats.rx_dropped++;
+ drop_no_stat:
+	kfree_skb(skb);
+	return RX_HANDLER_CONSUMED;
+ handle_by_bridge:
+	/* trill is not enable return to bridge handle function */
+	return br_handle_frame(pskb);
+}
--=20
1.9.1
