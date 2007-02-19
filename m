From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/3] forcedeth: fixed missing call in napi poll
Date: Mon, 19 Feb 2007 09:27:52 -0500
Message-ID: <45D9B3E8.7030109@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070705070406020400070709"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:1051 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965780AbXBTApu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 19:45:50 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070705070406020400070709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The napi poll routine was missing the call to the optimized rx process 
routine. This patch adds the missing call for the optimized path.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070705070406020400070709
Content-Type: text/plain;
 name="patch-forcedeth-napi-poll"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-napi-poll"

--- orig/drivers/net/forcedeth.c	2007-02-19 09:13:10.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-02-19 09:13:46.000000000 -0500
@@ -3104,13 +3104,17 @@
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;
+	u32 retcode;
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		pkts = nv_rx_process(dev, limit);
-	else
+		retcode = nv_alloc_rx(dev);
+	} else {
 		pkts = nv_rx_process_optimized(dev, limit);
+		retcode = nv_alloc_rx_optimized(dev);
+	}
 
-	if (nv_alloc_rx(dev)) {
+	if (retcode) {
 		spin_lock_irqsave(&np->lock, flags);
 		if (!np->in_shutdown)
 			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);

--------------070705070406020400070709--
