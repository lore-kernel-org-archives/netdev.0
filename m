From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipgre tunnel dynamic net device's
Date: Thu, 12 Jun 2003 15:45:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612154543.16314928.shemminger@osdl.org>
References: <20030612152731.14d3f23d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030612152731.14d3f23d.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Similar change as earlier ipip tunnel.  Allocate network device's dynamically using alloc_netdev.
Likewise tested by create/remove/add/delete with iptunnel.

--- linux-2.5/net/ipv4/ip_gre.c	2003-06-05 10:04:52.000000000 -0700
+++ linux-2.5-dyn/net/ipv4/ip_gre.c	2003-06-12 14:02:34.000000000 -0700
@@ -114,20 +114,13 @@
  */
 
 static int ipgre_tunnel_init(struct net_device *dev);
+static void ipgre_tunnel_setup(struct net_device *dev);
 
 /* Fallback tunnel: no source, no destination, no key, no options */
 
 static int ipgre_fb_tunnel_init(struct net_device *dev);
 
-static struct net_device ipgre_fb_tunnel_dev = {
-	.name =	"gre0",
-	.init =	ipgre_fb_tunnel_init
-};
-
-static struct ip_tunnel ipgre_fb_tunnel = {
-	.dev =	&ipgre_fb_tunnel_dev,
-	.parms ={ .name = "gre0" }
-};
+static struct net_device *ipgre_fb_tunnel_dev;
 
 /* Tunnel hash table */
 
@@ -190,8 +183,9 @@ static struct ip_tunnel * ipgre_tunnel_l
 		if (t->parms.i_key == key && (t->dev->flags&IFF_UP))
 			return t;
 	}
-	if (ipgre_fb_tunnel_dev.flags&IFF_UP)
-		return &ipgre_fb_tunnel;
+
+	if (ipgre_fb_tunnel_dev->flags&IFF_UP)
+		return ipgre_fb_tunnel_dev->priv;
 	return NULL;
 }
 
@@ -246,6 +240,7 @@ static struct ip_tunnel * ipgre_tunnel_l
 	struct net_device *dev;
 	unsigned h = HASH(key);
 	int prio = 0;
+	char name[IFNAMSIZ];
 
 	if (local)
 		prio |= 1;
@@ -262,32 +257,28 @@ static struct ip_tunnel * ipgre_tunnel_l
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
-	dev->init = ipgre_tunnel_init;
-	memcpy(&nt->parms, parms, sizeof(*parms));
-	nt->parms.name[IFNAMSIZ-1] = '\0';
-	strcpy(dev->name, nt->parms.name);
-	if (dev->name[0] == 0) {
+	if (parms->name[0])
+		strlcpy(name, parms->name, IFNAMSIZ);
+	else {
 		int i;
 		for (i=1; i<100; i++) {
-			sprintf(dev->name, "gre%d", i);
-			if (__dev_get_by_name(dev->name) == NULL)
+			sprintf(name, "gre%d", i);
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
+	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
+	if (register_netdevice(dev) < 0) {
+		kfree(dev);
 		goto failed;
+	}
+
+	nt = dev->priv;
+	dev->init = ipgre_tunnel_init;
+	nt->parms = *parms;
 
 	dev_hold(dev);
 	ipgre_tunnel_link(nt);
@@ -295,16 +286,9 @@ static struct ip_tunnel * ipgre_tunnel_l
 	return nt;
 
 failed:
-	kfree(dev);
 	return NULL;
 }
 
-static void ipgre_tunnel_destructor(struct net_device *dev)
-{
-	if (dev != &ipgre_fb_tunnel_dev)
-		kfree(dev);
-}
-
 static void ipgre_tunnel_uninit(struct net_device *dev)
 {
 	ipgre_tunnel_unlink((struct ip_tunnel*)dev->priv);
@@ -916,7 +900,7 @@ ipgre_tunnel_ioctl (struct net_device *d
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 		t = NULL;
-		if (dev == &ipgre_fb_tunnel_dev) {
+		if (dev == ipgre_fb_tunnel_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
 				err = -EFAULT;
 				break;
@@ -955,8 +939,7 @@ ipgre_tunnel_ioctl (struct net_device *d
 
 		t = ipgre_tunnel_locate(&p, cmd == SIOCADDTUNNEL);
 
-		if (dev != &ipgre_fb_tunnel_dev && cmd == SIOCCHGTUNNEL &&
-		    t != &ipgre_fb_tunnel) {
+		if (dev != ipgre_fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -1006,7 +989,7 @@ ipgre_tunnel_ioctl (struct net_device *d
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		if (dev == &ipgre_fb_tunnel_dev) {
+		if (dev == ipgre_fb_tunnel_dev) {
 			err = -EFAULT;
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 				goto done;
@@ -1014,7 +997,7 @@ ipgre_tunnel_ioctl (struct net_device *d
 			if ((t = ipgre_tunnel_locate(&p, 0)) == NULL)
 				goto done;
 			err = -EPERM;
-			if (t == &ipgre_fb_tunnel)
+			if (t == ipgre_fb_tunnel_dev->priv)
 				goto done;
 			dev = t->dev;
 		}
@@ -1140,12 +1123,11 @@ static int ipgre_close(struct net_device
 
 #endif
 
-static void ipgre_tunnel_init_gen(struct net_device *dev)
+static void ipgre_tunnel_setup(struct net_device *dev)
 {
-	struct ip_tunnel *t = (struct ip_tunnel*)dev->priv;
-
+	SET_MODULE_OWNER(dev);
 	dev->uninit		= ipgre_tunnel_uninit;
-	dev->destructor		= ipgre_tunnel_destructor;
+	dev->destructor 	= (void (*)(struct net_device *))kfree;
 	dev->hard_start_xmit	= ipgre_tunnel_xmit;
 	dev->get_stats		= ipgre_tunnel_get_stats;
 	dev->do_ioctl		= ipgre_tunnel_ioctl;
@@ -1157,8 +1139,6 @@ static void ipgre_tunnel_init_gen(struct
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	memcpy(dev->dev_addr, &t->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &t->parms.iph.daddr, 4);
 }
 
 static int ipgre_tunnel_init(struct net_device *dev)
@@ -1173,7 +1153,9 @@ static int ipgre_tunnel_init(struct net_
 	tunnel = (struct ip_tunnel*)dev->priv;
 	iph = &tunnel->parms.iph;
 
-	ipgre_tunnel_init_gen(dev);
+	tunnel->dev			= dev;
+	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
+	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	/* Guess output device to choose reasonable mtu and hard_header_len */
 
@@ -1231,18 +1213,15 @@ static int ipgre_tunnel_init(struct net_
 int __init ipgre_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = (struct ip_tunnel*)dev->priv;
-	struct iphdr *iph;
-
-	ipgre_tunnel_init_gen(dev);
+	struct iphdr *iph = &tunnel->parms.iph;
 
-	iph = &ipgre_fb_tunnel.parms.iph;
 	iph->version		= 4;
 	iph->protocol		= IPPROTO_GRE;
 	iph->ihl		= 5;
 	tunnel->hlen		= sizeof(struct iphdr) + 4;
 
 	dev_hold(dev);
-	tunnels_wc[0]		= &ipgre_fb_tunnel;
+	tunnels_wc[0]		= tunnel;
 	return 0;
 }
 
@@ -1259,6 +1238,8 @@ static struct inet_protocol ipgre_protoc
 
 int __init ipgre_init(void)
 {
+	int err = -EINVAL;
+
 	printk(KERN_INFO "GRE over IPv4 tunneling driver\n");
 
 	if (inet_add_protocol(&ipgre_protocol, IPPROTO_GRE) < 0) {
@@ -1266,10 +1247,23 @@ int __init ipgre_init(void)
 		return -EAGAIN;
 	}
 
-	ipgre_fb_tunnel_dev.priv = (void*)&ipgre_fb_tunnel;
-	SET_MODULE_OWNER(&ipgre_fb_tunnel_dev);
-	register_netdev(&ipgre_fb_tunnel_dev);
-	return 0;
+	ipgre_fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "gre0",
+					   ipgre_tunnel_setup);
+	if (!ipgre_fb_tunnel_dev) {
+		err = -ENOMEM;
+		goto fail;
+	}
+
+	ipgre_fb_tunnel_dev->init = ipgre_fb_tunnel_init;
+
+	if ((err = register_netdev(ipgre_fb_tunnel_dev)))
+		goto fail;
+out:
+	return err;
+fail:
+	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
+	kfree(ipgre_fb_tunnel_dev);
+	goto out;
 }
 
 void ipgre_fini(void)
@@ -1277,7 +1271,7 @@ void ipgre_fini(void)
 	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
 		printk(KERN_INFO "ipgre close: can't remove protocol\n");
 
-	unregister_netdev(&ipgre_fb_tunnel_dev);
+	unregister_netdev(ipgre_fb_tunnel_dev);
 }
 
 #ifdef MODULE
