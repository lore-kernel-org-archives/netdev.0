From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 15/27] e1000e: fix double initialization in blink path
Date: Fri, 10 Dec 2010 02:03:22 -0800
Message-ID: <1291975414-30487-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Holger Eitzenberger <holger@eitzenberger.org>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:44991 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983Ab0LJKD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 05:03:57 -0500
To: davem@davemloft.net
In-Reply-To: <1291975414-30487-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>

The kernel goes BUG() at the time 'ethtool -p eth0 3' comes
back, which is due to adapter->led_blink_task initialized
several times.  At the time it is still running this results
in a corrupted task_list of the associated workqueue.

The fix is to move the workqueue initialization to the
probe function instead.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
Reviewed-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ethtool.c |    3 +--
 drivers/net/e1000e/netdev.c  |    1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index fdc67fe..3d9366f 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -482,6 +482,7 @@ extern const char e1000e_driver_version[];
 
 extern void e1000e_check_options(struct e1000_adapter *adapter);
 extern void e1000e_set_ethtool_ops(struct net_device *netdev);
+extern void e1000e_led_blink_task(struct work_struct *work);
 
 extern int e1000e_up(struct e1000_adapter *adapter);
 extern void e1000e_down(struct e1000_adapter *adapter);
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8984d16..26d4f3b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1860,7 +1860,7 @@ static int e1000_set_wol(struct net_device *netdev,
 /* bit defines for adapter->led_status */
 #define E1000_LED_ON		0
 
-static void e1000e_led_blink_task(struct work_struct *work)
+void e1000e_led_blink_task(struct work_struct *work)
 {
 	struct e1000_adapter *adapter = container_of(work,
 	                                struct e1000_adapter, led_blink_task);
@@ -1892,7 +1892,6 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 	    (hw->mac.type == e1000_pch2lan) ||
 	    (hw->mac.type == e1000_82583) ||
 	    (hw->mac.type == e1000_82574)) {
-		INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function =
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0adcb79..f8efbbb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5903,6 +5903,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->downshift_task, e1000e_downshift_workaround);
 	INIT_WORK(&adapter->update_phy_task, e1000e_update_phy_task);
 	INIT_WORK(&adapter->print_hang_task, e1000_print_hw_hang);
+	INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
-- 
1.7.3.2

