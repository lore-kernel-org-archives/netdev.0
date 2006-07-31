From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] forcedeth: move mac address setup/teardown
Date: Mon, 31 Jul 2006 12:04:45 -0400
Message-ID: <44CE2A1D.4000805@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040904080403090803080702"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:56385 "EHLO
	HQEMGATE01.nvidia.com") by vger.kernel.org with ESMTP
	id S1030300AbWGaSMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 14:12:49 -0400
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	shemminger@osdl.org, Ayaz Abdulla <aabdulla@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040904080403090803080702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch moves the mac address setup/teardown to the 
nv_probe/nv_remove functions. This fixes WOL wakeup since on nv_close we 
would reverse the mac address. Also, bonding driver will reset address 
after nv_close is called.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040904080403090803080702
Content-Type: text/plain;
 name="patch-forcedeth-move-macaddress-set"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-move-macaddress-set"

--- orig-2.6/drivers/net/forcedeth.c	2006-07-06 15:05:31.000000000 -0400
+++ new-2.6/drivers/net/forcedeth.c	2006-07-06 15:05:54.000000000 -0400
@@ -3895,10 +3895,9 @@
 
 	dprintk(KERN_DEBUG "nv_open: begin\n");
 
-	/* 1) erase previous misconfiguration */
+	/* erase previous misconfiguration */
 	if (np->driver_data & DEV_HAS_POWER_CNTRL)
 		nv_mac_reset(dev);
-	/* 4.1-1: stop adapter: ignored, 4.3 seems to be overkill */
 	writel(NVREG_MCASTADDRA_FORCE, base + NvRegMulticastAddrA);
 	writel(0, base + NvRegMulticastAddrB);
 	writel(0, base + NvRegMulticastMaskA);
@@ -3913,7 +3912,7 @@
 	if (np->pause_flags & NV_PAUSEFRAME_TX_CAPABLE)
 		writel(NVREG_TX_PAUSEFRAME_DISABLE,  base + NvRegTxPauseFrame);
 
-	/* 2) initialize descriptor rings */
+	/* initialize descriptor rings */
 	set_bufsize(dev);
 	oom = nv_init_ring(dev);
 
@@ -3924,15 +3923,11 @@
 
 	np->in_shutdown = 0;
 
-	/* 3) set mac address */
-	nv_copy_mac_to_hw(dev);
-
-	/* 4) give hw rings */
+	/* give hw rings */
 	setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
 	writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
 		base + NvRegRingSizes);
 
-	/* 5) continue setup */
 	writel(np->linkspeed, base + NvRegLinkSpeed);
 	if (np->desc_ver == DESC_VER_1)
 		writel(NVREG_TX_WM_DESC1_DEFAULT, base + NvRegTxWatermark);
@@ -3950,7 +3945,6 @@
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 	writel(NVREG_MIISTAT_MASK2, base + NvRegMIIStatus);
 
-	/* 6) continue setup */
 	writel(NVREG_MISC1_FORCE | NVREG_MISC1_HD, base + NvRegMisc1);
 	writel(readl(base + NvRegTransmitterStatus), base + NvRegTransmitterStatus);
 	writel(NVREG_PFF_ALWAYS, base + NvRegPacketFilterFlags);
@@ -4076,12 +4070,6 @@
 	if (np->wolenabled)
 		nv_start_rx(dev);
 
-	/* special op: write back the misordered MAC address - otherwise
-	 * the next nv_probe would see a wrong address.
-	 */
-	writel(np->orig_mac[0], base + NvRegMacAddrA);
-	writel(np->orig_mac[1], base + NvRegMacAddrB);
-
 	/* FIXME: power down nic */
 
 	return 0;
@@ -4309,6 +4297,9 @@
 			dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
 			dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
 
+	/* set mac address */
+	nv_copy_mac_to_hw(dev);
+
 	/* disable WOL */
 	writel(0, base + NvRegWakeUpFlags);
 	np->wolenabled = 0;
@@ -4421,9 +4412,17 @@
 static void __devexit nv_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
 
 	unregister_netdev(dev);
 
+	/* special op: write back the misordered MAC address - otherwise
+	 * the next nv_probe would see a wrong address.
+	 */
+	writel(np->orig_mac[0], base + NvRegMacAddrA);
+	writel(np->orig_mac[1], base + NvRegMacAddrB);
+
 	/* free all structures */
 	free_rings(dev);
 	iounmap(get_hwbase(dev));

--------------040904080403090803080702--
