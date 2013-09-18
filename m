From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net 2/2] cnic: Fix crash in cnic_bnx2x_service_kcq()
Date: Wed, 18 Sep 2013 01:50:39 -0700
Message-ID: <1379494239-5481-3-git-send-email-mchan@broadcom.com>
References: <1379494239-5481-1-git-send-email-mchan@broadcom.com>
 <1379494239-5481-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4410 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946Ab3IRIaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 04:30:39 -0400
In-Reply-To: <1379494239-5481-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 104a43edb264321a4d41850e98153b4fa8a9ef42
    cnic: Use CHIP_NUM macros from bnx2x.h

changed the code to use the bnx2x macro NO_FCOE() to determine if FCoE
is supported or not.  There is another place in cnic that is still using
the old method to determine if FCoE is supported or not.  The 2 methods
may not yield the same result after the network interface is brought down
and up.  This will cause the crash as cnic_bnx2x_service_kcq() will access
the uninitialized cp->kcq2.

The fix is to consistently use the same macro CNIC_SUPPORTS_FCOE() which
uses the bnx2x NO_FCOE() macro.  As a follow-up, we can clean up the code
to remove the old method as it is no longer needed.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 93da16b..99394bd 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3135,6 +3135,7 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 {
 	struct cnic_dev *dev = (struct cnic_dev *) data;
 	struct cnic_local *cp = dev->cnic_priv;
+	struct bnx2x *bp = netdev_priv(dev->netdev);
 	u32 status_idx, new_status_idx;
 
 	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
@@ -3146,7 +3147,7 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 		CNIC_WR16(dev, cp->kcq1.io_addr,
 			  cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
 
-		if (cp->ethdev->drv_state & CNIC_DRV_STATE_NO_FCOE) {
+		if (!CNIC_SUPPORTS_FCOE(bp)) {
 			cp->arm_int(dev, status_idx);
 			break;
 		}
-- 
1.7.1
