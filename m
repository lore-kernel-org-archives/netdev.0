From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: [PATCH] 3c59x in linux-3.18.0: memory leak
Date: Sat, 20 Dec 2014 21:06:54 +0800
Message-ID: <001401d01c55$d4f70220$7ee50660$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <klassert@mathematik.tu-chemnitz.de>, <netdev@vger.kernel.org>,
	<vortex@scyld.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:53229 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbaLTNHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 08:07:12 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have actually tested 3c59x driver on the real hardware(3Com 3c905B
100BaseTX PCI Ethernet Controller), and find a memory leak:
The target file is drivers/net/ethernet/3com/3c59x.c, which is used to build
3c59x.ko.

(1) The function vortex_up is called by vortex_open when initializing the
ethernet card driver. But when vortex_up is failed, which means that it
returns the error value, "out" segment is executed immediately to halt the
process. However, the resources allocated by __netdev_alloc_skb in
vortex_open are not released by dev_kfree_skb when vortex_up is failed.
(2) As shown in (1), one reason that vortex_up is failed is that
pci_enable_device is failed(return the error value) in vortex_up, and
"err_out" segment is executed immediately to return.

Meanwhile, I also write the patch to fix the bug. I have run the patch on
the hardware, it can work normally and fix this bug.

diff --git a/drivers/net/ethernet/3com/3c59x.c
b/drivers/net/ethernet/3com/3c59x.c
index 41095eb..d0c5bee 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1782,6 +1782,16 @@ vortex_open(struct net_device *dev)
 	if (!retval)
 		goto out;
 
+	if (vp->full_bus_master_rx) {
+		for (i = 0; i < RX_RING_SIZE; i++) {
+			if (vp->rx_skbuff[i]) {
+				dev_kfree_skb(vp->rx_skbuff[i]);
+				vp->rx_skbuff[i] = NULL;
+			}
+		}
+		retval = -ENOMEM;
+	}
+
 err_free_irq:
 	free_irq(dev->irq, dev);
 err:
