From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot
 device
Date: Thu, 13 Oct 2011 20:38:01 -0700
Message-ID: <1318563481-19631-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3996 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932284Ab1JNE1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 00:27:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

For an FCoE or iSCSI boot device, the networking side must stay "up" all
the time.  Otherwise, the FCoE/iSCSI interface driven by bnx2i/bnx2fc
will be reset and we'll lose the root file system.

If LRO is enabled, scripts that enable IP forwarding or bridging will
disable LRO and cause the device to be reset.  Disabling LRO on these
boot devices will prevent the reset.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6486ab8..4960048 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9794,6 +9794,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	int func;
 	int timer_interval;
 	int rc;
+	u32 cnic_boot_device;
 
 	mutex_init(&bp->port.phy_mutex);
 	mutex_init(&bp->fw_mb_mutex);
@@ -9840,8 +9841,11 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	bp->multi_mode = multi_mode;
 
+	cnic_boot_device =
+		!!SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].iscsi_boot_signature);
+
 	/* Set TPA flags */
-	if (disable_tpa) {
+	if (disable_tpa || cnic_boot_device) {
 		bp->flags &= ~TPA_ENABLE_FLAG;
 		bp->dev->features &= ~NETIF_F_LRO;
 	} else {
-- 
1.7.1
