From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 13/16] net: mvpp2: rework RXQ interrupt group initialization for PPv2.2
Date: Tue, 27 Dec 2016 17:54:34 +0100
Message-ID: <1482857677-16166-14-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36784 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933202AbcL0Qyv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:51 -0500
In-Reply-To: <1482857677-16166-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adjusts how the MVPP2_ISR_RXQ_GROUP_REG register is
configured, since it changed between PPv2.1 and PPv2.2.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 45 ++++++++++++++++++++++++++++++++----
 1 file changed, 41 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index d5b197d..baad991 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -188,7 +188,21 @@
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
@@ -6385,7 +6399,18 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	}
 
 	/* Configure Rx queue group interrupt for this port */
-	mvpp2_write(priv, MVPP2_ISR_RXQ_GROUP_REG(port->id), rxq_number);
+	if (priv->hw_version == MVPP21)
+		mvpp2_write(priv, MVPP21_ISR_RXQ_GROUP_REG(port->id),
+			    rxq_number);
+	else {
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
@@ -6775,8 +6800,20 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	mvpp2_rx_fifo_init(priv);
 
 	/* Reset Rx queue group interrupt configuration */
-	for (i = 0; i < MVPP2_MAX_PORTS; i++)
-		mvpp2_write(priv, MVPP2_ISR_RXQ_GROUP_REG(i), rxq_number);
+	for (i = 0; i < MVPP2_MAX_PORTS; i++) {
+		if (priv->hw_version == MVPP21)
+			mvpp2_write(priv, MVPP21_ISR_RXQ_GROUP_REG(i),
+				    rxq_number);
+		else {
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
