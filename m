From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: systemport: Implement RX coalescing control knobs
Date: Mon, 11 May 2015 15:12:42 -0700
Message-ID: <1431382362-22332-3-git-send-email-f.fainelli@gmail.com>
References: <1431382362-22332-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34354 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbbEKWOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:14:36 -0400
Received: by pacyx8 with SMTP id yx8so120279206pac.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:14:36 -0700 (PDT)
In-Reply-To: <1431382362-22332-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to the TX path, allow the RX path to be configured with both
'rx-frames' and 'rx-usecs' coalescing parameters.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 27 +++++++++++++++++++++------
 drivers/net/ethernet/broadcom/bcmsysport.h |  2 +-
 2 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 29d5750a5738..084a50a555de 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -467,6 +467,11 @@ static int bcm_sysport_get_coalesce(struct net_device *dev,
 	ec->tx_coalesce_usecs = (reg >> RING_TIMEOUT_SHIFT) * 8192 / 1000;
 	ec->tx_max_coalesced_frames = reg & RING_INTR_THRESH_MASK;
 
+	reg = rdma_readl(priv, RDMA_MBDONE_INTR);
+
+	ec->rx_coalesce_usecs = (reg >> RDMA_TIMEOUT_SHIFT) * 8192 / 1000;
+	ec->rx_max_coalesced_frames = reg & RDMA_INTR_THRESH_MASK;
+
 	return 0;
 }
 
@@ -477,16 +482,18 @@ static int bcm_sysport_set_coalesce(struct net_device *dev,
 	unsigned int i;
 	u32 reg;
 
-	/* Base system clock is 125Mhz, TDMA timeout is this reference clock
-	 * divided by 1024, which yield roughly 8.192 us, our maximum value
-	 * has to fit in the RING_TIMEOUT_MASK (16 bits).
+	/* Base system clock is 125Mhz, DMA timeout is this reference clock
+	 * divided by 1024, which yield roughly 8.192 us, our maximum value has
+	 * to fit in the RING_TIMEOUT_MASK (16 bits).
 	 */
 	if (ec->tx_max_coalesced_frames > RING_INTR_THRESH_MASK ||
-	    ec->tx_coalesce_usecs > (RING_TIMEOUT_MASK * 8) + 1)
+	    ec->tx_coalesce_usecs > (RING_TIMEOUT_MASK * 8) + 1 ||
+	    ec->rx_max_coalesced_frames > RDMA_INTR_THRESH_MASK ||
+	    ec->rx_coalesce_usecs > (RDMA_TIMEOUT_MASK * 8) + 1)
 		return -EINVAL;
 
-	if (ec->tx_coalesce_usecs == 0 &&
-	    ec->tx_max_coalesced_frames == 0)
+	if ((ec->tx_coalesce_usecs == 0 && ec->tx_max_coalesced_frames == 0) ||
+	    (ec->rx_coalesce_usecs == 0 && ec->rx_max_coalesced_frames == 0))
 		return -EINVAL;
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
@@ -499,6 +506,14 @@ static int bcm_sysport_set_coalesce(struct net_device *dev,
 		tdma_writel(priv, reg, TDMA_DESC_RING_INTR_CONTROL(i));
 	}
 
+	reg = rdma_readl(priv, RDMA_MBDONE_INTR);
+	reg &= ~(RDMA_INTR_THRESH_MASK |
+		 RDMA_TIMEOUT_MASK << RDMA_TIMEOUT_SHIFT);
+	reg |= ec->rx_max_coalesced_frames;
+	reg |= DIV_ROUND_UP(ec->rx_coalesce_usecs * 1000, 8192) <<
+			    RDMA_TIMEOUT_SHIFT;
+	rdma_writel(priv, reg, RDMA_MBDONE_INTR);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index e2c043eabbf3..42a4b4a0bc14 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -292,7 +292,7 @@ struct bcm_rsb {
 #define RDMA_END_ADDR_LO		0x102c
 
 #define RDMA_MBDONE_INTR		0x1030
-#define  RDMA_INTR_THRESH_MASK		0xff
+#define  RDMA_INTR_THRESH_MASK		0x1ff
 #define  RDMA_TIMEOUT_SHIFT		16
 #define  RDMA_TIMEOUT_MASK		0xffff
 
-- 
2.1.0
