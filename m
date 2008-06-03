From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 34/39] mv643xx_eth: detect extended rx coal register field
Date: Tue,  3 Jun 2008 13:02:49 +0200
Message-ID: <1212490974-23719-35-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48750 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753649AbYFCMAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:31 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Newer hardware has a 16-bit instead of a 14-bit RX coalescing
count field in the SDMA_CONFIG register.  This patch adds a run-time
check for which of the two we have, and adjusts further writes to the
rx coal count field accordingly.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   38 +++++++++++++++++++++++++++++++-------
 1 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 8e4ca2b..4168a8a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -240,6 +240,7 @@ struct mv643xx_eth_shared_private {
 	 * Hardware-specific parameters.
 	 */
 	unsigned int t_clk;
+	int extended_rx_coal_limit;
 };
 
 
@@ -1796,14 +1797,22 @@ static void port_start(struct mv643xx_eth_private *mep)
 static void set_rx_coal(struct mv643xx_eth_private *mep, unsigned int delay)
 {
 	unsigned int coal = ((mep->shared->t_clk / 1000000) * delay) / 64;
+	u32 val;
 
-	if (coal > 0x3fff)
-		coal = 0x3fff;
-
-	wrl(mep, SDMA_CONFIG(mep->port_num),
-		((coal & 0x3fff) << 8) |
-		(rdl(mep, SDMA_CONFIG(mep->port_num))
-			& 0xffc000ff));
+	val = rdl(mep, SDMA_CONFIG(mep->port_num));
+	if (mep->shared->extended_rx_coal_limit) {
+		if (coal > 0xffff)
+			coal = 0xffff;
+		val &= ~0x023fff80;
+		val |= (coal & 0x8000) << 10;
+		val |= (coal & 0x7fff) << 7;
+	} else {
+		if (coal > 0x3fff)
+			coal = 0x3fff;
+		val &= ~0x003fff00;
+		val |= (coal & 0x3fff) << 8;
+	}
+	wrl(mep, SDMA_CONFIG(mep->port_num), val);
 }
 
 static void set_tx_coal(struct mv643xx_eth_private *mep, unsigned int delay)
@@ -2068,6 +2077,20 @@ mv643xx_eth_conf_mbus_windows(struct mv643xx_eth_shared_private *mesp,
 	mesp->win_protect = win_protect;
 }
 
+static void infer_hw_params(struct mv643xx_eth_shared_private *mesp)
+{
+	/*
+	 * Check whether we have a 14-bit coal limit field in bits
+	 * [21:8], or a 16-bit coal limit in bits [25,21:7] of the
+	 * SDMA config register.
+	 */
+	writel(0x02000000, mesp->base + SDMA_CONFIG(0));
+	if (readl(mesp->base + SDMA_CONFIG(0)) & 0x02000000)
+		mesp->extended_rx_coal_limit = 1;
+	else
+		mesp->extended_rx_coal_limit = 0;
+}
+
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
 	static int mv643xx_eth_version_printed = 0;
@@ -2106,6 +2129,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	 * Detect hardware parameters.
 	 */
 	mesp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
+	infer_hw_params(mesp);
 
 	platform_set_drvdata(pdev, mesp);
 
-- 
1.5.3.4

