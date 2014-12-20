From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: [PATCH] e1000e in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 16:02:22 +0800
Message-ID: <000f01d01c2b$4af1b3b0$e0d51b10$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <e1000-devel@lists.sourceforge.net>, <linux.nics@intel.com>
To: <todd.fujinaka@intel.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-134.163.com ([123.125.50.134]:50866 "EHLO m50-134.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbaLTIC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 03:02:58 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have actually tested e1000e driver on the real hardware(Intel 82572EI
PCI-E Gigabit Ethernet Controller), and find some potential bugs:
The target file is drivers/net/ethernet/intel/e1000e/netdev.c, which is used
to build e1000e.ko.

(1) In the normal process, netif_napi_add is called in e1000_probe, but
netif_napi_del is not called in e1000_remove. However, many other ethernet
card drivers call them in pairs, even in the error handling paths, such as
r8169 and igb.

(2) The function vzalloc is called by e1000e_setup_rx_resources (in
e1000_open) when initializing the ethernet card driver. But when vzalloc is
failed, "err" segment in e1000e_setup_rx_resources is executed to return and
then e1000e_free_tx_resources in "err_setup_rx" segment in e1000_open is
executed to halt. However, "writel(0, tx_ring->head)" statement in
e1000_clean_tx_ring in e1000e_free_tx_resources will cause system crash,
because "tx_ring->head" is not assigned the value. In the code,
"tx_ring->head" is initialized in e1000_configure_tx in e1000_configure
after the e1000e_setup_rx_resources.
(3) The same system crashes happens, when kcalloc in
e1000e_setup_rx_resources is failed(returns NULL).
(4) The same system crashes happens, when e1000_alloc_ring_dma in
e1000e_setup_rx_resources is failed(returns error code).

(5) In the normal process of e1000e, pci_enable_pcie_error_reporting and
pci_disable_pcie_error_reporting is called in pairs in e1000_probe and
e1000_remove. However, when pci_enable_pcie_error_reporting has been called
and pci_save_state in e1000_probe is failed, "err_alloc_etherdev" segment in
e1000_probe is executed immediately to exit, but
pci_disable_pcie_error_reporting is not called.
(6) The same situation happens when alloc_etherdev_mqs in e1000_probe is
failed.
(7) The same situation happens when ioremap in e1000_probe is failed.
(8) The same situation happens when e1000_sw_init in e1000_probe is failed.
(9) The same situation happens when register_netdev in e1000_probe is
failed.

(10) When request_irq in e1000_request_irq is failed, pm_qos_add_request in
e1000_open is called, but pm_qos_remove_request is not called.

Meanwhile, I also write the patch to fix the bugs. I have run the patch on
the hardware, it can work normally and fix the above bugs.

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
b/drivers/net/ethernet/intel/e1000e/netdev.c
index 247335d..02d1e67 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2444,6 +2444,8 @@ static void e1000_clean_tx_ring(struct e1000_ring
*tx_ring)
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
+	if(!(tx_ring->head))
+		return;
 	writel(0, tx_ring->head);
 	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
 		e1000e_update_tdt_wa(tx_ring, 0);
@@ -4358,11 +4360,13 @@ static int e1000_open(struct net_device *netdev)
 	netif_carrier_off(netdev);
 
 	/* allocate transmit descriptors */
+	adapter->tx_ring->head = NULL;
 	err = e1000e_setup_tx_resources(adapter->tx_ring);
 	if (err)
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
+	adapter->rx_ring->head = NULL;
 	err = e1000e_setup_rx_resources(adapter->rx_ring);
 	if (err)
 		goto err_setup_rx;
@@ -4430,6 +4434,7 @@ static int e1000_open(struct net_device *netdev)
 	return 0;
 
 err_req_irq:
+	pm_qos_remove_request(&adapter->netdev->pm_qos_req);
 	e1000e_release_hw_control(adapter);
 	e1000_power_down_phy(adapter);
 	e1000e_free_rx_resources(adapter->rx_ring);
@@ -7045,6 +7050,7 @@ err_hw_init:
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 err_sw_init:
+	netif_napi_del(&adapter->napi);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
 	e1000e_reset_interrupt_capability(adapter);
@@ -7053,6 +7059,7 @@ err_flashmap:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
+	pci_disable_pcie_error_reporting(pdev);
 	pci_release_selected_regions(pdev,
 				     pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:
@@ -7103,6 +7110,7 @@ static void e1000_remove(struct pci_dev *pdev)
 	/* Don't lie to e1000_close() down the road. */
 	if (!down)
 		clear_bit(__E1000_DOWN, &adapter->state);
+	netif_napi_del(&adapter->napi);
 	unregister_netdev(netdev);
 
 	if (pci_dev_run_wake(pdev))

Thanks!
