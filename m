From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH] stmmac: dwmac-ipq806x: fix static checker warning
Date: Tue,  4 Aug 2015 17:25:02 -0700
Message-ID: <1438734302-22930-1-git-send-email-mathieu@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathieu Olivari <mathieu@codeaurora.org>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52835 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbbHEAZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 20:25:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch b1c17215d718: "stmmac: add ipq806x glue layer", leads to the
following static checker warning:

.../stmmac/dwmac-ipq806x.c:314 ipq806x_gmac_probe()
warn: double left shift '1 << (1 << gmac->id)'

The NSS_COMMON_CLK_SRC_CTRL_OFFSET macro is used once as an offset, and
once as a mask, which is a bug indeed. We'll fix it by defining the
offset as the real offset value and computing the mask from it when
required.

Tested on IPQ806x ref designs AP148 & DB149.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
index 333489f..9d89bdb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
@@ -42,7 +42,7 @@
 #define NSS_COMMON_CLK_DIV_MASK			0x7f
 
 #define NSS_COMMON_CLK_SRC_CTRL			0x14
-#define NSS_COMMON_CLK_SRC_CTRL_OFFSET(x)	(1 << x)
+#define NSS_COMMON_CLK_SRC_CTRL_OFFSET(x)	(x)
 /* Mode is coded on 1 bit but is different depending on the MAC ID:
  * MAC0: QSGMII=0 RGMII=1
  * MAC1: QSGMII=0 SGMII=0 RGMII=1
@@ -308,7 +308,7 @@ static int ipq806x_gmac_probe(struct platform_device *pdev)
 
 	/* Configure the clock src according to the mode */
 	regmap_read(gmac->nss_common, NSS_COMMON_CLK_SRC_CTRL, &val);
-	val &= ~NSS_COMMON_CLK_SRC_CTRL_OFFSET(gmac->id);
+	val &= ~(1 << NSS_COMMON_CLK_SRC_CTRL_OFFSET(gmac->id));
 	switch (gmac->phy_mode) {
 	case PHY_INTERFACE_MODE_RGMII:
 		val |= NSS_COMMON_CLK_SRC_CTRL_RGMII(gmac->id) <<
-- 
2.1.4
