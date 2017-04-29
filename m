From: gfree.wind@foxmail.com
Subject: [PATCH net v3] driver: ifb: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:43:07 +0800
Message-ID: <1493437387-26798-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, willemb@google.com,
        stephen@networkplumber.org, edumazet@google.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpproxy19.qq.com ([184.105.206.84]:48577 "EHLO
        smtpproxy19.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1166145AbdD2DnX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 23:43:23 -0400
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
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

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
@@ -187,6 +208,7 @@ static const struct net_device_ops ifb_netdev_ops = {
 	.ndo_start_xmit	= ifb_xmit,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_init	= ifb_dev_init,
+	.ndo_uninit	= ifb_dev_uninit,
 };
 
 #define IFB_FEATURES (NETIF_F_HW_CSUM | NETIF_F_SG  | NETIF_F_FRAGLIST	| \
@@ -197,16 +219,7 @@ static const struct net_device_ops ifb_netdev_ops = {
 
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
2.7.4
