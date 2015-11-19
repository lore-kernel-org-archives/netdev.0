From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 3/3 v3] dl2k: Implement suspend
Date: Thu, 19 Nov 2015 20:13:06 +0100
Message-ID: <1447960386-3049-3-git-send-email-linux@rainbow-software.org>
References: <1447960386-3049-1-git-send-email-linux@rainbow-software.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447960386-3049-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add suspend/resume support to dl2k driver.
This requires RX/TX rings to be reset so split out the required
functionality from alloc_list() into new rio_reset_ring().

Tested on Asus NX1101 (IP1000A) and D-Link DGE-550T (DL-2000).

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/dlink/dl2k.c |   79 ++++++++++++++++++++++++++++++-------
 1 file changed, 65 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 9e9baa0..f92b6d9 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -464,36 +464,40 @@ static void free_list(struct net_device *dev)
 	}
 }
 
+static void rio_reset_ring(struct netdev_private *np)
+{
+	int i;
+
+	np->cur_rx = 0;
+	np->cur_tx = 0;
+	np->old_rx = 0;
+	np->old_tx = 0;
+
+	for (i = 0; i < TX_RING_SIZE; i++)
+		np->tx_ring[i].status = cpu_to_le64(TFDDone);
+
+	for (i = 0; i < RX_RING_SIZE; i++)
+		np->rx_ring[i].status = 0;
+}
+
  /* allocate and initialize Tx and Rx descriptors */
 static int alloc_list(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
-	np->cur_rx = np->cur_tx = 0;
-	np->old_rx = np->old_tx = 0;
+	rio_reset_ring(np);
 	np->rx_buf_sz = (dev->mtu <= 1500 ? PACKET_SIZE : dev->mtu + 32);
 
 	/* Initialize Tx descriptors, TFDListPtr leaves in start_xmit(). */
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		np->tx_skbuff[i] = NULL;
-		np->tx_ring[i].status = cpu_to_le64(TFDDone);
 		np->tx_ring[i].next_desc = cpu_to_le64(np->tx_ring_dma +
 					      ((i + 1) % TX_RING_SIZE) *
 					      sizeof(struct netdev_desc));
 	}
 
-	/* Initialize Rx descriptors */
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		np->rx_ring[i].next_desc = cpu_to_le64(np->rx_ring_dma +
-						((i + 1) % RX_RING_SIZE) *
-						sizeof(struct netdev_desc));
-		np->rx_ring[i].status = 0;
-		np->rx_ring[i].fraginfo = 0;
-		np->rx_skbuff[i] = NULL;
-	}
-
-	/* Allocate the rx buffers */
+	/* Initialize Rx descriptors & allocate buffers */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		/* Allocated fixed size of skbuff */
 		struct sk_buff *skb;
@@ -505,6 +509,9 @@ static int alloc_list(struct net_device *dev)
 			return -ENOMEM;
 		}
 
+		np->rx_ring[i].next_desc = cpu_to_le64(np->rx_ring_dma +
+						((i + 1) % RX_RING_SIZE) *
+						sizeof(struct netdev_desc));
 		/* Rubicon now supports 40 bits of addressing space. */
 		np->rx_ring[i].fraginfo =
 		    cpu_to_le64(pci_map_single(
@@ -1824,11 +1831,55 @@ rio_remove1 (struct pci_dev *pdev)
 	}
 }
 
+#ifdef CONFIG_PM_SLEEP
+static int rio_suspend(struct device *device)
+{
+	struct net_device *dev = dev_get_drvdata(device);
+	struct netdev_private *np = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return 0;
+
+	netif_device_detach(dev);
+	del_timer_sync(&np->timer);
+	rio_hw_stop(dev);
+
+	return 0;
+}
+
+static int rio_resume(struct device *device)
+{
+	struct net_device *dev = dev_get_drvdata(device);
+	struct netdev_private *np = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return 0;
+
+	rio_reset_ring(np);
+	rio_hw_init(dev);
+	np->timer.expires = jiffies + 1 * HZ;
+	add_timer(&np->timer);
+	netif_device_attach(dev);
+	dl2k_enable_int(np);
+
+	return 0;
+}
+
+static SIMPLE_DEV_PM_OPS(rio_pm_ops, rio_suspend, rio_resume);
+#define RIO_PM_OPS    (&rio_pm_ops)
+
+#else
+
+#define RIO_PM_OPS	NULL
+
+#endif /* CONFIG_PM_SLEEP */
+
 static struct pci_driver rio_driver = {
 	.name		= "dl2k",
 	.id_table	= rio_pci_tbl,
 	.probe		= rio_probe1,
 	.remove		= rio_remove1,
+	.driver.pm	= RIO_PM_OPS,
 };
 
 module_pci_driver(rio_driver);
-- 
Ondrej Zary
