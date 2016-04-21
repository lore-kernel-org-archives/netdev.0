From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] fm10k: do not disable PCI device in fm10k_io_error_detected
Date: Wed, 20 Apr 2016 23:09:21 -0700
Message-ID: <1461218969-68578-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55438 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751619AbcDUGJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:35 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

fm10k_io_error_detected() does not need to call pci_disable_device(). In
the cases where the reset needs to occur, the stack flow will result in
calling fm10k_remove() which already disables the PCI device. If we
leave the pci_disable_device(), we result in a warning about disabling
an already disabled device.

Many PCI drivers do call pci_disable_device() in their .error_detected()
routines, but it does not appear to be required. In addition, these
drivers have a check "is_pci_enabled()" call in their remove routines,
which is how they chose to handle the duplicate device disable.

This seems incorrect, since the PCI device structure is reference
counted. It is very possible that the reference count for the PCI device
could be greater than 1. In this case, you would remove the PCI device
within the error_detected routine, reducing count to 1, then remove it
again in the remove function, reducing it to zero. This would result in
yet another disable somewhere else failing. Thus, we shouldn't be using
is_pci_enabled() to check for this issue. Instead, just remove the
extraneous pci_device_disable() found within the error_detected routine.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9055681..1d83378 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2207,8 +2207,6 @@ static pci_ers_result_t fm10k_io_error_detected(struct pci_dev *pdev,
 
 	rtnl_unlock();
 
-	pci_disable_device(pdev);
-
 	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
 }
-- 
2.5.5
