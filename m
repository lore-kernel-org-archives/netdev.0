From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 09/13] bnx2x: add pri_map module parameter
Date: Thu, 10 Nov 2011 17:14:10 +0200
Message-ID: <1320938054-31288-10-git-send-email-dmitry@broadcom.com>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4002 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935078Ab1KJPOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 10:14:40 -0500
In-Reply-To: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

The optional parameter pri_map is used to map the
skb->priority to a Class Of Service (CoS) in the HW.
This 32 bit parameter is evaluated by the  driver as 8
values of 4 bits each. Each nibble sets the desired
HW queue number for that priority.

Also:
on the 5771x family this feature is unavailable (a single COS services all).
on the 57712 family two classes of service are available.
on the 578xx family three classes of service are availabe.
configuring  priorities to unavailable COSs will log an error and default to
COS 0.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   26 ++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 967c41b..5b44b85 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -92,6 +92,10 @@ MODULE_FIRMWARE(FW_FILE_NAME_E1);
 MODULE_FIRMWARE(FW_FILE_NAME_E1H);
 MODULE_FIRMWARE(FW_FILE_NAME_E2);
 
+static uint pri_map;
+module_param(pri_map, uint, 0);
+MODULE_PARM_DESC(pri_map, " Priority to HW queue mapping");
+
 static int multi_mode = 1;
 module_param(multi_mode, int, 0);
 MODULE_PARM_DESC(multi_mode, " Multi queue mode "
@@ -9682,6 +9686,25 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	return rc;
 }
 
+static void bnx2x_init_multi_cos(struct bnx2x *bp)
+{
+	int pri, cos;
+	for (pri = 0; pri < BNX2X_MAX_PRIORITY; pri++) {
+		cos = ((pri_map & (0xf << pri*4)) >> pri*4);
+		if (cos < bp->max_cos) {
+			bp->prio_to_cos[pri] = cos;
+			DP(BNX2X_MSG_SP, "configuring priority %d to cos %d",
+			   pri, cos);
+		} else {
+			netdev_err(bp->dev,
+			       "Illegal COS (%d) for priority %d "
+			       "Max COS allowed is %d "
+			       "defaulting to 0\n", cos, pri, bp->max_cos - 1);
+			bp->prio_to_cos[pri] = 0;
+		}
+	}
+}
+
 static void __devinit bnx2x_read_fwinfo(struct bnx2x *bp)
 {
 	int cnt, i, block_end, rodi;
@@ -10832,6 +10855,9 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	 */
 	bnx2x_set_int_mode(bp);
 
+	/* configure priority to cos map according to pri_map module param */
+	bnx2x_init_multi_cos(bp);
+
 	/* Add all NAPI objects */
 	bnx2x_add_all_napi(bp);
 
-- 
1.7.7.2
