From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] fm10k: fix PCI device enable_cnt leak in .io_slot_reset
Date: Mon, 29 Aug 2016 02:13:33 -0700
Message-ID: <1472462026-42133-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56356 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756027AbcH2JNt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:49 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A previous patch removed the pci_disable_device() call in
.io_error_detected. This call corresponded to a pci_enable_device_mem()
call within .io_slot_reset handler. Change the call here to
a pci_reenable_device() so that it does not increment and leak the
enable_cnt reference count for the device. Without this change, VF
devices may fail during an unbind/bind, and we'll never zero the
reference counter for the pci_dev structure.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 774a565..377a3fb 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2275,7 +2275,7 @@ static pci_ers_result_t fm10k_io_slot_reset(struct pci_dev *pdev)
 {
 	pci_ers_result_t result;
 
-	if (pci_enable_device_mem(pdev)) {
+	if (pci_reenable_device(pdev)) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
 		result = PCI_ERS_RESULT_DISCONNECT;
-- 
2.7.4
