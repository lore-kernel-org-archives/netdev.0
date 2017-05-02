From: gfree.wind@foxmail.com
Subject: [PATCH net v4 06/12] net: ip6_gre: Fix one possbile memleak when fail to register_netdevice
Date: Tue,  2 May 2017 13:58:48 +0800
Message-ID: <633520572339e8f834eca7833363c253969aa500.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Cc: Gao Feng <gfree.wind@foxmail.com>
To: davem@davemloft.net, jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg126.qq.com ([183.60.2.42]:47605 "EHLO smtpbg126.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750920AbdEBGNh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 02:13:37 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
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
 
 
@@ -981,10 +993,7 @@ static int ip6gre_header(struct sk_buff *skb, struct net_device *dev,
 
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
1.9.1
