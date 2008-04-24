From: wendy xiong <wendyx@us.ibm.com>
Subject: Re: [ PATCH 1/1 2.6.25-rc9] bnx2: Add EEH support in bnx2 driver -
	Resending
Date: Thu, 24 Apr 2008 10:37:11 -0500
Message-ID: <1209051431.7339.35.camel@wendyx.austin.ibm.com>
References: <1208812834.24768.40.camel@wendyx.austin.ibm.com>
	 <1208823296.16633.230.camel@dell>
	 <1208893442.7339.17.camel@wendyx.austin.ibm.com>
	 <1208900791.13806.5.camel@dell>
	 <1208983008.7339.24.camel@wendyx.austin.ibm.com>
	 <1208996602.6194.26.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	David Miller <davem@davemloft.net>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:35706 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188AbYDXPhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 11:37:25 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3OFdTra024200
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 11:39:29 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3OFbMQY456242
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 11:37:22 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3OFbMfb020252
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 11:37:22 -0400
In-Reply-To: <1208996602.6194.26.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

Thanks!

Wendy

diff -Nuarp linux-2.6.25-rc9.orig/drivers/net/bnx2.c linux-2.6.25-rc9.eeh/drivers/net/bnx2.c
--- linux-2.6.25-rc9.orig/drivers/net/bnx2.c    2008-04-18 22:12:53.000000000 -0500
+++ linux-2.6.25-rc9.eeh/drivers/net/bnx2.c     2008-04-24 10:30:58.000000000 -0500
@@ -7108,6 +7108,7 @@ bnx2_init_board(struct pci_dev *pdev, st
        }

        pci_set_master(pdev);
+       pci_save_state(pdev);

        bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
        if (bp->pm_cap == 0) {
@@ -7617,6 +7618,92 @@ bnx2_resume(struct pci_dev *pdev)
        return 0;
 }

+/**
+ * bnx2_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t bnx2_io_error_detected(struct pci_dev *pdev,
+                                               pci_channel_state_t state)
+{
+       struct net_device *dev = pci_get_drvdata(pdev);
+       struct bnx2 *bp = netdev_priv(dev);
+
+       rtnl_lock();
+       netif_device_detach(dev);
+
+       if (netif_running(dev)) {
+               bnx2_netif_stop(bp);
+               del_timer_sync(&bp->timer);
+               bnx2_reset_nic(bp, BNX2_DRV_MSG_CODE_RESET);
+       }
+
+       pci_disable_device(pdev);
+       rtnl_unlock();
+
+       /* Request a slot slot reset. */
+       return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * bnx2_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot.
+ */
+static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
+{
+       struct net_device *dev = pci_get_drvdata(pdev);
+       struct bnx2 *bp = netdev_priv(dev);
+
+       rtnl_lock();
+       if (pci_enable_device(pdev)) {
+               dev_err(&pdev->dev,
+                       "Cannot re-enable PCI device after reset.\n");
+               rtnl_unlock();
+               return PCI_ERS_RESULT_DISCONNECT;
+       }
+       pci_set_master(pdev);
+       pci_restore_state(pdev);
+
+       if (netif_running(dev)) {
+               bnx2_set_power_state(bp, PCI_D0);
+               bnx2_init_nic(bp);
+       }
+
+       rtnl_unlock();
+       return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * bnx2_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation.
+ */
+static void bnx2_io_resume(struct pci_dev *pdev)
+{
+       struct net_device *dev = pci_get_drvdata(pdev);
+       struct bnx2 *bp = netdev_priv(dev);
+
+       rtnl_lock();
+       if (netif_running(dev))
+               bnx2_netif_start(bp);
+
+       netif_device_attach(dev);
+       rtnl_unlock();
+}
+
+static struct pci_error_handlers bnx2_err_handler = {
+       .error_detected = bnx2_io_error_detected,
+       .slot_reset = bnx2_io_slot_reset,
+       .resume = bnx2_io_resume,
+};
+
 static struct pci_driver bnx2_pci_driver = {
        .name           = DRV_MODULE_NAME,
        .id_table       = bnx2_pci_tbl,
@@ -7624,6 +7711,7 @@ static struct pci_driver bnx2_pci_driver
        .remove         = __devexit_p(bnx2_remove_one),
        .suspend        = bnx2_suspend,
        .resume         = bnx2_resume,
+       .err_handler    = &bnx2_err_handler,
 };

 static int __init bnx2_init(void)


