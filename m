From: gfree.wind@foxmail.com
Subject: [PATCH net v4 08/12] net: ip6_vti: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 21:34:37 +0800
Message-ID: <d29424a045abe0e4a41e869a9da0c7c357c0a20f.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg298.qq.com ([184.105.67.102]:47101 "EHLO smtpbg298.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750955AbdEBNfy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 09:35:54 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The ip6_vti allocates some resources in its ndo_init func, and
free some of them in its destructor func. Then there is one memleak
that some errors happen after register_netdevice invokes the ndo_init
callback. Because only the ndo_uninit callback is invoked in the error
handler of register_netdevice, but destructor not.

Now create one new func vti6_destructor_free to free the mem in
the destructor, and ndo_uninit func also invokes it when fail to
register the vti6 device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 net/ipv6/ip6_vti.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 3d8a3b6..3b3f49a 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -177,9 +177,14 @@ struct vti6_net {
 	}
 }
 
-static void vti6_dev_free(struct net_device *dev)
+static void vti6_destructor_free(struct net_device *dev)
 {
 	free_percpu(dev->tstats);
+}
+
+static void vti6_dev_free(struct net_device *dev)
+{
+	vti6_destructor_free(dev);
 	free_netdev(dev);
 }
 
@@ -296,6 +301,10 @@ static void vti6_dev_uninit(struct net_device *dev)
 	else
 		vti6_tnl_unlink(ip6n, t);
 	dev_put(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		vti6_destructor_free(dev);
 }
 
 static int vti6_rcv(struct sk_buff *skb)
-- 
1.9.1
