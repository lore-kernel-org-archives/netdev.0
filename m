From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: [PATCH 1/4] batman: don't bother flipping ->tt_data
Date: Wed, 18 Apr 2012 19:09:47 +0100
Message-ID: <20120418180947.GC6589@ZenIV.linux.org.uk>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
	<20120418180837.GB6589@ZenIV.linux.org.uk>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120418180837.GB6589-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
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

just keep it net-endian all along

Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
---
 net/batman-adv/packet.h            |    2 +-
 net/batman-adv/routing.c           |    6 +-----
 net/batman-adv/translation-table.c |    8 ++++----
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 307dbb3..9157f7c 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -220,7 +220,7 @@ struct tt_query_packet {
 	 * if TT_REQUEST: crc associated with the
 	 *		  ttvn
 	 * if TT_RESPONSE: table_size */
-	uint16_t tt_data;
+	__be16   tt_data;
 } __packed;
 
 struct roam_adv_packet {
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 2181a91..4310cfe 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -596,8 +596,6 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	tt_query = (struct tt_query_packet *)skb->data;
 
-	tt_query->tt_data = ntohs(tt_query->tt_data);
-
 	switch (tt_query->flags & TT_QUERY_TYPE_MASK) {
 	case TT_REQUEST:
 		/* If we cannot provide an answer the tt_request is
@@ -607,7 +605,6 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 				"Routing TT_REQUEST to %pM [%c]\n",
 				tt_query->dst,
 				(tt_query->flags & TT_FULL_TABLE ? 'F' : '.'));
-			tt_query->tt_data = htons(tt_query->tt_data);
 			return route_unicast_packet(skb, recv_if);
 		}
 		break;
@@ -618,7 +615,7 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 			if (skb_linearize(skb) < 0)
 				goto out;
 
-			tt_len = tt_query->tt_data * sizeof(struct tt_change);
+			tt_len = ntohs(tt_query->tt_data) * sizeof(struct tt_change);
 
 			/* Ensure we have all the claimed data */
 			if (unlikely(skb_headlen(skb) <
@@ -631,7 +628,6 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 				"Routing TT_RESPONSE to %pM [%c]\n",
 				tt_query->dst,
 				(tt_query->flags & TT_FULL_TABLE ? 'F' : '.'));
-			tt_query->tt_data = htons(tt_query->tt_data);
 			return route_unicast_packet(skb, recv_if);
 		}
 		break;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 88e4c8e..a9c2b59 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1416,7 +1416,7 @@ static bool send_other_tt_response(struct bat_priv *bat_priv,
 
 	/* I don't have the requested data */
 	if (orig_ttvn != req_ttvn ||
-	    tt_request->tt_data != req_dst_orig_node->tt_crc)
+	    tt_request->tt_data != htons(req_dst_orig_node->tt_crc))
 		goto out;
 
 	/* If the full table has been explicitly requested */
@@ -1672,7 +1672,7 @@ static void tt_fill_gtable(struct bat_priv *bat_priv,
 
 	_tt_update_changes(bat_priv, orig_node,
 			   (struct tt_change *)(tt_response + 1),
-			   tt_response->tt_data, tt_response->ttvn);
+			   ntohs(tt_response->tt_data), tt_response->ttvn);
 
 	spin_lock_bh(&orig_node->tt_buff_lock);
 	kfree(orig_node->tt_buff);
@@ -1727,7 +1727,7 @@ void handle_tt_response(struct bat_priv *bat_priv,
 
 	bat_dbg(DBG_TT, bat_priv,
 		"Received TT_RESPONSE from %pM for ttvn %d t_size: %d [%c]\n",
-		tt_response->src, tt_response->ttvn, tt_response->tt_data,
+		tt_response->src, tt_response->ttvn, ntohs(tt_response->tt_data),
 		(tt_response->flags & TT_FULL_TABLE ? 'F' : '.'));
 
 	/* we should have never asked a backbone gw */
@@ -1741,7 +1741,7 @@ void handle_tt_response(struct bat_priv *bat_priv,
 	if (tt_response->flags & TT_FULL_TABLE)
 		tt_fill_gtable(bat_priv, tt_response);
 	else
-		tt_update_changes(bat_priv, orig_node, tt_response->tt_data,
+		tt_update_changes(bat_priv, orig_node, ntohs(tt_response->tt_data),
 				  tt_response->ttvn,
 				  (struct tt_change *)(tt_response + 1));
 
-- 
1.7.2.5
