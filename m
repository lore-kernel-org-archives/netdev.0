From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 3/4] forcedeth: napi schedule lock fix
Date: Fri, 09 Jan 2009 16:03:49 -0500
Message-ID: <4967BBB5.9080803@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080704090407070807010208"
To: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:8306 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbZAJAJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 19:09:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080704090407070807010208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes a potential race condition between scheduling napi and 
completing napi poll. The call to netif_rx_schedule should be under 
protection of the lock (as is the completion), otherwise, interrupts 
could be masked off.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------080704090407070807010208
Content-Type: text/plain;
 name="patch-forcedeth-napi-lock"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-napi-lock"

--- old/drivers/net/forcedeth.c	2009-01-09 15:11:55.000000000 -0800
+++ new/drivers/net/forcedeth.c	2009-01-09 15:17:27.000000000 -0800
@@ -3407,10 +3407,10 @@
 
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
+			spin_lock(&np->lock);
 			netif_rx_schedule(dev, &np->napi);
 
 			/* Disable furthur receive irq's */
-			spin_lock(&np->lock);
 			np->irqmask &= ~NVREG_IRQ_RX_ALL;
 
 			if (np->msi_flags & NV_MSI_X_ENABLED)
@@ -3524,10 +3524,10 @@
 
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
+			spin_lock(&np->lock);
 			netif_rx_schedule(dev, &np->napi);
 
 			/* Disable furthur receive irq's */
-			spin_lock(&np->lock);
 			np->irqmask &= ~NVREG_IRQ_RX_ALL;
 
 			if (np->msi_flags & NV_MSI_X_ENABLED)

--------------080704090407070807010208--
