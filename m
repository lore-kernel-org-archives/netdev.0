From: "David S. Miller" <davem@redhat.com>
Subject: Re: MOD_{INC,SEC}_USE_COUNT() in net/ipv{4,6}
Date: Wed, 09 Apr 2003 23:29:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030409.232918.112623123.davem@redhat.com>
References: <20030409.180004.08009488.davem@redhat.com>
	<200304100254.GAA06560@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200304100254.GAA06560@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Thu, 10 Apr 2003 06:54:38 +0400 (MSD)
   
   Why not to delete this things instead? Calls of these functions
   from inside of module is completely meaningless.

Better to implement correctly than to outright delete.

Please review.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1176  -> 1.1177 
#	   net/ipv4/ip_gre.c	1.21    -> 1.22   
#	     net/ipv4/ipip.c	1.24    -> 1.25   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/04/09	davem@nuts.ninka.net	1.1177
# [IPV4]: Do proper netdev module refcounting in tunnel drivers.
# --------------------------------------------
#
diff -Nru a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
--- a/net/ipv4/ip_gre.c	Wed Apr  9 23:34:23 2003
+++ b/net/ipv4/ip_gre.c	Wed Apr  9 23:34:23 2003
@@ -262,13 +262,10 @@
 	if (!create)
 		return NULL;
 
-	if (!try_module_get(THIS_MODULE))
-		return NULL;
 	dev = kmalloc(sizeof(*dev) + sizeof(*t), GFP_KERNEL);
-	if (dev == NULL) {
-		module_put(THIS_MODULE);
+	if (dev == NULL)
 		return NULL;
-	}
+
 	memset(dev, 0, sizeof(*dev) + sizeof(*t));
 	dev->priv = (void*)(dev+1);
 	nt = (struct ip_tunnel*)dev->priv;
@@ -288,6 +285,7 @@
 			goto failed;
 		memcpy(nt->parms.name, dev->name, IFNAMSIZ);
 	}
+	SET_MODULE_OWNER(dev);
 	if (register_netdevice(dev) < 0)
 		goto failed;
 
@@ -298,16 +296,13 @@
 
 failed:
 	kfree(dev);
-	module_put(THIS_MODULE);
 	return NULL;
 }
 
 static void ipgre_tunnel_destructor(struct net_device *dev)
 {
-	if (dev != &ipgre_fb_tunnel_dev) {
+	if (dev != &ipgre_fb_tunnel_dev)
 		kfree(dev);
-		module_put(THIS_MODULE);
-	}
 }
 
 static void ipgre_tunnel_uninit(struct net_device *dev)
@@ -921,9 +916,6 @@
 	struct ip_tunnel_parm p;
 	struct ip_tunnel *t;
 
-	if (!try_module_get(THIS_MODULE))
-		return -EBUSY;
-
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		t = NULL;
@@ -1037,7 +1029,6 @@
 	}
 
 done:
-	module_put(THIS_MODULE);
 	return err;
 }
 
@@ -1117,8 +1108,6 @@
 {
 	struct ip_tunnel *t = (struct ip_tunnel*)dev->priv;
 
-	if (!try_module_get(THIS_MODULE))
-		return -EBUSY;
 	if (MULTICAST(t->parms.iph.daddr)) {
 		struct flowi fl = { .oif = t->parms.link,
 				    .nl_u = { .ip4_u =
@@ -1127,16 +1116,12 @@
 						.tos = RT_TOS(t->parms.iph.tos) } },
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
-		if (ip_route_output_key(&rt, &fl)) {
-			module_put(THIS_MODULE);
+		if (ip_route_output_key(&rt, &fl))
 			return -EADDRNOTAVAIL;
-		}
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
-		if (__in_dev_get(dev) == NULL) {
-			module_put(THIS_MODULE);
+		if (__in_dev_get(dev) == NULL)
 			return -EADDRNOTAVAIL;
-		}
 		t->mlink = dev->ifindex;
 		ip_mc_inc_group(__in_dev_get(dev), t->parms.iph.daddr);
 	}
@@ -1153,7 +1138,6 @@
 			in_dev_put(in_dev);
 		}
 	}
-	module_put(THIS_MODULE);
 	return 0;
 }
 
@@ -1247,31 +1231,12 @@
 	return 0;
 }
 
-#ifdef MODULE
-static int ipgre_fb_tunnel_open(struct net_device *dev)
-{
-	if (!try_module_get(THIS_MODULE))
-		return -EBUSY;
-	return 0;
-}
-
-static int ipgre_fb_tunnel_close(struct net_device *dev)
-{
-	module_put(THIS_MODULE);
-	return 0;
-}
-#endif
-
 int __init ipgre_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = (struct ip_tunnel*)dev->priv;
 	struct iphdr *iph;
 
 	ipgre_tunnel_init_gen(dev);
-#ifdef MODULE
-	dev->open		= ipgre_fb_tunnel_open;
-	dev->stop		= ipgre_fb_tunnel_close;
-#endif
 
 	iph = &ipgre_fb_tunnel.parms.iph;
 	iph->version		= 4;
@@ -1295,11 +1260,7 @@
  *	And now the modules code and kernel interface.
  */
 
-#ifdef MODULE
-int init_module(void) 
-#else
 int __init ipgre_init(void)
-#endif
 {
 	printk(KERN_INFO "GRE over IPv4 tunneling driver\n");
 
@@ -1309,13 +1270,12 @@
 	}
 
 	ipgre_fb_tunnel_dev.priv = (void*)&ipgre_fb_tunnel;
+	SET_MODULE_OWNER(&ipgre_fb_tunnel_dev);
 	register_netdev(&ipgre_fb_tunnel_dev);
 	return 0;
 }
 
-#ifdef MODULE
-
-void cleanup_module(void)
+void ipgre_fini(void)
 {
 	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
 		printk(KERN_INFO "ipgre close: can't remove protocol\n");
@@ -1323,5 +1283,8 @@
 	unregister_netdev(&ipgre_fb_tunnel_dev);
 }
 
+#ifdef MODULE
+module_init(ipgre_init);
 #endif
+module_exit(ipgre_fini);
 MODULE_LICENSE("GPL");
diff -Nru a/net/ipv4/ipip.c b/net/ipv4/ipip.c
--- a/net/ipv4/ipip.c	Wed Apr  9 23:34:23 2003
+++ b/net/ipv4/ipip.c	Wed Apr  9 23:34:23 2003
@@ -231,13 +231,10 @@
 	if (!create)
 		return NULL;
 
-	if (!try_module_get(THIS_MODULE))
-		return NULL;
 	dev = kmalloc(sizeof(*dev) + sizeof(*t), GFP_KERNEL);
-	if (dev == NULL) {
-		module_put(THIS_MODULE);
+	if (dev == NULL)
 		return NULL;
-	}
+
 	memset(dev, 0, sizeof(*dev) + sizeof(*t));
 	dev->priv = (void*)(dev+1);
 	nt = (struct ip_tunnel*)dev->priv;
@@ -257,6 +254,7 @@
 			goto failed;
 		memcpy(nt->parms.name, dev->name, IFNAMSIZ);
 	}
+	SET_MODULE_OWNER(dev);
 	if (register_netdevice(dev) < 0)
 		goto failed;
 
@@ -267,16 +265,13 @@
 
 failed:
 	kfree(dev);
-	module_put(THIS_MODULE);
 	return NULL;
 }
 
 static void ipip_tunnel_destructor(struct net_device *dev)
 {
-	if (dev != &ipip_fb_tunnel_dev) {
+	if (dev != &ipip_fb_tunnel_dev)
 		kfree(dev);
-		module_put(THIS_MODULE);
-	}
 }
 
 static void ipip_tunnel_uninit(struct net_device *dev)
@@ -683,9 +678,6 @@
 	struct ip_tunnel_parm p;
 	struct ip_tunnel *t;
 
-	if (!try_module_get(THIS_MODULE))
-		return -EBUSY;
-
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		t = NULL;
@@ -784,7 +776,6 @@
 	}
 
 done:
-	module_put(THIS_MODULE);
 	return err;
 }
 
@@ -860,30 +851,11 @@
 	return 0;
 }
 
-#ifdef MODULE
-static int ipip_fb_tunnel_open(struct net_device *dev)
-{
-	if (!try_module_get(THIS_MODULE))
-		return -EBUSY;
-	return 0;
-}
-
-static int ipip_fb_tunnel_close(struct net_device *dev)
-{
-	module_put(THIS_MODULE);
-	return 0;
-}
-#endif
-
 int __init ipip_fb_tunnel_init(struct net_device *dev)
 {
 	struct iphdr *iph;
 
 	ipip_tunnel_init_gen(dev);
-#ifdef MODULE
-	dev->open		= ipip_fb_tunnel_open;
-	dev->stop		= ipip_fb_tunnel_close;
-#endif
 
 	iph = &ipip_fb_tunnel.parms.iph;
 	iph->version		= 4;
@@ -913,6 +885,7 @@
 	}
 
 	ipip_fb_tunnel_dev.priv = (void*)&ipip_fb_tunnel;
+	SET_MODULE_OWNER(&ipip_fb_tunnel_dev);
 	register_netdev(&ipip_fb_tunnel_dev);
 	return 0;
 }
