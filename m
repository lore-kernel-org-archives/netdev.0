From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH RFC] gianfar: Make polling safe with IRQs disabled
Date: Thu, 5 Nov 2009 01:57:11 +0300
Message-ID: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Jason Wessel <jason.wessel@windriver.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:11203 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751507AbZKDW5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 17:57:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using KGDBoE, gianfar driver spits 'Interrupt problem' messages,
which appears to be a legitimate warning, i.e. we may end up calling
netif_receive_skb() or vlan_hwaccel_receive_skb() with IRQs disabled.

This patch reworks the RX path so that if netpoll is enabled (the
only case when the driver don't know from what context the polling
may be called), we check whether IRQs are disabled, and if so we
fall back to safe variants of skb receiving functions.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

I'm not sure if this is suitable for mainline since it doesn't
have KGDBoE support. Jason, if the patch is OK, would you like
to merge it into KGDB tree?

 drivers/net/gianfar.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 197b358..024ca4a 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2412,9 +2412,17 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct rxfcb *fcb = NULL;
-
+	int irqs_dis = 0;
 	int ret;
 
+	/*
+	 * With netpoll we don't know from what context we're called (e.g
+	 * KGDBoE may call us from an exception handler), otherwise we're
+	 * pretty sure that IRQs are enabled.
+	 */
+#ifdef CONFIG_NETPOLL
+	irqs_dis = irqs_disabled();
+#endif
 	/* fcb is at the beginning if exists */
 	fcb = (struct rxfcb *)skb->data;
 
@@ -2432,7 +2440,10 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 
 	/* Send the packet up the stack */
 	if (unlikely(priv->vlgrp && (fcb->flags & RXFCB_VLN)))
-		ret = vlan_hwaccel_receive_skb(skb, priv->vlgrp, fcb->vlctl);
+		ret = __vlan_hwaccel_rx(skb, priv->vlgrp, fcb->vlctl,
+					!irqs_dis);
+	else if (irqs_dis)
+		ret = netif_rx(skb);
 	else
 		ret = netif_receive_skb(skb);
 
@@ -2504,8 +2515,6 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				skb_put(skb, pkt_len);
 				dev->stats.rx_bytes += pkt_len;
 
-				if (in_irq() || irqs_disabled())
-					printk("Interrupt problem!\n");
 				gfar_process_frame(dev, skb, amount_pull);
 
 			} else {
-- 
1.6.3.3
