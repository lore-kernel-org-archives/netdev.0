From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v3 07/10] net/macb: ethtool interface: add register dump feature
Date: Tue, 30 Oct 2012 11:17:59 +0100
Message-ID: <b8611016a21ddc980a6413390c7d54a0b712d93e.1351591858.git.nicolas.ferre@atmel.com>
References: <cover.1351591858.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>,
	<linux-arm-kernel@lists.infradead.org>, <plagnioj@jcrosoft.com>,
	<patrice.vilchez@atmel.com>, <linux-kernel@vger.kernel.org>,
	<manabian@gmail.com>, Nicolas Ferre <nicolas.ferre@atmel.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<havard@skinnemoen.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1351591858.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add macb_get_regs() ethtool function and its helper function:
macb_get_regs_len().
The version field is deduced from the IP revision which gives the
"MACB or GEM" information. An additional version field is reserved.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/cadence/macb.c | 40 +++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/cadence/macb.h |  3 +++
 2 files changed, 43 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index dc03b36..ce29741 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1273,9 +1273,49 @@ static int macb_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return phy_ethtool_sset(phydev, cmd);
 }
 
+static int macb_get_regs_len(struct net_device *netdev)
+{
+	return MACB_GREGS_NBR * sizeof(u32);
+}
+
+static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+			  void *p)
+{
+	struct macb *bp = netdev_priv(dev);
+	unsigned int tail, head;
+	u32 *regs_buff = p;
+
+	regs->version = (macb_readl(bp, MID) & ((1 << MACB_REV_SIZE) - 1))
+			| MACB_GREGS_VERSION;
+
+	tail = macb_tx_ring_wrap(bp->tx_tail);
+	head = macb_tx_ring_wrap(bp->tx_head);
+
+	regs_buff[0]  = macb_readl(bp, NCR);
+	regs_buff[1]  = macb_or_gem_readl(bp, NCFGR);
+	regs_buff[2]  = macb_readl(bp, NSR);
+	regs_buff[3]  = macb_readl(bp, TSR);
+	regs_buff[4]  = macb_readl(bp, RBQP);
+	regs_buff[5]  = macb_readl(bp, TBQP);
+	regs_buff[6]  = macb_readl(bp, RSR);
+	regs_buff[7]  = macb_readl(bp, IMR);
+
+	regs_buff[8]  = tail;
+	regs_buff[9]  = head;
+	regs_buff[10] = macb_tx_dma(bp, tail);
+	regs_buff[11] = macb_tx_dma(bp, head);
+
+	if (macb_is_gem(bp)) {
+		regs_buff[12] = gem_readl(bp, USRIO);
+		regs_buff[13] = gem_readl(bp, DMACFG);
+	}
+}
+
 const struct ethtool_ops macb_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
+	.get_regs_len		= macb_get_regs_len,
+	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
 };
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 024a270..232dca6 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -10,6 +10,9 @@
 #ifndef _MACB_H
 #define _MACB_H
 
+#define MACB_GREGS_NBR 16
+#define MACB_GREGS_VERSION 1
+
 /* MACB register offsets */
 #define MACB_NCR				0x0000
 #define MACB_NCFGR				0x0004
-- 
1.8.0
