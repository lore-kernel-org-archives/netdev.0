From: gfree.wind@foxmail.com
Subject: [PATCH net v3] net: ip6_gre: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:53:14 +0800
Message-ID: <1493437994-27267-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:33995 "EHLO smtpbg202.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033913AbdD2Dx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 23:53:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The ip6_gre allocates some resources in its ndo_init func, and
free some of them in its destructor func. Then there is one memleak
that some errors happen after register_netdevice invokes the ndo_init
callback. Because only the ndo_uninit callback is invoked in the error
handler of register_netdevice, but destructor not.

Now create one new func ip6_gre_destructor_free to free the mem in
the destructor, and ndo_uninit func also invokes it when fail to
register the ip6_gre device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 net/ipv6/ip6_gre.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 6fcb7cb..e53c3ac 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -355,6 +355,14 @@ static struct ip6_tnl *ip6gre_tunnel_locate(struct net *net,
 	return NULL;
 }
 
+static void ip6gre_destructor_free(struct net_device *dev)
+{
+	struct ip6_tnl *t = netdev_priv(dev);
+
+	dst_cache_destroy(&t->dst_cache);
+	free_percpu(dev->tstats);
+}
+
 static void ip6gre_tunnel_uninit(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
@@ -363,6 +371,10 @@ static void ip6gre_tunnel_uninit(struct net_device *dev)
 	ip6gre_tunnel_unlink(ign, t);
 	dst_cache_reset(&t->dst_cache);
 	dev_put(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ip6gre_destructor_free(dev);
 }
 
 
@@ -981,10 +993,7 @@ static const struct net_device_ops ip6gre_netdev_ops = {
 
 static void ip6gre_dev_free(struct net_device *dev)
 {
-	struct ip6_tnl *t = netdev_priv(dev);
-
-	dst_cache_destroy(&t->dst_cache);
-	free_percpu(dev->tstats);
+	ip6gre_destructor_free(dev);
 	free_netdev(dev);
 }
 
-- 
2.7.4
