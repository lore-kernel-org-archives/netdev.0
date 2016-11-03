From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 08/10] amd-xgbe: Support for 64-bit management
 counter registers
Date: Thu, 3 Nov 2016 13:19:07 -0500
Message-ID: <20161103181907.7383.49229.stgit@tlendack-t1.amdoffice.net>
References: <20161103181727.7383.34446.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0048.outbound.protection.outlook.com ([104.47.32.48]:35520
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757846AbcKCSTN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 14:19:13 -0400
In-Reply-To: <20161103181727.7383.34446.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading all management counter registers as 64-bit
values.  The indication of whether to read the high 32-bits to form
a 64-bit value is indicated in the version data.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   36 ++++++++++++++++++++++--------
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    1 +
 2 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index b8a04e7..fbd60ee 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -2588,17 +2588,33 @@ static u64 xgbe_mmc_read(struct xgbe_prv_data *pdata, unsigned int reg_lo)
 	bool read_hi;
 	u64 val;
 
-	switch (reg_lo) {
-	/* These registers are always 64 bit */
-	case MMC_TXOCTETCOUNT_GB_LO:
-	case MMC_TXOCTETCOUNT_G_LO:
-	case MMC_RXOCTETCOUNT_GB_LO:
-	case MMC_RXOCTETCOUNT_G_LO:
-		read_hi = true;
-		break;
+	if (pdata->vdata->mmc_64bit) {
+		switch (reg_lo) {
+		/* These registers are always 32 bit */
+		case MMC_RXRUNTERROR:
+		case MMC_RXJABBERERROR:
+		case MMC_RXUNDERSIZE_G:
+		case MMC_RXOVERSIZE_G:
+		case MMC_RXWATCHDOGERROR:
+			read_hi = false;
+			break;
 
-	default:
-		read_hi = false;
+		default:
+			read_hi = true;
+		}
+	} else {
+		switch (reg_lo) {
+		/* These registers are always 64 bit */
+		case MMC_TXOCTETCOUNT_GB_LO:
+		case MMC_TXOCTETCOUNT_G_LO:
+		case MMC_RXOCTETCOUNT_GB_LO:
+		case MMC_RXOCTETCOUNT_G_LO:
+			read_hi = true;
+			break;
+
+		default:
+			read_hi = false;
+		}
 	}
 
 	val = XGMAC_IOREAD(pdata, reg_lo);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 160b498..7cbf91b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -804,6 +804,7 @@ struct xgbe_hw_features {
 struct xgbe_version_data {
 	void (*init_function_ptrs_phy_impl)(struct xgbe_phy_if *);
 	enum xgbe_xpcs_access xpcs_access;
+	unsigned int mmc_64bit;
 };
 
 struct xgbe_prv_data {
