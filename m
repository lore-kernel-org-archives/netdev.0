From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv3 net-next 1/2] cxgb4: Add control net_device for configuring PCIe VF
Date: Thu, 11 Aug 2016 09:24:46 +0530
Message-ID: <1470887687-27155-2-git-send-email-hariprasad@chelsio.com>
References: <1470887687-27155-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:2250 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932291AbcHKDtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 23:49:13 -0400
In-Reply-To: <1470887687-27155-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Issue:
For instance, the current APIs assume a 1-to-1 mapping of Network Ports,
Physical Functions and the SR-IOV Virtual Functions of those Physical
Functions. This is not the case with our cards where any Virtual
Function can be hooked up to any Port -- or any number of Ports the
current Linux APIs also assume only 1 Network Interface/Port can be
accessed per Virtual Function.

Another issue is that these APIs assume that the Administrative Driver
is attached to the Physical Function Associated with a Virtual Function.
This is not the case with our card where all administration is performed
by a Driver which is not attached to any of the Physical Functions which
have SR-IOV PCI Capabilities.

Another consequence of these assumptions is the inability to utilize all
of the cards SR-IOV resources. For instance, our cards have SR-IOV
Capabilities on Physical Functions 0..3 and the administrative Driver
attaches to Physical Function 4. Each of the Physical Functions 0..3 can
support up to 16 Virtual Functions. With the current Linux APIs, a
2-Port card would only be able to use the Virtual Functions on Physical
Function 0..1 and not allow the Virtual Functions on Physical Functions
2..3 to be used since there are no Ports 2..3 on a 2-Port card.

Fix:
Since the control node is always the netdevice for all VF ACL commands.
Created a dummy netdevice for each Physical Function from 0 to 3 through
which one could control their VFs. The device won't be associated with
any port, since it doesn't need to transmit/receive. Its purely used
for VF management purpose only. The device will be registered only when
VF for a particular PF is configured using PCI sysfs interface and
unregistered while pci_disable_sriov() for the PF is called.

The interface will be named "mgmtpf<adapter no.><PF no.>", for example
for PF1 of adapter 0 will be named 'mgmtpf01'.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 115 ++++++++++++++++++++----
 1 file changed, 97 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c45de49dc963..490388239b7f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3139,6 +3139,24 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 
 };
 
+static const struct net_device_ops cxgb4_mgmt_netdev_ops = {
+};
+
+static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+{
+	struct adapter *adapter = netdev2adap(dev);
+
+	strlcpy(info->driver, cxgb4_driver_name, sizeof(info->driver));
+	strlcpy(info->version, cxgb4_driver_version,
+		sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(adapter->pdev),
+		sizeof(info->bus_info));
+}
+
+static const struct ethtool_ops cxgb4_mgmt_ethtool_ops = {
+	.get_drvinfo       = get_drvinfo,
+};
+
 void t4_fatal_err(struct adapter *adap)
 {
 	t4_set_reg_field(adap, SGE_CONTROL_A, GLOBALENABLE_F, 0);
@@ -4836,19 +4854,12 @@ static int get_chip_type(struct pci_dev *pdev, u32 pl_rev)
 #ifdef CONFIG_PCI_IOV
 static int cxgb4_iov_configure(struct pci_dev *pdev, int num_vfs)
 {
+	struct adapter *adap = pci_get_drvdata(pdev);
 	int err = 0;
 	int current_vfs = pci_num_vf(pdev);
 	u32 pcie_fw;
-	void __iomem *regs;
 
-	regs = pci_ioremap_bar(pdev, 0);
-	if (!regs) {
-		dev_err(&pdev->dev, "cannot map device registers\n");
-		return -ENOMEM;
-	}
-
-	pcie_fw = readl(regs + PCIE_FW_A);
-	iounmap(regs);
+	pcie_fw = readl(adap->regs + PCIE_FW_A);
 	/* Check if cxgb4 is the MASTER and fw is initialized */
 	if (!(pcie_fw & PCIE_FW_INIT_F) ||
 	    !(pcie_fw & PCIE_FW_MASTER_VLD_F) ||
@@ -4875,6 +4886,8 @@ static int cxgb4_iov_configure(struct pci_dev *pdev, int num_vfs)
 	 */
 	if (!num_vfs) {
 		pci_disable_sriov(pdev);
+		if (adap->port[0]->reg_state == NETREG_REGISTERED)
+			unregister_netdev(adap->port[0]);
 		return num_vfs;
 	}
 
@@ -4882,6 +4895,12 @@ static int cxgb4_iov_configure(struct pci_dev *pdev, int num_vfs)
 		err = pci_enable_sriov(pdev, num_vfs);
 		if (err)
 			return err;
+
+		if (adap->port[0]->reg_state == NETREG_UNINITIALIZED) {
+			err = register_netdev(adap->port[0]);
+			if (err < 0)
+				pr_info("Unable to register VF mgmt netdev\n");
+		}
 	}
 	return num_vfs;
 }
@@ -4893,9 +4912,14 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct port_info *pi;
 	bool highdma = false;
 	struct adapter *adapter = NULL;
+	struct net_device *netdev;
+#ifdef CONFIG_PCI_IOV
+	char name[IFNAMSIZ];
+#endif
 	void __iomem *regs;
 	u32 whoami, pl_rev;
 	enum chip_type chip;
+	static int adap_idx = 1;
 
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
 
@@ -4930,7 +4954,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	func = CHELSIO_CHIP_VERSION(chip) <= CHELSIO_T5 ?
 		SOURCEPF_G(whoami) : T6_SOURCEPF_G(whoami);
 	if (func != ent->driver_data) {
+#ifndef CONFIG_PCI_IOV
 		iounmap(regs);
+#endif
 		pci_disable_device(pdev);
 		pci_save_state(pdev);        /* to restore SR-IOV later */
 		goto sriov;
@@ -4962,6 +4988,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = -ENOMEM;
 		goto out_unmap_bar0;
 	}
+	adap_idx++;
 
 	adapter->workq = create_singlethread_workqueue("cxgb4");
 	if (!adapter->workq) {
@@ -5048,8 +5075,6 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			      T6_STATMODE_V(0)));
 
 	for_each_port(adapter, i) {
-		struct net_device *netdev;
-
 		netdev = alloc_etherdev_mq(sizeof(struct port_info),
 					   MAX_ETH_QSETS);
 		if (!netdev) {
@@ -5217,6 +5242,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		attach_ulds(adapter);
 
 	print_adapter_info(adapter);
+	return 0;
 
 sriov:
 #ifdef CONFIG_PCI_IOV
@@ -5230,8 +5256,51 @@ sriov:
 				 "instantiated %u virtual functions\n",
 				 num_vf[func]);
 	}
-#endif
+
+	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
+	if (!adapter) {
+		err = -ENOMEM;
+		goto free_pci_region;
+	}
+
+	snprintf(name, IFNAMSIZ, "mgmtpf%d%d", adap_idx, func);
+	netdev = alloc_netdev(0, name, NET_NAME_UNKNOWN, ether_setup);
+	if (!netdev) {
+		err = -ENOMEM;
+		goto free_adapter;
+	}
+
+	adapter->pdev = pdev;
+	adapter->pdev_dev = &pdev->dev;
+	adapter->name = pci_name(pdev);
+	adapter->mbox = func;
+	adapter->pf = func;
+	adapter->regs = regs;
+	adapter->mbox_log = kzalloc(sizeof(*adapter->mbox_log) +
+				    (sizeof(struct mbox_cmd) *
+				     T4_OS_LOG_MBOX_CMDS),
+				    GFP_KERNEL);
+	pi = netdev_priv(netdev);
+	pi->adapter = adapter;
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+	pci_set_drvdata(pdev, adapter);
+
+	adapter->port[0] = netdev;
+	netdev->netdev_ops = &cxgb4_mgmt_netdev_ops;
+	netdev->ethtool_ops = &cxgb4_mgmt_ethtool_ops;
+
+	return 0;
+
+ free_adapter:
+	kfree(adapter);
+ free_pci_region:
+	iounmap(regs);
+	pci_disable_sriov(pdev);
+	pci_release_regions(pdev);
+	return err;
+#else
 	return 0;
+#endif
 
  out_free_dev:
 	free_some_resources(adapter);
@@ -5258,12 +5327,12 @@ static void remove_one(struct pci_dev *pdev)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
 
-#ifdef CONFIG_PCI_IOV
-	pci_disable_sriov(pdev);
-
-#endif
+	if (!adapter) {
+		pci_release_regions(pdev);
+		return;
+	}
 
-	if (adapter) {
+	if (adapter->pf == 4) {
 		int i;
 
 		/* Tear down per-adapter Work Queue first since it can contain
@@ -5312,8 +5381,18 @@ static void remove_one(struct pci_dev *pdev)
 		kfree(adapter->mbox_log);
 		synchronize_rcu();
 		kfree(adapter);
-	} else
+	}
+#ifdef CONFIG_PCI_IOV
+	else {
+		if (adapter->port[0]->reg_state == NETREG_REGISTERED)
+			unregister_netdev(adapter->port[0]);
+		free_netdev(adapter->port[0]);
+		iounmap(adapter->regs);
+		kfree(adapter);
+		pci_disable_sriov(pdev);
 		pci_release_regions(pdev);
+	}
+#endif
 }
 
 static struct pci_driver cxgb4_driver = {
-- 
2.3.4
