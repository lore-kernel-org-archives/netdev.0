From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] fm10k: avoid needless delay when loading driver
Date: Mon,  2 Oct 2017 08:42:31 -0700
Message-ID: <20171002154236.84043-9-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24370 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751085AbdJBPm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:42:59 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When we load the driver, we set the last_reset to be in the future,
which delays the initial driver reset. Additionally, the service task
isn't scheduled to run automatically until the timer runs out. This
causes a needless delay of the first reset to begin talking to the
switch manager.

We can avoid this by simply not setting last_reset and immediately
scheduling the service task while in probe. This allows the device to
wake up faster, and avoids this delay.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9212b3fa3b62..6c2c4bffaedf 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1800,9 +1800,6 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
 	}
 
-	/* delay any future reset requests */
-	interface->last_reset = jiffies + (10 * HZ);
-
 	/* reset and initialize the hardware so it is in a known state */
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
@@ -2079,8 +2076,9 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* enable SR-IOV after registering netdev to enforce PF/VF ordering */
 	fm10k_iov_configure(pdev, 0);
 
-	/* clear the service task disable bit to allow service task to start */
+	/* clear the service task disable bit and kick off service task */
 	clear_bit(__FM10K_SERVICE_DISABLE, interface->state);
+	fm10k_service_event_schedule(interface);
 
 	return 0;
 
-- 
2.14.2
