From: gfree.wind@foxmail.com
Subject: [PATCH net v3] driver: loopback: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:48:58 +0800
Message-ID: <1493437738-27028-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, marcelo.leitner@gmail.com,
        edumazet@google.com, stephen@networkplumber.org,
        sowmini.varadhan@oracle.com, willemb@google.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg302.qq.com ([184.105.206.27]:53296 "EHLO smtpbg302.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164547AbdD2DtM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 23:49:12 -0400
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
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

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
2.7.4
