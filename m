From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes .26
Date: Fri, 30 May 2008 22:26:33 -0400
Message-ID: <20080531022633.GA3070@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51345 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643AbYEaC0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:26:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/atlx/atl1.c         |    1 +
 drivers/net/cs89x0.c            |   10 +++++++---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 drivers/net/sc92031.c           |    2 +-
 drivers/net/sfc/falcon_xmac.c   |    2 +-
 drivers/net/tulip/tulip_core.c  |   10 ++++++++--
 drivers/net/ucc_geth_ethtool.c  |    3 ++-
 drivers/net/virtio_net.c        |   36 +++++++++++++++++++++++++++++++-----
 8 files changed, 52 insertions(+), 14 deletions(-)

Alexey Dobriyan (1):
      atl1: fix 4G memory corruption bug

Ben Hutchings (1):
      [netdrvr] sfc: Report XAUI link down at default log level

Brice Goglin (1):
      myri10ge: update driver version

Cesar Eduardo Barros (1):
      sc92031: remove bogus unlikely()

Grant Grundler (1):
      [netdrvr] tulip: oops in tulip_interrupt when hibernating with swsusp/suspend2

Joakim Tjernlund (1):
      ucc_geth_ethtool: Fix typo

Li Yang (1):
      ucc_geth_ethtool: Add a missing HW stats counter

Rusty Russell (2):
      virtio: fix virtio_net xmit of freed skb bug
      virtio: fix delayed xmit of packet and freeing of old packets.

Wang Chen (1):
      [netdrvr] CS89X0: Add cleanup for dma after fail

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 9c2394d..79325c4 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2023,6 +2023,7 @@ rrd_ok:
 		/* Good Receive */
 		pci_unmap_page(adapter->pdev, buffer_info->dma,
 			       buffer_info->length, PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
 		skb = buffer_info->skb;
 		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
 
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 348371f..fba87ab 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1394,7 +1394,11 @@ net_open(struct net_device *dev)
 #endif
         if (!result) {
                 printk(KERN_ERR "%s: EEPROM is configured for unavailable media\n", dev->name);
-        release_irq:
+release_dma:
+#if ALLOW_DMA
+		free_dma(dev->dma);
+#endif
+release_irq:
 #if ALLOW_DMA
 		release_dma_buff(lp);
 #endif
@@ -1442,12 +1446,12 @@ net_open(struct net_device *dev)
 			if ((result = detect_bnc(dev)) != DETECTED_NONE)
 				break;
 		printk(KERN_ERR "%s: no media detected\n", dev->name);
-                goto release_irq;
+		goto release_dma;
 	}
 	switch(result) {
 	case DETECTED_NONE:
 		printk(KERN_ERR "%s: no network cable attached to configured media\n", dev->name);
-                goto release_irq;
+		goto release_dma;
 	case DETECTED_RJ45H:
 		printk(KERN_INFO "%s: using half-duplex 10Base-T (RJ-45)\n", dev->name);
 		break;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 36be6ef..e0d76c7 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.3.2-1.287"
+#define MYRI10GE_VERSION_STR "1.3.99-1.347"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index b4b6380..61955f8 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -972,7 +972,7 @@ static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_copy_and_csum_dev(skb, priv->tx_bufs + entry * TX_BUF_SIZE);
 
 	len = skb->len;
-	if (unlikely(len < ETH_ZLEN)) {
+	if (len < ETH_ZLEN) {
 		memset(priv->tx_bufs + entry * TX_BUF_SIZE + len,
 				0, ETH_ZLEN - len);
 		len = ETH_ZLEN;
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index dbdcee4..55c0d97 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -459,7 +459,7 @@ static int falcon_check_xaui_link_up(struct efx_nic *efx)
 		tries--;
 	}
 
-	EFX_ERR(efx, "Failed to bring XAUI link back up in %d tries!\n",
+	EFX_LOG(efx, "Failed to bring XAUI link back up in %d tries!\n",
 		max_tries);
 	return 0;
 }
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index f9d13fa..55670b5 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1729,12 +1729,15 @@ static int tulip_suspend (struct pci_dev *pdev, pm_message_t state)
 	if (!dev)
 		return -EINVAL;
 
-	if (netif_running(dev))
-		tulip_down(dev);
+	if (!netif_running(dev))
+		goto save_state;
+
+	tulip_down(dev);
 
 	netif_device_detach(dev);
 	free_irq(dev->irq, dev);
 
+save_state:
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -1754,6 +1757,9 @@ static int tulip_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
+	if (!netif_running(dev))
+		return 0;
+
 	if ((retval = pci_enable_device(pdev))) {
 		printk (KERN_ERR "tulip: pci_enable_device failed in resume\n");
 		return retval;
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 299b7f1..f5839c4 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -73,6 +73,7 @@ static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"tx-frames-ok",
 	"tx-excessive-differ-frames",
 	"tx-256-511-frames",
+	"tx-512-1023-frames",
 	"tx-1024-1518-frames",
 	"tx-jumbo-frames",
 };
@@ -308,7 +309,7 @@ static void uec_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
 		buf += UEC_TX_FW_STATS_LEN * ETH_GSTRING_LEN;
 	}
 	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
-		memcpy(buf, tx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
+		memcpy(buf, rx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
 			       	ETH_GSTRING_LEN);
 }
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fe7cdf2..5450eac 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -47,6 +47,9 @@ struct virtnet_info
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
 
+	/* For cleaning up after transmission. */
+	struct tasklet_struct tasklet;
+
 	/* Receive & send queues. */
 	struct sk_buff_head recv;
 	struct sk_buff_head send;
@@ -68,8 +71,13 @@ static void skb_xmit_done(struct virtqueue *svq)
 
 	/* Suppress further interrupts. */
 	svq->vq_ops->disable_cb(svq);
+
 	/* We were waiting for more output buffers. */
 	netif_wake_queue(vi->dev);
+
+	/* Make sure we re-xmit last_xmit_skb: if there are no more packets
+	 * queued, start_xmit won't be called. */
+	tasklet_schedule(&vi->tasklet);
 }
 
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
@@ -278,6 +286,18 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 	return vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
 }
 
+static void xmit_tasklet(unsigned long data)
+{
+	struct virtnet_info *vi = (void *)data;
+
+	netif_tx_lock_bh(vi->dev);
+	if (vi->last_xmit_skb && xmit_skb(vi, vi->last_xmit_skb) == 0) {
+		vi->svq->vq_ops->kick(vi->svq);
+		vi->last_xmit_skb = NULL;
+	}
+	netif_tx_unlock_bh(vi->dev);
+}
+
 static int start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -287,21 +307,25 @@ again:
 	free_old_xmit_skbs(vi);
 
 	/* If we has a buffer left over from last time, send it now. */
-	if (vi->last_xmit_skb) {
+	if (unlikely(vi->last_xmit_skb)) {
 		if (xmit_skb(vi, vi->last_xmit_skb) != 0) {
 			/* Drop this skb: we only queue one. */
 			vi->dev->stats.tx_dropped++;
 			kfree_skb(skb);
+			skb = NULL;
 			goto stop_queue;
 		}
 		vi->last_xmit_skb = NULL;
 	}
 
 	/* Put new one in send queue and do transmit */
-	__skb_queue_head(&vi->send, skb);
-	if (xmit_skb(vi, skb) != 0) {
-		vi->last_xmit_skb = skb;
-		goto stop_queue;
+	if (likely(skb)) {
+		__skb_queue_head(&vi->send, skb);
+		if (xmit_skb(vi, skb) != 0) {
+			vi->last_xmit_skb = skb;
+			skb = NULL;
+			goto stop_queue;
+		}
 	}
 done:
 	vi->svq->vq_ops->kick(vi->svq);
@@ -428,6 +452,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	skb_queue_head_init(&vi->recv);
 	skb_queue_head_init(&vi->send);
 
+	tasklet_init(&vi->tasklet, xmit_tasklet, (unsigned long)vi);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
