From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH v4 2/2] igb: remove sysfs entry that was used to set the
	number of vfs
Date: Tue, 07 Apr 2009 17:37:52 -0700
Message-ID: <20090408003752.2448.65978.stgit@localhost.localdomain>
References: <20090408003556.2448.26129.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:54831
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758825AbZDHJGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 05:06:14 -0400
In-Reply-To: <20090408003556.2448.26129.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes the sysfs entry num_vfs which was added to support
enabling pci virtual functions for 82576.

To prevent VFs from loading automatically a module parameter "max_vfs" was
added so that the number of VFs per PF can be limited.  This is especially
useful when 4 or more 82576 ports are on the system because otherwise to
load all VFs would result in 8 interface per physical port.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |  159 +++++++++++++++-----------------------------
 1 files changed, 54 insertions(+), 105 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6b0697c..db7274e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -152,14 +152,13 @@ static struct notifier_block dca_notifier = {
 /* for netdump / net console */
 static void igb_netpoll(struct net_device *);
 #endif
-
 #ifdef CONFIG_PCI_IOV
-static ssize_t igb_set_num_vfs(struct device *, struct device_attribute *,
-                               const char *, size_t);
-static ssize_t igb_show_num_vfs(struct device *, struct device_attribute *,
-                               char *);
-DEVICE_ATTR(num_vfs, S_IRUGO | S_IWUSR, igb_show_num_vfs, igb_set_num_vfs);
-#endif
+static unsigned int max_vfs = 0;
+module_param(max_vfs, uint, 0);
+MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate "
+                 "per physical function");
+#endif /* CONFIG_PCI_IOV */
+
 static pci_ers_result_t igb_io_error_detected(struct pci_dev *,
 		     pci_channel_state_t);
 static pci_ers_result_t igb_io_slot_reset(struct pci_dev *);
@@ -671,6 +670,21 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 
 	/* If we can't do MSI-X, try MSI */
 msi_only:
+#ifdef CONFIG_PCI_IOV
+	/* disable SR-IOV for non MSI-X configurations */
+	if (adapter->vf_data) {
+		struct e1000_hw *hw = &adapter->hw;
+		/* disable iov and allow time for transactions to clear */
+		pci_disable_sriov(adapter->pdev);
+		msleep(500);
+
+		kfree(adapter->vf_data);
+		adapter->vf_data = NULL;
+		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
+		msleep(100);
+		dev_info(&adapter->pdev->dev, "IOV Disabled\n");
+	}
+#endif
 	adapter->num_rx_queues = 1;
 	adapter->num_tx_queues = 1;
 	if (!pci_enable_msi(adapter->pdev))
@@ -1238,6 +1252,39 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
+#ifdef CONFIG_PCI_IOV
+	/* since iov functionality isn't critical to base device function we
+	 * can accept failure.  If it fails we don't allow iov to be enabled */
+	if (hw->mac.type == e1000_82576) {
+		/* 82576 supports a maximum of 7 VFs in addition to the PF */
+		unsigned int num_vfs = (max_vfs > 7) ? 7 : max_vfs;
+		int i;
+		unsigned char mac_addr[ETH_ALEN];
+
+		if (num_vfs)
+			adapter->vf_data = kcalloc(num_vfs,
+						sizeof(struct vf_data_storage),
+						GFP_KERNEL);
+		if (!adapter->vf_data) {
+			dev_err(&pdev->dev, "Could not allocate VF private "
+				"data - IOV enable failed\n");
+		} else {
+			err = pci_enable_sriov(pdev, num_vfs);
+			if (!err) {
+				adapter->vfs_allocated_count = num_vfs;
+				dev_info(&pdev->dev, "%d vfs allocated\n", num_vfs);
+				for (i = 0; i < adapter->vfs_allocated_count; i++) {
+					random_ether_addr(mac_addr);
+					igb_set_vf_mac(adapter, i, mac_addr);
+				}
+			} else {
+				kfree(adapter->vf_data);
+				adapter->vf_data = NULL;
+			}
+		}
+	}
+
+#endif
 	/* setup the private structure */
 	err = igb_sw_init(adapter);
 	if (err)
@@ -1397,19 +1444,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-#ifdef CONFIG_PCI_IOV
-	/* since iov functionality isn't critical to base device function we
-	 * can accept failure.  If it fails we don't allow iov to be enabled */
-	if (hw->mac.type == e1000_82576) {
-		err = pci_enable_sriov(pdev, 0);
-		if (!err)
-			err = device_create_file(&netdev->dev,
-			                         &dev_attr_num_vfs);
-		if (err)
-			dev_err(&pdev->dev, "Failed to initialize IOV\n");
-	}
-
-#endif
 #ifdef CONFIG_IGB_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IGB_FLAG_DCA_ENABLED;
@@ -5422,89 +5456,4 @@ static void igb_vmm_control(struct igb_adapter *adapter)
 	igb_vmdq_set_replication_pf(hw, true);
 }
 
-#ifdef CONFIG_PCI_IOV
-static ssize_t igb_show_num_vfs(struct device *dev,
-                                struct device_attribute *attr, char *buf)
-{
-	struct igb_adapter *adapter = netdev_priv(to_net_dev(dev));
-
-	return sprintf(buf, "%d\n", adapter->vfs_allocated_count);
-}
-
-static ssize_t igb_set_num_vfs(struct device *dev,
-                               struct device_attribute *attr,
-                               const char *buf, size_t count)
-{
-	struct net_device *netdev = to_net_dev(dev);
-	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-	struct pci_dev *pdev = adapter->pdev;
-	unsigned int num_vfs, i;
-	unsigned char mac_addr[ETH_ALEN];
-	int err;
-
-	sscanf(buf, "%u", &num_vfs);
-
-	if (num_vfs > 7)
-		num_vfs = 7;
-
-	/* value unchanged do nothing */
-	if (num_vfs == adapter->vfs_allocated_count)
-		return count;
-
-	if (netdev->flags & IFF_UP)
-		igb_close(netdev);
-
-	igb_reset_interrupt_capability(adapter);
-	igb_free_queues(adapter);
-	adapter->tx_ring = NULL;
-	adapter->rx_ring = NULL;
-	adapter->vfs_allocated_count = 0;
-
-	/* reclaim resources allocated to VFs since we are changing count */
-	if (adapter->vf_data) {
-		/* disable iov and allow time for transactions to clear */
-		pci_disable_sriov(pdev);
-		msleep(500);
-
-		kfree(adapter->vf_data);
-		adapter->vf_data = NULL;
-		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
-		msleep(100);
-		dev_info(&pdev->dev, "IOV Disabled\n");
-	}
-
-	if (num_vfs) {
-		adapter->vf_data = kcalloc(num_vfs,
-		                           sizeof(struct vf_data_storage),
-		                           GFP_KERNEL);
-		if (!adapter->vf_data) {
-			dev_err(&pdev->dev, "Could not allocate VF private "
-				"data - IOV enable failed\n");
-		} else {
-			err = pci_enable_sriov(pdev, num_vfs);
-			if (!err) {
-				adapter->vfs_allocated_count = num_vfs;
-				dev_info(&pdev->dev, "%d vfs allocated\n", num_vfs);
-				for (i = 0; i < adapter->vfs_allocated_count; i++) {
-					random_ether_addr(mac_addr);
-					igb_set_vf_mac(adapter, i, mac_addr);
-				}
-			} else {
-				kfree(adapter->vf_data);
-				adapter->vf_data = NULL;
-			}
-		}
-	}
-
-	igb_set_interrupt_capability(adapter);
-	igb_alloc_queues(adapter);
-	igb_reset(adapter);
-
-	if (netdev->flags & IFF_UP)
-		igb_open(netdev);
-
-	return count;
-}
-#endif /* CONFIG_PCI_IOV */
 /* igb_main.c */

