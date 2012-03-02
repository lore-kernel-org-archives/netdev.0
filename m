From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 6/6] stmmac: Replace infinite loops by timeouts in mdio r/w
Date: Fri, 2 Mar 2012 18:25:28 +0530
Message-ID: <1330692928-30330-7-git-send-email-deepak.sikri@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-2-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-3-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-5-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-6-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear-devel@list.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:44395 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755102Ab2CBM4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 07:56:12 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id D1076CE
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:47:41 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 9AA1575F
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:56:06 +0000 (GMT)
In-Reply-To: <1330692928-30330-6-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the infinite waits from the mdio read and
write interfaces. These infinite waits have been replaced by
the timeout handling. In case if a time out occurs, an error is
returned.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   30 ++++++++++++++++-----
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 7319532..b6a6fb2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -34,6 +34,20 @@
 #define MII_BUSY 0x00000001
 #define MII_WRITE 0x00000002
 
+static int stmmac_mdio_busy_wait(unsigned long ioaddr, unsigned int mii_addr)
+{
+	unsigned long finish = jiffies + 3 * HZ;
+
+	do {
+		if (readl(ioaddr + mii_addr) & MII_BUSY)
+			cpu_relax();
+		else
+			return 0;
+	} while (!time_after_eq(jiffies, finish));
+
+	return -EBUSY;
+}
+
 /**
  * stmmac_mdio_read
  * @bus: points to the mii_bus structure
@@ -56,9 +70,13 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
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
@@ -88,18 +106,16 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 
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
1.6.0.2
