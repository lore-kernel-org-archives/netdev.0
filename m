From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/5] cxgb4: Add support to S25FL032P flash
Date: Wed, 10 Sep 2014 17:44:28 +0530
Message-ID: <1410351271-26428-3-git-send-email-hariprasad@chelsio.com>
References: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:42772
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751332AbaIJMJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:09:02 -0400
In-Reply-To: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for Spansion S25FL032P flash
Based on original work by Dimitris Michailidis

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 41d0446..7d4cc28 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3850,8 +3850,20 @@ int t4_wait_dev_ready(struct adapter *adap)
 	return t4_read_reg(adap, PL_WHOAMI) != 0xffffffff ? 0 : -EIO;
 }
 
+struct flash_desc {
+	u32 vendor_and_model_id;
+	u32 size_mb;
+};
+
 static int get_flash_params(struct adapter *adap)
 {
+	/* Table for non-Numonix supported flash parts.  Numonix parts are left
+	 * to the preexisting code.  All flash parts have 64KB sectors.
+	 */
+	static struct flash_desc supported_flash[] = {
+		{ 0x150201, 4 << 20 },       /* Spansion 4MB S25FL032P */
+	};
+
 	int ret;
 	u32 info;
 
@@ -3862,6 +3874,14 @@ static int get_flash_params(struct adapter *adap)
 	if (ret)
 		return ret;
 
+	for (ret = 0; ret < ARRAY_SIZE(supported_flash); ++ret)
+		if (supported_flash[ret].vendor_and_model_id == info) {
+			adap->params.sf_size = supported_flash[ret].size_mb;
+			adap->params.sf_nsec =
+				adap->params.sf_size / SF_SEC_SIZE;
+			return 0;
+		}
+
 	if ((info & 0xff) != 0x20)             /* not a Numonix flash */
 		return -EINVAL;
 	info >>= 16;                           /* log2 of size */
-- 
1.7.1
