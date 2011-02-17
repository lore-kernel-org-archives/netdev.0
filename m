From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 1/4] e1000e: check down flag in tasks
Date: Thu, 17 Feb 2011 01:35:07 -0800
Message-ID: <1297935310-23510-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59899 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179Ab1BQJfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 04:35:16 -0500
In-Reply-To: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This change is part of a fix to avoid any tasks running while the driver is
exiting and deinitializing resources.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3065870..174633c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -937,6 +937,9 @@ static void e1000_print_hw_hang(struct work_struct *work)
 	u16 phy_status, phy_1000t_status, phy_ext_status;
 	u16 pci_status;
 
+	if (test_bit(__E1000_DOWN, &adapter->state))
+		return;
+
 	e1e_rphy(hw, PHY_STATUS, &phy_status);
 	e1e_rphy(hw, PHY_1000T_STATUS, &phy_1000t_status);
 	e1e_rphy(hw, PHY_EXT_STATUS, &phy_ext_status);
@@ -1506,6 +1509,9 @@ static void e1000e_downshift_workaround(struct work_struct *work)
 	struct e1000_adapter *adapter = container_of(work,
 					struct e1000_adapter, downshift_task);
 
+	if (test_bit(__E1000_DOWN, &adapter->state))
+		return;
+
 	e1000e_gig_downshift_workaround_ich8lan(&adapter->hw);
 }
 
@@ -3765,6 +3771,10 @@ static void e1000e_update_phy_task(struct work_struct *work)
 {
 	struct e1000_adapter *adapter = container_of(work,
 					struct e1000_adapter, update_phy_task);
+
+	if (test_bit(__E1000_DOWN, &adapter->state))
+		return;
+
 	e1000_get_phy_info(&adapter->hw);
 }
 
@@ -3775,6 +3785,10 @@ static void e1000e_update_phy_task(struct work_struct *work)
 static void e1000_update_phy_info(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+
+	if (test_bit(__E1000_DOWN, &adapter->state))
+		return;
+
 	schedule_work(&adapter->update_phy_task);
 }
 
@@ -4149,6 +4163,9 @@ static void e1000_watchdog_task(struct work_struct *work)
 	u32 link, tctl;
 	int tx_pending = 0;
 
+	if (test_bit(__E1000_DOWN, &adapter->state))
+		return;
+
 	link = e1000e_has_link(adapter);
 	if ((netif_carrier_ok(netdev)) && link) {
 		/* Cancel scheduled suspend requests. */
@@ -4887,6 +4904,10 @@ static void e1000_reset_task(struct work_struct *work)
 	struct e1000_adapter *adapter;
 	adapter = container_of(work, struct e1000_adapter, reset_task);
 
+	/* don't run the task if already down */
+	if (test_bit(__E1000_DOWN, &adapter->state))
+		return;
+
 	if (!((adapter->flags & FLAG_RX_NEEDS_RESTART) &&
 	      (adapter->flags & FLAG_RX_RESTART_NOW))) {
 		e1000e_dump(adapter);
-- 
1.7.4

