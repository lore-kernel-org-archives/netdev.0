From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH 2.6.9-rc3-mm2] 3c59x: support more ethtool_ops
Date: Tue, 5 Oct 2004 15:41:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005134143.GA4829@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With this the driver supports the ethtool_ops {get,set}_msglvl, 
{get,set}_settings, get_stats, get_link, and nway_reset.
Patch is tested with a 3c905-TX and a3c905B-TX NIC.

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
 
--- vanilla-2.6.9-rc3-mm2/drivers/net/3c59x.c	Mon Oct  4 09:52:58 2004
+++ linux-2.6.9-rc3-mm2/drivers/net/3c59x.c	Tue Oct  5 11:54:02 2004
@@ -881,6 +881,22 @@
   { "Default",	 0,			0xFF, XCVR_10baseT, 10000},
 };
 
+static struct {
+	const char str[ETH_GSTRING_LEN];
+} ethtool_stats_keys[] = {
+	{ "rx_packets" },
+	{ "tx_packets" },
+	{ "rx_bytes" },
+	{ "tx_bytes" },
+	{ "collisions" },
+	{ "tx_carrier_errors" },
+	{ "tx_heartbeat_errors" },
+	{ "tx_window_errors" },
+};
+
+/* number of ETHTOOL_GSTATS u64's */
+#define VORTEX_NUM_STATS      8
+
 static int vortex_probe1(struct device *gendev, long ioaddr, int irq,
 				   int chip_idx, int card_idx);
 static void vortex_up(struct net_device *dev);
@@ -2874,6 +2890,85 @@
 	return;
 }
 
+static int vortex_nway_reset(struct net_device *dev)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+	long ioaddr = dev->base_addr;
+	EL3WINDOW(4);
+	return mii_nway_restart(&vp->mii);
+}
+
+static u32 vortex_get_link(struct net_device *dev)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+	long ioaddr = dev->base_addr;
+	EL3WINDOW(4);
+	return mii_link_ok(&vp->mii);
+}
+
+static int vortex_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+	long ioaddr = dev->base_addr;
+	EL3WINDOW(4);
+	return mii_ethtool_gset(&vp->mii, cmd);
+}
+
+static int vortex_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+	long ioaddr = dev->base_addr;
+	EL3WINDOW(4);
+	return mii_ethtool_sset(&vp->mii, cmd);
+}
+
+static u32 vortex_get_msglevel(struct net_device *dev)
+{
+	return vortex_debug;
+}
+
+static void vortex_set_msglevel(struct net_device *dev, u32 dbg)
+{
+	vortex_debug = dbg;
+}
+
+static int vortex_get_stats_count(struct net_device *dev)
+{
+	return VORTEX_NUM_STATS;
+}
+
+static void vortex_get_ethtool_stats(struct net_device *dev,
+	struct ethtool_stats *stats, u64 *data)
+{
+	struct vortex_private *vp = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave (&vp->lock, flags);
+	update_stats(dev->base_addr, dev);
+	spin_unlock_irqrestore (&vp->lock, flags);
+
+	data[0] = vp->stats.rx_packets;
+	data[1] = vp->stats.tx_packets;
+	data[2] = vp->stats.rx_bytes;
+	data[3] = vp->stats.tx_bytes;
+	data[4] = vp->stats.collisions;
+	data[5] = vp->stats.tx_carrier_errors;
+	data[6] = vp->stats.tx_heartbeat_errors;
+	data[7] = vp->stats.tx_window_errors;
+}
+
+
+static void vortex_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, &ethtool_stats_keys, sizeof(ethtool_stats_keys));
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
 
 static void vortex_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *info)
@@ -2895,6 +2990,15 @@
 
 static struct ethtool_ops vortex_ethtool_ops = {
 	.get_drvinfo =		vortex_get_drvinfo,
+	.get_strings            = vortex_get_strings,
+	.get_msglevel           = vortex_get_msglevel,
+	.set_msglevel           = vortex_set_msglevel,
+	.get_ethtool_stats      = vortex_get_ethtool_stats,
+	.get_stats_count        = vortex_get_stats_count,
+	.get_settings           = vortex_get_settings,
+	.set_settings           = vortex_set_settings,
+	.get_link               = vortex_get_link,
+	.nway_reset             = vortex_nway_reset,
 };
 
 #ifdef CONFIG_PCI
