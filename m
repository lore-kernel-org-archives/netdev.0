From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 06/10] stmmac: Replace infinite loops by timeouts in mdio r/w
Date: Wed,  4 Apr 2012 16:33:24 +0200
Message-ID: <1333550008-16500-7-git-send-email-peppe.cavallaro@st.com>
References: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, deepak.sikri@st.com, spear-devel@list.st.com,
	shiraz.hashim@st.com, viresh.kumar@st.com,
	srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:58025 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756428Ab2DDOeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 10:34:14 -0400
In-Reply-To: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak SIKRI <deepak.sikri@st.com>

This patch removes the infinite waits from the mdio read and
write interfaces. These infinite waits have been replaced by
the timeout handling. In case if a time out occurs, an error is
returned.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   32 ++++++++++++++++----
 1 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 7319532..83292f4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -34,6 +34,22 @@
 #define MII_BUSY 0x00000001
 #define MII_WRITE 0x00000002
 
+static int stmmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_addr)
+{
+	unsigned long curr;
+	unsigned long finish = jiffies + 3 * HZ;
+
+	do {
+		curr = jiffies;
+		if (readl(ioaddr + mii_addr) & MII_BUSY)
+			cpu_relax();
+		else
+			return 0;
+	} while (!time_after_eq(curr, finish));
+
+	return -EBUSY;
+}
+
 /**
  * stmmac_mdio_read
  * @bus: points to the mii_bus structure
@@ -56,9 +72,13 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 			((phyreg << 6) & (0x000007C0)));
 	regValue |= MII_BUSY | ((priv->plat->clk_csr & 7) << 2);
 
-	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
+	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
+		return -EBUSY;
+
 	writel(regValue, priv->ioaddr + mii_address);
-	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
+
+	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
+		return -EBUSY;
 
 	/* Read the data from the MII data register */
 	data = (int)readl(priv->ioaddr + mii_data);
@@ -88,18 +108,16 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 
 	value |= MII_BUSY | ((priv->plat->clk_csr & 7) << 2);
 
-
 	/* Wait until any existing MII operation is complete */
-	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
+	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
+		return -EBUSY;
 
 	/* Set the MII address register to write */
 	writel(phydata, priv->ioaddr + mii_data);
 	writel(value, priv->ioaddr + mii_address);
 
 	/* Wait until any existing MII operation is complete */
-	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
-
-	return 0;
+	return stmmac_mdio_busy_wait(priv->ioaddr, mii_address);
 }
 
 /**
-- 
1.7.4.4
