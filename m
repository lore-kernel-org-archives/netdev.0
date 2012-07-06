From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net] cnic: Don't use netdev->base_addr
Date: Thu, 5 Jul 2012 17:21:55 -0700
Message-ID: <1341534115-710-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3447 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932264Ab2GFAKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2012 20:10:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    commit c0357e975afdbbedab5c662d19bef865f02adc17
    bnx2: stop using net_device.{base_addr, irq}.

removed netdev->base_addr so we need to update cnic to get the MMIO
base address from pci_resource_start().  Otherwise, mmap of the uio
device will fail.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index c95e7b5..3c95065 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1053,12 +1053,13 @@ static int cnic_init_uio(struct cnic_dev *dev)
 
 	uinfo = &udev->cnic_uinfo;
 
-	uinfo->mem[0].addr = dev->netdev->base_addr;
+	uinfo->mem[0].addr = pci_resource_start(dev->pcidev, 0);
 	uinfo->mem[0].internal_addr = dev->regview;
-	uinfo->mem[0].size = dev->netdev->mem_end - dev->netdev->mem_start;
 	uinfo->mem[0].memtype = UIO_MEM_PHYS;
 
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
+		uinfo->mem[0].size = MB_GET_CID_ADDR(TX_TSS_CID +
+						     TX_MAX_TSS_RINGS + 1);
 		uinfo->mem[1].addr = (unsigned long) cp->status_blk.gen &
 					PAGE_MASK;
 		if (cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
@@ -1068,6 +1069,8 @@ static int cnic_init_uio(struct cnic_dev *dev)
 
 		uinfo->name = "bnx2_cnic";
 	} else if (test_bit(CNIC_F_BNX2X_CLASS, &dev->flags)) {
+		uinfo->mem[0].size = pci_resource_len(dev->pcidev, 0);
+
 		uinfo->mem[1].addr = (unsigned long) cp->bnx2x_def_status_blk &
 			PAGE_MASK;
 		uinfo->mem[1].size = sizeof(*cp->bnx2x_def_status_blk);
-- 
1.7.1
