From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next] Driver: Vmxnet3: Reinitialize vmxnet3 backend on wakeup from hibernate
Date: Fri,  9 Jan 2015 15:19:14 -0800
Message-ID: <1420845554-491-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Srividya Murali <smurali@vmware.com>
To: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Failing to reinitialize on wakeup results in loss of network connectivity for
vmxnet3 interface.

Signed-off-by: Srividya Murali <smurali@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Reviewed-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   44 +++++++++++++++++++++----------------
 drivers/net/vmxnet3/vmxnet3_int.h |    4 +-
 2 files changed, 27 insertions(+), 21 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7af1f5c..3143981 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3290,27 +3290,15 @@ skip_arp:
 static int
 vmxnet3_resume(struct device *device)
 {
-	int err, i = 0;
+	int err;
 	unsigned long flags;
 	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
-	struct Vmxnet3_PMConf *pmConf;
 
 	if (!netif_running(netdev))
 		return 0;
 
-	/* Destroy wake-up filters. */
-	pmConf = adapter->pm_conf;
-	memset(pmConf, 0, sizeof(*pmConf));
-
-	adapter->shared->devRead.pmConfDesc.confVer = cpu_to_le32(1);
-	adapter->shared->devRead.pmConfDesc.confLen = cpu_to_le32(sizeof(
-								  *pmConf));
-	adapter->shared->devRead.pmConfDesc.confPA =
-		cpu_to_le64(adapter->pm_conf_pa);
-
-	netif_device_attach(netdev);
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	err = pci_enable_device_mem(pdev);
@@ -3319,15 +3307,31 @@ vmxnet3_resume(struct device *device)
 
 	pci_enable_wake(pdev, PCI_D0, 0);
 
+	vmxnet3_alloc_intr_resources(adapter);
+
+	/* During hibernate and suspend, device has to be reinitialized as the
+	 * device state need not be preserved.
+	 */
+
+	/* Need not check adapter state as other reset tasks cannot run during
+	 * device resume.
+	 */
 	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
-			       VMXNET3_CMD_UPDATE_PMCFG);
+			       VMXNET3_CMD_QUIESCE_DEV);
 	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
-	vmxnet3_alloc_intr_resources(adapter);
-	vmxnet3_request_irqs(adapter);
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		napi_enable(&adapter->rx_queue[i].napi);
-	vmxnet3_enable_all_intrs(adapter);
+	vmxnet3_tq_cleanup_all(adapter);
+	vmxnet3_rq_cleanup_all(adapter);
+
+	vmxnet3_reset_dev(adapter);
+	err = vmxnet3_activate_dev(adapter);
+	if (err != 0) {
+		netdev_err(netdev,
+			   "failed to re-activate on resume, error: %d", err);
+		vmxnet3_force_close(adapter);
+		return err;
+	}
+	netif_device_attach(netdev);
 
 	return 0;
 }
@@ -3335,6 +3339,8 @@ vmxnet3_resume(struct device *device)
 static const struct dev_pm_ops vmxnet3_pm_ops = {
 	.suspend = vmxnet3_suspend,
 	.resume = vmxnet3_resume,
+	.freeze = vmxnet3_suspend,
+	.restore = vmxnet3_resume,
 };
 #endif
 
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 048f020..6297d9f 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.3.1.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.3.2.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01030100
+#define VMXNET3_DRIVER_VERSION_NUM      0x01030200
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
-- 
1.7.4.1
