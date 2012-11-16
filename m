From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/4] ipip: allow to deactivate the creation of fb dev
Date: Fri, 16 Nov 2012 17:14:13 +0100
Message-ID: <1353082456-21234-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37992 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213Ab2KPQNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 11:13:31 -0500
In-Reply-To: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that tunnels can be configured via rtnetlink, this device is not mandatory.
The default is conservative.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipip.c | 42 ++++++++++++++++++++++++++----------------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index c26c171..9e11633 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -124,6 +124,11 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+static bool setup_fb = true;
+module_param(setup_fb, bool, 0644);
+MODULE_PARM_DESC(setup_fb,
+		 "Setup the fb device to configure tunnel via IOCTL");
+
 static int ipip_net_id __read_mostly;
 struct ipip_net {
 	struct ip_tunnel __rcu *tunnels_r_l[HASH_SIZE];
@@ -1022,25 +1027,29 @@ static int __net_init ipip_init_net(struct net *net)
 	ipn->tunnels[2] = ipn->tunnels_r;
 	ipn->tunnels[3] = ipn->tunnels_r_l;
 
-	ipn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel),
-					   "tunl0",
-					   ipip_tunnel_setup);
-	if (!ipn->fb_tunnel_dev) {
-		err = -ENOMEM;
-		goto err_alloc_dev;
-	}
-	dev_net_set(ipn->fb_tunnel_dev, net);
+	if (setup_fb) {
+		ipn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel),
+						  "tunl0",
+						  ipip_tunnel_setup);
+		if (!ipn->fb_tunnel_dev) {
+			err = -ENOMEM;
+			goto err_alloc_dev;
+		}
+		dev_net_set(ipn->fb_tunnel_dev, net);
 
-	err = ipip_fb_tunnel_init(ipn->fb_tunnel_dev);
-	if (err)
-		goto err_reg_dev;
+		err = ipip_fb_tunnel_init(ipn->fb_tunnel_dev);
+		if (err)
+			goto err_reg_dev;
 
-	if ((err = register_netdev(ipn->fb_tunnel_dev)))
-		goto err_reg_dev;
+		err = register_netdev(ipn->fb_tunnel_dev);
+		if (err)
+			goto err_reg_dev;
 
-	t = netdev_priv(ipn->fb_tunnel_dev);
+		t = netdev_priv(ipn->fb_tunnel_dev);
 
-	strcpy(t->parms.name, ipn->fb_tunnel_dev->name);
+		strcpy(t->parms.name, ipn->fb_tunnel_dev->name);
+	} else
+		ipn->fb_tunnel_dev = NULL;
 	return 0;
 
 err_reg_dev:
@@ -1057,7 +1066,8 @@ static void __net_exit ipip_exit_net(struct net *net)
 
 	rtnl_lock();
 	ipip_destroy_tunnels(ipn, &list);
-	unregister_netdevice_queue(ipn->fb_tunnel_dev, &list);
+	if (setup_fb)
+		unregister_netdevice_queue(ipn->fb_tunnel_dev, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
-- 
1.7.12
