From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH net v2 1/1] r8169: fix lockdep warning when removing interface
Date: Mon, 22 Jul 2013 09:53:30 +0200
Message-ID: <3190648.uJuPIZ6zlh@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48801 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500Ab3GVHxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 03:53:36 -0400
Received: by mail-wg0-f44.google.com with SMTP id l18so739837wgh.11
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 00:53:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The work queue is initialised in rtl_open (when the interface goes up),
but canceled in rtl_remove_one (when the PCI device gets removed). If
the network interface is not brought up, then the work queue struct is
not initialised. When the device is removed, the attempt to cancel the
uninitialised work queue causes a lockdep warning.

This patch fixes the issue by moving cancel_work_sync to rtl_close (to
match rtl_open). (Note that rtl_close is also called via
unregister_netdev in rtl_remove_one.)

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c 
b/drivers/net/ethernet/realtek/r8169.c
index 4106a74..880015c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6468,6 +6468,8 @@ static int rtl8169_close(struct net_device *dev)
 	rtl8169_down(dev);
 	rtl_unlock_work(tp);
 
+	cancel_work_sync(&tp->wk.work);
+
 	free_irq(pdev->irq, dev);
 
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
@@ -6793,8 +6795,6 @@ static void rtl_remove_one(struct pci_dev *pdev)
 		rtl8168_driver_stop(tp);
 	}
 
-	cancel_work_sync(&tp->wk.work);
-
 	netif_napi_del(&tp->napi);
 
 	unregister_netdev(dev);
-- 
1.8.3.2
