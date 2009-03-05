From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 3/13] forcedeth: remove msix + napi
Date: Thu, 05 Mar 2009 13:01:59 -0500
Message-ID: <49B01397.7000804@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070500020502000204090302"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8335 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbZCEVAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:00:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070500020502000204090302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes support for msix running in conjunction with napi. 
There has been reported issues regarding the behaviour of irqmask and 
generation of interrupts by the HW when in MSIX mode. When running napi, 
the driver is constantly turning off/on the irqmask. For the time being, 
I am going to disable it until I can root cause the issue.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070500020502000204090302
Content-Type: text/plain;
 name="patch-forcedeth-napi-msix-remove"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-napi-msix-remove"

--- old/drivers/net/forcedeth.c	2009-03-05 10:39:14.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:39:06.000000000 -0800
@@ -3731,26 +3731,6 @@
 }
 #endif
 
-#ifdef CONFIG_FORCEDETH_NAPI
-static irqreturn_t nv_nic_irq_rx(int foo, void *data)
-{
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
-	u8 __iomem *base = get_hwbase(dev);
-	u32 events;
-
-	events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
-
-	if (events) {
-		/* disable receive interrupts on the nic */
-		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
-		pci_push(base);
-		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
-		napi_schedule(&np->napi);
-	}
-	return IRQ_HANDLED;
-}
-#else
 static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -3797,7 +3777,6 @@
 
 	return IRQ_RETVAL(i);
 }
-#endif
 
 static irqreturn_t nv_nic_irq_other(int foo, void *data)
 {
@@ -5670,7 +5649,12 @@
 		np->msi_flags |= NV_MSI_CAPABLE;
 	}
 	if ((id->driver_data & DEV_HAS_MSI_X) && msix) {
+		/* msix has had reported issues when modifying irqmask
+		   as in the case of napi, therefore, disable for now
+		*/
+#ifndef CONFIG_FORCEDETH_NAPI
 		np->msi_flags |= NV_MSI_X_CAPABLE;
+#endif
 	}
 
 	np->pause_flags = NV_PAUSEFRAME_RX_CAPABLE | NV_PAUSEFRAME_RX_REQ | NV_PAUSEFRAME_AUTONEG;

--------------070500020502000204090302--
