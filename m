From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 1/6] net: mvpp2: set the Rx FIFO size depending on the port speeds for PPv2.2
Date: Mon, 30 Oct 2017 11:23:28 +0100
Message-ID: <20171030102333.30781-2-antoine.tenart@free-electrons.com>
References: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Rx FIFO size was set to the same value for all ports. This patch
sets it depending on the maximum speed a given port can handle. This is
only working for PPv2.2.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 52 +++++++++++++++++++++++++++++++-----
 1 file changed, 46 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index cac19065e931..3bf9eaafcde5 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -504,9 +504,13 @@
 #define MVPP2_TX_DESC_ALIGN		(MVPP2_DESC_ALIGNED_SIZE - 1)
 
 /* RX FIFO constants */
-#define MVPP2_RX_FIFO_PORT_DATA_SIZE	0x2000
-#define MVPP2_RX_FIFO_PORT_ATTR_SIZE	0x80
-#define MVPP2_RX_FIFO_PORT_MIN_PKT	0x80
+#define MVPP2_RX_FIFO_PORT_DATA_SIZE_32KB	0x8000
+#define MVPP2_RX_FIFO_PORT_DATA_SIZE_8KB	0x2000
+#define MVPP2_RX_FIFO_PORT_DATA_SIZE_4KB	0x1000
+#define MVPP2_RX_FIFO_PORT_ATTR_SIZE_32KB	0x200
+#define MVPP2_RX_FIFO_PORT_ATTR_SIZE_8KB	0x80
+#define MVPP2_RX_FIFO_PORT_ATTR_SIZE_4KB	0x40
+#define MVPP2_RX_FIFO_PORT_MIN_PKT		0x80
 
 /* RX buffer constants */
 #define MVPP2_SKB_SHINFO_SIZE \
@@ -7764,9 +7768,42 @@ static void mvpp2_rx_fifo_init(struct mvpp2 *priv)
 
 	for (port = 0; port < MVPP2_MAX_PORTS; port++) {
 		mvpp2_write(priv, MVPP2_RX_DATA_FIFO_SIZE_REG(port),
-			    MVPP2_RX_FIFO_PORT_DATA_SIZE);
+			    MVPP2_RX_FIFO_PORT_DATA_SIZE_4KB);
 		mvpp2_write(priv, MVPP2_RX_ATTR_FIFO_SIZE_REG(port),
-			    MVPP2_RX_FIFO_PORT_ATTR_SIZE);
+			    MVPP2_RX_FIFO_PORT_ATTR_SIZE_4KB);
+	}
+
+	mvpp2_write(priv, MVPP2_RX_MIN_PKT_SIZE_REG,
+		    MVPP2_RX_FIFO_PORT_MIN_PKT);
+	mvpp2_write(priv, MVPP2_RX_FIFO_INIT_REG, 0x1);
+}
+
+static void mvpp22_rx_fifo_init(struct mvpp2 *priv)
+{
+	int port;
+
+	/* The FIFO size parameters are set depending on the maximum speed a
+	 * given port can handle:
+	 * - Port 0: 10Gbps
+	 * - Port 1: 2.5Gbps
+	 * - Ports 2 and 3: 1Gbps
+	 */
+
+	mvpp2_write(priv, MVPP2_RX_DATA_FIFO_SIZE_REG(0),
+		    MVPP2_RX_FIFO_PORT_DATA_SIZE_32KB);
+	mvpp2_write(priv, MVPP2_RX_ATTR_FIFO_SIZE_REG(0),
+		    MVPP2_RX_FIFO_PORT_ATTR_SIZE_32KB);
+
+	mvpp2_write(priv, MVPP2_RX_DATA_FIFO_SIZE_REG(1),
+		    MVPP2_RX_FIFO_PORT_DATA_SIZE_8KB);
+	mvpp2_write(priv, MVPP2_RX_ATTR_FIFO_SIZE_REG(1),
+		    MVPP2_RX_FIFO_PORT_ATTR_SIZE_8KB);
+
+	for (port = 2; port < MVPP2_MAX_PORTS; port++) {
+		mvpp2_write(priv, MVPP2_RX_DATA_FIFO_SIZE_REG(port),
+			    MVPP2_RX_FIFO_PORT_DATA_SIZE_4KB);
+		mvpp2_write(priv, MVPP2_RX_ATTR_FIFO_SIZE_REG(port),
+			    MVPP2_RX_FIFO_PORT_ATTR_SIZE_4KB);
 	}
 
 	mvpp2_write(priv, MVPP2_RX_MIN_PKT_SIZE_REG,
@@ -7870,7 +7907,10 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	}
 
 	/* Rx Fifo Init */
-	mvpp2_rx_fifo_init(priv);
+	if (priv->hw_version == MVPP21)
+		mvpp2_rx_fifo_init(priv);
+	else
+		mvpp22_rx_fifo_init(priv);
 
 	if (priv->hw_version == MVPP21)
 		writel(MVPP2_EXT_GLOBAL_CTRL_DEFAULT,
-- 
2.14.3
