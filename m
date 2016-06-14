From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4: Enable SR-IOV configuration via PCI sysfs interface
Date: Tue, 14 Jun 2016 14:39:31 +0530
Message-ID: <1465895372-21101-3-git-send-email-hariprasad@chelsio.com>
References: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:39768 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751701AbcFNJEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 05:04:15 -0400
In-Reply-To: <1465895372-21101-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement callback in the driver for the new PCI bus driver
interface that allows the user to enable/disable SR-IOV
virtual functions in a device via the sysfs interface.

Deprecate module parameter used to configure SRIOV

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 66 ++++++++++++++++++++++++-
 1 file changed, 64 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c045f65d4106..6ce4344ea6fb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -207,7 +207,7 @@ static int rx_dma_offset = 2;
 static unsigned int num_vf[NUM_OF_PF_WITH_SRIOV];
 
 module_param_array(num_vf, uint, NULL, 0644);
-MODULE_PARM_DESC(num_vf, "number of VFs for each of PFs 0-3");
+MODULE_PARM_DESC(num_vf, "number of VFs for each of PFs 0-3, deprecated parameter - please use the pci sysfs interface.");
 #endif
 
 /* TX Queue select used to determine what algorithm to use for selecting TX
@@ -4836,6 +4836,60 @@ static int get_chip_type(struct pci_dev *pdev, u32 pl_rev)
 	return -EINVAL;
 }
 
+#ifdef CONFIG_PCI_IOV
+static int cxgb4_iov_configure(struct pci_dev *pdev, int num_vfs)
+{
+	int err = 0;
+	int current_vfs = pci_num_vf(pdev);
+	u32 pcie_fw;
+	void __iomem *regs;
+
+	regs = pci_ioremap_bar(pdev, 0);
+	if (!regs) {
+		dev_err(&pdev->dev, "cannot map device registers\n");
+		return -ENOMEM;
+	}
+
+	pcie_fw = readl(regs + PCIE_FW_A);
+	iounmap(regs);
+	/* Check if cxgb4 is the MASTER and fw is initialized */
+	if (!(pcie_fw & PCIE_FW_INIT_F) ||
+	    !(pcie_fw & PCIE_FW_MASTER_VLD_F) ||
+	    PCIE_FW_MASTER_G(pcie_fw) != 4) {
+		dev_warn(&pdev->dev,
+			 "cxgb4 driver needs to be MASTER to support SRIOV\n");
+		return -EOPNOTSUPP;
+	}
+
+	/* If any of the VF's is already assigned to Guest OS, then
+	 * SRIOV for the same cannot be modified
+	 */
+	if (current_vfs && pci_vfs_assigned(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot modify SR-IOV while VFs are assigned\n");
+		num_vfs = current_vfs;
+		return num_vfs;
+	}
+
+	/* Disable SRIOV when zero is passed.
+	 * One needs to disable SRIOV before modifying it, else
+	 * stack throws the below warning:
+	 * " 'n' VFs already enabled. Disable before enabling 'm' VFs."
+	 */
+	if (!num_vfs) {
+		pci_disable_sriov(pdev);
+		return num_vfs;
+	}
+
+	if (num_vfs != current_vfs) {
+		err = pci_enable_sriov(pdev, num_vfs);
+		if (err)
+			return err;
+	}
+	return num_vfs;
+}
+#endif
+
 static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	int func, i, err, s_qpp, qpp, num_seg;
@@ -5169,11 +5223,16 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 sriov:
 #ifdef CONFIG_PCI_IOV
-	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
+	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0) {
+		dev_warn(&pdev->dev,
+			 "Enabling SR-IOV VFs using the num_vf module "
+			 "parameter is deprecated - please use the pci sysfs "
+			 "interface instead.\n");
 		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
 			dev_info(&pdev->dev,
 				 "instantiated %u virtual functions\n",
 				 num_vf[func]);
+	}
 #endif
 	return 0;
 
@@ -5266,6 +5325,9 @@ static struct pci_driver cxgb4_driver = {
 	.probe    = init_one,
 	.remove   = remove_one,
 	.shutdown = remove_one,
+#ifdef CONFIG_PCI_IOV
+	.sriov_configure = cxgb4_iov_configure,
+#endif
 	.err_handler = &cxgb4_eeh,
 };
 
-- 
2.3.4
