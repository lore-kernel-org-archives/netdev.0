From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Tue, 27 Dec 2011 00:06:15 -0500
Message-ID: <4EF95247.7000403@gentoo.org>
References: <4EED3A3D.9080503@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Linux MIPS List <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:43748
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750738Ab1L0FGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 00:06:38 -0500
In-Reply-To: <4EED3A3D.9080503@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGI IP32 (O2)'s ethernet driver (meth) lacks a set_rx_mode function, which
prevents IPv6 from working completely because any ICMPv6 neighbor
solicitation requests aren't picked up by the driver.  So the machine can
ping out and connect to other systems, but other systems will have a very
hard time connecting to the O2.

Signed-off-by: Joshua Kinard <kumba@gentoo.org>
---

 arch/mips/include/asm/ip32/mace.h |    2 -
 drivers/net/ethernet/sgi/meth.c   |   48 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 48 insertions(+), 2 deletions(-)

diff -Naurp a/arch/mips/include/asm/ip32/mace.h
b/arch/mips/include/asm/ip32/mace.h
--- a/arch/mips/include/asm/ip32/mace.h	2011-12-24 16:19:46.703561171 -0500
+++ b/arch/mips/include/asm/ip32/mace.h	2011-12-26 20:04:15.281839510 -0500
@@ -95,7 +95,7 @@ struct mace_video {
  * Ethernet interface
  */
 struct mace_ethernet {
-	volatile unsigned long mac_ctrl;
+	volatile u64 mac_ctrl;
 	volatile unsigned long int_stat;
 	volatile unsigned long dma_ctrl;
 	volatile unsigned long timer;
diff -Naurp a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
--- a/drivers/net/ethernet/sgi/meth.c	2011-12-24 16:20:06.743560985 -0500
+++ b/drivers/net/ethernet/sgi/meth.c	2011-12-26 20:03:53.471839710 -0500
@@ -28,6 +28,7 @@
 #include <linux/tcp.h>         /* struct tcphdr */
 #include <linux/skbuff.h>
 #include <linux/mii.h>         /* MII definitions */
+#include <linux/crc32.h>

 #include <asm/ip32/mace.h>
 #include <asm/ip32/ip32_ints.h>
@@ -58,12 +59,19 @@ static int timeout = TX_TIMEOUT;
 module_param(timeout, int, 0);

 /*
+ * Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
+ * MACE Ethernet uses a 64 element hash table based on the Ethernet CRC.
+ */
+#define METH_MCF_LIMIT 32
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
 	unsigned long dma_ctrl;
 	/* address of PHY, used by mdio_* functions, initialized in mdio_probe */
@@ -79,6 +87,9 @@ struct meth_private {
 	struct sk_buff *rx_skbs[RX_RING_ENTRIES];
 	unsigned long rx_write;

+	/* Multicast filter. */
+	u64 mcast_filter;
+
 	spinlock_t meth_lock;
 };

@@ -765,6 +776,40 @@ static int meth_ioctl(struct net_device
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
@@ -774,6 +819,7 @@ static const struct net_device_ops meth_
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_rx_mode    	= meth_set_rx_mode,
 };

 /*
