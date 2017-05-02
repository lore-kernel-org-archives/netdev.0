From: gfree.wind@foxmail.com
Subject: [PATCH net v4 05/12] driver: veth: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 13:58:47 +0800
Message-ID: <0e559357e70cfda4335347cda8d8bfce320397b8.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG7.QQ.COM ([183.60.61.200]:38225 "EHLO smtpbg7.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751004AbdEBGQY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 02:16:24 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The veth driver allocates some resources in its ndo_init func, and
free them in its destructor func. Then there is one memleak that some
errors happen after register_netdevice invokes the ndo_init callback.
Because the destructor would not be invoked to free the resources.

Now create one new func veth_destructor_free to free the mem in the
destructor, and add ndo_uninit func also invokes it when fail to register
the veth device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 drivers/net/veth.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8c39d6d..418376a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -224,9 +224,21 @@ static int veth_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static void veth_dev_free(struct net_device *dev)
+static void veth_destructor_free(struct net_device *dev)
 {
 	free_percpu(dev->vstats);
+}
+
+static void veth_dev_uninit(struct net_device *dev)
+{
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		veth_destructor_free(dev);
+}
+
+static void veth_dev_free(struct net_device *dev)
+{
+	veth_destructor_free(dev);
 	free_netdev(dev);
 }
 
@@ -284,6 +296,7 @@ static void veth_set_rx_headroom(struct net_device *dev, int new_hr)
 
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
+	.ndo_uninit          = veth_dev_uninit,
 	.ndo_open            = veth_open,
 	.ndo_stop            = veth_close,
 	.ndo_start_xmit      = veth_xmit,
-- 
1.9.1
