From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/6) bridge: prevent bad forwarding table updates
Date: Thu, 26 May 2005 11:04:18 -0700
Message-ID: <20050526110418.418b9eef@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============77949807219883316=="
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: "David S. Miller" <davem@davemloft.net>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============77949807219883316==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Avoid poisoning of the bridge forwarding table by frames that have been
dropped by filtering. This prevents spoofed source addresses on hostile
side of bridge from causing packet leakage, a small but possible security
risk.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: bridge/net/bridge/br_input.c
===================================================================
--- bridge.orig/net/bridge/br_input.c
+++ bridge/net/bridge/br_input.c
@@ -54,6 +54,9 @@ int br_handle_frame_finish(struct sk_buf
 	struct net_bridge_fdb_entry *dst;
 	int passedup = 0;
 
+	/* insert into forwarding database after filtering to avoid spoofing */
+	br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
+
 	if (br->dev->flags & IFF_PROMISC) {
 		struct sk_buff *skb2;
 
@@ -108,8 +111,7 @@ int br_handle_frame(struct net_bridge_po
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto err;
 
-	if (p->state == BR_STATE_LEARNING ||
-	    p->state == BR_STATE_FORWARDING)
+	if (p->state == BR_STATE_LEARNING)
 		br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
 
 	if (p->br->stp_enabled &&
Index: bridge/net/bridge/br_stp_bpdu.c
===================================================================
--- bridge.orig/net/bridge/br_stp_bpdu.c
+++ bridge/net/bridge/br_stp_bpdu.c
@@ -140,6 +140,9 @@ int br_stp_handle_bpdu(struct sk_buff *s
 	struct net_bridge *br = p->br;
 	unsigned char *buf;
 
+	/* insert into forwarding database after filtering to avoid spoofing */
+	br_fdb_update(p->br, p, eth_hdr(skb)->h_source);
+
 	/* need at least the 802 and STP headers */
 	if (!pskb_may_pull(skb, sizeof(header)+1) ||
 	    memcmp(skb->data, header, sizeof(header)))

--===============77949807219883316==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============77949807219883316==--
