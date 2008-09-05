From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 13/18] netdevice wanrouter: Convert directly reference of
 netdev->priv to netdev->ml_priv
Date: Fri, 05 Sep 2008 11:25:47 +0800
Message-ID: <48C0A6BB.4050608@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>,
	Krzysztof Halasa <khc@pm.waw.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49382 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752602AbYIED2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:28:10 -0400
In-Reply-To: <48C0A219.2030004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have some reasons to kill netdev->priv:
1. netdev->priv is equal to netdev_priv().
2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
   netdev_priv() is more flexible than netdev->priv.
But we cann't kill netdev->priv, because so many drivers reference to it
directly.

OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
and I want to kill netdev->priv later, I decided to convert all the direct
reference of netdev->priv first.

Different to readonly reference of netdev->priv, in this driver, netdev->priv
was changed. I use netdev->ml_priv to replace netdev->priv.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/wanrouter/wanmain.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index 7f07152..d5542da 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -59,6 +59,7 @@
 #include <linux/init.h>         /* __initfunc et al. */
 
 #define KMEM_SAFETYZONE 8
+#define DEV_ML_PRIV(dev)	(*((struct net_device **)dev->ml_priv))
 
 /*
  * 	Function Prototypes
@@ -622,10 +623,10 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 					wandev->dev = dev;
 				} else {
 					for (slave=wandev->dev;
-					 *((struct net_device **)slave->priv);
-				 slave = *((struct net_device **)slave->priv));
+						DEV_ML_PRIV(slave);
+						slave = DEV_ML_PRIV(slave));
 
-				     *((struct net_device **)slave->priv) = dev;
+						DEV_ML_PRIV(slave) = dev;
 				}
 				++wandev->ndev;
 
@@ -639,8 +640,8 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 	}
 
 	/* This code has moved from del_if() function */
-	kfree(dev->priv);
-	dev->priv = NULL;
+	kfree(dev->ml_priv);
+	dev->ml_priv = NULL;
 
 	/* Sync PPP is disabled */
 	if (cnf->config_id != WANCONFIG_MPPP)
@@ -734,7 +735,7 @@ static int wanrouter_delete_interface(struct wan_device *wandev, char *name)
 	dev = wandev->dev;
 	prev = NULL;
 	while (dev && strcmp(name, dev->name)) {
-		struct net_device **slave = dev->priv;
+		struct net_device **slave = dev->ml_priv;
 		prev = dev;
 		dev = *slave;
 	}
@@ -751,12 +752,12 @@ static int wanrouter_delete_interface(struct wan_device *wandev, char *name)
 
 	lock_adapter_irq(&wandev->lock, &smp_flags);
 	if (prev) {
-		struct net_device **prev_slave = prev->priv;
-		struct net_device **slave = dev->priv;
+		struct net_device **prev_slave = prev->ml_priv;
+		struct net_device **slave = dev->ml_priv;
 
 		*prev_slave = *slave;
 	} else {
-		struct net_device **slave = dev->priv;
+		struct net_device **slave = dev->ml_priv;
 		wandev->dev = *slave;
 	}
 	--wandev->ndev;
@@ -766,8 +767,8 @@ static int wanrouter_delete_interface(struct wan_device *wandev, char *name)
 
 	/* Due to new interface linking method using dev->priv,
 	 * this code has moved from del_if() function.*/
-	kfree(dev->priv);
-	dev->priv=NULL;
+	kfree(dev->ml_priv);
+	dev->ml_priv = NULL;
 
 	unregister_netdev(dev);
 
-- 
1.5.3.4


