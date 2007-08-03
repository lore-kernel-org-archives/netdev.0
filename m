From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2]: Fix suspend/resume problem.
Date: Fri, 03 Aug 2007 15:32:34 -0700
Message-ID: <1186180354.18322.79.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4734 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763019AbXHCVi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 17:38:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix suspend/resume problem.

The device would not resume properly if it was shutdown before the system
was suspended.  In such scenario where the netif_running state is 0,
bnx2_suspend() would not save the PCI state and so the memory enable bit
and bus master enable bit would be lost.

We fix this by always saving and restoring the PCI state in
bnx2_suspend() and bnx2_resume() regardless of netif_running() state.

Update version to 1.6.4.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d53dfc5..24e7f9a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -54,8 +54,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.6.3"
-#define DRV_MODULE_RELDATE	"July 16, 2007"
+#define DRV_MODULE_VERSION	"1.6.4"
+#define DRV_MODULE_RELDATE	"August 3, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -6937,6 +6937,11 @@ bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct bnx2 *bp = netdev_priv(dev);
 	u32 reset_code;
 
+	/* PCI register 4 needs to be saved whether netif_running() or not.
+	 * MSI address and data need to be saved if using MSI and
+	 * netif_running().
+	 */
+	pci_save_state(pdev);
 	if (!netif_running(dev))
 		return 0;
 
@@ -6952,7 +6957,6 @@ bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 		reset_code = BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL;
 	bnx2_reset_chip(bp, reset_code);
 	bnx2_free_skbs(bp);
-	pci_save_state(pdev);
 	bnx2_set_power_state(bp, pci_choose_state(pdev, state));
 	return 0;
 }
@@ -6963,10 +6967,10 @@ bnx2_resume(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2 *bp = netdev_priv(dev);
 
+	pci_restore_state(pdev);
 	if (!netif_running(dev))
 		return 0;
 
-	pci_restore_state(pdev);
 	bnx2_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 	bnx2_init_nic(bp);


