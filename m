From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next] netdevice: Kill netdev->priv
Date: Mon, 08 Dec 2008 13:35:54 +0800
Message-ID: <493CB23A.5010400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50539 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbYLHFn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 00:43:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the last shoot of this series.
After I removing all directly reference of netdev->priv, I am killing
"priv" of "struct net_device" and fixing relative comments/docs.

Anyone will not be allowed to reference netdev->priv directly.
If you want to reference the memory of private data, use netdev_priv()
instead.
If the private data is not allocted when alloc_netdev(), use
netdev->ml_priv to point that memory after you creating that private
data.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 Documentation/networking/driver.txt     |    2 +-
 Documentation/networking/netdevices.txt |    2 +-
 drivers/net/3c501.h                     |    2 +-
 drivers/net/atp.c                       |    2 +-
 drivers/net/eexpress.c                  |    2 +-
 drivers/net/forcedeth.c                 |    4 ++--
 drivers/net/lance.c                     |    2 +-
 drivers/net/myri_sbus.c                 |    2 +-
 drivers/net/pci-skeleton.c              |    2 +-
 drivers/net/sun3_82586.c                |    2 +-
 drivers/net/sunbmac.c                   |    2 +-
 drivers/net/tokenring/3c359.c           |    5 +++--
 drivers/net/via-rhine.c                 |    9 +++++----
 drivers/net/wireless/strip.c            |    2 +-
 include/linux/hdlc.h                    |    2 +-
 include/linux/netdevice.h               |    1 -
 net/atm/mpc.c                           |    4 ++--
 net/core/dev.c                          |    6 ------
 18 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/Documentation/networking/driver.txt b/Documentation/networking/driver.txt
index ea72d2e..03283da 100644
--- a/Documentation/networking/driver.txt
+++ b/Documentation/networking/driver.txt
@@ -13,7 +13,7 @@ Transmit path guidelines:
 	static int drv_hard_start_xmit(struct sk_buff *skb,
 		   		       struct net_device *dev)
 	{
-		struct drv *dp = dev->priv;
+		struct drv *dp = netdev_priv(dev);
 
 		lock_tx(dp);
 		...
diff --git a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
index d0f71fc..a2ab6a0 100644
--- a/Documentation/networking/netdevices.txt
+++ b/Documentation/networking/netdevices.txt
@@ -18,7 +18,7 @@ There are routines in net_init.c to handle the common cases of
 alloc_etherdev, alloc_netdev.  These reserve extra space for driver
 private data which gets freed when the network device is freed. If
 separately allocated data is attached to the network device
-(dev->priv) then it is up to the module exit handler to free that.
+(netdev_priv(dev)) then it is up to the module exit handler to free that.
 
 MTU
 ===
diff --git a/drivers/net/3c501.h b/drivers/net/3c501.h
index cfec64e..f40b049 100644
--- a/drivers/net/3c501.h
+++ b/drivers/net/3c501.h
@@ -23,7 +23,7 @@ static const struct ethtool_ops netdev_ethtool_ops;
 static int el_debug = EL_DEBUG;
 
 /*
- *	Board-specific info in dev->priv.
+ *	Board-specific info in netdev_priv(dev).
  */
 
 struct net_local
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 7028b27..1d6b74c 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -420,7 +420,7 @@ static unsigned short __init eeprom_op(long ioaddr, u32 cmd)
    registers that "should" only need to be set once at boot, so that
    there is non-reboot way to recover if something goes wrong.
 
-   This is an attachable device: if there is no dev->priv entry then it wasn't
+   This is an attachable device: if there is no private entry then it wasn't
    probed for at boot-time, and we need to probe for it again.
    */
 static int net_open(struct net_device *dev)
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index a125e41..9ff3f2f 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1046,7 +1046,7 @@ static void eexp_hw_tx_pio(struct net_device *dev, unsigned short *buf,
 /*
  * Sanity check the suspected EtherExpress card
  * Read hardware address, reset card, size memory and initialize buffer
- * memory pointers. These are held in dev->priv, in case someone has more
+ * memory pointers. These are held in netdev_priv(), in case someone has more
  * than one card in a machine.
  */
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 12384df..1f2b247 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -712,12 +712,12 @@ struct nv_skb_map {
 
 /*
  * SMP locking:
- * All hardware access under dev->priv->lock, except the performance
+ * All hardware access under netdev_priv(dev)->lock, except the performance
  * critical parts:
  * - rx is (pseudo-) lockless: it relies on the single-threading provided
  *	by the arch code for interrupts.
  * - tx setup is lockless: it relies on netif_tx_lock. Actual submission
- *	needs dev->priv->lock :-(
+ *	needs netdev_priv(dev)->lock :-(
  * - set_multicast_list: preparation lockless, relies on netif_tx_lock.
  */
 
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index e81b611..d7afb93 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -519,7 +519,7 @@ static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int
 		}
 	}
 
-	/* We can't allocate dev->priv from alloc_etherdev() because it must
+	/* We can't allocate private data from alloc_etherdev() because it must
 	   a ISA DMA-able region. */
 	chipname = chip_table[lance_version].name;
 	printk("%s: %s at %#3x, ", dev->name, chipname, ioaddr);
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 6833f65..899ed06 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -1091,7 +1091,7 @@ static int __devinit myri_sbus_probe(struct of_device *op, const struct of_devic
 err_free_irq:
 	free_irq(dev->irq, dev);
 err:
-	/* This will also free the co-allocated 'dev->priv' */
+	/* This will also free the co-allocated private data*/
 	free_netdev(dev);
 	return -ENODEV;
 }
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index b23b5c3..c95fd72 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -781,7 +781,7 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 
-	/* dev->priv/tp zeroed and aligned in alloc_etherdev */
+	/* netdev_priv()/tp zeroed and aligned in alloc_etherdev */
 	tp = netdev_priv(dev);
 
 	/* note: tp->chipset set in netdrv_init_board */
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index e8f97d5..e0d8477 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -209,7 +209,7 @@ static int sun3_82586_open(struct net_device *dev)
 static int check586(struct net_device *dev,char *where,unsigned size)
 {
 	struct priv pb;
-	struct priv *p = /* (struct priv *) dev->priv*/ &pb;
+	struct priv *p = &pb;
 	char *iscp_addr;
 	int i;
 
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 977b3e0..7f69c7f 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1233,7 +1233,7 @@ fail_and_cleanup:
 				  bp->bmac_block,
 				  bp->bblock_dvma);
 
-	/* This also frees the co-located 'dev->priv' */
+	/* This also frees the co-located private data */
 	free_netdev(dev);
 	return -ENODEV;
 }
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index e7a9446..43853e3 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -296,8 +296,9 @@ static int __devinit xl_probe(struct pci_dev *pdev,
 	} ; 
 
 	/* 
-	 * Allowing init_trdev to allocate the dev->priv structure will align xl_private
-   	 * on a 32 bytes boundary which we need for the rx/tx descriptors
+	 * Allowing init_trdev to allocate the private data will align
+	 * xl_private on a 32 bytes boundary which we need for the rx/tx
+	 * descriptors
 	 */
 
 	dev = alloc_trdev(sizeof(struct xl_private)) ; 
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 93b74b7..8d405c8 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -191,12 +191,13 @@ IIId. Synchronization
 
 The driver runs as two independent, single-threaded flows of control. One
 is the send-packet routine, which enforces single-threaded use by the
-dev->priv->lock spinlock. The other thread is the interrupt handler, which
-is single threaded by the hardware and interrupt handling software.
+netdev_priv(dev)->lock spinlock. The other thread is the interrupt handler,
+which is single threaded by the hardware and interrupt handling software.
 
 The send packet thread has partial control over the Tx ring. It locks the
-dev->priv->lock whenever it's queuing a Tx packet. If the next slot in the ring
-is not available it stops the transmit queue by calling netif_stop_queue.
+netdev_priv(dev)->lock whenever it's queuing a Tx packet. If the next slot in
+the ring is not available it stops the transmit queue by
+calling netif_stop_queue.
 
 The interrupt handler has exclusive control over the Rx ring and records stats
 from the Tx ring. After reaping the stats, it marks the Tx queue entry as
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 692e6c5..dd0de3a 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -2494,7 +2494,7 @@ static void strip_dev_setup(struct net_device *dev)
 	dev->type = ARPHRD_METRICOM;	/* dtang */
 	dev->hard_header_len = sizeof(STRIP_Header);
 	/*
-	 *  dev->priv             Already holds a pointer to our struct strip
+	 *  netdev_priv(dev) Already holds a pointer to our struct strip
 	 */
 
 	*(MetricomAddress *) & dev->broadcast = broadcast_address;
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index e960faa..fd47a15 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -43,7 +43,7 @@ struct hdlc_proto {
 };
 
 
-/* Pointed to by dev->priv */
+/* Pointed to by netdev_priv(dev) */
 typedef struct hdlc_device {
 	/* used by HDLC layer to take control over HDLC device from hw driver*/
 	int (*attach)(struct net_device *dev,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0df0db0..47e7315 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -785,7 +785,6 @@ struct net_device
 /*
  * One part is mostly used on xmit path (device)
  */
-	void			*priv;	/* pointer to private data	*/
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 12e9ea3..039d5cc 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -341,8 +341,8 @@ static const char *mpoa_device_type_string(char type)
 }
 
 /*
- * lec device calls this via its dev->priv->lane2_ops->associate_indicator()
- * when it sees a TLV in LE_ARP packet.
+ * lec device calls this via its netdev_priv(dev)->lane2_ops
+ * ->associate_indicator() when it sees a TLV in LE_ARP packet.
  * We fill in the pointer above when we see a LANE2 lec initializing
  * See LANE2 spec 3.1.5
  *
diff --git a/net/core/dev.c b/net/core/dev.c
index 4615e9a..f54cac7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4378,12 +4378,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->num_tx_queues = queue_count;
 	dev->real_num_tx_queues = queue_count;
 
-	if (sizeof_priv) {
-		dev->priv = ((char *)dev +
-			     ((sizeof(struct net_device) + NETDEV_ALIGN_CONST)
-			      & ~NETDEV_ALIGN_CONST));
-	}
-
 	dev->gso_max_size = GSO_MAX_SIZE;
 
 	netdev_init_queues(dev);
-- 
1.5.3.4





