From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 4/4] ip6tnl: allow to deactivate the creation of fb dev
Date: Fri, 16 Nov 2012 17:14:16 +0100
Message-ID: <1353082456-21234-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37995 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696Ab2KPQNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 11:13:31 -0500
In-Reply-To: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that tunnels can be configured via rtnetlink, this device is not mandatory.
The default is conservative.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 43 +++++++++++++++++++++++++++----------------
 1 file changed, 27 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index bf3a549..fe2028e 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -62,6 +62,11 @@ MODULE_DESCRIPTION("IPv6 tunneling device");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_NETDEV("ip6tnl0");
 
+static bool setup_fb = true;
+module_param(setup_fb, bool, 0644);
+MODULE_PARM_DESC(setup_fb,
+		 "Setup the fb device to configure tunnel via IOCTL");
+
 #ifdef IP6_TNL_DEBUG
 #define IP6_TNL_TRACE(x...) pr_debug("%s:" x "\n", __func__)
 #else
@@ -1711,8 +1716,10 @@ static void __net_exit ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 	}
 
 	t = rtnl_dereference(ip6n->tnls_wc[0]);
-	unregister_netdevice_queue(t->dev, &list);
-	unregister_netdevice_many(&list);
+	if (t) {
+		unregister_netdevice_queue(t->dev, &list);
+		unregister_netdevice_many(&list);
+	}
 }
 
 static int __net_init ip6_tnl_init_net(struct net *net)
@@ -1724,25 +1731,29 @@ static int __net_init ip6_tnl_init_net(struct net *net)
 	ip6n->tnls[0] = ip6n->tnls_wc;
 	ip6n->tnls[1] = ip6n->tnls_r_l;
 
-	err = -ENOMEM;
-	ip6n->fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
-				      ip6_tnl_dev_setup);
+	if (setup_fb) {
+		err = -ENOMEM;
+		ip6n->fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl),
+						"ip6tnl0", ip6_tnl_dev_setup);
 
-	if (!ip6n->fb_tnl_dev)
-		goto err_alloc_dev;
-	dev_net_set(ip6n->fb_tnl_dev, net);
+		if (!ip6n->fb_tnl_dev)
+			goto err_alloc_dev;
+		dev_net_set(ip6n->fb_tnl_dev, net);
 
-	err = ip6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
-	if (err < 0)
-		goto err_register;
+		err = ip6_fb_tnl_dev_init(ip6n->fb_tnl_dev);
+		if (err < 0)
+			goto err_register;
 
-	err = register_netdev(ip6n->fb_tnl_dev);
-	if (err < 0)
-		goto err_register;
+		err = register_netdev(ip6n->fb_tnl_dev);
+		if (err < 0)
+			goto err_register;
+
+		t = netdev_priv(ip6n->fb_tnl_dev);
 
-	t = netdev_priv(ip6n->fb_tnl_dev);
+		strcpy(t->parms.name, ip6n->fb_tnl_dev->name);
+	} else
+		ip6n->fb_tnl_dev = NULL;
 
-	strcpy(t->parms.name, ip6n->fb_tnl_dev->name);
 	return 0;
 
 err_register:
-- 
1.7.12
