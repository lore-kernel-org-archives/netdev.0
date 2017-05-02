From: gfree.wind@foxmail.com
Subject: [PATCH net v4 03/12] driver: loopback: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 13:58:45 +0800
Message-ID: <6067f8539a8a4cecfbe6f3ae31a76a4d6f3c9d13.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG2.QQ.COM ([183.60.61.197]:42839 "EHLO smtpbg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750920AbdEBGRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 02:17:46 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The loopback driver allocates some resources in its ndo_init func, and
free them in its destructor func. Then there is one memleak that some
errors happen after register_netdevice invokes the ndo_init callback.
Because the destructor would not be invoked to free the resources.

Now create one new func loopback_destructor_free to free the mem in
the destructor, and add ndo_uninit func also invokes it when fail to
register the loopback device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 drivers/net/loopback.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index b23b719..d7c1016 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -141,15 +141,28 @@ static int loopback_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static void loopback_dev_free(struct net_device *dev)
+static void loopback_destructor_free(struct net_device *dev)
 {
 	dev_net(dev)->loopback_dev = NULL;
 	free_percpu(dev->lstats);
+}
+
+static void loopback_dev_uninit(struct net_device *dev)
+{
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		loopback_destructor_free(dev);
+}
+
+static void loopback_dev_free(struct net_device *dev)
+{
+	loopback_destructor_free(dev);
 	free_netdev(dev);
 }
 
 static const struct net_device_ops loopback_ops = {
 	.ndo_init      = loopback_dev_init,
+	.ndo_uninit = loopback_dev_uninit,
 	.ndo_start_xmit= loopback_xmit,
 	.ndo_get_stats64 = loopback_get_stats64,
 	.ndo_set_mac_address = eth_mac_addr,
-- 
1.9.1
