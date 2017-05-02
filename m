From: gfree.wind@foxmail.com
Subject: [PATCH net v4 07/12] ip6_tunnel: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 14:59:39 +0800
Message-ID: <d6ef9cecae9d567a2c4dac8dcb550f2a190d5dc3.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg302.qq.com ([184.105.206.27]:58877 "EHLO smtpbg302.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750723AbdEBHAr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 03:00:47 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
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
 net/ipv6/ip6_tunnel.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a9692ec..7dcb234 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -247,13 +247,18 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
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
 
@@ -387,6 +392,10 @@ static struct ip6_tnl *ip6_tnl_locate(struct net *net,
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
1.9.1
