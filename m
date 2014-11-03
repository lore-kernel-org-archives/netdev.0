From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 2/4] vti6: Use vti6_dev_init as the ndo_init function.
Date: Mon, 3 Nov 2014 09:19:28 +0100
Message-ID: <1415002770-5797-3-git-send-email-steffen.klassert@secunet.com>
References: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35453 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbaKCIUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 03:20:01 -0500
In-Reply-To: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vti6_dev_init() sets the dev->iflink via a call to
vti6_link_config(). After that, register_netdevice()
sets dev->iflink = -1. So we loose the iflink configuration
for vti6 tunnels. Fix this by using vti6_dev_init() as the
ndo_init function. Then vti6_dev_init() is called after
dev->iflink is set to -1 from register_netdevice().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d440bb5..31089d1 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -172,10 +172,6 @@ static int vti6_tnl_create2(struct net_device *dev)
 	struct vti6_net *ip6n = net_generic(net, vti6_net_id);
 	int err;
 
-	err = vti6_dev_init(dev);
-	if (err < 0)
-		goto out;
-
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto out;
@@ -783,6 +779,7 @@ static int vti6_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 static const struct net_device_ops vti6_netdev_ops = {
+	.ndo_init	= vti6_dev_init,
 	.ndo_uninit	= vti6_dev_uninit,
 	.ndo_start_xmit = vti6_tnl_xmit,
 	.ndo_do_ioctl	= vti6_ioctl,
@@ -852,16 +849,10 @@ static int __net_init vti6_fb_tnl_dev_init(struct net_device *dev)
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct vti6_net *ip6n = net_generic(net, vti6_net_id);
-	int err = vti6_dev_init_gen(dev);
-
-	if (err)
-		return err;
 
 	t->parms.proto = IPPROTO_IPV6;
 	dev_hold(dev);
 
-	vti6_link_config(t);
-
 	rcu_assign_pointer(ip6n->tnls_wc[0], t);
 	return 0;
 }
-- 
1.9.1
