From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/7] sfc: Do not reinitialise XAUI serdes before it has
	completed reset
Date: Wed, 26 Aug 2009 19:16:46 +0100
Message-ID: <1251310606.27345.11.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:34852 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752604AbZHZSQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 14:16:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

falcon_reset_xaui() waits for XGXS reset to complete, but the XAUI
serdes reset may take longer.  It needs to check both reset active
bits.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_hwdefs.h |    2 ++
 drivers/net/sfc/falcon_xmac.c   |    8 +++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 375e2a5..2d22611 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -700,6 +700,8 @@
 /* XGXS/XAUI powerdown/reset register */
 #define XX_PWR_RST_REG 0x1300
 
+#define XX_SD_RST_ACT_LBN 16
+#define XX_SD_RST_ACT_WIDTH 1
 #define XX_PWRDND_EN_LBN 15
 #define XX_PWRDND_EN_WIDTH 1
 #define XX_PWRDNC_EN_LBN 14
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 2b3269c..bec52ca 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -64,13 +64,15 @@ int falcon_reset_xaui(struct efx_nic *efx)
 	efx_oword_t reg;
 	int count;
 
+	/* Start reset sequence */
 	EFX_POPULATE_DWORD_1(reg, XX_RST_XX_EN, 1);
 	falcon_write(efx, &reg, XX_PWR_RST_REG);
 
-	/* Give some time for the link to establish */
-	for (count = 0; count < 1000; count++) { /* wait upto 10ms */
+	/* Wait up to 10 ms for completion, then reinitialise */
+	for (count = 0; count < 1000; count++) {
 		falcon_read(efx, &reg, XX_PWR_RST_REG);
-		if (EFX_OWORD_FIELD(reg, XX_RST_XX_EN) == 0) {
+		if (EFX_OWORD_FIELD(reg, XX_RST_XX_EN) == 0 &&
+		    EFX_OWORD_FIELD(reg, XX_SD_RST_ACT) == 0) {
 			falcon_setup_xaui(efx);
 			return 0;
 		}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

