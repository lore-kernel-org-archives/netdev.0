From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: msi interrupts
Date: Fri, 06 Jun 2008 14:03:19 -0400
Message-ID: <48497BE7.6030104@nvidia.com>
References: <4845AEE2.1090905@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080207060901090505020906"
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:18766 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764120AbYFFVDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 17:03:03 -0400
In-Reply-To: <4845AEE2.1090905@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080207060901090505020906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a workaround for lost MSI interrupts. There is a race
condition in the HW in which future interrupts could be missed. The
workaround is to toggle the MSI irq mask.

Added cleanup based on comments from Andrew Morton.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------080207060901090505020906
Content-Type: text/plain;
 name="patch-forcedeth-msi-irq"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-msi-irq"

--- old/drivers/net/forcedeth.c	2008-06-03 16:16:26.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-06-06 13:19:50.000000000 -0400
@@ -3277,6 +3277,20 @@
 	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
 }
 
+static void nv_msi_workaround(struct fe_priv *np)
+{
+
+	/* Need to toggle the msi irq mask within the ethernet device,
+	 * otherwise, future interrupts will not be detected.
+	 */
+	if (np->msi_flags & NV_MSI_ENABLED) {
+		u8 __iomem *base = np->base;
+
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
 
+		nv_msi_workaround(np);
+
 		spin_lock(&np->lock);
 		nv_tx_done(dev);
 		spin_unlock(&np->lock);
@@ -3414,6 +3430,8 @@
 		if (!(events & np->irqmask))
 			break;
 
+		nv_msi_workaround(np);
+
 		spin_lock(&np->lock);
 		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
 		spin_unlock(&np->lock);
@@ -3754,6 +3772,8 @@
 	if (!(events & NVREG_IRQ_TIMER))
 		return IRQ_RETVAL(0);
 
+	nv_msi_workaround(np);
+
 	spin_lock(&np->lock);
 	np->intr_test = 1;
 	spin_unlock(&np->lock);

--------------080207060901090505020906--
