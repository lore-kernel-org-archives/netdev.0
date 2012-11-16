From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/4] sit: allow to deactivate the creation of fb device
Date: Fri, 16 Nov 2012 17:14:15 +0100
Message-ID: <1353082456-21234-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37994 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab2KPQNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 11:13:31 -0500
In-Reply-To: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that tunnels can be configured via rtnetlink, this device is not mandatory.
The default is conservative.

The fb device was also used by 6RD as a template for default 6RD parameters.
User was able to update this template for each netns, hence when the fb device
is not created, this option does not exist. However, user can now set 6RD
parameters in the same netlink message that create the tunnel (before two
ioctl were needed) thus user can directly set the right value.

Last point is about ISATAP. The potential routers list (prl) management has not
been converted to netlink, but the ioctl is anyway performed on the related
device directly and not on the fb device.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 62 +++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 40 insertions(+), 22 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 504422d..d789a55 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -65,6 +65,15 @@
 #define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
+static bool setup_fb = true;
+module_param(setup_fb, bool, 0644);
+MODULE_PARM_DESC(setup_fb,
+		 "Setup the fb device to configure tunnel via IOCTL");
+
+#ifdef CONFIG_IPV6_SIT_6RD
+static struct ip_tunnel_6rd_parm ip6rd_template;
+#endif
+
 static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 static void ipip6_dev_free(struct net_device *dev);
@@ -204,12 +213,9 @@ static void ipip6_tunnel_clone_6rd(struct net_device *dev, struct sit_net *sitn)
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel *t = netdev_priv(dev);
 
-	if (t->dev == sitn->fb_tunnel_dev) {
-		ipv6_addr_set(&t->ip6rd.prefix, htonl(0x20020000), 0, 0, 0);
-		t->ip6rd.relay_prefix = 0;
-		t->ip6rd.prefixlen = 16;
-		t->ip6rd.relay_prefixlen = 0;
-	} else {
+	if (t->dev == sitn->fb_tunnel_dev || setup_fb == false)
+		memcpy(&t->ip6rd, &ip6rd_template, sizeof(t->ip6rd));
+	else {
 		struct ip_tunnel *t0 = netdev_priv(sitn->fb_tunnel_dev);
 		memcpy(&t->ip6rd, &t0->ip6rd, sizeof(t->ip6rd));
 	}
@@ -1501,26 +1507,30 @@ static int __net_init sit_init_net(struct net *net)
 	sitn->tunnels[2] = sitn->tunnels_r;
 	sitn->tunnels[3] = sitn->tunnels_r_l;
 
-	sitn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "sit0",
-					   ipip6_tunnel_setup);
-	if (!sitn->fb_tunnel_dev) {
-		err = -ENOMEM;
-		goto err_alloc_dev;
-	}
-	dev_net_set(sitn->fb_tunnel_dev, net);
+	if (setup_fb) {
+		sitn->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel),
+						   "sit0", ipip6_tunnel_setup);
+		if (!sitn->fb_tunnel_dev) {
+			err = -ENOMEM;
+			goto err_alloc_dev;
+		}
+		dev_net_set(sitn->fb_tunnel_dev, net);
 
-	err = ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
-	if (err)
-		goto err_dev_free;
+		err = ipip6_fb_tunnel_init(sitn->fb_tunnel_dev);
+		if (err)
+			goto err_dev_free;
 
-	ipip6_tunnel_clone_6rd(sitn->fb_tunnel_dev, sitn);
+		ipip6_tunnel_clone_6rd(sitn->fb_tunnel_dev, sitn);
 
-	if ((err = register_netdev(sitn->fb_tunnel_dev)))
-		goto err_reg_dev;
+		err = register_netdev(sitn->fb_tunnel_dev);
+		if (err)
+			goto err_reg_dev;
 
-	t = netdev_priv(sitn->fb_tunnel_dev);
+		t = netdev_priv(sitn->fb_tunnel_dev);
 
-	strcpy(t->parms.name, sitn->fb_tunnel_dev->name);
+		strcpy(t->parms.name, sitn->fb_tunnel_dev->name);
+	} else
+		sitn->fb_tunnel_dev = NULL;
 	return 0;
 
 err_reg_dev:
@@ -1538,7 +1548,8 @@ static void __net_exit sit_exit_net(struct net *net)
 
 	rtnl_lock();
 	sit_destroy_tunnels(sitn, &list);
-	unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
+	if (setup_fb)
+		unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 }
@@ -1565,6 +1576,13 @@ static int __init sit_init(void)
 
 	pr_info("IPv6 over IPv4 tunneling driver\n");
 
+#ifdef CONFIG_IPV6_SIT_6RD
+	ipv6_addr_set(&ip6rd_template.prefix, htonl(0x20020000), 0, 0, 0);
+	ip6rd_template.relay_prefix = 0;
+	ip6rd_template.prefixlen = 16;
+	ip6rd_template.relay_prefixlen = 0;
+#endif
+
 	err = register_pernet_device(&sit_net_ops);
 	if (err < 0)
 		return err;
-- 
1.7.12
