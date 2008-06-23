From: Stefan Roese <sr@denx.de>
Subject: [PATCH] ibm_newemac: Fixes memory leak in ibm_newemac ethernet driver
Date: Mon, 23 Jun 2008 14:55:12 +0200
Message-ID: <1214225712-25882-1-git-send-email-sr@denx.de>
Cc: benh@kernel.crashing.org, Sathya Narayanan <sathyan@teamf1.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49677 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbYFWMzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 08:55:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Narayanan <sathyan@teamf1.com>

This patch addresses the memory leak happenning in drivers transmit queue
under heavy load condition. Once the transmit queue becomes full, driver
does an automatic wrapup of queue. During which the untransmitted SKB's are
lost without getting freed up.

Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/core.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index aa407b2..ee868b6 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1328,6 +1328,13 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	DBG2(dev, "xmit(%u) %d" NL, len, slot);
 
+	if (dev->tx_skb[slot] && dev->tx_desc[slot].data_ptr) {
+		dev_kfree_skb(dev->tx_skb[slot]);
+		dev->tx_skb[slot] = NULL;
+		dev->tx_cnt--;
+		++dev->estats.tx_dropped;
+	}
+
 	dev->tx_skb[slot] = skb;
 	dev->tx_desc[slot].data_ptr = dma_map_single(&dev->ofdev->dev,
 						     skb->data, len,
-- 
1.5.6

