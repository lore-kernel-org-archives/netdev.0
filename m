From: gfree.wind@foxmail.com
Subject: [PATCH net v4 02/12] driver: ifb: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 13:58:44 +0800
Message-ID: <7996f6d9a1764af9e05b65409bceab3376a9cf84.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg338.qq.com ([14.17.44.33]:56533 "EHLO smtpbg338.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751008AbdEBGNz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 02:13:55 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The ifb driver allocates some resources in its ndo_init func, and free
them in its destructor func. Then there is one memleak that some errors
happen after register_netdevice invokes the ndo_init callback. Because
the destructor would not be invoked to free the resources.

Now create one new func ifb_destructor_free to free the mem in the
destructor, and add ndo_uninit func also invokes it when fail to register
the ifb device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 drivers/net/ifb.c | 33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 312fce7..b25aea1 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -180,6 +180,27 @@ static int ifb_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static void ifb_destructor_free(struct net_device *dev)
+{
+	struct ifb_dev_private *dp = netdev_priv(dev);
+	struct ifb_q_private *txp = dp->tx_private;
+	int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++, txp++) {
+		tasklet_kill(&txp->ifb_tasklet);
+		__skb_queue_purge(&txp->rq);
+		__skb_queue_purge(&txp->tq);
+	}
+	kfree(dp->tx_private);
+}
+
+static void ifb_dev_uninit(struct net_device *dev)
+{
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ifb_destructor_free(dev);
+}
+
 static const struct net_device_ops ifb_netdev_ops = {
 	.ndo_open	= ifb_open,
 	.ndo_stop	= ifb_close,
@@ -187,6 +208,7 @@ static int ifb_dev_init(struct net_device *dev)
 	.ndo_start_xmit	= ifb_xmit,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_init	= ifb_dev_init,
+	.ndo_uninit	= ifb_dev_uninit,
 };
 
 #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
@@ -197,16 +219,7 @@ static int ifb_dev_init(struct net_device *dev)
 
 static void ifb_dev_free(struct net_device *dev)
 {
-	struct ifb_dev_private *dp = netdev_priv(dev);
-	struct ifb_q_private *txp = dp->tx_private;
-	int i;
-
-	for (i = 0; i < dev->num_tx_queues; i++,txp++) {
-		tasklet_kill(&txp->ifb_tasklet);
-		__skb_queue_purge(&txp->rq);
-		__skb_queue_purge(&txp->tq);
-	}
-	kfree(dp->tx_private);
+	ifb_destructor_free(dev);
 	free_netdev(dev);
 }
 
-- 
1.9.1
