From: gfree.wind@foxmail.com
Subject: [PATCH net v3] net: sit: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:57:25 +0800
Message-ID: <1493438245-27622-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgau2.qq.com ([54.206.34.216]:47075 "EHLO smtpbgau2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933136AbdD2D5j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 23:57:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The ipip6 allocates some resources in its ndo_init func, and
free some of them in its destructor func. Then there is one memleak
that some errors happen after register_netdevice invokes the ndo_init
callback. Because only the ndo_uninit callback is invoked in the error
handler of register_netdevice, but destructor not.

Now create one new func ipip6_destructor_free to free the mem in
the destructor, and ndo_uninit func also invokes it when fail to
register the ipip6 device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 net/ipv6/sit.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 99853c6..28c1649 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -464,6 +464,14 @@ isatap_chksrc(struct sk_buff *skb, const struct iphdr *iph, struct ip_tunnel *t)
 	return ok;
 }
 
+static void ipip6_destructor_free(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	dst_cache_destroy(&tunnel->dst_cache);
+	free_percpu(dev->tstats);
+}
+
 static void ipip6_tunnel_uninit(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
@@ -477,6 +485,10 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 	}
 	dst_cache_reset(&tunnel->dst_cache);
 	dev_put(dev);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ipip6_destructor_free(dev);
 }
 
 static int ipip6_err(struct sk_buff *skb, u32 info)
@@ -1329,10 +1341,7 @@ static const struct net_device_ops ipip6_netdev_ops = {
 
 static void ipip6_dev_free(struct net_device *dev)
 {
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-
-	dst_cache_destroy(&tunnel->dst_cache);
-	free_percpu(dev->tstats);
+	ipip6_destructor_free(dev);
 	free_netdev(dev);
 }
 
-- 
2.7.4
