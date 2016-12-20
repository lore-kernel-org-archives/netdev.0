From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 07/10] net: netcp: use hw capability to remove FCS word from rx packets
Date: Tue, 20 Dec 2016 17:09:50 -0500
Message-ID: <1482271793-7671-8-git-send-email-m-karicheri2@ti.com>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <grygorii.strashko@ti.com>, <mugunthanvnm@ti.com>,
        <linux-kernel@vger.kernel.org>, <arnd@arndb.de>,
        <davem@davemloft.net>, <devicetree@vger.kernel.org>,
        <mark.rutland@arm.com>, <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some of the newer Ethernet switch hw (such as that on k2e/l/g) can
strip the Etherenet FCS from packet at the port 0 egress of the switch.
So use this capability instead of doing it in software.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/netcp.h       |  2 ++
 drivers/net/ethernet/ti/netcp_core.c  |  8 ++++++--
 drivers/net/ethernet/ti/netcp_ethss.c | 10 ++++++++--
 3 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp.h b/drivers/net/ethernet/ti/netcp.h
index d243c5d..8900a6f 100644
--- a/drivers/net/ethernet/ti/netcp.h
+++ b/drivers/net/ethernet/ti/netcp.h
@@ -102,6 +102,8 @@ struct netcp_intf {
 	void			*rx_fdq[KNAV_DMA_FDQ_PER_CHAN];
 	struct napi_struct	rx_napi;
 	struct napi_struct	tx_napi;
+#define ETH_SW_CAN_REMOVE_ETH_FCS	BIT(0)
+	u32			hw_cap;
 
 	/* 64-bit netcp stats */
 	struct netcp_stats	stats;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index b077ed4..68a75cc 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -739,8 +739,12 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		dev_dbg(netcp->ndev_dev, "mismatch in packet size(%d) & sum of fragments(%d)\n",
 			pkt_sz, accum_sz);
 
-	/* Remove ethernet FCS from the packet */
-	__pskb_trim(skb, skb->len - ETH_FCS_LEN);
+	/* Newer version of the Ethernet switch can trim the Ethernet FCS
+	 * from the packet and is indicated in hw_cap. So trim it only for
+	 * older h/w
+	 */
+	if (!(netcp->hw_cap & ETH_SW_CAN_REMOVE_ETH_FCS))
+		__pskb_trim(skb, skb->len - ETH_FCS_LEN);
 
 	/* Call each of the RX hooks */
 	p_info.skb = skb;
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 9266961..4b2a911 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -133,6 +133,7 @@
 #define MACSL_FULLDUPLEX			BIT(0)
 
 #define GBE_CTL_P0_ENABLE			BIT(2)
+#define ETH_SW_CTL_P0_TX_CRC_REMOVE		BIT(13)
 #define GBE13_REG_VAL_STAT_ENABLE_ALL		0xff
 #define XGBE_REG_VAL_STAT_ENABLE_ALL		0xf
 #define GBE_STATS_CD_SEL			BIT(28)
@@ -2847,7 +2848,7 @@ static int gbe_open(void *intf_priv, struct net_device *ndev)
 	struct netcp_intf *netcp = netdev_priv(ndev);
 	struct gbe_slave *slave = gbe_intf->slave;
 	int port_num = slave->port_num;
-	u32 reg;
+	u32 reg, val;
 	int ret;
 
 	reg = readl(GBE_REG_ADDR(gbe_dev, switch_regs, id_ver));
@@ -2877,7 +2878,12 @@ static int gbe_open(void *intf_priv, struct net_device *ndev)
 	writel(0, GBE_REG_ADDR(gbe_dev, switch_regs, ptype));
 
 	/* Control register */
-	writel(GBE_CTL_P0_ENABLE, GBE_REG_ADDR(gbe_dev, switch_regs, control));
+	val = GBE_CTL_P0_ENABLE;
+	if (IS_SS_ID_MU(gbe_dev)) {
+		val |= ETH_SW_CTL_P0_TX_CRC_REMOVE;
+		netcp->hw_cap = ETH_SW_CAN_REMOVE_ETH_FCS;
+	}
+	writel(val, GBE_REG_ADDR(gbe_dev, switch_regs, control));
 
 	/* All statistics enabled and STAT AB visible by default */
 	writel(gbe_dev->stats_en_mask, GBE_REG_ADDR(gbe_dev, switch_regs,
-- 
1.9.1
