From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 5/5] igb: this patch addes the sr-iov enablement
	option via num_vfs parameter
Date: Thu, 19 Feb 2009 20:40:30 -0800
Message-ID: <20090220044030.29650.14066.stgit@lost.foo-projects.org>
References: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Yu Zhao <yu.zhao@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758716AbZBTElY@vger.kernel.org>
In-Reply-To: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This code adds a module parameter called num_vfs which defines if the
driver should attempt to use sr-iov and if so how many VFs should be
enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Yu Zhao <yu.zhao@intel.com>
CC: LKML <linux-kernel@vger.kernel.org>
---

 drivers/net/igb/igb_main.c |  125 ++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 120 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f48f6d4..91a29ea 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -146,12 +146,18 @@ static struct notifier_block dca_notifier = {
 	.priority	= 0
 };
 #endif
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
 static void igb_netpoll(struct net_device *);
 #endif
 
+#ifdef CONFIG_PCI_IOV
+static ssize_t igb_set_num_vfs(struct device *, struct device_attribute *,
+                               const char *, size_t);
+static ssize_t igb_show_num_vfs(struct device *, struct device_attribute *,
+                               char *);
+DEVICE_ATTR(num_vfs, S_IRUGO | S_IWUSR, igb_show_num_vfs, igb_set_num_vfs);
+#endif
 static pci_ers_result_t igb_io_error_detected(struct pci_dev *,
 		     pci_channel_state_t);
 static pci_ers_result_t igb_io_slot_reset(struct pci_dev *);
@@ -588,9 +594,6 @@ static int igb_request_msix(struct igb_adapter *adapter)
 			goto out;
 		ring->itr_register = E1000_EITR(0) + (vector << 2);
 		ring->itr_val = adapter->itr;
-		/* overwrite the poll routine for MSIX, we've already done
-		 * netif_napi_add */
-		ring->napi.poll = &igb_clean_rx_ring_msix;
 		vector++;
 	}
 
@@ -1392,6 +1395,19 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
+#ifdef CONFIG_PCI_IOV
+	/* since iov functionality isn't critical to base device function we
+	 * can accept failure.  If it fails we don't allow iov to be enabled */
+	if (hw->mac.type == e1000_82576) {
+		err = pci_enable_sriov(pdev, 0);
+		if (!err)
+			err = device_create_file(&netdev->dev,
+			                         &dev_attr_num_vfs);
+		if (err)
+			dev_err(&pdev->dev, "Failed to initialize IOV\n");
+	}
+
+#endif
 #ifdef CONFIG_IGB_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IGB_FLAG_DCA_ENABLED;
@@ -1547,6 +1563,20 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	igb_free_queues(adapter);
 
+#ifdef CONFIG_PCI_IOV
+	/* reclaim resources allocated to VFs */
+	if (adapter->vf_data) {
+		/* disable iov and allow time for transactions to clear */
+		pci_disable_sriov(pdev);
+		msleep(500);
+
+		kfree(adapter->vf_data);
+		adapter->vf_data = NULL;
+		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
+		msleep(100);
+		dev_info(&pdev->dev, "IOV Disabled\n");
+	}
+#endif
 	iounmap(hw->hw_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
@@ -5341,7 +5371,7 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
 
 	igb_rar_set(hw, mac_addr, rar_entry);
 
-	memcpy(adapter->vf_data[vf].vf_mac_addresses, mac_addr, 6);
+	memcpy(adapter->vf_data[vf].vf_mac_addresses, mac_addr, ETH_ALEN);
 
 	igb_set_rah_pool(hw, vf, rar_entry);
 
@@ -5366,4 +5396,89 @@ static void igb_vmm_control(struct igb_adapter *adapter)
 	igb_vmdq_set_replication_pf(hw, true);
 }
 
+#ifdef CONFIG_PCI_IOV
+static ssize_t igb_show_num_vfs(struct device *dev,
+                                struct device_attribute *attr, char *buf)
+{
+	struct igb_adapter *adapter = netdev_priv(to_net_dev(dev));
+
+	return sprintf(buf, "%d\n", adapter->vfs_allocated_count);
+}
+
+static ssize_t igb_set_num_vfs(struct device *dev,
+                               struct device_attribute *attr,
+                               const char *buf, size_t count)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned int num_vfs, i;
+	unsigned char mac_addr[ETH_ALEN];
+	int err;
+
+	sscanf(buf, "%u", &num_vfs);
+
+	if (num_vfs > 7)
+		num_vfs = 7;
+
+	/* value unchanged do nothing */
+	if (num_vfs == adapter->vfs_allocated_count)
+		return count;
+
+	if (netdev->flags & IFF_UP)
+		igb_close(netdev);
+
+	igb_reset_interrupt_capability(adapter);
+	igb_free_queues(adapter);
+	adapter->tx_ring = NULL;
+	adapter->rx_ring = NULL;
+	adapter->vfs_allocated_count = 0;
+
+	/* reclaim resources allocated to VFs since we are changing count */
+	if (adapter->vf_data) {
+		/* disable iov and allow time for transactions to clear */
+		pci_disable_sriov(pdev);
+		msleep(500);
+
+		kfree(adapter->vf_data);
+		adapter->vf_data = NULL;
+		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
+		msleep(100);
+		dev_info(&pdev->dev, "IOV Disabled\n");
+	}
+
+	if (num_vfs) {
+		adapter->vf_data = kcalloc(num_vfs,
+		                           sizeof(struct vf_data_storage),
+		                           GFP_KERNEL);
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
+	igb_set_interrupt_capability(adapter);
+	igb_alloc_queues(adapter);
+	igb_reset(adapter);
+
+	if (netdev->flags & IFF_UP)
+		igb_open(netdev);
+
+	return count;
+}
+#endif /* CONFIG_PCI_IOV */
 /* igb_main.c */
