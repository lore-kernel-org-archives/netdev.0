From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/11) netrom - convert to alloc_netdev
Date: Wed, 13 Aug 2003 15:47:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813154709.66812756.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert net_device's from array of structures to an array
of pointers, so they can be freed individually on module
exit.  The net_device_stats are stored at dev->priv


diff -Nru a/include/net/netrom.h b/include/net/netrom.h
--- a/include/net/netrom.h	Wed Aug 13 14:22:03 2003
+++ b/include/net/netrom.h	Wed Aug 13 14:22:03 2003
@@ -183,7 +183,7 @@
 
 /* nr_dev.c */
 extern int  nr_rx_ip(struct sk_buff *, struct net_device *);
-extern int  nr_init(struct net_device *);
+extern void nr_setup(struct net_device *);
 
 /* nr_in.c */
 extern int  nr_process_rx_frame(struct sock *, struct sk_buff *);
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Wed Aug 13 14:22:03 2003
+++ b/net/netrom/af_netrom.c	Wed Aug 13 14:22:03 2003
@@ -1341,7 +1341,7 @@
 	.notifier_call	=	nr_device_event,
 };
 
-static struct net_device *dev_nr;
+static struct net_device **dev_nr;
 
 static char banner[] __initdata = KERN_INFO "G4KLX NET/ROM for Linux. Version 0.7 for AX25.037 Linux 2.4\n";
 
@@ -1354,21 +1354,39 @@
 		return -1;
 	}
 
-	if ((dev_nr = kmalloc(nr_ndevs * sizeof(struct net_device), GFP_KERNEL)) == NULL) {
-		printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device structure\n");
+	dev_nr = kmalloc(nr_ndevs * sizeof(struct net_device *), GFP_KERNEL);
+	if (dev_nr == NULL) {
+		printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device array\n");
 		return -1;
 	}
 
-	memset(dev_nr, 0x00, nr_ndevs * sizeof(struct net_device));
+	memset(dev_nr, 0x00, nr_ndevs * sizeof(struct net_device *));
 
 	for (i = 0; i < nr_ndevs; i++) {
-		sprintf(dev_nr[i].name, "nr%d", i);
-		dev_nr[i].base_addr = i;
-		dev_nr[i].init = nr_init;
-		register_netdev(&dev_nr[i]);
+		char name[IFNAMSIZ];
+		struct net_device *dev;
+
+		sprintf(name, "nr%d", i);
+		dev = alloc_netdev(sizeof(struct net_device_stats), name,
+					  nr_setup);
+		if (!dev) {
+			printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device structure\n");
+			goto fail;
+		}
+		
+		dev->base_addr = i;
+		if (register_netdev(dev)) {
+			printk(KERN_ERR "NET/ROM: nr_proto_init - unable to register network device\n");
+			goto fail;
+		}
+		dev_nr[i] = dev;
 	}
 
-	sock_register(&nr_family_ops);
+	if (sock_register(&nr_family_ops)) {
+		printk(KERN_ERR "NET/ROM: nr_proto_init - unable to register socket family\n");
+		goto fail;
+	}
+		
 	register_netdevice_notifier(&nr_dev_notifier);
 	printk(banner);
 
@@ -1385,6 +1403,11 @@
 	proc_net_create("nr_neigh", 0, nr_neigh_get_info);
 	proc_net_create("nr_nodes", 0, nr_nodes_get_info);
 	return 0;
+ fail:
+	while (--i >= 0)
+		unregister_netdev(dev_nr[i]);
+	kfree(dev_nr);
+	return -1;
 }
 
 module_init(nr_proto_init);
@@ -1420,11 +1443,9 @@
 	sock_unregister(PF_NETROM);
 
 	for (i = 0; i < nr_ndevs; i++) {
-		if (dev_nr[i].priv != NULL) {
-			unregister_netdev(&dev_nr[i]);
-			kfree(dev_nr[i].priv);
-			dev_nr[i].priv = NULL;
-		}
+		struct net_device *dev = dev_nr[i];
+		if (dev) 
+			unregister_netdev(dev);
 	}
 
 	kfree(dev_nr);
diff -Nru a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
--- a/net/netrom/nr_dev.c	Wed Aug 13 14:22:03 2003
+++ b/net/netrom/nr_dev.c	Wed Aug 13 14:22:03 2003
@@ -197,12 +197,13 @@
 	return (struct net_device_stats *)dev->priv;
 }
 
-int nr_init(struct net_device *dev)
+void nr_setup(struct net_device *dev)
 {
	SET_MODULE_OWNER(dev);
 	dev->mtu		= NR_MAX_PACKET_SIZE;
 	dev->hard_start_xmit	= nr_xmit;
 	dev->open		= nr_open;
 	dev->stop		= nr_close;
+	dev->destructor		= (void (*)(struct net_device *))kfree;
 
 	dev->hard_header	= nr_header;
@@ -215,12 +216,5 @@
 	/* New-style flags. */
 	dev->flags		= 0;
 
-	if ((dev->priv = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL)) == NULL)
-		return -ENOMEM;
-
-	memset(dev->priv, 0, sizeof(struct net_device_stats));
-
-	dev->get_stats = nr_get_stats;
-
-	return 0;
-};
+	dev->get_stats 		= nr_get_stats;
+}
