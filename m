From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: msi interrupts
Date: Tue, 03 Jun 2008 16:51:46 -0400
Message-ID: <4845AEE2.1090905@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040806060109050803050803"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:9022 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbYFCX4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:56:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040806060109050803050803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a workaround for lost MSI interrupts. There is a race 
condition in the HW in which future interrupts could be missed. The 
workaround is to toggle the MSI irq mask.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040806060109050803050803
Content-Type: text/plain;
 name="patch-forcedeth-msi-irq"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-msi-irq"

--- old/drivers/net/forcedeth.c	2008-06-03 16:16:26.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-06-03 16:31:44.000000000 -0400
@@ -3277,6 +3277,20 @@
 	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
 }
 
+static inline void nv_msi_workaround(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+
+	/* Need to toggle the msi irq mask within the ethernet device,
+	 * otherwise, future interrupts will not be detected.
+	 */
+	if (np->msi_flags & NV_MSI_ENABLED) {
+		writel(0, base + NvRegMSIIrqMask);
+		writel(NVREG_MSI_VECTOR_0_ENABLED, base + NvRegMSIIrqMask);
+	}
+}
+
 static irqreturn_t nv_nic_irq(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -3299,6 +3313,8 @@
 		if (!(events & np->irqmask))
 			break;
 
+		nv_msi_workaround(dev);
+
 		spin_lock(&np->lock);
 		nv_tx_done(dev);
 		spin_unlock(&np->lock);
@@ -3414,6 +3430,8 @@
 		if (!(events & np->irqmask))
 			break;
 
+		nv_msi_workaround(dev);
+
 		spin_lock(&np->lock);
 		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
 		spin_unlock(&np->lock);
@@ -3754,6 +3772,8 @@
 	if (!(events & NVREG_IRQ_TIMER))
 		return IRQ_RETVAL(0);
 
+	nv_msi_workaround(dev);
+
 	spin_lock(&np->lock);
 	np->intr_test = 1;
 	spin_unlock(&np->lock);

--------------040806060109050803050803--
