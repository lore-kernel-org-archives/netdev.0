From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] 3c59x: convert to net_device_ops
Date: Sat, 21 Mar 2009 12:35:53 +0100
Message-ID: <20090321113552.GB3380@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	klassert@mathematik.tu-chemnitz.de, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756084AbZCULgk@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I converted this driver to use net_device_ops. I made two structures, one for
vortex and one for boomerang start_xmit function. Tested on my test system with
3Com PCI 3c905C Tornado.

Jirka

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/3c59x.c |   50 ++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index cdbbb62..6c3d66b 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -992,6 +992,38 @@ out:
 	return rc;
 }
 
+static const struct net_device_ops vortex_netdev_ops = {
+	.ndo_open               = vortex_open,
+	.ndo_stop               = vortex_close,
+	.ndo_start_xmit         = vortex_start_xmit,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_validate_addr      = eth_validate_addr,
+#ifdef CONFIG_PCI
+	.ndo_do_ioctl		= vortex_ioctl,
+#endif
+	.ndo_tx_timeout         = vortex_tx_timeout,
+	.ndo_get_stats		= vortex_get_stats,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller    = poll_vortex,
+#endif
+};
+
+static const struct net_device_ops boomerang_netdev_ops = {
+	.ndo_open               = vortex_open,
+	.ndo_stop               = vortex_close,
+	.ndo_start_xmit         = boomerang_start_xmit,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_validate_addr      = eth_validate_addr,
+#ifdef CONFIG_PCI
+	.ndo_do_ioctl		= vortex_ioctl,
+#endif
+	.ndo_tx_timeout         = vortex_tx_timeout,
+	.ndo_get_stats		= vortex_get_stats,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller    = poll_vortex,
+#endif
+};
+
 /*
  * Start up the PCI/EISA device which is described by *gendev.
  * Return 0 on success.
@@ -1366,17 +1398,17 @@ static int __devinit vortex_probe1(struct device *gendev,
 	}
 
 	/* The 3c59x-specific entries in the device structure. */
-	dev->open = vortex_open;
 	if (vp->full_bus_master_tx) {
-		dev->hard_start_xmit = boomerang_start_xmit;
+		dev->netdev_ops = &boomerang_netdev_ops;
 		/* Actually, it still should work with iommu. */
 		if (card_idx < MAX_UNITS &&
 		    ((hw_checksums[card_idx] == -1 && (vp->drv_flags & HAS_HWCKSM)) ||
 				hw_checksums[card_idx] == 1)) {
 			dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		}
-	} else {
-		dev->hard_start_xmit = vortex_start_xmit;
+	}
+	else {
+		dev->netdev_ops = &vortex_netdev_ops;
 	}
 
 	if (print_info) {
@@ -1386,18 +1418,8 @@ static int __devinit vortex_probe1(struct device *gendev,
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
 	if (pdev) {
 		vp->pm_state_valid = 1;
  		pci_save_state(VORTEX_PCI(vp));
