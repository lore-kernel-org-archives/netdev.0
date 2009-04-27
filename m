From: "gouji-new" <gouji.masayuki@jp.fujitsu.com>
Subject: [PATCH] Proposed PARCH PCIE legacy I/O port free intel 10Gb NIC driver
Date: Mon, 27 Apr 2009 16:42:07 +0900
Message-ID: <AB661B51A8B54AF0A4D28FEF67718445@WINAK2QSSPDVFH>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:53011 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbZD0Hme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 03:42:34 -0400
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3R7gSfZ027152
	for <netdev@vger.kernel.org> (envelope-from gouji.masayuki@jp.fujitsu.com);
	Mon, 27 Apr 2009 16:42:28 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 56D6D45DE50
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 16:42:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 17B0F45DE53
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 16:42:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 92BFEE08006
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 16:42:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D3D9E08004
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 16:42:24 +0900 (JST)
Received: from m105.css.fujitsu.com (m105 [127.0.0.1])
	by m105.s.css.fujitsu.com (Postfix) with ESMTP id 01D5D5D8001
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 16:42:24 +0900 (JST)
Received: from WINAK2QSSPDVFH (unknown [10.124.100.244])
	by m105.s.css.fujitsu.com (Postfix) with ESMTP id 8EAED5D8002
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 16:42:23 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Traditionally Intel based NIC drivers request I/O port even though it
doesn't need that really.

Intel PCIE 10Gb driver (ixgbe) also requests I/O port but it doesn't need it
either.

This is a little inconvenient situation because sometimes we have to handle
those cards
on the slots where any I/O space is not attached.
 



So we made pach which makes ixgbe driver legacy I/O port free.

Signed-off-by: Masayuki Gouji <gouji.masayuki@jp.fujitsu.com> 

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0188425..c816cf1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3626,7 +3626,8 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	err = pci_enable_device(pdev);
+
+	err = pci_enable_device_mem(pdev);
 	if (err) {
 		printk(KERN_ERR "ixgbe: Cannot enable PCI device from "
 				"suspend\n");
@@ -4578,7 +4579,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	u16 pm_value = 0;
 	u32 part_num, eec;
 
-	err = pci_enable_device(pdev);
+	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
 
@@ -4598,9 +4599,12 @@ static int __devinit ixgbe_probe(struct pci_dev
*pdev,
 		pci_using_dac = 0;
 	}
 
-	err = pci_request_regions(pdev, ixgbe_driver_name);
+	err = pci_request_selected_regions(pdev,
+					  pci_select_bars(pdev,
IORESOURCE_MEM),
+					  ixgbe_driver_name);
 	if (err) {
-		dev_err(&pdev->dev, "pci_request_regions failed 0x%x\n",
err);
+		dev_err(&pdev->dev,
+			"pci_request_selected_regions failed 0x%x\n", err);
 		goto err_pci_reg;
 	}
 
@@ -4845,7 +4849,8 @@ err_eeprom:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev,
+				     pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -4897,7 +4902,8 @@ static void __devexit ixgbe_remove(struct pci_dev
*pdev)
 	ixgbe_release_hw_control(adapter);
 
 	iounmap(adapter->hw.hw_addr);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev,
+				     pci_select_bars(pdev, IORESOURCE_MEM));
 
 	DPRINTK(PROBE, INFO, "complete\n");
 	kfree(adapter->tx_ring);
@@ -4950,7 +4956,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct
pci_dev *pdev)
 	pci_ers_result_t result;
 	int err;
 
-	if (pci_enable_device(pdev)) {
+	if (pci_enable_device_mem(pdev)) {
 		DPRINTK(PROBE, ERR,
 		        "Cannot re-enable PCI device after reset.\n");
 		result = PCI_ERS_RESULT_DISCONNECT;


