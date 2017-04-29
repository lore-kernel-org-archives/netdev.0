From: gfree.wind@foxmail.com
Subject: [PATCH net v3] driver: dummy: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:39:46 +0800
Message-ID: <1493437186-26727-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, sd@queasysnail.net, phil@nwl.cc,
        stephen@networkplumber.org, zhangshengju@cmss.chinamobile.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:52817 "EHLO smtpbg202.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163585AbdD2DkO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 23:40:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The dummy driver allocates dev->dstats and priv->vfinfo in its
ndo_init func dummy_dev_init, free the dev->dstats in the ndo_uninit
and free the priv->vfinfo in its destructor func. Then there is one
memleak that some errors happen after register_netdevice invokes the
ndo_init callback. Because only the ndo_uninit callback is invoked in
the error handler of register_netdevice, but destructor not.

Now create one new func dummy_destructor_free to free the mem in the
destructor, and the ndo_uninit func also invokes it when fail to
register the dummy device.

It's not only free all resources, but also follow the original desgin
that the priv->vfinfo is freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 drivers/net/dummy.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 2c80611..0b3c1cc 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -153,9 +153,19 @@ static int dummy_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static void dummy_destructor_free(struct net_device *dev)
+{
+	struct dummy_priv *priv = netdev_priv(dev);
+
+	kfree(priv->vfinfo);
+}
+
 static void dummy_dev_uninit(struct net_device *dev)
 {
 	free_percpu(dev->dstats);
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		dummy_destructor_free(dev);
 }
 
 static int dummy_change_carrier(struct net_device *dev, bool new_carrier)
@@ -310,9 +320,7 @@ static const struct ethtool_ops dummy_ethtool_ops = {
 
 static void dummy_free_netdev(struct net_device *dev)
 {
-	struct dummy_priv *priv = netdev_priv(dev);
-
-	kfree(priv->vfinfo);
+	dummy_destructor_free(dev);
 	free_netdev(dev);
 }
 
-- 
2.7.4
