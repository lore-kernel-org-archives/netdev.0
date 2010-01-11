From: "Wu Jiajun-B06378" <B06378@freescale.com>
Subject: RE: [PATCH 1/3] ucc_geth: Fix empty TX queue processing
Date: Mon, 11 Jan 2010 11:47:37 +0800
Message-ID: <100CB1A1877FF245BDB7AF83A0E73FFE26BE4D@zch01exm28.fsl.freescale.net>
References: <0A1FE637C2C7E148B9573BB60CC630E56C3E90@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>,
	<lsorense@csclub.uwaterloo.ca>, <davem@davemloft.net>
To: <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:63137 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab0AKDrr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 22:47:47 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o0B3leYm004458
	for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 20:47:40 -0700 (MST)
Received: from zch01exm28.fsl.freescale.net (zch01exm28.ap.freescale.net [10.192.129.225])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id o0B3rUT6010336
	for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 21:53:31 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <0A1FE637C2C7E148B9573BB60CC630E56C3E90@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
'bd == ugeth->txBd[txQ]' has two possible statuses: 1)full queue.
2)empty queue.
Removing 'netif_queue_stopped() == 0' will make transmitting stopping
when the queue is full. 

I made a new patch for this oops.

>From 726765194352d01dc8ea672d97612589b67cec3f Mon Sep 17 00:00:00 2001
From: Jiajun Wu <b06378@freescale.com>
Date: Mon, 11 Jan 2010 10:57:22 +0800
Subject: [PATCH] ucc_geth: Fix empty TX queue processing

Signed-off-by: Jiajun Wu <b06378@freescale.com>
---
 drivers/net/ucc_geth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index f982220..34345f0 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3576,17 +3576,17 @@ static int ucc_geth_tx(struct net_device *dev,
u8 txQ)
 	while ((bd_status & T_R) == 0) {
 		struct sk_buff *skb;
 
+		skb = ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
+
 		/* BD contains already transmitted buffer.   */
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if ((bd == ugeth->txBd[txQ]) &&
(netif_queue_stopped(dev) == 0))
+		if ((bd == ugeth->txBd[txQ]) && (skb == NULL))
 			break;
 
 		dev->stats.tx_packets++;
 
-		skb = ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
-
 		if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN
&&
 			     skb_recycle_check(skb,
 
ugeth->ug_info->uf_info.max_rx_buf_length +
-- 
1.5.6.3
-----Original Message-----
From: linuxppc-dev-bounces+b13201=freescale.com@lists.ozlabs.org
[mailto:linuxppc-dev-bounces+b13201=freescale.com@lists.ozlabs.org] On
Behalf Of Anton Vorontsov
Sent: Thursday, December 24, 2009 11:31 PM
To: David Miller
Cc: linuxppc-dev@ozlabs.org; netdev@vger.kernel.org; Lennart Sorensen
Subject: [PATCH 1/3] ucc_geth: Fix empty TX queue processing
-----------

Following oops was seen with the ucc_geth driver:

 Unable to handle kernel paging request for data at address 0x00000058
Faulting instruction address: 0xc024f2fc
 Oops: Kernel access of bad area, sig: 11 [#1]  [...]  NIP [c024f2fc]
skb_recycle_check+0x14/0x100  LR [e30aa0a4] ucc_geth_poll+0xd8/0x4e0
[ucc_geth_driver]  Call Trace:
 [df857d50] [c000b03c] __ipipe_grab_irq+0x3c/0xa4 (unreliable)
[df857d60] [e30aa0a4] ucc_geth_poll+0xd8/0x4e0 [ucc_geth_driver]
[df857dd0] [c0258cf8] net_rx_action+0xf8/0x1b8  [df857e10] [c0032a38]
__do_softirq+0xb8/0x13c  [df857e60] [c00065cc] do_softirq+0xa0/0xac
[...]

This is because ucc_geth_tx() tries to process an empty queue when
queues are logically stopped. Stopping the queues doesn't disable
polling, and since nowadays ucc_geth_tx() is actually called from the
polling routine, the oops above might pop up.

Fix this by removing 'netif_queue_stopped() == 0' check.

Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Tested-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Cc: Stable <stable@vger.kernel.org> [2.6.32]
---
 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c index
afaf088..0f8c99e 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3273,7 +3273,7 @@ static int ucc_geth_tx(struct net_device *dev, u8
txQ)
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if ((bd == ugeth->txBd[txQ]) &&
(netif_queue_stopped(dev) == 0))
+		if (bd == ugeth->txBd[txQ]) /* queue empty? */
 			break;
 
 		dev->stats.tx_packets++;
--
1.6.3.3

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev

