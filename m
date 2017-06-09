From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 6/8] qed: No need for LL2 frags indication
Date: Fri, 9 Jun 2017 17:13:23 +0300
Message-ID: <20170609141325.20547-7-Yuval.Mintz@cavium.com>
References: <20170609141325.20547-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0063.outbound.protection.outlook.com ([104.47.34.63]:21149
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751764AbdFIOOP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:14:15 -0400
In-Reply-To: <20170609141325.20547-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a legacy leftover; There's no current flow where 'frags_mapped'
would be set.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 31 ++++++++-----------------------
 1 file changed, 8 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index b222b2b..2a68fb9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -73,7 +73,6 @@ struct qed_cb_ll2_info {
 	int rx_cnt;
 	u32 rx_size;
 	u8 handle;
-	bool frags_mapped;
 
 	/* Lock protecting LL2 buffer lists in sleepless context */
 	spinlock_t lock;
@@ -108,12 +107,6 @@ static void qed_ll2b_complete_tx_packet(void *cxt,
 		cdev->ll2->cbs->tx_cb(cdev->ll2->cb_cookie, skb,
 				      b_last_fragment);
 
-	if (cdev->ll2->frags_mapped)
-		/* Case where mapped frags were received, need to
-		 * free skb with nr_frags marked as 0
-		 */
-		skb_shinfo(skb)->nr_frags = 0;
-
 	dev_kfree_skb_any(skb);
 }
 
@@ -2100,7 +2093,6 @@ static int qed_ll2_start(struct qed_dev *cdev, struct qed_ll2_params *params)
 	spin_lock_init(&cdev->ll2->lock);
 	cdev->ll2->rx_size = NET_SKB_PAD + ETH_HLEN +
 			     L1_CACHE_BYTES + params->mtu;
-	cdev->ll2->frags_mapped = params->frags_mapped;
 
 	/*Allocate memory for LL2 */
 	DP_INFO(cdev, "Allocating LL2 buffers of size %08x bytes\n",
@@ -2313,21 +2305,14 @@ static int qed_ll2_start_xmit(struct qed_dev *cdev, struct sk_buff *skb)
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		frag = &skb_shinfo(skb)->frags[i];
-		if (!cdev->ll2->frags_mapped) {
-			mapping = skb_frag_dma_map(&cdev->pdev->dev, frag, 0,
-						   skb_frag_size(frag),
-						   DMA_TO_DEVICE);
-
-			if (unlikely(dma_mapping_error(&cdev->pdev->dev,
-						       mapping))) {
-				DP_NOTICE(cdev,
-					  "Unable to map frag - dropping packet\n");
-				rc = -ENOMEM;
-				goto err;
-			}
-		} else {
-			mapping = page_to_phys(skb_frag_page(frag)) |
-			    frag->page_offset;
+
+		mapping = skb_frag_dma_map(&cdev->pdev->dev, frag, 0,
+					   skb_frag_size(frag), DMA_TO_DEVICE);
+
+		if (unlikely(dma_mapping_error(&cdev->pdev->dev, mapping))) {
+			DP_NOTICE(cdev,
+				  "Unable to map frag - dropping packet\n");
+			goto err;
 		}
 
 		rc = qed_ll2_set_fragment_of_tx_packet(QED_LEADING_HWFN(cdev),
-- 
2.9.4
