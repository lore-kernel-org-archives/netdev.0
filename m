From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ethertap update
Date: Tue, 2 Sep 2003 12:11:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902121114.4f489216.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Updates to ethertap 
includes these changes from viro
	* switched ethertap to dynamic allocation
	* ethertap: embedded ->priv
	* ethertap: fixed resource leaks on failure exits
and from me
	* get it out of the static device list completely.
	* add dependency on NETLINK_DEV 
	* not really obsolete yet
	* configurable number of interfaces

Patch against 2.6.0-test4

diff -Nru a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	Tue Sep  2 12:07:05 2003
+++ b/drivers/net/Kconfig	Tue Sep  2 12:07:05 2003
@@ -132,8 +132,8 @@
 	  If you don't know what to use this for, you don't need it.
 
 config ETHERTAP
-	tristate "Ethertap network tap (OBSOLETE)"
-	depends on NETDEVICES && EXPERIMENTAL
+	tristate "Ethertap network tap"
+	depends on NETDEVICES && EXPERIMENTAL && NETLINK_DEV
 	---help---
 	  If you say Y here (and have said Y to "Kernel/User network link
 	  driver", above) and create a character special file /dev/tap0 with
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Sep  2 12:07:05 2003
+++ b/drivers/net/Space.c	Tue Sep  2 12:07:05 2003
@@ -89,7 +89,6 @@
 extern int bionet_probe(struct net_device *);
 extern int pamsnet_probe(struct net_device *);
 extern int cs89x0_probe(struct net_device *dev);
-extern int ethertap_probe(struct net_device *dev);
 extern int hplance_probe(struct net_device *dev);
 extern int bagetlance_probe(struct net_device *);
 extern int mvme147lance_probe(struct net_device *dev);
@@ -386,17 +385,6 @@
 		return 0;
 	return -ENODEV;
 }
-
-#ifdef CONFIG_ETHERTAP
-static struct net_device tap0_dev = {
-	.name		= "tap0",
-	.base_addr	= NETLINK_TAPBASE,
-	.next		= NEXT_DEV,
-	.init		= ethertap_probe,
-};
-#undef NEXT_DEV
-#define NEXT_DEV	(&tap0_dev)
-#endif
 
 #ifdef CONFIG_SDLA
 extern int sdla_init(struct net_device *);
diff -Nru a/drivers/net/ethertap.c b/drivers/net/ethertap.c
--- a/drivers/net/ethertap.c	Tue Sep  2 12:07:05 2003
+++ b/drivers/net/ethertap.c	Tue Sep  2 12:07:05 2003
@@ -33,7 +33,6 @@
  *	Index to functions.
  */
 
-int	    ethertap_probe(struct net_device *dev);
 static int  ethertap_open(struct net_device *dev);
 static int  ethertap_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int  ethertap_close(struct net_device *dev);
@@ -45,7 +44,11 @@
 
 static int ethertap_debug;
 
-static struct net_device *tap_map[32];	/* Returns the tap device for a given netlink */
+static int max_taps = 1;
+MODULE_PARM(max_taps, "i");
+MODULE_PARM_DESC(max_taps,"Max number of ethernet tap devices");
+
+static struct net_device **tap_map;	/* Returns the tap device for a given netlink */
 
 /*
  *	Board-specific info in dev->priv.
@@ -64,25 +67,29 @@
  *	To call this a probe is a bit misleading, however for real
  *	hardware it would have to check what was present.
  */
- 
-int __init ethertap_probe(struct net_device *dev)
+static int  __init ethertap_probe(int unit)
 {
+	struct net_device *dev;
+	int err = -ENOMEM;
+
+	dev = alloc_netdev(sizeof(struct net_local), "tap%d",
+			   ether_setup);
+
+	if (!dev)
+		goto out;
+
 	SET_MODULE_OWNER(dev);
 
+	sprintf(dev->name, "tap%d", unit);
+	dev->base_addr = unit + NETLINK_TAPBASE;
+
+	netdev_boot_setup_check(dev);
+
 	memcpy(dev->dev_addr, "\xFE\xFD\x00\x00\x00\x00", 6);
 	if (dev->mem_start & 0xf)
 		ethertap_debug = dev->mem_start & 0x7;
 
 	/*
-	 *	Initialize the device structure.
-	 */
-
-	dev->priv = kmalloc(sizeof(struct net_local), GFP_KERNEL);
-	if (dev->priv == NULL)
-		return -ENOMEM;
-	memset(dev->priv, 0, sizeof(struct net_local));
-
-	/*
 	 *	The tap specific entries in the device structure.
 	 */
 
@@ -94,17 +101,19 @@
 	dev->set_multicast_list = set_multicast_list;
 #endif
 
-	/*
-	 *	Setup the generic properties
-	 */
-
-	ether_setup(dev);
-
 	dev->tx_queue_len = 0;
 	dev->flags|=IFF_NOARP;
-	tap_map[dev->base_addr]=dev;
 
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+
+	tap_map[unit]=dev;
 	return 0;
+out1:
+	kfree(dev);
+out:
+	return err;
 }
 
 /*
@@ -116,11 +125,12 @@
 	struct net_local *lp = (struct net_local*)dev->priv;
 
 	if (ethertap_debug > 2)
-		printk("%s: Doing ethertap_open()...", dev->name);
+		printk(KERN_DEBUG "%s: Doing ethertap_open()...", dev->name);
 
 	lp->nl = netlink_kernel_create(dev->base_addr, ethertap_rx);
 	if (lp->nl == NULL)
 		return -ENOBUFS;
+
 	netif_start_queue(dev);
 	return 0;
 }
@@ -302,7 +312,7 @@
 	}
 
 	if (ethertap_debug > 3)
-		printk("%s: ethertap_rx()\n", dev->name);
+		printk(KERN_DEBUG "%s: ethertap_rx()\n", dev->name);
 
 	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL)
 		ethertap_rx_skb(skb, dev);
@@ -314,7 +324,7 @@
 	struct sock *sk = lp->nl;
 
 	if (ethertap_debug > 2)
-		printk("%s: Shutting down.\n", dev->name);
+		printk(KERN_DEBUG "%s: Shutting down.\n", dev->name);
 
 	netif_stop_queue(dev);
 
@@ -332,45 +342,49 @@
 	return &lp->stats;
 }
 
-#ifdef MODULE
-
-static int unit;
-MODULE_PARM(unit,"i");
-MODULE_PARM_DESC(unit,"Ethertap device number");
 
-static struct net_device dev_ethertap =
+int __init ethertap_init(void)
 {
-	.name		=	" ",
-	.init		=	 ethertap_probe
-};
+	int i, err = 0;
 
-int init_module(void)
-{
-	dev_ethertap.base_addr=unit+NETLINK_TAPBASE;
-	sprintf(dev_ethertap.name,"tap%d",unit);
-	if (dev_get(dev_ethertap.name))
-	{
-		printk(KERN_INFO "%s already loaded.\n", dev_ethertap.name);
-		return -EBUSY;
-	}
-	if (register_netdev(&dev_ethertap) != 0)
-		return -EIO;
-	return 0;
-}
-
-void cleanup_module(void)
-{
-	tap_map[dev_ethertap.base_addr]=NULL;
-	unregister_netdev(&dev_ethertap);
+	/* netlink can only hande 16 entries unless modified */
+	if (max_taps > MAX_LINKS - NETLINK_TAPBASE)
+		return -E2BIG;
 
-	/*
-	 *	Free up the private structure.
-	 */
+	tap_map = kmalloc(sizeof(struct net_device *)*max_taps, GFP_KERNEL);
+	if (!tap_map)
+		return -ENOMEM;
 
-	kfree(dev_ethertap.priv);
-	dev_ethertap.priv = NULL;	/* gets re-allocated by ethertap_probe */
+	for (i = 0; i < max_taps; i++) {
+		err = ethertap_probe(i);
+		if (err) {
+			while (--i > 0) {
+				unregister_netdev(tap_map[i]);
+				free_netdev(tap_map[i]);
+			}
+			break;
+		}
+	}
+	if (err)
+		kfree(tap_map);
+	return err;
+}
+module_init(ethertap_init);
+
+void __exit ethertap_cleanup(void)
+{
+	int i;
+
+	for (i = 0; i < max_taps; i++) {
+		struct net_device *dev = tap_map[i];
+		if (dev) {
+			tap_map[i] = NULL;
+			unregister_netdev(dev);
+			free_netdev(dev);
+		}
+	}
+	kfree(tap_map);
 }
+module_exit(ethertap_cleanup);
 
-#endif /* MODULE */
 MODULE_LICENSE("GPL");
-
