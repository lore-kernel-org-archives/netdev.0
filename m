From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/2] 8139cp: set ring address before enabling receiver
Date: Fri, 01 Jun 2012 12:19:39 +0800
Message-ID: <20120601041939.4311.55827.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, we enable the receiver before setting the ring address which could
lead the card DMA into unexpected areas. Solving this by set the ring address
before enabling the receiver.

btw. I find and test this in qemu as I didn't have a 8139cp card in hand. please
review it carefully.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/ethernet/realtek/8139cp.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 5eef290..7f08779 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -979,6 +979,17 @@ static void cp_init_hw (struct cp_private *cp)
 	cpw32_f (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
 	cpw32_f (MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr + 4)));
 
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
 	cp_start_hw(cp);
 	cpw8(TxThresh, 0x06); /* XXX convert magic num to a constant */
 
@@ -992,17 +1003,6 @@ static void cp_init_hw (struct cp_private *cp)
 
 	cpw8(Config5, cpr8(Config5) & PMEStatus);
 
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
 	cpw16(MultiIntr, 0);
 
 	cpw8_f(Cfg9346, Cfg9346_Lock);
