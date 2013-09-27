From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Subject: [PATCH] ll_temac: Reset dma descriptors on ndo_open
Date: Fri, 27 Sep 2013 13:24:28 +0200
Message-ID: <1380281068-13269-1-git-send-email-ricardo.ribalda@gmail.com>
Cc: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Jingoo Han <jg1.han@samsung.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:46015 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616Ab3I0LYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 07:24:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dma descriptors are only initialized on the probe function.

If a packet is on the buffer when temac_stop is called, the dma
descriptors can be left on a incorrect status where no other package can
be sent.

So an interface could be left in an usable state after ifdow/ifup.

This patch makes sure that the descriptors are in a proper status when
the device is started.

Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index b88121f..8bae87f 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -229,6 +229,25 @@ static void temac_dma_bd_release(struct net_device *ndev)
 }
 
 /**
+ * temac_dma_bd_reset - Reset buffer descriptor rings
+ */
+static void temac_dma_bd_reset(struct net_device *ndev)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	int i;
+
+	for (i = 0; i < TX_BD_NUM; i++)
+		lp->tx_bd_v[i].app0 = 0;
+
+	lp->tx_bd_ci = 0;
+	lp->tx_bd_next = 0;
+	lp->tx_bd_tail = 0;
+	lp->rx_bd_ci = 0;
+
+	return;
+}
+
+/**
  * temac_dma_bd_init - Setup buffer descriptor rings
  */
 static int temac_dma_bd_init(struct net_device *ndev)
@@ -864,6 +883,8 @@ static int temac_open(struct net_device *ndev)
 	if (rc)
 		goto err_rx_irq;
 
+	temac_dma_bd_reset(ndev);
+
 	return 0;
 
  err_rx_irq:
-- 
1.8.4.rc3
