From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Add a check for flashing FW using ethtool
Date: Tue,  2 Dec 2014 17:39:37 +0530
Message-ID: <1417522177-14842-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:52524
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754508AbaLBMDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 07:03:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't let T4 firmware flash on a T5 adapter and vice-versa
using ethtool

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 163a2a1..fae205a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1131,6 +1131,27 @@ unsigned int t4_flash_cfg_addr(struct adapter *adapter)
 		return FLASH_CFG_START;
 }
 
+/* Return TRUE if the specified firmware matches the adapter.  I.e. T4
+ * firmware for T4 adapters, T5 firmware for T5 adapters, etc.  We go ahead
+ * and emit an error message for mismatched firmware to save our caller the
+ * effort ...
+ */
+static int t4_fw_matches_chip(const struct adapter *adap,
+			      const struct fw_hdr *hdr)
+{
+	/* The expression below will return FALSE for any unsupported adapter
+	 * which will keep us "honest" in the future ...
+	 */
+	if ((is_t4(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T4) ||
+	    (is_t5(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T5))
+		return 1;
+
+	dev_err(adap->pdev_dev,
+		"FW image (%d) is not suitable for this adapter (%d)\n",
+		hdr->chip, CHELSIO_CHIP_VERSION(adap->params.chip));
+	return 0;
+}
+
 /**
  *	t4_load_fw - download firmware
  *	@adap: the adapter
@@ -1170,6 +1191,8 @@ int t4_load_fw(struct adapter *adap, const u8 *fw_data, unsigned int size)
 			FW_MAX_SIZE);
 		return -EFBIG;
 	}
+	if (!t4_fw_matches_chip(adap, hdr))
+		return -EINVAL;
 
 	for (csum = 0, i = 0; i < size / sizeof(csum); i++)
 		csum += ntohl(p[i]);
@@ -3080,6 +3103,9 @@ int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 	const struct fw_hdr *fw_hdr = (const struct fw_hdr *)fw_data;
 	int reset, ret;
 
+	if (!t4_fw_matches_chip(adap, fw_hdr))
+		return -EINVAL;
+
 	ret = t4_fw_halt(adap, mbox, force);
 	if (ret < 0 && !force)
 		return ret;
-- 
1.7.1
