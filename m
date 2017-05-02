From: gfree.wind@foxmail.com
Subject: [PATCH net v4 10/12] net: sit: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 21:39:45 +0800
Message-ID: <c6446a52d81ac0c1e7d3211291b30bb60c5de08b.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg65.qq.com ([103.7.28.233]:22238 "EHLO smtpbg65.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750936AbdEBNkA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 09:40:00 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
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
 net/ipv6/sit.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 99853c6..28c1649 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -464,6 +464,14 @@ static void prl_list_destroy_rcu(struct rcu_head *head)
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
@@ -1329,10 +1341,7 @@ static bool ipip6_valid_ip_proto(u8 ipproto)
 
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
1.9.1
