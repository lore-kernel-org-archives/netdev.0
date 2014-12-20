From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: [PATCH] igb in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 16:11:26 +0800
Message-ID: <001101d01c2c$8dcc0040$a96400c0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <e1000-devel@lists.sourceforge.net>, <linux.nics@intel.com>
To: <todd.fujinaka@intel.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-134.163.com ([123.125.50.134]:32832 "EHLO m50-134.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbaLTIL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 03:11:59 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have actually tested igb driver on the real hardware(Intel 82575EB PCI-E
Gigabit Ethernet Controller), and find some potential bugs:
The target file is drivers/net/ethernet/intel/igb/igb_main.c

(1) In the normal process of igb, pci_enable_pcie_error_reporting and
pci_disable_pcie_error_reporting is called in pairs in igb_probe and
igb_remove. However, when pci_enable_pcie_error_reporting has been called
and alloc_etherdev_mqs in igb_probe is failed, "err_alloc_etherdev" segment
in igb_probe is executed immediately to exit, but
pci_disable_pcie_error_reporting is not called.
(2) The same situation happens when pci_iomap in igb_probe is failed.
(3) The same situation happens when igb_sw_init in igb_probe is failed.
(4) The same situation happens when register_netdev in igb_probe is failed.
(5) The same situation happens when igb_init_i2c in igb_probe is failed.

(6) The function kcalloc is called by igb_sw_init when initializing the
ethernet card driver, but kfree is not called when register_netdev in
igb_probe is failed, which may cause memory leak.
(7) The same situation happens when igb_init_i2c in igb_probe is failed.
(8) The same situation happens when kzalloc in igb_alloc_q_vector is failed.
(9) The same situation happens when igb_alloc_q_vector in
igb_alloc_q_vectors is failed.

(10) When igb_init_i2c in igb_probe is failed, igb_enable_sriov is called in
igb_probe_vfs, but igb_disable_sriov is not called.
(11) The same situation with [10] happens when register_netdev in igb_probe
is failed.

Meanwhile, I also write the patch to fix the bugs. I have run the patch on
the hardware, it can work normally and fix the above bugs.

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
b/drivers/net/ethernet/intel/igb/igb_main.c
index 487cd9c..cd9364a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -179,6 +179,7 @@ static void igb_check_vf_rate_limit(struct igb_adapter
*);
 #ifdef CONFIG_PCI_IOV
 static int igb_vf_configure(struct igb_adapter *adapter, int vf);
 static int igb_pci_enable_sriov(struct pci_dev *dev, int num_vfs);
+static int igb_disable_sriov(struct pci_dev *pdev);
 #endif
 
 #ifdef CONFIG_PM
@@ -2653,17 +2654,22 @@ err_register:
 	igb_release_hw_control(adapter);
 	memset(&adapter->i2c_adap, 0, sizeof(adapter->i2c_adap));
 err_eeprom:
+#ifdef CONFIG_PCI_IOV
+	igb_disable_sriov(pdev);
+#endif
 	if (!igb_check_reset_block(hw))
 		igb_reset_phy(hw);
 
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
 err_sw_init:
+	kfree(adapter->shadow_vfta);
 	igb_clear_interrupt_scheme(adapter);
 	pci_iounmap(pdev, hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
+	pci_disable_pcie_error_reporting(pdev);
 	pci_release_selected_regions(pdev,
 				     pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:


Thanks!
