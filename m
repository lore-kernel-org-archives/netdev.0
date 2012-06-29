From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] cnic: Fix mmap regression.
Date: Fri, 29 Jun 2012 12:32:45 -0700
Message-ID: <1340998365-15753-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2418 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932067Ab2F2TVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 15:21:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1f85d58cdf15354a7120fc9ccc9bb9c45b53af88
    cnic: Remove uio mem[0].

introduced a regression as older versions of userspace app still rely
on this mmap.  Restore the mmap functionality and get the base address
from pci_resource_start() as the nedev->base_addr has been deprecated for
PCI devices.

Update version to 2.5.12.

Signed-off-by: Michael Chan <mchan@broadocm.com>
---
 drivers/net/ethernet/broadcom/cnic.c    |    8 +++++++-
 drivers/net/ethernet/broadcom/cnic_if.h |    4 ++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index f897306..22ad7b6 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1063,9 +1063,13 @@ static int cnic_init_uio(struct cnic_dev *dev)
 
 	uinfo = &udev->cnic_uinfo;
 
-	uinfo->mem[0].memtype = UIO_MEM_NONE;
+	uinfo->mem[0].addr = pci_resource_start(dev->pcidev, 0);
+	uinfo->mem[0].internal_addr = dev->regview;
+	uinfo->mem[0].memtype = UIO_MEM_PHYS;
 
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
+		uinfo->mem[0].size = MB_GET_CID_ADDR(TX_TSS_CID +
+						     TX_MAX_TSS_RINGS + 1);
 		uinfo->mem[1].addr = (unsigned long) cp->status_blk.gen &
 					PAGE_MASK;
 		if (cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
@@ -1075,6 +1079,8 @@ static int cnic_init_uio(struct cnic_dev *dev)
 
 		uinfo->name = "bnx2_cnic";
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
+		uinfo->mem[0].size = pci_resource_len(dev->pcidev, 0);
+
 		uinfo->mem[1].addr = (unsigned long) cp->bnx2x_def_status_blk &
 			PAGE_MASK;
 		uinfo->mem[1].size = sizeof(*cp->bnx2x_def_status_blk);
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 54f68f0..5cb8888 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.11"
-#define CNIC_MODULE_RELDATE	"June 27, 2012"
+#define CNIC_MODULE_VERSION	"2.5.12"
+#define CNIC_MODULE_RELDATE	"June 29, 2012"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.7.1
