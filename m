From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] IPV6 tunnel (sit) using alloc_netdev
Date: Thu, 12 Jun 2003 15:20:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612152008.1bf2c9e1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change IPV6 tunnel pseudo-device to dynamically allocate using alloc_netdev.
This prevents problems with later changes where all net_device's need to be dynamically
allocated.

Tested by starting; configuring sit0; add/delete sit1, 
but can't really test unregister because IPV6 always seems to have refcounts.

--- linux-2.5/net/ipv6/sit.c	2003-06-05 10:04:53.000000000 -0700
+++ linux-2.5-dyn/net/ipv6/sit.c	2003-06-12 13:43:10.000000000 -0700
@@ -61,16 +61,9 @@
 
 static int ipip6_fb_tunnel_init(struct net_device *dev);
 static int ipip6_tunnel_init(struct net_device *dev);
+static void ipip6_tunnel_setup(struct net_device *dev);
 
-static struct net_device ipip6_fb_tunnel_dev = {
-	.name = "sit0",
-	.init = ipip6_fb_tunnel_init
-};
-
-static struct ip_tunnel ipip6_fb_tunnel = {
-	.dev = &ipip6_fb_tunnel_dev,
-	.parms = { .name = "sit0" }
-};
+static struct net_device *ipip6_fb_tunnel_dev;
 
 static struct ip_tunnel *tunnels_r_l[HASH_SIZE];
 static struct ip_tunnel *tunnels_r[HASH_SIZE];
@@ -154,6 +147,7 @@ static struct ip_tunnel * ipip6_tunnel_l
 	struct net_device *dev;
 	unsigned h = 0;
 	int prio = 0;
+	char name[IFNAMSIZ];
 
 	if (remote) {
 		prio |= 2;
@@ -168,54 +162,47 @@ static struct ip_tunnel * ipip6_tunnel_l
 			return t;
 	}
 	if (!create)
-		return NULL;
-
-	dev = kmalloc(sizeof(*dev) + sizeof(*t), GFP_KERNEL);
-	if (dev == NULL)
-		return NULL;
+		goto failed;
 
-	memset(dev, 0, sizeof(*dev) + sizeof(*t));
-	dev->priv = (void*)(dev+1);
-	nt = (struct ip_tunnel*)dev->priv;
-	nt->dev = dev;
-	dev->init = ipip6_tunnel_init;
-	memcpy(&nt->parms, parms, sizeof(*parms));
-	nt->parms.name[IFNAMSIZ-1] = '\0';
-	strcpy(dev->name, nt->parms.name);
-	if (dev->name[0] == 0) {
+	if (parms->name[0])
+		strlcpy(name, parms->name, IFNAMSIZ);
+	else {
 		int i;
 		for (i=1; i<100; i++) {
-			sprintf(dev->name, "sit%d", i);
-			if (__dev_get_by_name(dev->name) == NULL)
+			sprintf(name, "sit%d", i);
+			if (__dev_get_by_name(name) == NULL)
 				break;
 		}
 		if (i==100)
 			goto failed;
-		memcpy(nt->parms.name, dev->name, IFNAMSIZ);
 	}
-	SET_MODULE_OWNER(dev);
-	if (register_netdevice(dev) < 0)
+
+	dev = alloc_netdev(sizeof(*t), name, ipip6_tunnel_setup);
+	if (dev == NULL)
+		return NULL;
+
+	nt = dev->priv;
+	dev->init = ipip6_tunnel_init;
+	nt->parms = *parms;
+
+	if (register_netdevice(dev) < 0) {
+		kfree(dev);
 		goto failed;
+	}
 
 	dev_hold(dev);
+
 	ipip6_tunnel_link(nt);
 	/* Do not decrement MOD_USE_COUNT here. */
 	return nt;
 
 failed:
-	kfree(dev);
 	return NULL;
 }
 
-static void ipip6_tunnel_destructor(struct net_device *dev)
-{
-	if (dev != &ipip6_fb_tunnel_dev)
-		kfree(dev);
-}
-
 static void ipip6_tunnel_uninit(struct net_device *dev)
 {
-	if (dev == &ipip6_fb_tunnel_dev) {
+	if (dev == ipip6_fb_tunnel_dev) {
 		write_lock_bh(&ipip6_lock);
 		tunnels_wc[0] = NULL;
 		write_unlock_bh(&ipip6_lock);
@@ -621,7 +608,7 @@ ipip6_tunnel_ioctl (struct net_device *d
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		t = NULL;
-		if (dev == &ipip6_fb_tunnel_dev) {
+		if (dev == ipip6_fb_tunnel_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
@@ -654,8 +641,7 @@ ipip6_tunnel_ioctl (struct net_device *d
 
 		t = ipip6_tunnel_locate(&p, cmd == SIOCADDTUNNEL);
 
-		if (dev != &ipip6_fb_tunnel_dev && cmd == SIOCCHGTUNNEL &&
-		    t != &ipip6_fb_tunnel) {
+		if (dev != ipip6_fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -695,7 +681,7 @@ ipip6_tunnel_ioctl (struct net_device *d
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		if (dev == &ipip6_fb_tunnel_dev) {
+		if (dev == ipip6_fb_tunnel_dev) {
 			err = -EFAULT;
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
@@ -703,7 +689,7 @@ ipip6_tunnel_ioctl (struct net_device *d
 			if ((t = ipip6_tunnel_locate(&p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
-			if (t == &ipip6_fb_tunnel)
+			if (t == ipip6_fb_tunnel_dev->priv)
 				goto done;
 			dev = t->dev;
 		}
@@ -731,12 +717,11 @@ static int ipip6_tunnel_change_mtu(struc
 	return 0;
 }
 
-static void ipip6_tunnel_init_gen(struct net_device *dev)
+static void ipip6_tunnel_setup(struct net_device *dev)
 {
-	struct ip_tunnel *t = (struct ip_tunnel*)dev->priv;
-
-	dev->destructor		= ipip6_tunnel_destructor;
+	SET_MODULE_OWNER(dev);
 	dev->uninit		= ipip6_tunnel_uninit;
+	dev->destructor 	= (void (*)(struct net_device *))kfree;
 	dev->hard_start_xmit	= ipip6_tunnel_xmit;
 	dev->get_stats		= ipip6_tunnel_get_stats;
 	dev->do_ioctl		= ipip6_tunnel_ioctl;
@@ -748,8 +733,6 @@ static void ipip6_tunnel_init_gen(struct
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	memcpy(dev->dev_addr, &t->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &t->parms.iph.daddr, 4);
 }
 
 static int ipip6_tunnel_init(struct net_device *dev)
@@ -760,8 +743,9 @@ static int ipip6_tunnel_init(struct net_
 
 	tunnel = (struct ip_tunnel*)dev->priv;
 	iph = &tunnel->parms.iph;
-
-	ipip6_tunnel_init_gen(dev);
+	tunnel->dev = dev;
+	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
+	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	if (iph->daddr) {
 		struct flowi fl = { .nl_u = { .ip4_u =
@@ -793,18 +777,16 @@ static int ipip6_tunnel_init(struct net_
 
 int __init ipip6_fb_tunnel_init(struct net_device *dev)
 {
-	struct iphdr *iph;
+	struct ip_tunnel *tunnel = dev->priv;
+	struct iphdr *iph = &tunnel->parms.iph;
 
-	ipip6_tunnel_init_gen(dev);
-
-	iph = &ipip6_fb_tunnel.parms.iph;
 	iph->version		= 4;
 	iph->protocol		= IPPROTO_IPV6;
 	iph->ihl		= 5;
 	iph->ttl		= 64;
 
 	dev_hold(dev);
-	tunnels_wc[0]		= &ipip6_fb_tunnel;
+	tunnels_wc[0]		= tunnel;
 	return 0;
 }
 
@@ -817,12 +799,14 @@ static struct inet_protocol sit_protocol
 void sit_cleanup(void)
 {
 	inet_del_protocol(&sit_protocol, IPPROTO_IPV6);
-	unregister_netdev(&ipip6_fb_tunnel_dev);
+	unregister_netdev(ipip6_fb_tunnel_dev);
 }
 #endif
 
 int __init sit_init(void)
 {
+	int err;
+
 	printk(KERN_INFO "IPv6 over IPv4 tunneling driver\n");
 
 	if (inet_add_protocol(&sit_protocol, IPPROTO_IPV6) < 0) {
@@ -830,9 +814,22 @@ int __init sit_init(void)
 		return -EAGAIN;
 	}
 
-	ipip6_fb_tunnel_dev.priv = (void*)&ipip6_fb_tunnel;
-	strcpy(ipip6_fb_tunnel_dev.name, ipip6_fb_tunnel.parms.name);
-	SET_MODULE_OWNER(&ipip6_fb_tunnel_dev);
-	register_netdev(&ipip6_fb_tunnel_dev);
-	return 0;
+	ipip6_fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "sit0", 
+					   ipip6_tunnel_setup);
+	if (!ipip6_fb_tunnel_dev) {
+		err = -ENOMEM;
+		goto fail;
+	}
+
+	ipip6_fb_tunnel_dev->init = ipip6_fb_tunnel_init;
+
+	if ((err =  register_netdev(ipip6_fb_tunnel_dev)))
+		goto fail;
+
+ out:
+	return err;
+ fail:
+	inet_del_protocol(&sit_protocol, IPPROTO_IPV6);
+	kfree(ipip6_fb_tunnel_dev);
+	goto out;
 }
