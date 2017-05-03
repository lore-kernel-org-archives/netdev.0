From: Quentin Schulz <quentin.schulz@free-electrons.com>
Subject: [PATCH v2 1/2] can: m_can: move Message RAM initialization to function
Date: Wed,  3 May 2017 14:37:49 +0200
Message-ID: <20170503123750.26134-1-quentin.schulz@free-electrons.com>
Cc: Quentin Schulz <quentin.schulz@free-electrons.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: wg@grandegger.com, mkl@pengutronix.de, mario.huettel@gmx.net,
        socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To avoid possible ECC/parity checksum errors when reading an
uninitialized buffer, the entire Message RAM is initialized when probing
the driver. This initialization is done in the same function reading the
Device Tree properties.

This patch moves the RAM initialization to a separate function so it can
be called separately from device initialization from Device Tree.

Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
---
 drivers/net/can/m_can/m_can.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index bf8fdaeb955e..3f0445440146 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1489,6 +1489,20 @@ static int register_m_can_dev(struct net_device *dev)
 	return register_candev(dev);
 }
 
+static void m_can_init_ram(struct m_can_priv *priv)
+{
+	int end, i, start;
+
+	/* initialize the entire Message RAM in use to avoid possible
+	 * ECC/parity checksum errors when reading an uninitialized buffer
+	 */
+	start = priv->mcfg[MRAM_SIDF].off;
+	end = priv->mcfg[MRAM_TXB].off +
+		priv->mcfg[MRAM_TXB].num * TXB_ELEMENT_SIZE;
+	for (i = start; i < end; i += 4)
+		writel(0x0, priv->mram_base + i);
+}
+
 static void m_can_of_parse_mram(struct m_can_priv *priv,
 				const u32 *mram_config_vals)
 {
@@ -1529,15 +1543,7 @@ static void m_can_of_parse_mram(struct m_can_priv *priv,
 		priv->mcfg[MRAM_TXE].off, priv->mcfg[MRAM_TXE].num,
 		priv->mcfg[MRAM_TXB].off, priv->mcfg[MRAM_TXB].num);
 
-	/* initialize the entire Message RAM in use to avoid possible
-	 * ECC/parity checksum errors when reading an uninitialized buffer
-	 */
-	start = priv->mcfg[MRAM_SIDF].off;
-	end = priv->mcfg[MRAM_TXB].off +
-		priv->mcfg[MRAM_TXB].num * TXB_ELEMENT_SIZE;
-	for (i = start; i < end; i += 4)
-		writel(0x0, priv->mram_base + i);
-
+	m_can_init_ram(priv);
 }
 
 static int m_can_plat_probe(struct platform_device *pdev)
-- 
2.11.0

