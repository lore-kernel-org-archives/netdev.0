From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 21/45] 3c59x: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:18 -0800
Message-ID: <20090109230138.260145774@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42258 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609AbZAIXSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:05 -0500
Content-Disposition: inline; filename=3c59x.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c59x.c	2009-01-08 10:29:45.774507470 -0800
+++ b/drivers/net/3c59x.c	2009-01-08 10:34:17.010259034 -0800
@@ -992,6 +992,42 @@ out:
 	return rc;
 }
 
+static const struct net_device_ops boomrang_netdev_ops = {
+	.ndo_open		= vortex_open,
+	.ndo_stop		= vortex_close,
+	.ndo_start_xmit		= boomerang_start_xmit,
+	.ndo_tx_timeout		= vortex_tx_timeout,
+	.ndo_get_stats		= vortex_get_stats,
+#ifdef CONFIG_PCI
+	.ndo_do_ioctl 		= vortex_ioctl,
+#endif
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= poll_vortex,
+#endif
+};
+
+static const struct net_device_ops vortex_netdev_ops = {
+	.ndo_open		= vortex_open,
+	.ndo_stop		= vortex_close,
+	.ndo_start_xmit		= vortex_start_xmit,
+	.ndo_tx_timeout		= vortex_tx_timeout,
+	.ndo_get_stats		= vortex_get_stats,
+#ifdef CONFIG_PCI
+	.ndo_do_ioctl 		= vortex_ioctl,
+#endif
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= poll_vortex,
+#endif
+};
+
 /*
  * Start up the PCI/EISA device which is described by *gendev.
  * Return 0 on success.
@@ -1366,18 +1402,16 @@ static int __devinit vortex_probe1(struc
 	}
 
 	/* The 3c59x-specific entries in the device structure. */
-	dev->open = vortex_open;
 	if (vp->full_bus_master_tx) {
-		dev->hard_start_xmit = boomerang_start_xmit;
+		dev->netdev_ops = &boomrang_netdev_ops;
 		/* Actually, it still should work with iommu. */
 		if (card_idx < MAX_UNITS &&
 		    ((hw_checksums[card_idx] == -1 && (vp->drv_flags & HAS_HWCKSM)) ||
 				hw_checksums[card_idx] == 1)) {
 			dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		}
-	} else {
-		dev->hard_start_xmit = vortex_start_xmit;
-	}
+	} else
+		dev->netdev_ops =  &vortex_netdev_ops;
 
 	if (print_info) {
 		printk(KERN_INFO "%s: scatter/gather %sabled. h/w checksums %sabled\n",
@@ -1386,18 +1420,9 @@ static int __devinit vortex_probe1(struc
 				(dev->features & NETIF_F_IP_CSUM) ? "en":"dis");
 	}
 
-	dev->stop = vortex_close;
-	dev->get_stats = vortex_get_stats;
-#ifdef CONFIG_PCI
-	dev->do_ioctl = vortex_ioctl;
-#endif
 	dev->ethtool_ops = &vortex_ethtool_ops;
-	dev->set_multicast_list = set_rx_mode;
-	dev->tx_timeout = vortex_tx_timeout;
 	dev->watchdog_timeo = (watchdog * HZ) / 1000;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = poll_vortex;
-#endif
+
 	if (pdev) {
 		vp->pm_state_valid = 1;
  		pci_save_state(VORTEX_PCI(vp));


