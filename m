From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 12/13] forcedeth: fix irq clearing and napi spin lock changes
Date: Thu, 05 Mar 2009 13:02:34 -0500
Message-ID: <49B013BA.2040202@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030607050300050808070000"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8518 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756AbZCEVBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 16:01:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030607050300050808070000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch clears the irqstatus register with the exact same events it 
has read from it. Since the read-write operation is not atomic, a new 
irqstatus bit could have been set in between these operations and would 
then be cleared accidentally.

Secondly, we now don't need any spin lock protection when 
scheduling/completing napi poll as the isr will not execute anymore (as 
we turn off all interrupts now).

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------030607050300050808070000
Content-Type: text/plain;
 name="patch-forcedeth-irq"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-irq"

--- old/drivers/net/forcedeth.c	2009-03-05 10:47:33.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-03-05 10:47:45.000000000 -0800
@@ -3464,10 +3464,10 @@
 
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		np->events = readl(base + NvRegIrqStatus);
-		writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+		writel(np->events, base + NvRegIrqStatus);
 	} else {
 		np->events = readl(base + NvRegMSIXIrqStatus);
-		writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
+		writel(np->events, base + NvRegMSIXIrqStatus);
 	}
 	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
 	if (!(np->events & np->irqmask))
@@ -3476,15 +3476,12 @@
 	nv_msi_workaround(np);
 
 #ifdef CONFIG_FORCEDETH_NAPI
-	spin_lock(&np->lock);
 	napi_schedule(&np->napi);
 
 	/* Disable furthur irq's
 	   (msix not enabled with napi) */
 	writel(0, base + NvRegIrqMask);
 
-	spin_unlock(&np->lock);
-
 #else
 	do
 	{
@@ -3568,10 +3565,10 @@
 
 	if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
 		np->events = readl(base + NvRegIrqStatus);
-		writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+		writel(np->events, base + NvRegIrqStatus);
 	} else {
 		np->events = readl(base + NvRegMSIXIrqStatus);
-		writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
+		writel(np->events, base + NvRegMSIXIrqStatus);
 	}
 	dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, np->events);
 	if (!(np->events & np->irqmask))
@@ -3580,15 +3577,12 @@
 	nv_msi_workaround(np);
 
 #ifdef CONFIG_FORCEDETH_NAPI
-	spin_lock(&np->lock);
 	napi_schedule(&np->napi);
 
 	/* Disable furthur irq's
 	   (msix not enabled with napi) */
 	writel(0, base + NvRegIrqMask);
 
-	spin_unlock(&np->lock);
-
 #else
 	do
 	{
@@ -3758,13 +3752,9 @@
 	if (rx_work < budget) {
 		/* re-enable interrupts
 		   (msix not enabled in napi) */
-		spin_lock_irqsave(&np->lock, flags);
-
 		__napi_complete(napi);
 
 		writel(np->irqmask, base + NvRegIrqMask);
-
-		spin_unlock_irqrestore(&np->lock, flags);
 	}
 	return rx_work;
 }

--------------030607050300050808070000--
