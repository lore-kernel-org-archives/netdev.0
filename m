From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 3/4] sit: Use ipip6_tunnel_init as the ndo_init function.
Date: Mon, 3 Nov 2014 09:19:29 +0100
Message-ID: <1415002770-5797-4-git-send-email-steffen.klassert@secunet.com>
References: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35458 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbaKCIUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 03:20:01 -0500
In-Reply-To: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipip6_tunnel_init() sets the dev->iflink via a call to
ipip6_tunnel_bind_dev(). After that, register_netdevice()
sets dev->iflink = -1. So we loose the iflink configuration
for ipv6 tunnels. Fix this by using ipip6_tunnel_init() as the
ndo_init function. Then ipip6_tunnel_init() is called after
dev->iflink is set to -1 from register_netdevice().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/sit.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 58e5b47..a24557a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -195,10 +195,8 @@ static int ipip6_tunnel_create(struct net_device *dev)
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 	int err;
 
-	err = ipip6_tunnel_init(dev);
-	if (err < 0)
-		goto out;
-	ipip6_tunnel_clone_6rd(dev, sitn);
+	memcpy(dev->dev_addr, &t->parms.iph.saddr, 4);
+	memcpy(dev->broadcast, &t->parms.iph.daddr, 4);
 
 	if ((__force u16)t->parms.i_flags & SIT_ISATAP)
 		dev->priv_flags |= IFF_ISATAP;
@@ -207,7 +205,8 @@ static int ipip6_tunnel_create(struct net_device *dev)
 	if (err < 0)
 		goto out;
 
-	strcpy(t->parms.name, dev->name);
+	ipip6_tunnel_clone_6rd(dev, sitn);
+
 	dev->rtnl_link_ops = &sit_link_ops;
 
 	dev_hold(dev);
@@ -1330,6 +1329,7 @@ static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 static const struct net_device_ops ipip6_netdev_ops = {
+	.ndo_init	= ipip6_tunnel_init,
 	.ndo_uninit	= ipip6_tunnel_uninit,
 	.ndo_start_xmit	= sit_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
@@ -1378,9 +1378,7 @@ static int ipip6_tunnel_init(struct net_device *dev)
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
-
-	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
+	strcpy(tunnel->parms.name, dev->name);
 
 	ipip6_tunnel_bind_dev(dev);
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
@@ -1405,7 +1403,6 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
-	strcpy(tunnel->parms.name, dev->name);
 
 	iph->version		= 4;
 	iph->protocol		= IPPROTO_IPV6;
-- 
1.9.1
