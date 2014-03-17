From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] ixgbevf: Indicate removal state explicitly
Date: Mon, 17 Mar 2014 05:45:15 -0700
Message-ID: <1395060316-16897-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16178 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933073AbaCQMp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:45:26 -0400
In-Reply-To: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Add a bit, __IXGBEVF_REMOVING, to indicate that the module is being
removed. The __IXGBEVF_DOWN bit had been overloaded for this purpose,
but that leads to trouble. A few places now check both __IXGBEVF_DOWN
and __IXGBEVF_REMOVING.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  5 +++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 14 +++++++++-----
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 5482932..08fb88a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -412,7 +412,8 @@ struct ixgbevf_adapter {
 enum ixbgevf_state_t {
 	__IXGBEVF_TESTING,
 	__IXGBEVF_RESETTING,
-	__IXGBEVF_DOWN
+	__IXGBEVF_DOWN,
+	__IXGBEVF_REMOVING,
 };
 
 struct ixgbevf_cb {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 8581079..940d924 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -608,7 +608,8 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	napi_complete(napi);
 	if (adapter->rx_itr_setting & 1)
 		ixgbevf_set_itr(q_vector);
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
+	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
+	    !test_bit(__IXGBEVF_REMOVING, &adapter->state))
 		ixgbevf_irq_enable_queues(adapter,
 					  1 << q_vector->v_idx);
 
@@ -833,7 +834,8 @@ static irqreturn_t ixgbevf_msix_other(int irq, void *data)
 
 	hw->mac.get_link_status = 1;
 
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
+	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
+	    !test_bit(__IXGBEVF_REMOVING, &adapter->state))
 		mod_timer(&adapter->watchdog_timer, jiffies);
 
 	IXGBE_WRITE_REG(hw, IXGBE_VTEIMS, adapter->eims_other);
@@ -2329,6 +2331,7 @@ static void ixgbevf_reset_task(struct work_struct *work)
 
 	/* If we're already down or resetting, just bail */
 	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
+	    test_bit(__IXGBEVF_REMOVING, &adapter->state) ||
 	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
 		return;
 
@@ -2413,7 +2416,8 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 
 pf_has_reset:
 	/* Reset the timer */
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
+	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
+	    !test_bit(__IXGBEVF_REMOVING, &adapter->state))
 		mod_timer(&adapter->watchdog_timer,
 			  round_jiffies(jiffies + (2 * HZ)));
 
@@ -3563,7 +3567,7 @@ static void ixgbevf_remove(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
-	set_bit(__IXGBEVF_DOWN, &adapter->state);
+	set_bit(__IXGBEVF_REMOVING, &adapter->state);
 
 	del_timer_sync(&adapter->watchdog_timer);
 
-- 
1.8.3.1
