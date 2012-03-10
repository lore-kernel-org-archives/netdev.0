From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 4/8] r8169: move rtl_set_rx_mode before its rtl_hw_start callers.
Date: Sat, 10 Mar 2012 23:19:51 +0100
Message-ID: <20120310221951.GE9692@electric-eye.fr.zoreil.com>
References: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41091 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752673Ab2CJWVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:21:04 -0500
Content-Disposition: inline
In-Reply-To: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |  101 +++++++++++++++++-----------------
 1 files changed, 50 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5ce9f64..abb6dea 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -777,7 +777,6 @@ MODULE_FIRMWARE(FIRMWARE_8168F_2);
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance);
 static int rtl8169_init_ring(struct net_device *dev);
 static void rtl_hw_start(struct net_device *dev);
-static void rtl_set_rx_mode(struct net_device *dev);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
 
@@ -4223,6 +4222,56 @@ static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
 	}
 }
 
+static void rtl_set_rx_mode(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 mc_filter[2];	/* Multicast hash filter */
+	int rx_mode;
+	u32 tmp = 0;
+
+	if (dev->flags & IFF_PROMISC) {
+		/* Unconditionally log net taps. */
+		netif_notice(tp, link, dev, "Promiscuous mode enabled\n");
+		rx_mode =
+		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
+		    AcceptAllPhys;
+		mc_filter[1] = mc_filter[0] = 0xffffffff;
+	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
+		   (dev->flags & IFF_ALLMULTI)) {
+		/* Too many to filter perfectly -- accept all multicasts. */
+		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
+		mc_filter[1] = mc_filter[0] = 0xffffffff;
+	} else {
+		struct netdev_hw_addr *ha;
+
+		rx_mode = AcceptBroadcast | AcceptMyPhys;
+		mc_filter[1] = mc_filter[0] = 0;
+		netdev_for_each_mc_addr(ha, dev) {
+			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
+			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
+			rx_mode |= AcceptMulticast;
+		}
+	}
+
+	if (dev->features & NETIF_F_RXALL)
+		rx_mode |= (AcceptErr | AcceptRunt);
+
+	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
+
+	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
+		u32 data = mc_filter[0];
+
+		mc_filter[0] = swab32(mc_filter[1]);
+		mc_filter[1] = swab32(data);
+	}
+
+	RTL_W32(MAR0 + 4, mc_filter[1]);
+	RTL_W32(MAR0 + 0, mc_filter[0]);
+
+	RTL_W32(RxConfig, tmp);
+}
+
 static void rtl_hw_start_8169(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -5757,56 +5806,6 @@ static int rtl8169_close(struct net_device *dev)
 	return 0;
 }
 
-static void rtl_set_rx_mode(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	u32 mc_filter[2];	/* Multicast hash filter */
-	int rx_mode;
-	u32 tmp = 0;
-
-	if (dev->flags & IFF_PROMISC) {
-		/* Unconditionally log net taps. */
-		netif_notice(tp, link, dev, "Promiscuous mode enabled\n");
-		rx_mode =
-		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
-		    AcceptAllPhys;
-		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
-		   (dev->flags & IFF_ALLMULTI)) {
-		/* Too many to filter perfectly -- accept all multicasts. */
-		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
-		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else {
-		struct netdev_hw_addr *ha;
-
-		rx_mode = AcceptBroadcast | AcceptMyPhys;
-		mc_filter[1] = mc_filter[0] = 0;
-		netdev_for_each_mc_addr(ha, dev) {
-			int bit_nr = ether_crc(ETH_ALEN, ha->addr) >> 26;
-			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
-			rx_mode |= AcceptMulticast;
-		}
-	}
-
-	if (dev->features & NETIF_F_RXALL)
-		rx_mode |= (AcceptErr | AcceptRunt);
-
-	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
-
-	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
-		u32 data = mc_filter[0];
-
-		mc_filter[0] = swab32(mc_filter[1]);
-		mc_filter[1] = swab32(data);
-	}
-
-	RTL_W32(MAR0 + 4, mc_filter[1]);
-	RTL_W32(MAR0 + 0, mc_filter[0]);
-
-	RTL_W32(RxConfig, tmp);
-}
-
 static struct rtnl_link_stats64 *
 rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
-- 
1.7.7.6
