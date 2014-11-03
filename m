From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 1/4] ip6_tunnel: Use ip6_tnl_dev_init as the ndo_init function.
Date: Mon, 3 Nov 2014 09:19:27 +0100
Message-ID: <1415002770-5797-2-git-send-email-steffen.klassert@secunet.com>
References: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35463 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbaKCIUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 03:20:06 -0500
In-Reply-To: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_tnl_dev_init() sets the dev->iflink via a call to
ip6_tnl_link_config(). After that, register_netdevice()
sets dev->iflink = -1. So we loose the iflink configuration
for ipv6 tunnels. Fix this by using ip6_tnl_dev_init() as the
ndo_init function. Then ip6_tnl_dev_init() is called after
dev->iflink is set to -1 from register_netdevice().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_tunnel.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9409887..9cb94cf 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -272,9 +272,6 @@ static int ip6_tnl_create2(struct net_device *dev)
 	int err;
 
 	t = netdev_priv(dev);
-	err = ip6_tnl_dev_init(dev);
-	if (err < 0)
-		goto out;
 
 	err = register_netdevice(dev);
 	if (err < 0)
@@ -1462,6 +1459,7 @@ ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 
 
 static const struct net_device_ops ip6_tnl_netdev_ops = {
+	.ndo_init	= ip6_tnl_dev_init,
 	.ndo_uninit	= ip6_tnl_dev_uninit,
 	.ndo_start_xmit = ip6_tnl_xmit,
 	.ndo_do_ioctl	= ip6_tnl_ioctl,
@@ -1546,16 +1544,10 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net *net = dev_net(dev);
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
-	int err = ip6_tnl_dev_init_gen(dev);
-
-	if (err)
-		return err;
 
 	t->parms.proto = IPPROTO_IPV6;
 	dev_hold(dev);
 
-	ip6_tnl_link_config(t);
-
 	rcu_assign_pointer(ip6n->tnls_wc[0], t);
 	return 0;
 }
-- 
1.9.1
