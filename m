From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: skb_tx_hash() improvements
Date: Fri, 01 May 2009 10:29:09 +0200
Message-ID: <49FAB2D5.60508@cosmosbay.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>	 <20090430.022417.07019547.davem@davemloft.net>	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>	 <20090430.070811.260649067.davem@davemloft.net> <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com> <49FA932B.4030405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Dickinson <andrew@whydna.net>, jelaas@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55761 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbZEAI3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 04:29:18 -0400
In-Reply-To: <49FA932B.4030405@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, here is the followup I promised

Thanks

[PATCH] net: skb_tx_hash() improvements

When skb_rx_queue_recorded() is true, we dont want to use jhash distribution
as the device driver exactly told us which queue was selected at RX time.
jhash makes a statistical shuffle, but this wont work with only 8 different inputs.

We also need to implement a true reciprocal division, to not disturb
symmetric setups (when number of tx queues matches number of rx queues)
and cpu affinities.

This patch introduces a new helper, dev_real_num_tx_queues_set()
to set both real_num_tx_queues and its reciprocal value,
and makes all drivers use this helper.

Many thanks to Andrew Dickinson to let us see the light here :)

Reported-by: Andrew Dickinson <andrew@whydna.net>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 drivers/net/bnx2.c              |    2 +-
 drivers/net/bnx2x_main.c        |    2 +-
 drivers/net/cxgb3/cxgb3_main.c  |    2 +-
 drivers/net/igb/igb_main.c      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c  |    2 +-
 drivers/net/mv643xx_eth.c       |    2 +-
 drivers/net/myri10ge/myri10ge.c |    4 ++--
 drivers/net/niu.c               |    2 +-
 drivers/net/vxge/vxge-main.c    |    2 +-
 include/linux/netdevice.h       |    2 ++
 net/core/dev.c                  |   26 ++++++++++++++++++--------
 11 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d478391..1f674c1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5951,7 +5951,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 	}
 
 	bp->num_tx_rings = rounddown_pow_of_two(bp->irq_nvecs);
-	bp->dev->real_num_tx_queues = bp->num_tx_rings;
+	dev_real_num_tx_queues_set(bp->dev, bp->num_tx_rings);
 
 	bp->num_rx_rings = bp->irq_nvecs;
 }
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ad5ef25..d5c641b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6800,7 +6800,7 @@ static void bnx2x_set_int_mode(struct bnx2x *bp)
 		}
 		break;
 	}
-	bp->dev->real_num_tx_queues = bp->num_tx_queues;
+	dev_real_num_tx_queues_set(bp->dev, bp->num_tx_queues);
 }
 
 static void bnx2x_set_rx_mode(struct net_device *dev);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 7ea4841..a84abf3 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1220,7 +1220,7 @@ static int cxgb_open(struct net_device *dev)
 			       "Could not initialize offload capabilities\n");
 	}
 
-	dev->real_num_tx_queues = pi->nqsets;
+	dev_real_num_tx_queues_set(dev, pi->nqsets);
 	link_start(dev);
 	t3_port_intr_enable(adapter, pi->port_id);
 	netif_tx_start_all_queues(dev);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 08c8014..48c530d 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -691,7 +691,7 @@ msi_only:
 		adapter->flags |= IGB_FLAG_HAS_MSI;
 out:
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
+	dev_real_num_tx_queues_set(adapter->netdev, adapter->num_tx_queues);
 	return;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 07e778d..4b4369b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2737,7 +2737,7 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 
 done:
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
+	dev_real_num_tx_queues_set(adapter->netdev, adapter->num_tx_queues);
 }
 
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b3185bf..cb6d859 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2904,7 +2904,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->dev = dev;
 
 	set_params(mp, pd);
-	dev->real_num_tx_queues = mp->txq_count;
+	dev_real_num_tx_queues_set(dev, mp->txq_count);
 
 	if (pd->phy_addr != MV643XX_ETH_PHY_NONE)
 		mp->phy = phy_scan(mp, pd->phy_addr);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index f2c4a66..bfb6a11 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -968,7 +968,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 		 * RX queues, so if we get an error, first retry using a
 		 * single TX queue before giving up */
 		if (status != 0 && mgp->dev->real_num_tx_queues > 1) {
-			mgp->dev->real_num_tx_queues = 1;
+			dev_real_num_tx_queues_set(mgp->dev, 1);
 			cmd.data0 = mgp->num_slices;
 			cmd.data1 = MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE;
 			status = myri10ge_send_cmd(mgp,
@@ -3862,7 +3862,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "failed to alloc slice state\n");
 		goto abort_with_firmware;
 	}
-	netdev->real_num_tx_queues = mgp->num_slices;
+	dev_real_num_tx_queues_set(netdev, mgp->num_slices);
 	status = myri10ge_reset(mgp);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed reset\n");
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2b17453..a6eac3b 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4501,7 +4501,7 @@ static int niu_alloc_channels(struct niu *np)
 	np->num_rx_rings = parent->rxchan_per_port[port];
 	np->num_tx_rings = parent->txchan_per_port[port];
 
-	np->dev->real_num_tx_queues = np->num_tx_rings;
+	dev_real_num_tx_queues_set(np->dev, np->num_tx_rings);
 
 	np->rx_rings = kzalloc(np->num_rx_rings * sizeof(struct rx_ring_info),
 			       GFP_KERNEL);
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index b7f08f3..15602ab 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3331,7 +3331,7 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 		ndev->features |= NETIF_F_GRO;
 
 	if (vdev->config.tx_steering_type == TX_MULTIQ_STEERING)
-		ndev->real_num_tx_queues = no_of_vpath;
+		dev_real_num_tx_queues_set(ndev, no_of_vpath);
 
 #ifdef NETIF_F_LLTX
 	ndev->features |= NETIF_F_LLTX;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5a96a1a..f3939ec 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -790,6 +790,7 @@ struct net_device
 
 	/* Number of TX queues currently active in device  */
 	unsigned int		real_num_tx_queues;
+	unsigned int		rec_real_num_tx_queues; /* reciprocal value */
 
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 	spinlock_t		tx_global_lock;
@@ -1782,6 +1783,7 @@ static inline void netif_addr_unlock_bh(struct net_device *dev)
 
 extern void		ether_setup(struct net_device *dev);
 
+extern void dev_real_num_tx_queues_set(struct net_device *dev, unsigned int count);
 /* Support for loadable net-drivers */
 extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 				       void (*setup)(struct net_device *),
diff --git a/net/core/dev.c b/net/core/dev.c
index 308a7d0..dfb8f32 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -126,6 +126,7 @@
 #include <linux/in.h>
 #include <linux/jhash.h>
 #include <linux/random.h>
+#include <linux/reciprocal_div.h>
 
 #include "net-sysfs.h"
 
@@ -1735,19 +1736,28 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 {
 	u32 hash;
 
-	if (skb_rx_queue_recorded(skb)) {
+	if (skb_rx_queue_recorded(skb))
 		hash = skb_get_rx_queue(skb);
-	} else if (skb->sk && skb->sk->sk_hash) {
-		hash = skb->sk->sk_hash;
-	} else
-		hash = skb->protocol;
+	else {
+		if (skb->sk && skb->sk->sk_hash)
+			hash = skb->sk->sk_hash;
+		else
+			hash = skb->protocol;
 
-	hash = jhash_1word(hash, skb_tx_hashrnd);
+		hash = jhash_1word(hash, skb_tx_hashrnd);
+	}
+	return (u16) reciprocal_divide(hash, dev->rec_real_num_tx_queues);
 
-	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
 EXPORT_SYMBOL(skb_tx_hash);
 
+void dev_real_num_tx_queues_set(struct net_device *dev, unsigned int count)
+{
+	dev->real_num_tx_queues = count;
+	dev->rec_real_num_tx_queues = reciprocal_value(count);
+}
+EXPORT_SYMBOL(dev_real_num_tx_queues_set);
+
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
@@ -4781,7 +4791,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev->_tx = tx;
 	dev->num_tx_queues = queue_count;
-	dev->real_num_tx_queues = queue_count;
+	dev_real_num_tx_queues_set(dev, queue_count);
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 
