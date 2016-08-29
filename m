From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] fm10k: don't continue probe if PCI device not in normal IO state
Date: Mon, 29 Aug 2016 02:13:40 -0700
Message-ID: <1472462026-42133-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56356 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932179AbcH2JNv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:51 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In the event of an uncorrectable AER error occurring when the driver has
not loaded, the recovery routines are not done. This is done because
future loads of the driver may not be aware of the IO state and may not
be able to recover at all. In this case, when we next load the driver it
fails due to what appears to be a surprise remove event. Instead, add
a check to ensure that the device is in the normal IO state before
continuing to probe. This allows us to give a more descriptive message
of what is wrong.

Without this change, the driver will attempt to probe up to our first
call of .reset_hw() which will be unable to read registers and act as if
a surprise remove event occurred.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index e5f37b7..860fe04 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1950,6 +1950,12 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct fm10k_intfc *interface;
 	int err;
 
+	if (pdev->error_state != pci_channel_io_normal) {
+		dev_err(&pdev->dev,
+			"PCI device still in an error state. Unable to load...\n");
+		return -EIO;
+	}
+
 	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
-- 
2.7.4
