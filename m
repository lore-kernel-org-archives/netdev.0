From: gfree.wind@foxmail.com
Subject: [PATCH net v4 01/12] driver: dummy: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 13:58:43 +0800
Message-ID: <9f7df9a0e81f9200505daf4499117314244f0356.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgsg2.qq.com ([54.254.200.128]:39003 "EHLO smtpbgsg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750715AbdEBF7U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 01:59:20 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
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
@@ -310,9 +320,7 @@ static void dummy_get_drvinfo(struct net_device *dev,
 
 static void dummy_free_netdev(struct net_device *dev)
 {
-	struct dummy_priv *priv = netdev_priv(dev);
-
-	kfree(priv->vfinfo);
+	dummy_destructor_free(dev);
 	free_netdev(dev);
 }
 
-- 
1.9.1
