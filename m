From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] alloc_netdev for shaper
Date: Mon, 16 Jun 2003 14:11:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616141148.72df9830.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This converts shaper to allocating an array of pointers to net_device's rather
than an array of net_devices.  This is necessary because in future, network_device's
may live past unregister.

Tested with shapecfg to run e1000 at 64kbps.

This is against 2.5.71+ bk latest.

--- linux-2.5/drivers/net/shaper.c	2003-06-12 13:32:15.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/shaper.c	2003-06-16 13:58:57.000000000 -0700
@@ -630,7 +630,7 @@ static void shaper_init_priv(struct net_
  *	Add a shaper device to the system
  */
  
-static int __init shaper_probe(struct net_device *dev)
+static void __init shaper_setup(struct net_device *dev)
 {
 	/*
 	 *	Set up the shaper.
@@ -642,6 +642,7 @@ static int __init shaper_probe(struct ne
 
 	dev->open		= shaper_open;
 	dev->stop		= shaper_close;
+	dev->destructor 	= (void (*)(struct net_device *))kfree;
 	dev->hard_start_xmit 	= shaper_start_xmit;
 	dev->get_stats 		= shaper_get_stats;
 	dev->set_multicast_list = NULL;
@@ -669,12 +670,6 @@ static int __init shaper_probe(struct ne
 	dev->addr_len		= 0;
 	dev->tx_queue_len	= 10;
 	dev->flags		= 0;
-		
-	/*
-	 *	Shaper is ok
-	 */	
-	 
-	return 0;
 }
  
 static int shapers = 1;
@@ -695,35 +690,38 @@ __setup("shapers=", set_num_shapers);
 
 #endif /* MODULE */
 
-static struct net_device *devs;
+static struct net_device **devs;
 
 static unsigned int shapers_registered = 0;
 
 static int __init shaper_init(void)
 {
-	int i, err;
+	int i;
 	size_t alloc_size;
-	struct shaper *sp;
+	struct net_device *dev;
+	char name[IFNAMSIZ];
 
 	if (shapers < 1)
 		return -ENODEV;
 
-	alloc_size = (sizeof(*devs) * shapers) +
-		     (sizeof(struct shaper) * shapers);
+	alloc_size = sizeof(*dev) * shapers;
 	devs = kmalloc(alloc_size, GFP_KERNEL);
 	if (!devs)
 		return -ENOMEM;
 	memset(devs, 0, alloc_size);
-	sp = (struct shaper *) &devs[shapers];
 
 	for (i = 0; i < shapers; i++) {
-		err = dev_alloc_name(&devs[i], "shaper%d");
-		if (err < 0)
+
+		snprintf(name, IFNAMSIZ, "shaper%d", i);
+		dev = alloc_netdev(sizeof(struct shaper), name,
+				   shaper_setup);
+		if (!dev) 
 			break;
-		devs[i].init = shaper_probe;
-		devs[i].priv = &sp[i];
-		if (register_netdev(&devs[i]))
+
+		if (register_netdev(dev))
 			break;
+
+		devs[i] = dev;
 		shapers_registered++;
 	}
 
@@ -740,7 +738,8 @@ static void __exit shaper_exit (void)
 	int i;
 
 	for (i = 0; i < shapers_registered; i++)
-		unregister_netdev(&devs[i]);
+		if (devs[i])
+			unregister_netdev(devs[i]);
 
 	kfree(devs);
 	devs = NULL;
