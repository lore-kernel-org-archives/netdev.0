From: Martin Buck <mb-tmp-yvahk-argqri@gromit.dyndns.org>
Subject: [PATCH] Speedup link loss detection for 3c59x
Date: Thu, 15 Apr 2010 11:11:34 +0200
Message-ID: <20100415091134.GA9574@gromit.at.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail17.bluewin.ch ([195.186.18.64]:19796 "EHLO
	mail17.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756817Ab0DOJSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 05:18:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Buck <mb-tmp-yvahk-argqri@gromit.dyndns.org>

Change the timer used for link status checking to check link every 5s,
regardless of the current link state. This way, link loss is detected as
fast as new link, whereas this took up to 60s previously (which is pretty
inconvenient when trying to react on link loss using e.g. ifplugd). This
also matches behaviour of most other Ethernet drivers which typically have
link check intervals in the low second range.

Signed-off-by: Martin Buck <mb-tmp-yvahk-argqri@gromit.dyndns.org>
---

--- linux-2.6.31.6/drivers/net/3c59x.c.orig	2010-04-13 17:46:07.000000000 +0200
+++ linux-2.6.31.6/drivers/net/3c59x.c	2010-04-13 17:55:31.000000000 +0200
@@ -1761,7 +1761,7 @@ vortex_timer(unsigned long data)
 	struct net_device *dev = (struct net_device *)data;
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
-	int next_tick = 60*HZ;
+	int next_tick = 5*HZ;
 	int ok = 0;
 	int media_status, old_window;
 
@@ -1807,9 +1807,6 @@ vortex_timer(unsigned long data)
 		ok = 1;
 	}
 
-	if (!netif_carrier_ok(dev))
-		next_tick = 5*HZ;
-
 	if (vp->medialock)
 		goto leave_media_alone;
 
