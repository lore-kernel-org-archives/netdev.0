From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 2/2] net: calxedaxgmac: Wake-on-LAN fixes
Date: Thu, 28 Mar 2013 16:32:45 -0500
Message-ID: <1364506365-13689-2-git-send-email-robherring2@gmail.com>
References: <1364506365-13689-1-git-send-email-robherring2@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364506365-13689-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

WOL is broken because the magic packet status bit is getting set rather
than the enable bit. The PMT interrupt is not getting serviced because
the PMT interrupt is also enabled on the global interrupt, but not
cleared by the global interrupt and the global interrupt is higher
priority. This fixes both of these issues to get WOL working.

There's still a problem with receive after resume, but at least now we
can wake-up.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index bb1e80b..b0ebc9f 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -163,6 +163,7 @@
 #define XGMAC_FLOW_CTRL_FCB_BPA	0x00000001	/* Flow Control Busy ... */
 
 /* XGMAC_INT_STAT reg */
+#define XGMAC_INT_STAT_PMTIM	0x00800000	/* PMT Interrupt Mask */
 #define XGMAC_INT_STAT_PMT	0x0080		/* PMT Interrupt Status */
 #define XGMAC_INT_STAT_LPI	0x0040		/* LPI Interrupt Status */
 
@@ -960,6 +961,9 @@ static int xgmac_hw_init(struct net_device *dev)
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_STATUS);
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + XGMAC_DMA_INTR_ENA);
 
+	/* Mask power mgt interrupt */
+	writel(XGMAC_INT_STAT_PMTIM, ioaddr + XGMAC_INT_STAT);
+
 	/* XGMAC requires AXI bus init. This is a 'magic number' for now */
 	writel(0x0077000E, ioaddr + XGMAC_DMA_AXI_BUS);
 
@@ -1828,7 +1832,7 @@ static void xgmac_pmt(void __iomem *ioaddr, unsigned long mode)
 	unsigned int pmt = 0;
 
 	if (mode & WAKE_MAGIC)
-		pmt |= XGMAC_PMT_POWERDOWN | XGMAC_PMT_MAGIC_PKT;
+		pmt |= XGMAC_PMT_POWERDOWN | XGMAC_PMT_MAGIC_PKT_EN;
 	if (mode & WAKE_UCAST)
 		pmt |= XGMAC_PMT_POWERDOWN | XGMAC_PMT_GLBL_UNICAST;
 
-- 
1.7.10.4
