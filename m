From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: [PATCH] 8139too in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 21:20:35 +0800
Message-ID: <001601d01c57$be1e65a0$3a5b30e0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	<shangh@realtek.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:58012 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752891AbaLTNUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 08:20:52 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have actually tested 8139too driver on the real hardware(Realtek RTL8139D
PCI Ethernet Controller), and find some potential bugs:
The target file is drivers/net/ethernet/realtek/8139too.c, which is used to
build 8139too.ko.

(1) In the normal process of 8139too, netif_napi_add is called in
rtl8139_init_one, but netif_napi_del is not called in rtl8139_remove_one.
However, many other ethernet card drivers call them in pairs, even in the
error handling paths, such as r8169 and igb.

(2) In the normal process of 8139too, pci_enable_device and
pci_disable_device are called in pairs in rtl8139_init_board(in
rtl8139_init_one) and rtl8139_remove_one. However, when pci_enable_device
has been called and pci_request_regions is failed in rtl8139_init_board,
"err_out" segment in rtl8139_init_board is executed immediately to exit, but
pci_disable_device is not called because "disable_dev_on_err = 0".


Meanwhile, I also write the patch to fix the bugs. I have run the patch on
the hardware, it can work normally and fix the above bugs.

diff --git a/drivers/net/ethernet/realtek/8139too.c
b/drivers/net/ethernet/realtek/8139too.c
index 007b38c..f277c5f 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -782,11 +782,11 @@ static struct net_device *rtl8139_init_board(struct
pci_dev *pdev)
 	rc = pci_enable_device (pdev);
 	if (rc)
 		goto err_out;
+	disable_dev_on_err = 1;
 
 	rc = pci_request_regions (pdev, DRV_NAME);
 	if (rc)
 		goto err_out;
-	disable_dev_on_err = 1;
 
 	pci_set_master (pdev);
 
@@ -1098,6 +1098,7 @@ static int rtl8139_init_one(struct pci_dev *pdev,
 	return 0;
 
 err_out:
+	netif_napi_del (&tp->napi);
 	__rtl8139_cleanup_dev (dev);
 	pci_disable_device (pdev);
 	return i;
@@ -1112,6 +1113,7 @@ static void rtl8139_remove_one(struct pci_dev *pdev)
 	assert (dev != NULL);
 
 	cancel_delayed_work_sync(&tp->thread);
+	netif_napi_del (&tp->napi);
 
 	unregister_netdev (dev);

Thanks!
