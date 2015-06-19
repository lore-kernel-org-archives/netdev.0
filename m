From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [net-next] vmxnet3: Register shutdown handler for device (fwd)
Date: Fri, 19 Jun 2015 13:36:02 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1506191335180.12845@promg-1n-a-dhcp378.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:45742 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751799AbbFSUfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 16:35:13 -0400
Received: from sc9-mailhost1.vmware.com (sc9-mailhost1.vmware.com [10.113.161.71])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id 361F7283F6
	for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 13:35:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Implement a handler for pci shutdown so that the driver has an
opportunity to make sure that device is quiesced before the PCI
switches to legacy IRQs. This way the possibility of
"screaming interrupt" is avoided.

Acked-by: Shrikrishna Khare <skhare@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 61c0840..bb35210 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3184,6 +3184,32 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
+static void vmxnet3_shutdown_device(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	unsigned long flags;
+
+	/* Reset_work may be in the middle of resetting the device, wait for its
+	 * completion.
+	 */
+	while (test_and_set_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state))
+		msleep(1);
+
+	if (test_and_set_bit(VMXNET3_STATE_BIT_QUIESCED,
+			     &adapter->state)) {
+		clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
+		return;
+	}
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
+	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+			       VMXNET3_CMD_QUIESCE_DEV);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+	vmxnet3_disable_all_intrs(adapter);
+
+	clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
+}
+
 
 #ifdef CONFIG_PM
 
@@ -3360,6 +3386,7 @@ static struct pci_driver vmxnet3_driver = {
 	.id_table	= vmxnet3_pciid_table,
 	.probe		= vmxnet3_probe_device,
 	.remove		= vmxnet3_remove_device,
+	.shutdown	= vmxnet3_shutdown_device,
 #ifdef CONFIG_PM
 	.driver.pm	= &vmxnet3_pm_ops,
 #endif
