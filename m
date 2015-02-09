From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40evf: reset on module unload
Date: Mon,  9 Feb 2015 02:43:52 -0800
Message-ID: <1423478641-3138-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35313 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760276AbbBIKoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:05 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When the module is being unloaded, don't wait for the PF to politely
handle all of our admin queue requests, as that might take forever with
a lot of VFs enabled. Instead, just stop everything and request a VF
reset.

When the original shutdown code was written, VF resets were unreliable,
so we avoided them. But with production hardware and firmware, and the
1.x PF driver, this is no longer the case.

This fixes a potential multi-minute delay on driver unload, VF disable,
or system shutdown.

Change-ID: Ib43d6d860ef6b9b8f26e8dce0615a0302608c7d9
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f946aac..cd71c47 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2423,7 +2423,6 @@ static void i40evf_remove(struct pci_dev *pdev)
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40evf_mac_filter *f, *ftmp;
 	struct i40e_hw *hw = &adapter->hw;
-	int count = 50;
 
 	cancel_delayed_work_sync(&adapter->init_task);
 	cancel_work_sync(&adapter->reset_task);
@@ -2432,12 +2431,18 @@ static void i40evf_remove(struct pci_dev *pdev)
 		unregister_netdev(netdev);
 		adapter->netdev_registered = false;
 	}
-	while (count-- && adapter->aq_required)
-		msleep(50);
 
-	if (count < 0)
-		dev_err(&pdev->dev, "Timed out waiting for PF driver.\n");
+	/* Shut down all the garbage mashers on the detention level */
 	adapter->state = __I40EVF_REMOVE;
+	adapter->aq_required = 0;
+	adapter->aq_pending = 0;
+	i40evf_request_reset(adapter);
+	msleep(20);
+	/* If the FW isn't responding, kick it once, but only once. */
+	if (!i40evf_asq_done(hw)) {
+		i40evf_request_reset(adapter);
+		msleep(20);
+	}
 
 	if (adapter->msix_entries) {
 		i40evf_misc_irq_disable(adapter);
-- 
1.9.3
