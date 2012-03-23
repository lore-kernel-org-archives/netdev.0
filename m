From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 08/10] stmmac: extend CSR Clock Range programming
Date: Fri, 23 Mar 2012 10:08:39 +0100
Message-ID: <1332493721-28309-9-git-send-email-peppe.cavallaro@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, srinivas.kandagatla@st.com,
	deepak.sikri@st.com, spear-devel@list.st.com, shiraz.hashim@st.com,
	viresh.kumar@st.com, bhutchings@solarflare.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:49536 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757880Ab2CWJJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 05:09:39 -0400
In-Reply-To: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CSR Clock Range has been reworked and new macros has
been added in the platform header to allow the CSR Clock
Range selection in the GMII Address Register.
The previous work didn't add the other fields
that can be used to achieve MDC clock of frequency
higher than the IEEE 802.3 specified frequency limit
of 2.5 MHz and program a clock divider of lower value.
On such platforms, these are used indeed so this patch
adds them.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    4 +-
 include/linux/stmmac.h                            |   31 +++++++++++----------
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 83292f4..1a42014 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -70,7 +70,7 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	int data;
 	u16 regValue = (((phyaddr << 11) & (0x0000F800)) |
 			((phyreg << 6) & (0x000007C0)));
-	regValue |= MII_BUSY | ((priv->plat->clk_csr & 7) << 2);
+	regValue |= MII_BUSY | ((priv->plat->clk_csr & 0xF) << 2);
 
 	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
 		return -EBUSY;
@@ -106,7 +106,7 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	    (((phyaddr << 11) & (0x0000F800)) | ((phyreg << 6) & (0x000007C0)))
 	    | MII_WRITE;
 
-	value |= MII_BUSY | ((priv->plat->clk_csr & 7) << 2);
+	value |= MII_BUSY | ((priv->plat->clk_csr & 0xF) << 2);
 
 	/* Wait until any existing MII operation is complete */
 	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 4aef9ba..cf64031 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -37,28 +37,29 @@
  * This could also be configured at run time using CPU freq framework. */
 
 /* MDC Clock Selection define*/
-#define	STMMAC_CSR_60_100M	0	/* MDC = clk_scr_i/42 */
-#define	STMMAC_CSR_100_150M	1	/* MDC = clk_scr_i/62 */
-#define	STMMAC_CSR_20_35M	2	/* MDC = clk_scr_i/16 */
-#define	STMMAC_CSR_35_60M	3	/* MDC = clk_scr_i/26 */
-#define	STMMAC_CSR_150_250M	4	/* MDC = clk_scr_i/102 */
-#define	STMMAC_CSR_250_300M	5	/* MDC = clk_scr_i/122 */
-
-/* FIXME: The MDC clock could be set higher than the IEEE 802.3
+#define	STMMAC_CSR_60_100M	0x0	/* MDC = clk_scr_i/42 */
+#define	STMMAC_CSR_100_150M	0x1	/* MDC = clk_scr_i/62 */
+#define	STMMAC_CSR_20_35M	0x2	/* MDC = clk_scr_i/16 */
+#define	STMMAC_CSR_35_60M	0x3	/* MDC = clk_scr_i/26 */
+#define	STMMAC_CSR_150_250M	0x4	/* MDC = clk_scr_i/102 */
+#define	STMMAC_CSR_250_300M	0x5	/* MDC = clk_scr_i/122 */
+
+/* The MDC clock could be set higher than the IEEE 802.3
  * specified frequency limit 0f 2.5 MHz, by programming a clock divider
  * of value different than the above defined values. The resultant MDIO
  * clock frequency of 12.5 MHz is applicable for the interfacing chips
  * supporting higher MDC clocks.
  * The MDC clock selection macros need to be defined for MDC clock rate
  * of 12.5 MHz, corresponding to the following selection.
- * 1000 clk_csr_i/4
- * 1001 clk_csr_i/6
- * 1010 clk_csr_i/8
- * 1011 clk_csr_i/10
- * 1100 clk_csr_i/12
- * 1101 clk_csr_i/14
- * 1110 clk_csr_i/16
- * 1111 clk_csr_i/18 */
+ */
+#define STMMAC_CSR_I_4		0x8	/* clk_csr_i/4 */
+#define STMMAC_CSR_I_6		0x9	/* clk_csr_i/6 */
+#define STMMAC_CSR_I_8		0xA	/* clk_csr_i/8 */
+#define STMMAC_CSR_I_10		0xB	/* clk_csr_i/10 */
+#define STMMAC_CSR_I_12		0xC	/* clk_csr_i/12 */
+#define STMMAC_CSR_I_14		0xD	/* clk_csr_i/14 */
+#define STMMAC_CSR_I_16		0xE	/* clk_csr_i/16 */
+#define STMMAC_CSR_I_18		0xF	/* clk_csr_i/18 */
 
 /* AXI DMA Burst length suported */
 #define DMA_AXI_BLEN_4		(1 << 1)
-- 
1.7.4.4
