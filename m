From: gfree.wind@foxmail.com
Subject: [PATCH net v3] net: ip_tunnel: Fix one possbile memleak when fail to register_netdevice
Date: Sat, 29 Apr 2017 11:56:47 +0800
Message-ID: <1493438207-27538-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgbr2.qq.com ([54.207.22.56]:54773 "EHLO smtpbgbr2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933136AbdD2D5A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 23:57:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@foxmail.com>

The ip_tunnel allocates some resources in its ndo_init func, and
free some of them in its destructor func. Then there is one memleak
that some errors happen after register_netdevice invokes the ndo_init
callback. Because only the ndo_uninit callback is invoked in the error
handler of register_netdevice, but destructor not.

Now create one new func ip_tunnel_destructor_free to free the mem in
the destructor, and ndo_uninit func also invokes it when fail to
register the ip_tunnel device.

It's not only free all resources, but also follow the original desgin
that the resources are freed in the destructor normally after
register the device successfully.

Signed-off-by: Gao Feng <gfree.wind@foxmail.com>
---
 v3: Split one patch to multiple commits, per David Ahern
 v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
 v1: initial version

 net/ipv4/ip_tunnel.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 823abae..96a3005 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -954,13 +954,18 @@ int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_change_mtu);
 
-static void ip_tunnel_dev_free(struct net_device *dev)
+static void ip_tunnel_destructor_free(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	gro_cells_destroy(&tunnel->gro_cells);
 	dst_cache_destroy(&tunnel->dst_cache);
 	free_percpu(dev->tstats);
+}
+
+static void ip_tunnel_dev_free(struct net_device *dev)
+{
+	ip_tunnel_destructor_free(dev);
 	free_netdev(dev);
 }
 
@@ -1192,6 +1197,10 @@ void ip_tunnel_uninit(struct net_device *dev)
 		ip_tunnel_del(itn, netdev_priv(dev));
 
 	dst_cache_reset(&tunnel->dst_cache);
+
+	/* dev is not registered, perform the free instead of destructor */
+	if (dev->reg_state == NETREG_UNINITIALIZED)
+		ip_tunnel_destructor_free(dev);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_uninit);
 
-- 
2.7.4
