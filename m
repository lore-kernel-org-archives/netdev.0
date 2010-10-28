From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] ip_gre: fix percpu stats accounting
Date: Thu, 28 Oct 2010 20:07:56 +0400
Message-ID: <4CC99FDC.9070102@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45797 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758192Ab0J1QII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 12:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e985aad7 (ip_gre: percpu stats accounting) forgot the fallback
tunnel case (gre0).

This is the 4th part of the "foo: fix percpu stats accounting" series ;)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 01087e0..be05d5b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1321,7 +1321,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static void ipgre_fb_tunnel_init(struct net_device *dev)
+static int ipgre_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -1335,8 +1335,13 @@ static void ipgre_fb_tunnel_init(struct net_device *dev)
 	iph->ihl		= 5;
 	tunnel->hlen		= sizeof(struct iphdr) + 4;
 
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
 	dev_hold(dev);
 	rcu_assign_pointer(ign->tunnels_wc[0], tunnel);
+	return 0;
 }
 
 
@@ -1377,7 +1382,10 @@ static int __net_init ipgre_init_net(struct net *net)
 	}
 	dev_net_set(ign->fb_tunnel_dev, net);
 
-	ipgre_fb_tunnel_init(ign->fb_tunnel_dev);
+	err = ipgre_fb_tunnel_init(ign->fb_tunnel_dev);
+	if (err)
+		goto err_reg_dev;
+
 	ign->fb_tunnel_dev->rtnl_link_ops = &ipgre_link_ops;
 
 	if ((err = register_netdev(ign->fb_tunnel_dev)))
@@ -1386,7 +1394,7 @@ static int __net_init ipgre_init_net(struct net *net)
 	return 0;
 
 err_reg_dev:
-	free_netdev(ign->fb_tunnel_dev);
+	ipgre_dev_free(ign->fb_tunnel_dev);
 err_alloc_dev:
 	return err;
 }
