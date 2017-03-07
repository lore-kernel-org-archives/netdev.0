From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 17/22] net: mvpp2: add AXI bridge initialization
 for PPv2.2
Date: Tue,  7 Mar 2017 16:53:15 +0100
Message-ID: <1488902000-2658-18-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Russell King <linux@arm.linux.org.uk>, Jason Cooper <jason@lakedaemon.net>,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
 devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Pawel Moll <pawel.moll@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Kumar Gala <galak@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The PPv2.2 unit is connected to an AXI bus on Armada 7K/8K, so this
commit adds the necessary initialization of the AXI bridge.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 85 ++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index bd7dc4b6..0e10303 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -154,6 +154,34 @@
 #define MVPP2_WIN_REMAP(w)			(0x4040 + ((w) << 2))
 #define MVPP2_BASE_ADDR_ENABLE			0x4060
 
+/* AXI Bridge Registers */
+#define MVPP22_AXI_BM_WR_ATTR_REG		0x4100
+#define MVPP22_AXI_BM_RD_ATTR_REG		0x4104
+#define MVPP22_AXI_AGGRQ_DESCR_RD_ATTR_REG	0x4110
+#define MVPP22_AXI_TXQ_DESCR_WR_ATTR_REG	0x4114
+#define MVPP22_AXI_TXQ_DESCR_RD_ATTR_REG	0x4118
+#define MVPP22_AXI_RXQ_DESCR_WR_ATTR_REG	0x411c
+#define MVPP22_AXI_RX_DATA_WR_ATTR_REG		0x4120
+#define MVPP22_AXI_TX_DATA_RD_ATTR_REG		0x4130
+#define MVPP22_AXI_RD_NORMAL_CODE_REG		0x4150
+#define MVPP22_AXI_RD_SNOOP_CODE_REG		0x4154
+#define MVPP22_AXI_WR_NORMAL_CODE_REG		0x4160
+#define MVPP22_AXI_WR_SNOOP_CODE_REG		0x4164
+
+/* Values for AXI Bridge registers */
+#define MVPP22_AXI_ATTR_CACHE_OFFS		0
+#define MVPP22_AXI_ATTR_DOMAIN_OFFS		12
+
+#define MVPP22_AXI_CODE_CACHE_OFFS		0
+#define MVPP22_AXI_CODE_DOMAIN_OFFS		4
+
+#define MVPP22_AXI_CODE_CACHE_NON_CACHE		0x3
+#define MVPP22_AXI_CODE_CACHE_WR_CACHE		0x7
+#define MVPP22_AXI_CODE_CACHE_RD_CACHE		0xb
+
+#define MVPP22_AXI_CODE_DOMAIN_OUTER_DOM	2
+#define MVPP22_AXI_CODE_DOMAIN_SYSTEM		3
+
 /* Interrupt Cause and Mask registers */
 #define MVPP2_ISR_RX_THRESHOLD_REG(rxq)		(0x5200 + 4 * (rxq))
 #define     MVPP2_MAX_ISR_RX_THRESHOLD		0xfffff0
@@ -6664,6 +6692,60 @@ static void mvpp2_rx_fifo_init(struct mvpp2 *priv)
 	mvpp2_write(priv, MVPP2_RX_FIFO_INIT_REG, 0x1);
 }
 
+static void mvpp2_axi_init(struct mvpp2 *priv)
+{
+	u32 val, rdval, wrval;
+
+	mvpp2_write(priv, MVPP22_BM_ADDR_HIGH_RLS_REG, 0x0);
+
+	/* AXI Bridge Configuration */
+
+	rdval = MVPP22_AXI_CODE_CACHE_RD_CACHE
+		<< MVPP22_AXI_ATTR_CACHE_OFFS;
+	rdval |= MVPP22_AXI_CODE_DOMAIN_OUTER_DOM
+		<< MVPP22_AXI_ATTR_DOMAIN_OFFS;
+
+	wrval = MVPP22_AXI_CODE_CACHE_WR_CACHE
+		<< MVPP22_AXI_ATTR_CACHE_OFFS;
+	wrval |= MVPP22_AXI_CODE_DOMAIN_OUTER_DOM
+		<< MVPP22_AXI_ATTR_DOMAIN_OFFS;
+
+	/* BM */
+	mvpp2_write(priv, MVPP22_AXI_BM_WR_ATTR_REG, wrval);
+	mvpp2_write(priv, MVPP22_AXI_BM_RD_ATTR_REG, rdval);
+
+	/* Descriptors */
+	mvpp2_write(priv, MVPP22_AXI_AGGRQ_DESCR_RD_ATTR_REG, rdval);
+	mvpp2_write(priv, MVPP22_AXI_TXQ_DESCR_WR_ATTR_REG, wrval);
+	mvpp2_write(priv, MVPP22_AXI_TXQ_DESCR_RD_ATTR_REG, rdval);
+	mvpp2_write(priv, MVPP22_AXI_RXQ_DESCR_WR_ATTR_REG, wrval);
+
+	/* Buffer Data */
+	mvpp2_write(priv, MVPP22_AXI_TX_DATA_RD_ATTR_REG, rdval);
+	mvpp2_write(priv, MVPP22_AXI_RX_DATA_WR_ATTR_REG, wrval);
+
+	val = MVPP22_AXI_CODE_CACHE_NON_CACHE
+		<< MVPP22_AXI_CODE_CACHE_OFFS;
+	val |= MVPP22_AXI_CODE_DOMAIN_SYSTEM
+		<< MVPP22_AXI_CODE_DOMAIN_OFFS;
+	mvpp2_write(priv, MVPP22_AXI_RD_NORMAL_CODE_REG, val);
+	mvpp2_write(priv, MVPP22_AXI_WR_NORMAL_CODE_REG, val);
+
+	val = MVPP22_AXI_CODE_CACHE_RD_CACHE
+		<< MVPP22_AXI_CODE_CACHE_OFFS;
+	val |= MVPP22_AXI_CODE_DOMAIN_OUTER_DOM
+		<< MVPP22_AXI_CODE_DOMAIN_OFFS;
+
+	mvpp2_write(priv, MVPP22_AXI_RD_SNOOP_CODE_REG, val);
+
+	val = MVPP22_AXI_CODE_CACHE_WR_CACHE
+		<< MVPP22_AXI_CODE_CACHE_OFFS;
+	val |= MVPP22_AXI_CODE_DOMAIN_OUTER_DOM
+		<< MVPP22_AXI_CODE_DOMAIN_OFFS;
+
+	mvpp2_write(priv, MVPP22_AXI_WR_SNOOP_CODE_REG, val);
+}
+
 /* Initialize network controller common part HW */
 static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 {
@@ -6683,6 +6765,9 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	if (dram_target_info)
 		mvpp2_conf_mbus_windows(dram_target_info, priv);
 
+	if (priv->hw_version == MVPP22)
+		mvpp2_axi_init(priv);
+
 	/* Disable HW PHY polling */
 	if (priv->hw_version == MVPP21) {
 		val = readl(priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
-- 
2.7.4
