From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 18/22] net: mvpp2: rework RXQ interrupt group
 initialization for PPv2.2
Date: Tue,  7 Mar 2017 16:53:16 +0100
Message-ID: <1488902000-2658-19-git-send-email-thomas.petazzoni@free-electrons.com>
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

This commit adjusts how the MVPP2_ISR_RXQ_GROUP_REG register is
configured, since it changed between PPv2.1 and PPv2.2.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 46 ++++++++++++++++++++++++++++++++----
 1 file changed, 42 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 0e10303..21f47d2 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -185,7 +185,21 @@
 /* Interrupt Cause and Mask registers */
 #define MVPP2_ISR_RX_THRESHOLD_REG(rxq)		(0x5200 + 4 * (rxq))
 #define     MVPP2_MAX_ISR_RX_THRESHOLD		0xfffff0
-#define MVPP2_ISR_RXQ_GROUP_REG(rxq)		(0x5400 + 4 * (rxq))
+#define MVPP21_ISR_RXQ_GROUP_REG(rxq)		(0x5400 + 4 * (rxq))
+
+#define MVPP22_ISR_RXQ_GROUP_INDEX_REG          0x5400
+#define MVPP22_ISR_RXQ_GROUP_INDEX_SUBGROUP_MASK 0xf
+#define MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_MASK   0x380
+#define MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_OFFSET 7
+
+#define MVPP22_ISR_RXQ_GROUP_INDEX_SUBGROUP_MASK 0xf
+#define MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_MASK   0x380
+
+#define MVPP22_ISR_RXQ_SUB_GROUP_CONFIG_REG     0x5404
+#define MVPP22_ISR_RXQ_SUB_GROUP_STARTQ_MASK    0x1f
+#define MVPP22_ISR_RXQ_SUB_GROUP_SIZE_MASK      0xf00
+#define MVPP22_ISR_RXQ_SUB_GROUP_SIZE_OFFSET    8
+
 #define MVPP2_ISR_ENABLE_REG(port)		(0x5420 + 4 * (port))
 #define     MVPP2_ISR_ENABLE_INTERRUPT(mask)	((mask) & 0xffff)
 #define     MVPP2_ISR_DISABLE_INTERRUPT(mask)	(((mask) << 16) & 0xffff0000)
@@ -6406,7 +6420,18 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	}
 
 	/* Configure Rx queue group interrupt for this port */
-	mvpp2_write(priv, MVPP2_ISR_RXQ_GROUP_REG(port->id), rxq_number);
+	if (priv->hw_version == MVPP21) {
+		mvpp2_write(priv, MVPP21_ISR_RXQ_GROUP_REG(port->id),
+			    rxq_number);
+	} else {
+		u32 val;
+
+		val = (port->id << MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_OFFSET);
+		mvpp2_write(priv, MVPP22_ISR_RXQ_GROUP_INDEX_REG, val);
+
+		val = (rxq_number << MVPP22_ISR_RXQ_SUB_GROUP_SIZE_OFFSET);
+		mvpp2_write(priv, MVPP22_ISR_RXQ_SUB_GROUP_CONFIG_REG, val);
+	}
 
 	/* Create Rx descriptor rings */
 	for (queue = 0; queue < rxq_number; queue++) {
@@ -6799,8 +6824,21 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	mvpp2_rx_fifo_init(priv);
 
 	/* Reset Rx queue group interrupt configuration */
-	for (i = 0; i < MVPP2_MAX_PORTS; i++)
-		mvpp2_write(priv, MVPP2_ISR_RXQ_GROUP_REG(i), rxq_number);
+	for (i = 0; i < MVPP2_MAX_PORTS; i++) {
+		if (priv->hw_version == MVPP21) {
+			mvpp2_write(priv, MVPP21_ISR_RXQ_GROUP_REG(i),
+				    rxq_number);
+			continue;
+		} else {
+			u32 val;
+
+			val = (i << MVPP22_ISR_RXQ_GROUP_INDEX_GROUP_OFFSET);
+			mvpp2_write(priv, MVPP22_ISR_RXQ_GROUP_INDEX_REG, val);
+
+			val = (rxq_number << MVPP22_ISR_RXQ_SUB_GROUP_SIZE_OFFSET);
+			mvpp2_write(priv, MVPP22_ISR_RXQ_SUB_GROUP_CONFIG_REG, val);
+		}
+	}
 
 	if (priv->hw_version == MVPP21)
 		writel(MVPP2_EXT_GLOBAL_CTRL_DEFAULT,
-- 
2.7.4
