From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] gianfar: Fix soft lockup with multi-interrupt TSECs
Date: Mon, 12 Jan 2009 21:38:35 +0300
Message-ID: <20090112183835.GA25390@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:53920 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752725AbZALSij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 13:38:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes following bug:

BUG: soft lockup - CPU#0 stuck for 61s! [S03mountvirtfs-:922]
Modules linked in:
NIP: c006505c LR: c00675f0 CTR: c0020438
REGS: c7a1db90 TRAP: 0901   Not tainted  (2.6.28-rc8-01311-g8c7396a)
MSR: 00009032 <EE,ME,IR,DR>  CR: 28248442  XER: 20000000
TASK = c7a288a0[922] 'S03mountvirtfs-' THREAD: c7a1c000
GPR00: 00009032 c7a1dc40 c7a288a0 00000024 c79a1840 00000000 00000300 00000020
GPR08: c035f97c 00000000 00004008 c04d5210 00000000
NIP [c006505c] handle_IRQ_event+0x34/0xb0
LR [c00675f0] handle_level_irq+0xa8/0x144
Call Trace:
[c7a1dc40] [c00204d8] ipic_mask_irq+0xa0/0xb4 (unreliable)
[c7a1dc60] [c00675f0] handle_level_irq+0xa8/0x144
[c7a1dc80] [c00067f8] do_IRQ+0x78/0x108
[c7a1dc90] [c0014d7c] ret_from_except+0x0/0x14
--- Exception: 501 at gfar_schedule_cleanup+0x54/0x7c
    LR = gfar_transmit+0x14/0x28
[c7a1dd50] [c0352a3c] _spin_unlock_irqrestore+0x18/0x30 (unreliable)
[c7a1dd60] [c01f49a8] gfar_transmit+0x14/0x28
[c7a1dd70] [c0065084] handle_IRQ_event+0x5c/0xb0
[c7a1dd90] [c00675f0] handle_level_irq+0xa8/0x144
[c7a1ddb0] [c00067f8] do_IRQ+0x78/0x108
[c7a1ddc0] [c0014d7c] ret_from_except+0x0/0x14
--- Exception: 501 at up_read+0x10/0x48
    LR = do_page_fault+0x2b0/0x3e0
[c7a1de80] [c7a177e8] 0xc7a177e8 (unreliable)
[c7a1de90] [c0017964] do_page_fault+0x2b0/0x3e0
[c7a1df40] [c0014b14] handle_page_fault+0xc/0x80
--- Exception: 301 at 0xfe98b7c
    LR = 0xfe989c0
Instruction dump:
7c0802a6 bf810010 7c9f2378 7c7c1b78 90010024 80040004 70090020 40820010
7c0000a6 60008000 7c000124 3bc00000 <3ba00000> 48000010 83ff0014 2f9f0000


The bug introduced by commit 8c7396aebb68994c0519e438eecdf4d5fa9c7844
("gianfar: Merge Tx and Rx interrupt for scheduling clean up ring").

The commit merged TX and RX interrupt code into a single routine that
schedules NAPI, but no locks were introduced. This causes irq races, so
when irqs are enabled and netif_rx_schedule_prep() returns 0, nobody
disable the interrupts again. This leads to interrupt storm and finally
to the lockup.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c672ecf..228b88f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1607,10 +1607,18 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 static void gfar_schedule_cleanup(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->txlock, flags);
+	spin_lock(&priv->rxlock);
+
 	if (netif_rx_schedule_prep(&priv->napi)) {
 		gfar_write(&priv->regs->imask, IMASK_RTX_DISABLED);
 		__netif_rx_schedule(&priv->napi);
 	}
+
+	spin_unlock(&priv->rxlock);
+	spin_unlock_irqrestore(&priv->txlock, flags);
 }
 
 /* Interrupt Handler for Transmit complete */
-- 
1.5.6.5
