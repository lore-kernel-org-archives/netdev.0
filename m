From: gfree.wind@foxmail.com
Subject: [PATCH net v3] net: ip6_tunnel: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:54:19 +0800
Message-ID: <1493438059-27358-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg65.qq.com ([103.7.28.233]:49461 "EHLO smtpbg65.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938752AbdD2Dyb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 23:54:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The ip6_tunnel allocates some resources in its ndo_init func, and
free some of them in its destructor func. Then there is one memleak
that some errors happen after register_netdevice invokes the ndo_init
callback. Because only the ndo_uninit callback is invoked in the error
handler of register_netdevice, but destructor not.

Now create one new func ip6_tnl_destructor_free to free the mem in
the destructor, and ndo_uninit func also invokes it when fail to
register the ip6_tunnel device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 net/ipv6/ip6_tunnel.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 75fac93..1e10334 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -247,13 +247,18 @@ ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 	}
 }
 
-static void ip6_dev_free(struct net_device *dev)
+static void ip6_tnl_destructor_free(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 
 	gro_cells_destroy(&t->gro_cells);
 	dst_cache_destroy(&t->dst_cache);
 	free_percpu(dev->tstats);
+}
+
+static void ip6_dev_free(struct net_device *dev)
+{
+	ip6_tnl_destructor_free(dev);
 	free_netdev(dev);
 }
 
@@ -387,6 +392,10 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 		ip6_tnl_unlink(ip6n, t);
 	dst_cache_reset(&t->dst_cache);
 	dev_put(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ip6_tnl_destructor_free(dev);
 }
 
 /**
-- 
2.7.4
