From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: add clock gating feature <resend>
Date: Fri, 01 May 2009 07:41:50 -0400
Message-ID: <49FADFFE.7020300@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000506000202010302010803"
To: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:14987 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbZEARR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 13:17:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000506000202010302010803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds new logic to support a clock gating feature found on the 
latest set of chipsets. The clock gating is performed on the tx/rx 
engines when the link is disconnected. Clock gating helps in reducing 
power consumption.

* modified based on comments from netdev

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>



--------------000506000202010302010803
Content-Type: text/plain;
 name="patch-forcedeth-gate-clocks"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-gate-clocks"

--- old/drivers/net/forcedeth.c	2009-04-25 18:33:15.000000000 -0400
+++ new/drivers/net/forcedeth.c	2009-05-01 07:30:57.000000000 -0400
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
+		writel(powerstate, base + NvRegPowerState2);
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

--------------000506000202010302010803--
