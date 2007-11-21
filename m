From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] amd8111e: don't call napi_enable if configured w/o NAPI
Date: Wed, 21 Nov 2007 13:40:07 +0100
Message-ID: <20071121124007.GB3335@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:33270 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752209AbXKUMkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 07:40:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The amd8111e network driver was broken by 
bea3348eef27e6044b6161fd04c3152215f96411, which makes the driver
call napi_enable() and napi_disable() even if the driver had been 
configured without CONFIG_AMD8111E_NAPI, and thus
netif_napi_add() had not been called on initialization.
This triggers a BUG in napi_enable().

This patch fixes the problem. Please apply.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>


diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index eebf5bb..e7fdd81 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1340,7 +1340,9 @@ static int amd8111e_close(struct net_device * dev)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	netif_stop_queue(dev);
 
+#ifdef CONFIG_AMD8111E_NAPI
 	napi_disable(&lp->napi);
+#endif
 
 	spin_lock_irq(&lp->lock);
 
@@ -1372,7 +1374,9 @@ static int amd8111e_open(struct net_device * dev )
 					 dev->name, dev))
 		return -EAGAIN;
 
+#ifdef CONFIG_AMD8111E_NAPI
 	napi_enable(&lp->napi);
+#endif
 
 	spin_lock_irq(&lp->lock);
 
@@ -1380,7 +1384,9 @@ static int amd8111e_open(struct net_device * dev )
 
 	if(amd8111e_restart(dev)){
 		spin_unlock_irq(&lp->lock);
+#ifdef CONFIG_AMD8111E_NAPI
 		napi_disable(&lp->napi);
+#endif
 		if (dev->irq)
 			free_irq(dev->irq, dev);
 		return -ENOMEM;




-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

