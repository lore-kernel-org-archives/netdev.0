From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.0-test2] (1/2) Dynamically allocate net_device
 structures for ROSE
Date: Tue, 5 Aug 2003 14:46:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030805144617.2e856d6d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch changes the ROSE protocol to allocate an array of pointers and each network device
separately.  This sets up later change where network_device object's are released on last use
which may be after the module is unloaded.

The patch is against 2.6.0-test2 (though this code hasn't changed in a long time).

Allocation is done via alloc_netdev so the dev->priv area is already reserved and
doesn't need to be allocated separately. 

diff -Nru a/include/net/rose.h b/include/net/rose.h
--- a/include/net/rose.h	Tue Aug  5 14:35:52 2003
+++ b/include/net/rose.h	Tue Aug  5 14:35:52 2003
@@ -163,7 +163,7 @@
 
 /* rose_dev.c */
 extern int  rose_rx_ip(struct sk_buff *, struct net_device *);
-extern int  rose_init(struct net_device *);
+extern void  rose_setup(struct net_device *);
 
 /* rose_in.c */
 extern int  rose_process_rx_frame(struct sock *, struct sk_buff *);
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	Tue Aug  5 14:35:52 2003
+++ b/net/rose/af_rose.c	Tue Aug  5 14:35:52 2003
@@ -43,7 +43,7 @@
 #include <net/ip.h>
 #include <net/arp.h>
 
-int rose_ndevs = 10;
+static int rose_ndevs = 10;
 
 int sysctl_rose_restart_request_timeout = ROSE_DEFAULT_T0;
 int sysctl_rose_call_request_timeout    = ROSE_DEFAULT_T1;
@@ -56,7 +56,7 @@
 int sysctl_rose_maximum_vcs             = ROSE_DEFAULT_MAXVC;
 int sysctl_rose_window_size             = ROSE_DEFAULT_WINDOW_SIZE;
 
-HLIST_HEAD(rose_list);
+static HLIST_HEAD(rose_list);
 static spinlock_t rose_list_lock = SPIN_LOCK_UNLOCKED;
 
 static struct proto_ops rose_proto_ops;
@@ -1435,7 +1435,7 @@
 	.notifier_call	=	rose_device_event,
 };
 
-static struct net_device *dev_rose;
+static struct net_device **dev_rose;
 
 static const char banner[] = KERN_INFO "F6FBB/G4KLX ROSE for Linux. Version 0.62 for AX25.037 Linux 2.4\n";
 
@@ -1450,17 +1450,39 @@
 		return -1;
 	}
 
-	if ((dev_rose = kmalloc(rose_ndevs * sizeof(struct net_device), GFP_KERNEL)) == NULL) {
+	dev_rose = kmalloc(rose_ndevs * sizeof(struct net_device *), GFP_KERNEL);
+	if (dev_rose == NULL) {
 		printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate device structure\n");
 		return -1;
 	}
 
-	memset(dev_rose, 0x00, rose_ndevs * sizeof(struct net_device));
+	memset(dev_rose, 0x00, rose_ndevs * sizeof(struct net_device*));
+	for (i = 0; i < rose_ndevs; i++) {
+		struct net_device *dev;
+		char name[IFNAMSIZ];
+
+		sprintf(name, "rose%d", i);
+		dev = alloc_netdev(sizeof(struct net_device_stats), 
+				   name, rose_setup);
+		if (!dev) {
+			printk(KERN_ERR "ROSE: rose_proto_init - unable to allocate memory\n");
+			while (--i >= 0)
+				kfree(dev_rose[i]);
+			return -ENOMEM;
+		}
+		dev_rose[i] = dev;
+	}
 
 	for (i = 0; i < rose_ndevs; i++) {
-		sprintf(dev_rose[i].name, "rose%d", i);
-		dev_rose[i].init = rose_init;
-		register_netdev(&dev_rose[i]);
+		if (register_netdev(dev_rose[i])) {
+			printk(KERN_ERR "ROSE: netdevice regeistration failed\n");
+			while (--i >= 0) {
+				unregister_netdev(dev_rose[i]);
+				kfree(dev_rose[i]);
+				return -EIO;
+			}
+		}
+			
 	}
 
 	sock_register(&rose_family_ops);
@@ -1518,10 +1540,11 @@
 	sock_unregister(PF_ROSE);
 
 	for (i = 0; i < rose_ndevs; i++) {
-		if (dev_rose[i].priv != NULL) {
-			kfree(dev_rose[i].priv);
-			dev_rose[i].priv = NULL;
-			unregister_netdev(&dev_rose[i]);
+		struct net_device *dev = dev_rose[i];
+
+		if (dev) {
+			unregister_netdev(dev);
+			kfree(dev);
 		}
 	}
 
diff -Nru a/net/rose/rose_dev.c b/net/rose/rose_dev.c
--- a/net/rose/rose_dev.c	Tue Aug  5 14:35:52 2003
+++ b/net/rose/rose_dev.c	Tue Aug  5 14:35:52 2003
@@ -165,7 +165,7 @@
 	return (struct net_device_stats *)dev->priv;
 }
 
-int rose_init(struct net_device *dev)
+void rose_setup(struct net_device *dev)
 {
 	SET_MODULE_OWNER(dev);
 	dev->mtu		= ROSE_MAX_PACKET_SIZE - 2;
@@ -182,13 +182,5 @@
 
 	/* New-style flags. */
 	dev->flags		= 0;
-
-	if ((dev->priv = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL)) == NULL)
-		return -ENOMEM;
-
-	memset(dev->priv, 0, sizeof(struct net_device_stats));
-
 	dev->get_stats = rose_get_stats;
-
-	return 0;
-};
+}
