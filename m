From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next] sunvnet: don't change gso data on clones
Date: Wed, 11 Feb 2015 08:20:17 -0500
Message-ID: <54DB5711.3040705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42421 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbbBKNUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 08:20:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch unclones an skb for the case where the sunvnet driver needs to
change the segmentation size so that it doesn't interfere with TCP SACK's
use of them.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 2b10b85..22e0cad 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1192,23 +1192,16 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
 	skb_pull(skb, maclen);
 
 	if (port->tso && gso_size < datalen) {
+		if (skb_unclone(skb, GFP_ATOMIC))
+			goto out_dropped;
+
 		/* segment to TSO size */
 		skb_shinfo(skb)->gso_size = datalen;
 		skb_shinfo(skb)->gso_segs = gso_segs;
-
-		segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
-
-		/* restore gso_size & gso_segs */
-		skb_shinfo(skb)->gso_size = gso_size;
-		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len - hlen,
-							 gso_size);
-	} else
-		segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
-	if (IS_ERR(segs)) {
-		dev->stats.tx_dropped++;
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
 	}
+	segs = skb_gso_segment(skb, dev->features & ~NETIF_F_TSO);
+	if (IS_ERR(segs))
+		goto out_dropped;
 
 	skb_push(skb, maclen);
 	skb_reset_mac_header(skb);
@@ -1246,6 +1239,10 @@ static int vnet_handle_offloads(struct vnet_port *port, struct sk_buff *skb)
 	if (!(status & NETDEV_TX_MASK))
 		dev_kfree_skb_any(skb);
 	return status;
+out_dropped:
+	dev->stats.tx_dropped++;
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
 }
 
 static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
1.7.1
