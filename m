From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] 3c59x: Fix resource leaks in vortex_open
Date: Mon,  3 Aug 2015 11:18:12 +0800
Message-ID: <1438571892-28318-1-git-send-email-baijiaju1990@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jia-Ju Bai <baijiaju1990@163.com>
To: davem@davemloft.net, nhorman@tuxdriver.com,
	klassert@mathematik.tu-chemnitz.de, paul.gortmaker@windriver.com,
	dvlasenk@redhat.com, linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When vortex_up is failed, the skb buffers allocated by __netdev_alloc_skb
in vortex_open are not released, which may cause resource leaks.
This bug has been submitted before.
This patch modifies the error handling code to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/3com/3c59x.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 2d1ce3c..753887d 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1763,16 +1763,9 @@ vortex_open(struct net_device *dev)
 			vp->rx_ring[i].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, PKT_BUF_SZ, PCI_DMA_FROMDEVICE));
 		}
 		if (i != RX_RING_SIZE) {
-			int j;
 			pr_emerg("%s: no memory for rx ring\n", dev->name);
-			for (j = 0; j < i; j++) {
-				if (vp->rx_skbuff[j]) {
-					dev_kfree_skb(vp->rx_skbuff[j]);
-					vp->rx_skbuff[j] = NULL;
-				}
-			}
 			retval = -ENOMEM;
-			goto err_free_irq;
+			goto err_free_skb;
 		}
 		/* Wrap the ring. */
 		vp->rx_ring[i-1].next = cpu_to_le32(vp->rx_ring_dma);
@@ -1782,7 +1775,13 @@ vortex_open(struct net_device *dev)
 	if (!retval)
 		goto out;
 
-err_free_irq:
+err_free_skb:
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		if (vp->rx_skbuff[i]) {
+			dev_kfree_skb(vp->rx_skbuff[i]);
+			vp->rx_skbuff[i] = NULL;
+		}
+	}
 	free_irq(dev->irq, dev);
 err:
 	if (vortex_debug > 1)
-- 
1.7.9.5
