From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Sat, 24 Dec 2011 20:45:32 -0500
Message-ID: <4EF6803C.9060203@gentoo.org>
References: <4EED3A3D.9080503@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Linux MIPS List <linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4EED3A3D.9080503@gentoo.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

SGI IP32 (O2)'s ethernet driver (meth) lacks meth_set_rx_mode, which
prevents IPv6 from working completely because any ICMPv6 neighbor
solicitation requests aren't picked up by the driver.  So the machine can
ping out and connect to other systems, but other systems will have a very
hard time connecting to the O2.

Signed-off-by: Joshua Kinard <kumba@gentoo.org>
---

 arch/mips/include/asm/ip32/mace.h |   52 +++++++++++++++----------------
 drivers/net/ethernet/sgi/meth.c   |   62 ++++++++++++++++++++++++++++++++++----
 2 files changed, 82 insertions(+), 32 deletions(-)

diff -Naurp a/arch/mips/include/asm/ip32/mace.h
b/arch/mips/include/asm/ip32/mace.h
--- a/arch/mips/include/asm/ip32/mace.h	2011-12-24 16:19:46.703561171 -0500
+++ b/arch/mips/include/asm/ip32/mace.h	2011-12-24 16:27:40.613556791 -0500
@@ -95,35 +95,35 @@ struct mace_video {
  * Ethernet interface
  */
 struct mace_ethernet {
-	volatile unsigned long mac_ctrl;
-	volatile unsigned long int_stat;
-	volatile unsigned long dma_ctrl;
-	volatile unsigned long timer;
-	volatile unsigned long tx_int_al;
-	volatile unsigned long rx_int_al;
-	volatile unsigned long tx_info;
-	volatile unsigned long tx_info_al;
-	volatile unsigned long rx_buff;
-	volatile unsigned long rx_buff_al1;
-	volatile unsigned long rx_buff_al2;
-	volatile unsigned long diag;
-	volatile unsigned long phy_data;
-	volatile unsigned long phy_regs;
-	volatile unsigned long phy_trans_go;
-	volatile unsigned long backoff_seed;
+	volatile u64 mac_ctrl;
+	volatile u64 int_stat;
+	volatile u64 dma_ctrl;
+	volatile u64 timer;
+	volatile u64 tx_int_al;
+	volatile u64 rx_int_al;
+	volatile u64 tx_info;
+	volatile u64 tx_info_al;
+	volatile u64 rx_buff;
+	volatile u64 rx_buff_al1;
+	volatile u64 rx_buff_al2;
+	volatile u64 diag;
+	volatile u64 phy_data;
+	volatile u64 phy_regs;
+	volatile u64 phy_trans_go;
+	volatile u64 backoff_seed;
 	/*===================================*/
-	volatile unsigned long imq_reserved[4];
-	volatile unsigned long mac_addr;
-	volatile unsigned long mac_addr2;
-	volatile unsigned long mcast_filter;
-	volatile unsigned long tx_ring_base;
+	volatile u64 imq_reserved[4];
+	volatile u64 mac_addr;
+	volatile u64 mac_addr2;
+	volatile u64 mcast_filter;
+	volatile u64 tx_ring_base;
 	/* Following are read-only registers for debugging */
-	volatile unsigned long tx_pkt1_hdr;
-	volatile unsigned long tx_pkt1_ptr[3];
-	volatile unsigned long tx_pkt2_hdr;
-	volatile unsigned long tx_pkt2_ptr[3];
+	volatile u64 tx_pkt1_hdr;
+	volatile u64 tx_pkt1_ptr[3];
+	volatile u64 tx_pkt2_hdr;
+	volatile u64 tx_pkt2_ptr[3];
 	/*===================================*/
-	volatile unsigned long rx_fifo;
+	volatile u64 rx_fifo;
 };

 /*
diff -Naurp a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
--- a/drivers/net/ethernet/sgi/meth.c	2011-12-24 16:20:06.743560985 -0500
+++ b/drivers/net/ethernet/sgi/meth.c	2011-12-24 16:27:18.743556993 -0500
@@ -28,6 +28,7 @@
 #include <linux/tcp.h>         /* struct tcphdr */
 #include <linux/skbuff.h>
 #include <linux/mii.h>         /* MII definitions */
+#include <linux/crc32.h>

 #include <asm/ip32/mace.h>
 #include <asm/ip32/ip32_ints.h>
@@ -48,9 +49,6 @@
 #define MFE_RX_DEBUG 0
 #endif

-
-static const char *meth_str="SGI O2 Fast Ethernet";
-
 /* The maximum time waited (in jiffies) before assuming a Tx failed. (400ms) */
 #define TX_TIMEOUT (400*HZ/1000)

@@ -58,27 +56,44 @@ static int timeout = TX_TIMEOUT;
 module_param(timeout, int, 0);

 /*
+ * Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
+ * MACE Ethernet uses a 64 element hash table based on the Ethernet CRC.
+ */
+#define METH_MCF_LIMIT 32
+
+/* Driver name */
+#define METH_DRV_NAME "SGI O2 Fast Ethernet"
+
+/*
  * This structure is private to each device. It is used to pass
  * packets in and out, so there is place for a packet
  */
 struct meth_private {
 	/* in-memory copy of MAC Control register */
-	unsigned long mac_ctrl;
+	u64 mac_ctrl;
+
 	/* in-memory copy of DMA Control register */
-	unsigned long dma_ctrl;
+	u64 dma_ctrl;
+
 	/* address of PHY, used by mdio_* functions, initialized in mdio_probe */
 	unsigned long phy_addr;
+
+	/* TX bits */
 	tx_packet *tx_ring;
 	dma_addr_t tx_ring_dma;
 	struct sk_buff *tx_skbs[TX_RING_ENTRIES];
 	dma_addr_t tx_skb_dmas[TX_RING_ENTRIES];
 	unsigned long tx_read, tx_write, tx_count;

+	/* RX bits */
 	rx_packet *rx_ring[RX_RING_ENTRIES];
 	dma_addr_t rx_ring_dmas[RX_RING_ENTRIES];
 	struct sk_buff *rx_skbs[RX_RING_ENTRIES];
 	unsigned long rx_write;

+	/* Multicast filter. */
+	u64 mcast_filter;
+
 	spinlock_t meth_lock;
 };

@@ -323,7 +338,7 @@ static int meth_open(struct net_device *
 	if (ret < 0)
 		goto out_free_tx_ring;

-	ret = request_irq(dev->irq, meth_interrupt, 0, meth_str, dev);
+	ret = request_irq(dev->irq, meth_interrupt, 0, METH_DRV_NAME, dev);
 	if (ret) {
 		printk(KERN_ERR "%s: Can't get irq %d\n", dev->name, dev->irq);
 		goto out_free_rx_ring;
@@ -765,6 +780,40 @@ static int meth_ioctl(struct net_device
 	}
 }

+static void meth_set_rx_mode(struct net_device *dev)
+{
+	struct meth_private *priv = netdev_priv(dev);
+	unsigned long flags;
+
+	netif_stop_queue(dev);
+	spin_lock_irqsave(&priv->meth_lock, flags);
+	priv->mac_ctrl &= ~METH_PROMISC;
+
+	if (dev->flags & IFF_PROMISC) {
+		priv->mac_ctrl |= METH_PROMISC;
+		priv->mcast_filter = 0xffffffffffffffffUL;
+	} else if ((netdev_mc_count(dev) > METH_MCF_LIMIT) ||
+		   (dev->flags & IFF_ALLMULTI)) {
+		priv->mac_ctrl |= METH_ACCEPT_AMCAST;
+		priv->mcast_filter = 0xffffffffffffffffUL;
+	} else {
+		struct netdev_hw_addr *ha;
+		priv->mac_ctrl |= METH_ACCEPT_MCAST;
+
+		netdev_for_each_mc_addr(ha, dev)
+			set_bit((ether_crc(ETH_ALEN, ha->addr) >> 26),
+			        (volatile unsigned long *)&priv->mcast_filter);
+	}
+
+	/* Write the changes to the chip registers. */
+	mace->eth.mac_ctrl = priv->mac_ctrl;
+	mace->eth.mcast_filter = priv->mcast_filter;
+
+	/* Done! */
+	spin_unlock_irqrestore(&priv->meth_lock, flags);
+	netif_wake_queue(dev);
+}
+
 static const struct net_device_ops meth_netdev_ops = {
 	.ndo_open		= meth_open,
 	.ndo_stop		= meth_release,
@@ -774,6 +823,7 @@ static const struct net_device_ops meth_
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_rx_mode    	= meth_set_rx_mode,
 };

 /*
