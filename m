From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] fix 3c515.c:(.text+0x57200): undefined reference to
	`pnp_get_resource'
Date: Fri, 20 Jun 2008 11:33:16 +0200
Message-ID: <20080620093316.GA19003@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:53321 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346AbYFTJdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 05:33:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2538003ce2ea0b936d273692bc4e51c5b52fe70d
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Jun 20 11:29:31 2008 +0200

    fix 3c515.c:(.text+0x57200): undefined reference to `pnp_get_resource'
    
    -tip testing found the following build failure:
    
      drivers/built-in.o: In function `corkscrew_setup':
      3c515.c:(.text+0x57200): undefined reference to `pnp_get_resource'
    
    which happens if 3c515.c is build without CONFIG_PNP:
    
      http://redhat.com/~mingo/misc/config-Fri_Jun_20_10_02_43_CEST_2008.bad
    
    the reason is pnp_irq() use outside of its __ISAPNP__ section.
    
    corkscrew_setup() always called with NULL in the !__ISAPNP__ case, but
    also check this condition to make sure.
    
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 105a8c7..09dd063 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -573,7 +573,12 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	DECLARE_MAC_BUF(mac);
 
 	if (idev) {
+#ifdef __ISAPNP__
 		irq = pnp_irq(idev, 0);
+#else
+		/* Can not happen - in the !PNP case we always pass in NULL */
+		BUG_ON(1);
+#endif
 		vp->dev = &idev->dev;
 	} else {
 		irq = inw(ioaddr + 0x2002) & 15;
