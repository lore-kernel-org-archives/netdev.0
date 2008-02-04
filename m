From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 5/5] forcedeth: preserve registers
Date: Mon, 04 Feb 2008 15:14:09 -0500
Message-ID: <47A77211.8080209@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000100000402080509080406"
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:17985 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759513AbYBEVuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 16:50:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000100000402080509080406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Various registers need to be preserved before resetting the device.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------000100000402080509080406
Content-Type: text/plain;
 name="patch-forcedeth-reg-reset"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-reg-reset"

--- old/drivers/net/forcedeth.c	2008-01-17 16:51:40.000000000 -0500
+++ new/drivers/net/forcedeth.c	2008-01-20 11:56:45.000000000 -0500
@@ -1443,16 +1443,30 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
+	u32 temp1, temp2, temp3;
 
 	dprintk(KERN_DEBUG "%s: nv_mac_reset\n", dev->name);
+
 	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
+
+	/* save registers since they will be cleared on reset */
+	temp1 = readl(base + NvRegMacAddrA);
+	temp2 = readl(base + NvRegMacAddrB);
+	temp3 = readl(base + NvRegTransmitPoll);
+
 	writel(NVREG_MAC_RESET_ASSERT, base + NvRegMacReset);
 	pci_push(base);
 	udelay(NV_MAC_RESET_DELAY);
 	writel(0, base + NvRegMacReset);
 	pci_push(base);
 	udelay(NV_MAC_RESET_DELAY);
+
+	/* restore saved registers */
+	writel(temp1, base + NvRegMacAddrA);
+	writel(temp2, base + NvRegMacAddrB);
+	writel(temp3, base + NvRegTransmitPoll);
+
 	writel(NVREG_TXRXCTL_BIT2 | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
 }

--------------000100000402080509080406--
