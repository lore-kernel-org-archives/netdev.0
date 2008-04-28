From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [PATCH 1/1 2.6.25-rc9] bnx2x: Add EEH support in bnx2x driver
	- 10G pci-express adapter - Re-submit with a minor fix
Date: Mon, 28 Apr 2008 16:52:05 -0500
Message-ID: <1209419525.8085.10.camel@wendyx.austin.ibm.com>
References: <1208983414.7339.31.camel@wendyx.austin.ibm.com>
	 <1209287558.4928.18.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org
To: Eliezer Tamir <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:55297 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964929AbYD1VwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 17:52:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3SLq6Se009293
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 17:52:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3SLq60J279932
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 17:52:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3SLq624026752
	for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 17:52:06 -0400
In-Reply-To: <1209287558.4928.18.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eliezer,

Thanks for your comments!

Re-sending with a minor fix.

Thanks,
Wendy

diff -Nuarp 2.6.25-rc9/drivers/net/bnx2x.c 2.6.25-rc9.bnx2x/drivers/net/bnx2x.c
--- 2.6.25-rc9/drivers/net/bnx2x.c      2008-04-23 10:38:03.000000000 -0500
+++ 2.6.25-rc9.bnx2x/drivers/net/bnx2x.c        2008-04-28 15:32:55.045159872 -0500
@@ -9645,6 +9645,7 @@ static int __devinit bnx2x_init_board(st
        }

        pci_set_master(pdev);
+       pci_save_state(pdev);

        bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
        if (bp->pm_cap == 0) {
@@ -9963,6 +9964,86 @@ static int bnx2x_resume(struct pci_dev *
        return 0;
 }

+/**
+ * bnx2x_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t bnx2x_io_error_detected(struct pci_dev *pdev,
+                                       pci_channel_state_t state)
+{
+       struct net_device *dev = pci_get_drvdata(pdev);
+       struct bnx2x *bp = netdev_priv(dev);
+
+       rtnl_lock();
+       netif_device_detach(dev);
+
+       if (netif_running(dev))
+               bnx2x_nic_unload(bp, 0);
+
+       pci_disable_device(pdev);
+       rtnl_unlock();
+
+       /* Request a slot slot reset. */
+       return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * bnx2x_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ */
+static pci_ers_result_t bnx2x_io_slot_reset(struct pci_dev *pdev)
+{
+       struct net_device *dev = pci_get_drvdata(pdev);
+       struct bnx2x *bp = netdev_priv(dev);
+
+       rtnl_lock();
+       if (pci_enable_device(pdev)) {
+               dev_err(&pdev->dev,
+                       "Cannot re-enable PCI device after reset.\n");
+               rtnl_unlock();
+               return PCI_ERS_RESULT_DISCONNECT;
+       }
+
+       pci_set_master(pdev);
+       pci_restore_state(pdev);
+       rtnl_unlock();
+
+       return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * bnx2x_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation.
+ */
+static void bnx2x_io_resume(struct pci_dev *pdev)
+{
+       struct net_device *dev = pci_get_drvdata(pdev);
+       struct bnx2x *bp = netdev_priv(dev);
+
+       rtnl_lock();
+
+       if (netif_running(dev))
+               bnx2x_nic_load(bp, 0);
+       netif_device_attach(dev);
+
+       rtnl_unlock();
+}
+
+static struct pci_error_handlers bnx2x_err_handler = {
+       .error_detected = bnx2x_io_error_detected,
+       .slot_reset = bnx2x_io_slot_reset,
+       .resume = bnx2x_io_resume,
+};
+
 static struct pci_driver bnx2x_pci_driver = {
        .name       = DRV_MODULE_NAME,
        .id_table   = bnx2x_pci_tbl,
@@ -9970,6 +10051,7 @@ static struct pci_driver bnx2x_pci_drive
        .remove     = __devexit_p(bnx2x_remove_one),
        .suspend    = bnx2x_suspend,
        .resume     = bnx2x_resume,
+       .err_handler= &bnx2x_err_handler,
 };

 static int __init bnx2x_init(void)


