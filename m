From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/19] br_netfilter: Convert to dst_neigh_lookup_skb().
Date: Tue, 03 Jul 2012 02:46:38 -0700 (PDT)
Message-ID: <20120703.024638.1364450951305249827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab2GCJqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:39 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 27BFA584120
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bridge/br_netfilter.c |   36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4378775..b98d3d7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -375,19 +375,29 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 	if (!skb->dev)
 		goto free_skb;
 	dst = skb_dst(skb);
-	neigh = dst_get_neighbour_noref(dst);
-	if (neigh->hh.hh_len) {
-		neigh_hh_bridge(&neigh->hh, skb);
-		skb->dev = nf_bridge->physindev;
-		return br_handle_frame_finish(skb);
-	} else {
-		/* the neighbour function below overwrites the complete
-		 * MAC header, so we save the Ethernet source address and
-		 * protocol number. */
-		skb_copy_from_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN), skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
-		/* tell br_dev_xmit to continue with forwarding */
-		nf_bridge->mask |= BRNF_BRIDGED_DNAT;
-		return neigh->output(neigh, skb);
+	neigh = dst_neigh_lookup_skb(dst, skb);
+	if (neigh) {
+		int ret;
+
+		if (neigh->hh.hh_len) {
+			neigh_hh_bridge(&neigh->hh, skb);
+			skb->dev = nf_bridge->physindev;
+			ret = br_handle_frame_finish(skb);
+		} else {
+			/* the neighbour function below overwrites the complete
+			 * MAC header, so we save the Ethernet source address and
+			 * protocol number.
+			 */
+			skb_copy_from_linear_data_offset(skb,
+							 -(ETH_HLEN-ETH_ALEN),
+							 skb->nf_bridge->data,
+							 ETH_HLEN-ETH_ALEN);
+			/* tell br_dev_xmit to continue with forwarding */
+			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
+			ret = neigh->output(neigh, skb);
+		}
+		neigh_release(neigh);
+		return ret;
 	}
 free_skb:
 	kfree_skb(skb);
-- 
1.7.10
