From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] jme: Fix unmap loop counting error:
Date: Mon, 12 May 2014 10:38:18 -0400
Message-ID: <1399905498-27691-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39915 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758678AbaELOie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 10:38:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In my recent fix (76a691d0a: fix dma unmap warning), Ben Hutchings noted that my
loop count was incorrect.  Where j started at startidx, it should have started
at zero, and gone on for count entries, not to endidx.  Additionally, a DMA
resource exhaustion should drop the frame and (for now), return
NETDEV_TX_OK, not NETEV_TX_BUSY.  This patch fixes both of those issues:

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Ben Hutchings <ben@decadent.org.uk>
CC: "David S. Miller" <davem@davemloft.net>
CC: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/ethernet/jme.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 6e664d9..b78378c 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2027,14 +2027,14 @@ jme_fill_tx_map(struct pci_dev *pdev,
 	return 0;
 }
 
-static void jme_drop_tx_map(struct jme_adapter *jme, int startidx, int endidx)
+static void jme_drop_tx_map(struct jme_adapter *jme, int startidx, int count)
 {
 	struct jme_ring *txring = &(jme->txring[0]);
 	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
 	int mask = jme->tx_ring_mask;
 	int j;
 
-	for (j = startidx ; j < endidx ; ++j) {
+	for (j = 0 ; j < count ; j++) {
 		ctxbi = txbi + ((startidx + j + 2) & (mask));
 		pci_unmap_page(jme->pdev,
 				ctxbi->mapping,
@@ -2069,7 +2069,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 				skb_frag_page(frag),
 				frag->page_offset, skb_frag_size(frag), hidma);
 		if (ret) {
-			jme_drop_tx_map(jme, idx, idx+i);
+			jme_drop_tx_map(jme, idx, i);
 			goto out;
 		}
 
@@ -2081,7 +2081,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	ret = jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi, virt_to_page(skb->data),
 			offset_in_page(skb->data), len, hidma);
 	if (ret)
-		jme_drop_tx_map(jme, idx, idx+i);
+		jme_drop_tx_map(jme, idx, i);
 
 out:
 	return ret;
@@ -2269,7 +2269,7 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (jme_fill_tx_desc(jme, skb, idx))
-		return NETDEV_TX_BUSY;
+		return NETDEV_TX_OK;
 
 	jwrite32(jme, JME_TXCS, jme->reg_txcs |
 				TXCS_SELECT_QUEUE0 |
-- 
1.8.3.1
