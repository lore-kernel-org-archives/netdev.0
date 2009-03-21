From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] 3c59x: convert to net_device_ops
Date: Sat, 21 Mar 2009 04:51:55 -0700
Message-ID: <20090321045155.fbdf8dac.akpm@linux-foundation.org>
References: <20090321113552.GB3380@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	klassert@mathematik.tu-chemnitz.de, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58323 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751496AbZCUMAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 08:00:01 -0400
In-Reply-To: <20090321113552.GB3380@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Mar 2009 12:35:53 +0100 Jiri Pirko <jpirko@redhat.com> wrote:

> I converted this driver to use net_device_ops. I made two structures, one for
> vortex and one for boomerang start_xmit function. Tested on my test system with
> 3Com PCI 3c905C Tornado.

linux-next already contains

commit 48b47a5e306c1c119ee81ccd24d487c2df656410
Author:     Stephen Hemminger <shemminger@linux-foundation.org>
AuthorDate: Fri Jan 9 13:01:18 2009 +0000
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Wed Jan 21 14:02:25 2009 -0800

    3c59x: convert to net_device_ops
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index cdbbb62..b2563d3 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
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
@@ -1366,18 +1402,16 @@ static int __devinit vortex_probe1(struct device *gendev,
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
@@ -1386,18 +1420,9 @@ static int __devinit vortex_probe1(struct device *gendev,
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

