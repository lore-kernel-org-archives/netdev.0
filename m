From: gfree.wind@foxmail.com
Subject: [PATCH net v4 12/12] net: batman-adv: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 22:17:27 +0800
Message-ID: <45493f3cb9eddd1e610dff64ff492c4405935393.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgbr2.qq.com ([54.207.22.56]:58457 "EHLO smtpbgbr2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdEBORo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 10:17:44 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The batman-adv allocates some resources in its ndo_init func, and free
them in its destructor func. Then there is one memleak that some errors
happen after register_netdevice invokes the ndo_init callback. Because
the destructor would not be invoked to free the resources.

Now create one new func batadv_destructor_free to free the mem in
the destructor, and add ndo_uninit func also invokes it when fail to
register the batman-adv device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 net/batman-adv/soft-interface.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index d042c99..626cbf6 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -878,6 +878,19 @@ static int batadv_softif_init_late(struct net_device *dev)
 	return ret;
 }
 
+static void batadv_destructor_free(struct net_device *dev)
+{
+	batadv_debugfs_del_meshif(dev);
+	batadv_mesh_free(dev);
+}
+
+static void batadv_softif_uninit(struct net_device *dev)
+{
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		batadv_destructor_free(dev);
+}
+
 /**
  * batadv_softif_slave_add - Add a slave interface to a batadv_soft_interface
  * @dev: batadv_soft_interface used as master interface
@@ -933,6 +946,7 @@ static int batadv_softif_slave_del(struct net_device *dev,
 
 static const struct net_device_ops batadv_netdev_ops = {
 	.ndo_init = batadv_softif_init_late,
+	.ndo_uninit = batadv_softif_uninit,
 	.ndo_open = batadv_interface_open,
 	.ndo_stop = batadv_interface_release,
 	.ndo_get_stats = batadv_interface_stats,
@@ -953,9 +967,7 @@ static int batadv_softif_slave_del(struct net_device *dev,
  */
 static void batadv_softif_free(struct net_device *dev)
 {
-	batadv_debugfs_del_meshif(dev);
-	batadv_mesh_free(dev);
-
+	batadv_destructor_free(dev);
 	/* some scheduled RCU callbacks need the bat_priv struct to accomplish
 	 * their tasks. Wait for them all to be finished before freeing the
 	 * netdev and its private data (bat_priv)
-- 
1.9.1
