From: gfree.wind@foxmail.com
Subject: [PATCH net v3] net: ip6_vti: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:55:39 +0800
Message-ID: <1493438139-27456-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbguseast2.qq.com ([54.204.34.130]:44137 "EHLO
        smtpbguseast2.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939956AbdD2Dzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 23:55:55 -0400
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
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 net/ipv6/ip6_vti.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 3d8a3b6..3b3f49a 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -177,9 +177,14 @@ vti6_tnl_unlink(struct vti6_net *ip6n, struct ip6_tnl *t)
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
2.7.4
