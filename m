From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 1/2] net/cxgb4: Avoid disabling PCI device for towice
Date: Thu, 23 Jan 2014 12:27:34 +0800
Message-ID: <1390451256-11486-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: dm@chelsio.com, ben@decadent.org.uk, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:32832 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbaAWE1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 23:27:45 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 22 Jan 2014 21:27:44 -0700
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E8FCA6E8047
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 23:27:38 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0N4RgiR6226234
	for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 04:27:42 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0N4Rgeh027868
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 23:27:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have EEH error happens to the adapter and we have to remove
it from the system for some reasons (e.g. more than 5 EEH errors
detected from the device in last hour), the adapter will be disabled
for towice separately by eeh_err_detected() and remove_one(), which
will incur following unexpected backtrace. The patch tries to avoid
it.

WARNING: at drivers/pci/pci.c:1431
CPU: 12 PID: 121 Comm: eehd Not tainted 3.13.0-rc7+ #1
task: c0000001823a3780 ti: c00000018240c000 task.ti: c00000018240c000
NIP: c0000000003c1e40 LR: c0000000003c1e3c CTR: 0000000001764c5c
REGS: c00000018240f470 TRAP: 0700   Not tainted  (3.13.0-rc7+)
MSR: 8000000000029032 <SF,EE,ME,IR,DR,RI>  CR: 28000024  XER: 00000004
CFAR: c000000000706528 SOFTE: 1
GPR00: c0000000003c1e3c c00000018240f6f0 c0000000010fe1f8 0000000000000035
GPR04: 0000000000000000 0000000000000000 00000000003ae509 0000000000000000
GPR08: 000000000000346f 0000000000000000 0000000000000000 0000000000003fef
GPR12: 0000000028000022 c00000000ec93000 c0000000000c11b0 c000000184ac3e40
GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
GPR20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
GPR24: 0000000000000000 c0000000009398d8 c00000000101f9c0 c0000001860ae000
GPR28: c000000182ba0000 00000000000001f0 c0000001860ae6f8 c0000001860ae000
NIP [c0000000003c1e40] .pci_disable_device+0xd0/0xf0
LR [c0000000003c1e3c] .pci_disable_device+0xcc/0xf0
Call Trace:
[c0000000003c1e3c] .pci_disable_device+0xcc/0xf0 (unreliable)
[d0000000073881c4] .remove_one+0x174/0x320 [cxgb4]
[c0000000003c57e0] .pci_device_remove+0x60/0x100
[c00000000046396c] .__device_release_driver+0x9c/0x120
[c000000000463a20] .device_release_driver+0x30/0x60
[c0000000003bcdb4] .pci_stop_bus_device+0x94/0xd0
[c0000000003bcf48] .pci_stop_and_remove_bus_device+0x18/0x30
[c00000000003f548] .pcibios_remove_pci_devices+0xa8/0x140
[c000000000035c00] .eeh_handle_normal_event+0xa0/0x3c0
[c000000000035f50] .eeh_handle_event+0x30/0x2b0
[c0000000000362c4] .eeh_event_handler+0xf4/0x1b0
[c0000000000c12b8] .kthread+0x108/0x130
[c00000000000a168] .ret_from_kernel_thread+0x5c/0x74

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    5 +++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   23 ++++++++++++++++++-----
 2 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 56e0415..b4ca0a1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -387,8 +387,9 @@ struct work_struct;
 
 enum {                                 /* adapter flags */
 	FULL_INIT_DONE     = (1 << 0),
-	USING_MSI          = (1 << 1),
-	USING_MSIX         = (1 << 2),
+	DEV_ENABLED        = (1 << 1),
+	USING_MSI          = (1 << 2),
+	USING_MSIX         = (1 << 3),
 	FW_OK              = (1 << 4),
 	RSS_TNLALLLOOKUP   = (1 << 5),
 	USING_SOFT_PARAMS  = (1 << 6),
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index fff02ed..c8eafbf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5505,7 +5505,10 @@ static pci_ers_result_t eeh_err_detected(struct pci_dev *pdev,
 	if (adap->flags & FULL_INIT_DONE)
 		cxgb_down(adap);
 	rtnl_unlock();
-	pci_disable_device(pdev);
+	if ((adap->flags & DEV_ENABLED)) {
+		pci_disable_device(pdev);
+		adap->flags &= ~DEV_ENABLED;
+	}
 out:	return state == pci_channel_io_perm_failure ?
 		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
 }
@@ -5522,9 +5525,13 @@ static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_RECOVERED;
 	}
 
-	if (pci_enable_device(pdev)) {
-		dev_err(&pdev->dev, "cannot reenable PCI device after reset\n");
-		return PCI_ERS_RESULT_DISCONNECT;
+	if (!(adap->flags & DEV_ENABLED)) {
+		if (pci_enable_device(pdev)) {
+			dev_err(&pdev->dev, "Cannot reenable PCI "
+					    "device after reset\n");
+			return PCI_ERS_RESULT_DISCONNECT;
+		}
+		adap->flags |= DEV_ENABLED;
 	}
 
 	pci_set_master(pdev);
@@ -5910,6 +5917,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_disable_device;
 	}
 
+	/* PCI device has been enabled */
+	adapter->flags |= DEV_ENABLED;
+
 	adapter->regs = pci_ioremap_bar(pdev, 0);
 	if (!adapter->regs) {
 		dev_err(&pdev->dev, "cannot map device registers\n");
@@ -6145,7 +6155,10 @@ static void remove_one(struct pci_dev *pdev)
 			iounmap(adapter->bar2);
 		kfree(adapter);
 		pci_disable_pcie_error_reporting(pdev);
-		pci_disable_device(pdev);
+		if ((adapter->flags & DEV_ENABLED)) {
+			pci_disable_device(pdev);
+			adapter->flags &= ~DEV_ENABLED;
+		}
 		pci_release_regions(pdev);
 	} else
 		pci_release_regions(pdev);
-- 
1.7.10.4
