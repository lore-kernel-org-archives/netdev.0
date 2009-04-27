From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: add clock gating feature
Date: Mon, 27 Apr 2009 08:31:35 -0400
Message-ID: <49F5A5A7.4050609@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020507060600070003080502"
To: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:10274 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758966AbZD0SH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 14:07:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020507060600070003080502
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support for clock gating the tx/rx engines which is 
available on certain chipsets.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------020507060600070003080502
Content-Type: text/plain;
 name="patch-forcedeth-gate-clocks"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-gate-clocks"

--- old/drivers/net/forcedeth.c	2009-04-25 18:33:15.000000000 -0400
+++ new/drivers/net/forcedeth.c	2009-04-25 18:39:51.000000000 -0400
@@ -343,6 +343,7 @@
 #define NVREG_POWERSTATE2_POWERUP_MASK		0x0F15
 #define NVREG_POWERSTATE2_POWERUP_REV_A3	0x0001
 #define NVREG_POWERSTATE2_PHY_RESET		0x0004
+#define NVREG_POWERSTATE2_GATE_CLOCKS		0x0F00
 };
 
 /* Big endian: should work, but is untested */
@@ -1017,6 +1018,23 @@
 		return 1;
 }
 
+static void nv_txrx_gate(struct net_device *dev, bool gate)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	u32 powerstate;
+
+	if (!np->mac_in_use &&
+	    (np->driver_data & DEV_HAS_POWER_CNTRL)) {
+		powerstate = readl(base + NvRegPowerState2);
+		if (gate)
+			powerstate |= NVREG_POWERSTATE2_GATE_CLOCKS;
+		else
+			powerstate &= ~NVREG_POWERSTATE2_GATE_CLOCKS;
+		writel(powerstate,base + NvRegPowerState2);
+	}
+}
+
 static void nv_enable_irq(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
@@ -3394,12 +3412,14 @@
 		if (!netif_carrier_ok(dev)) {
 			netif_carrier_on(dev);
 			printk(KERN_INFO "%s: link up.\n", dev->name);
+			nv_txrx_gate(dev, false);
 			nv_start_rx(dev);
 		}
 	} else {
 		if (netif_carrier_ok(dev)) {
 			netif_carrier_off(dev);
 			printk(KERN_INFO "%s: link down.\n", dev->name);
+			nv_txrx_gate(dev, true);
 			nv_stop_rx(dev);
 		}
 	}
@@ -5327,6 +5347,7 @@
 	mii_rw(dev, np->phyaddr, MII_BMCR,
 	       mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ) & ~BMCR_PDOWN);
 
+	nv_txrx_gate(dev, false);
 	/* erase previous misconfiguration */
 	if (np->driver_data & DEV_HAS_POWER_CNTRL)
 		nv_mac_reset(dev);
@@ -5514,12 +5535,14 @@
 	nv_drain_rxtx(dev);
 
 	if (np->wolenabled) {
+		nv_txrx_gate(dev, false);
 		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
 		nv_start_rx(dev);
 	} else {
 		/* power down phy */
 		mii_rw(dev, np->phyaddr, MII_BMCR,
 		       mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ)|BMCR_PDOWN);
+		nv_txrx_gate(dev, true);
 	}
 
 	/* FIXME: power down nic */

--------------020507060600070003080502--
