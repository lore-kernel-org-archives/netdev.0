From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] 8139cp: revert "set ring address before enabling receiver"
Date: Wed, 21 Nov 2012 21:07:29 +0100
Message-ID: <20121121200729.GA17603@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>,
	Jason Wang <jasowang@redhat.com>,
	Jeff Garzik <jgarzik@pobox.com>, gilboad@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39099 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756405Ab2KUUcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 15:32:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts b01af4579ec41f48e9b9c774e70bd6474ad210db.

The original patch was tested with emulated hardware. Real
hardware chokes.

Fixes https://bugzilla.kernel.org/show_bug.cgi?id=47041

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/8139cp.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 1c81825..b01f83a 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -979,17 +979,6 @@ static void cp_init_hw (struct cp_private *cp)
 	cpw32_f (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
 	cpw32_f (MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr + 4)));
 
-	cpw32_f(HiTxRingAddr, 0);
-	cpw32_f(HiTxRingAddr + 4, 0);
-
-	ring_dma = cp->ring_dma;
-	cpw32_f(RxRingAddr, ring_dma & 0xffffffff);
-	cpw32_f(RxRingAddr + 4, (ring_dma >> 16) >> 16);
-
-	ring_dma += sizeof(struct cp_desc) * CP_RX_RING_SIZE;
-	cpw32_f(TxRingAddr, ring_dma & 0xffffffff);
-	cpw32_f(TxRingAddr + 4, (ring_dma >> 16) >> 16);
-
 	cp_start_hw(cp);
 	cpw8(TxThresh, 0x06); /* XXX convert magic num to a constant */
 
@@ -1003,6 +992,17 @@ static void cp_init_hw (struct cp_private *cp)
 
 	cpw8(Config5, cpr8(Config5) & PMEStatus);
 
+	cpw32_f(HiTxRingAddr, 0);
+	cpw32_f(HiTxRingAddr + 4, 0);
+
+	ring_dma = cp->ring_dma;
+	cpw32_f(RxRingAddr, ring_dma & 0xffffffff);
+	cpw32_f(RxRingAddr + 4, (ring_dma >> 16) >> 16);
+
+	ring_dma += sizeof(struct cp_desc) * CP_RX_RING_SIZE;
+	cpw32_f(TxRingAddr, ring_dma & 0xffffffff);
+	cpw32_f(TxRingAddr + 4, (ring_dma >> 16) >> 16);
+
 	cpw16(MultiIntr, 0);
 
 	cpw8_f(Cfg9346, Cfg9346_Lock);
-- 
1.7.11.7
