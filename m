From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipip tunnel dynamic net_device's
Date: Thu, 12 Jun 2003 15:27:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612152731.14d3f23d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ipip tunnel pseudo-driver to use dynamically allocated network devices.
This depends on the alloc_netdev earlier patch.

Tested by creating/deleting and unloading ipip tunnels.

--- linux-2.5/net/ipv4/ipip.c	2003-06-05 10:04:53.000000000 -0700
+++ linux-2.5-dyn/net/ipv4/ipip.c	2003-06-12 14:02:34.000000000 -0700
@@ -122,16 +122,9 @@
 
 static int ipip_fb_tunnel_init(struct net_device *dev);
 static int ipip_tunnel_init(struct net_device *dev);
+static void ipip_tunnel_setup(struct net_device *dev);
 
-static struct net_device ipip_fb_tunnel_dev = {
-	.name =	"tunl0",
-	.init =	ipip_fb_tunnel_init,
-};
-
-static struct ip_tunnel ipip_fb_tunnel = {
-	.dev =	&ipip_fb_tunnel_dev,
-	.parms ={ .name	= "tunl0", }
-};
+static struct net_device *ipip_fb_tunnel_dev;
 
 static struct ip_tunnel *tunnels_r_l[HASH_SIZE];
 static struct ip_tunnel *tunnels_r[HASH_SIZE];
@@ -216,6 +209,7 @@ static struct ip_tunnel * ipip_tunnel_lo
 	struct net_device *dev;
 	unsigned h = 0;
 	int prio = 0;
+	char name[IFNAMSIZ];
 
 	if (remote) {
 		prio |= 2;
@@ -232,32 +226,33 @@ static struct ip_tunnel * ipip_tunnel_lo
 	if (!create)
 		return NULL;
 
-	dev = kmalloc(sizeof(*dev) + sizeof(*t), GFP_KERNEL);
-	if (dev == NULL)
-		return NULL;
-
-	memset(dev, 0, sizeof(*dev) + sizeof(*t));
-	dev->priv = (void*)(dev+1);
-	nt = (struct ip_tunnel*)dev->priv;
-	nt->dev = dev;
-	dev->init = ipip_tunnel_init;
-	memcpy(&nt->parms, parms, sizeof(*parms));
-	nt->parms.name[IFNAMSIZ-1] = '\0';
-	strcpy(dev->name, nt->parms.name);
-	if (dev->name[0] == 0) {
+	if (parms->name[0])
+		strlcpy(name, parms->name, IFNAMSIZ);
+	else {
 		int i;
 		for (i=1; i<100; i++) {
-			sprintf(dev->name, "tunl%d", i);
-			if (__dev_get_by_name(dev->name) == NULL)
+			sprintf(name, "tunl%d", i);
+			if (__dev_get_by_name(name) == NULL)
 				break;
 		}
 		if (i==100)
 			goto failed;
-		memcpy(nt->parms.name, dev->name, IFNAMSIZ);
 	}
+
+	dev = alloc_netdev(sizeof(*t), name, ipip_tunnel_setup);
+	if (dev == NULL)
+		return NULL;
+
+	nt = dev->priv;
 	SET_MODULE_OWNER(dev);
-	if (register_netdevice(dev) < 0)
+	dev->init = ipip_tunnel_init;
+	dev->destructor = (void (*)(struct net_device *))kfree;
+	nt->parms = *parms;
+
+	if (register_netdevice(dev) < 0) {
+		kfree(dev);
 		goto failed;
+	}
 
 	dev_hold(dev);
 	ipip_tunnel_link(nt);
@@ -265,19 +260,12 @@ static struct ip_tunnel * ipip_tunnel_lo
 	return nt;
 
 failed:
-	kfree(dev);
 	return NULL;
 }
 
-static void ipip_tunnel_destructor(struct net_device *dev)
-{
-	if (dev != &ipip_fb_tunnel_dev)
-		kfree(dev);
-}
-
 static void ipip_tunnel_uninit(struct net_device *dev)
 {
-	if (dev == &ipip_fb_tunnel_dev) {
+	if (dev == ipip_fb_tunnel_dev) {
 		write_lock_bh(&ipip_lock);
 		tunnels_wc[0] = NULL;
 		write_unlock_bh(&ipip_lock);
@@ -682,7 +670,7 @@ ipip_tunnel_ioctl (struct net_device *de
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		t = NULL;
-		if (dev == &ipip_fb_tunnel_dev) {
+		if (dev == ipip_fb_tunnel_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
@@ -715,8 +703,7 @@ ipip_tunnel_ioctl (struct net_device *de
 
 		t = ipip_tunnel_locate(&p, cmd == SIOCADDTUNNEL);
 
-		if (dev != &ipip_fb_tunnel_dev && cmd == SIOCCHGTUNNEL &&
-		    t != &ipip_fb_tunnel) {
+		if (dev != ipip_fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -757,7 +744,7 @@ ipip_tunnel_ioctl (struct net_device *de
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		if (dev == &ipip_fb_tunnel_dev) {
+		if (dev == ipip_fb_tunnel_dev) {
 			err = -EFAULT;
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
@@ -765,7 +752,7 @@ ipip_tunnel_ioctl (struct net_device *de
 			if ((t = ipip_tunnel_locate(&p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
-			if (t == &ipip_fb_tunnel)
+			if (t->dev == ipip_fb_tunnel_dev)
 				goto done;
 			dev = t->dev;
 		}
@@ -793,12 +780,10 @@ static int ipip_tunnel_change_mtu(struct
 	return 0;
 }
 
-static void ipip_tunnel_init_gen(struct net_device *dev)
+static void ipip_tunnel_setup(struct net_device *dev)
 {
-	struct ip_tunnel *t = (struct ip_tunnel*)dev->priv;
-
+	SET_MODULE_OWNER(dev);
 	dev->uninit		= ipip_tunnel_uninit;
-	dev->destructor		= ipip_tunnel_destructor;
 	dev->hard_start_xmit	= ipip_tunnel_xmit;
 	dev->get_stats		= ipip_tunnel_get_stats;
 	dev->do_ioctl		= ipip_tunnel_ioctl;
@@ -810,8 +795,6 @@ static void ipip_tunnel_init_gen(struct 
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	memcpy(dev->dev_addr, &t->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &t->parms.iph.daddr, 4);
 }
 
 static int ipip_tunnel_init(struct net_device *dev)
@@ -822,8 +805,9 @@ static int ipip_tunnel_init(struct net_d
 
 	tunnel = (struct ip_tunnel*)dev->priv;
 	iph = &tunnel->parms.iph;
-
-	ipip_tunnel_init_gen(dev);
+	tunnel->dev = dev;
+	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
+	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	if (iph->daddr) {
 		struct flowi fl = { .oif = tunnel->parms.link,
@@ -854,17 +838,15 @@ static int ipip_tunnel_init(struct net_d
 
 static int __init ipip_fb_tunnel_init(struct net_device *dev)
 {
-	struct iphdr *iph;
-
-	ipip_tunnel_init_gen(dev);
+	struct ip_tunnel *tunnel = dev->priv;
+	struct iphdr *iph = &tunnel->parms.iph;
 
-	iph = &ipip_fb_tunnel.parms.iph;
 	iph->version		= 4;
 	iph->protocol		= IPPROTO_IPIP;
 	iph->ihl		= 5;
 
 	dev_hold(dev);
-	tunnels_wc[0]		= &ipip_fb_tunnel;
+	tunnels_wc[0]		= tunnel;
 	return 0;
 }
 
@@ -878,6 +860,8 @@ static char banner[] __initdata =
 
 int __init ipip_init(void)
 {
+	int err;
+
 	printk(banner);
 
 	if (xfrm4_tunnel_register(&ipip_handler) < 0) {
@@ -885,10 +869,24 @@ int __init ipip_init(void)
 		return -EAGAIN;
 	}
 
-	ipip_fb_tunnel_dev.priv = (void*)&ipip_fb_tunnel;
-	SET_MODULE_OWNER(&ipip_fb_tunnel_dev);
-	register_netdev(&ipip_fb_tunnel_dev);
-	return 0;
+	ipip_fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel),
+					   "tunl0",
+					   ipip_tunnel_setup);
+	if (!ipip_fb_tunnel_dev) {
+		err = -ENOMEM;
+		goto fail;
+	}
+
+	ipip_fb_tunnel_dev->init = ipip_fb_tunnel_init;
+
+	if ((err = register_netdev(ipip_fb_tunnel_dev)))
+	    goto fail;
+ out:
+	return err;
+ fail:
+	xfrm4_tunnel_deregister(&ipip_handler);
+	kfree(ipip_fb_tunnel_dev);
+	goto out;
 }
 
 static void __exit ipip_fini(void)
@@ -896,7 +894,7 @@ static void __exit ipip_fini(void)
 	if (xfrm4_tunnel_deregister(&ipip_handler) < 0)
 		printk(KERN_INFO "ipip close: can't deregister tunnel\n");
 
-	unregister_netdev(&ipip_fb_tunnel_dev);
+	unregister_netdev(ipip_fb_tunnel_dev);
 }
 
 #ifdef MODULE
