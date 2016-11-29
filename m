From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v3 net-next 3/6] net: mvneta: Convert to be 64 bits compatible
Date: Tue, 29 Nov 2016 10:37:23 +0100
Message-ID: <de4cb6627b56e4433bd732b17e58558206510d97.1480412215.git-series.gregory.clement@free-electrons.com>
References: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Dmitri Epshtein <dima@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Yelena Krivosheev <yelena@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
References: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
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

From: Marcin Wojtas <mw@semihalf.com>

Prepare the mvneta driver in order to be usable on the 64 bits platform
such as the Armada 3700.

[gregory.clement@free-electrons.com]: this patch was extract from a larger
one to ease review and maintenance.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 32b142d0e44e..a8bd0d83028f 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -296,6 +296,12 @@
 /* descriptor aligned size */
 #define MVNETA_DESC_ALIGNED_SIZE	32
 
+/* Number of bytes to be taken into account by HW when putting incoming data
+ * to the buffers. It is needed in case NET_SKB_PAD exceeds maximum packet
+ * offset supported in MVNETA_RXQ_CONFIG_REG(q) registers.
+ */
+#define MVNETA_RX_PKT_OFFSET_CORRECTION		64
+
 #define MVNETA_RX_PKT_SIZE(mtu) \
 	ALIGN((mtu) + MVNETA_MH_SIZE + MVNETA_VLAN_TAG_LEN + \
 	      ETH_HLEN + ETH_FCS_LEN,			     \
@@ -416,6 +422,7 @@ struct mvneta_port {
 	u64 ethtool_stats[ARRAY_SIZE(mvneta_statistics)];
 
 	u32 indir[MVNETA_RSS_LU_TABLE_SIZE];
+	u16 rx_offset_correction;
 };
 
 /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
@@ -1807,6 +1814,7 @@ static int mvneta_rx_refill(struct mvneta_port *pp,
 		return -ENOMEM;
 	}
 
+	phys_addr += pp->rx_offset_correction;
 	mvneta_rx_desc_fill(rx_desc, phys_addr, data, rxq);
 	return 0;
 }
@@ -2742,6 +2750,7 @@ static int mvneta_rx_hwbm_refill(struct mvneta_port *pp,
 		return -ENOMEM;
 	}
 
+	phys_addr += pp->rx_offset_correction;
 	rx_desc->buf_phys_addr = phys_addr;
 	rx_desc->buf_cookie = (uintptr_t)data;
 
@@ -2837,7 +2846,7 @@ static int mvneta_rxq_init(struct mvneta_port *pp,
 	mvreg_write(pp, MVNETA_RXQ_SIZE_REG(rxq->id), rxq->size);
 
 	/* Set Offset */
-	mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD);
+	mvneta_rxq_offset_set(pp, rxq, NET_SKB_PAD - pp->rx_offset_correction);
 
 	/* Set coalescing pkts and time */
 	mvneta_rx_pkts_coal_set(pp, rxq, rxq->pkts_coal);
@@ -4088,6 +4097,13 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	pp->rxq_def = rxq_def;
 
+	/* Set RX packet offset correction for platforms, whose
+	 * NET_SKB_PAD, exceeds 64B. It should be 64B for 64-bit
+	 * platforms and 0B for 32-bit ones.
+	 */
+	pp->rx_offset_correction =
+		max(0, NET_SKB_PAD - MVNETA_RX_PKT_OFFSET_CORRECTION);
+
 	pp->indir[0] = rxq_def;
 
 	pp->clk = devm_clk_get(&pdev->dev, "core");
-- 
git-series 0.8.10
