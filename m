From: Jeff Garzik <jgarzik@pobox.com>
Subject: [patch 1/2][fyi] alloc_ei_netdev() function for 8390 devices
Date: Mon, 1 Sep 2003 13:56:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901175621.GA31452@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've just checked this into my 2.4 and 2.5 net-driver queues.

Most 8390-based (ne2000) drivers use a helper lib, drivers/net/8390.c.
This lib has been taking care of the chore of allocating and managing
dev->priv, which is a common struct ei_device shared across all 8390
drivers.

For such drivers, I've created alloc_ei_netdev(), which is intended to
replace

	dev = alloc_etherdev(...);
	if (!dev)
		...
	...
	if (ethdev_init(dev))	/* 8390-specific */
		...
	...

with

	dev = alloc_ei_netdev();
	if (!dev)
		...
	...

The patch below is the API change I checked in.  The patch that follows
in the next email is an example conversion -- drivers/net/ne2k-pci.c.

	Jeff






# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1119  -> 1.1120 
#	  drivers/net/8390.c	1.8     -> 1.9    
#	  drivers/net/8390.h	1.6     -> 1.7    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/01	jgarzik@redhat.com	1.1120
# [netdrvr 8390] new function alloc_ei_netdev()
# 
# (preferred over alloc_etherdev + 8390-specific ethdev_init)
# --------------------------------------------
#
diff -Nru a/drivers/net/8390.c b/drivers/net/8390.c
--- a/drivers/net/8390.c	Mon Sep  1 13:48:26 2003
+++ b/drivers/net/8390.c	Mon Sep  1 13:48:26 2003
@@ -1000,6 +1000,11 @@
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 }	
 
+static inline void ei_device_init(struct ei_device *ei_local)
+{
+	spin_lock_init(&ei_local->page_lock);
+}
+
 /**
  * ethdev_init - init rest of 8390 device struct
  * @dev: network device structure to init
@@ -1015,14 +1020,11 @@
     
 	if (dev->priv == NULL) 
 	{
-		struct ei_device *ei_local;
-		
 		dev->priv = kmalloc(sizeof(struct ei_device), GFP_KERNEL);
 		if (dev->priv == NULL)
 			return -ENOMEM;
 		memset(dev->priv, 0, sizeof(struct ei_device));
-		ei_local = (struct ei_device *)dev->priv;
-		spin_lock_init(&ei_local->page_lock);
+		ei_device_init(dev->priv);
 	}
     
 	dev->hard_start_xmit = &ei_start_xmit;
@@ -1033,6 +1035,29 @@
         
 	return 0;
 }
+
+/* wrapper to make alloc_netdev happy; probably should just cast... */
+static void __ethdev_init(struct net_device *dev)
+{
+	ethdev_init(dev);
+}
+
+/**
+ * alloc_ei_netdev - alloc_etherdev counterpart for 8390
+ *
+ * Allocate 8390-specific net_device.
+ */
+struct net_device *alloc_ei_netdev(void)
+{
+	struct net_device *dev;
+	
+	dev = alloc_netdev(sizeof(struct ei_device), "eth%d", __ethdev_init);
+	if (dev)
+		ei_device_init(dev->priv);
+
+	return dev;
+}
+
 
 
 
@@ -1136,6 +1161,7 @@
 EXPORT_SYMBOL(ei_tx_timeout);
 EXPORT_SYMBOL(ethdev_init);
 EXPORT_SYMBOL(NS8390_init);
+EXPORT_SYMBOL(alloc_ei_netdev);
 
 #if defined(MODULE)
 
diff -Nru a/drivers/net/8390.h b/drivers/net/8390.h
--- a/drivers/net/8390.h	Mon Sep  1 13:48:26 2003
+++ b/drivers/net/8390.h	Mon Sep  1 13:48:26 2003
@@ -50,6 +50,7 @@
 extern int ei_open(struct net_device *dev);
 extern int ei_close(struct net_device *dev);
 extern void ei_interrupt(int irq, void *dev_id, struct pt_regs *regs);
+extern struct net_device *alloc_ei_netdev(void);
 
 /* Most of these entries should be in 'struct net_device' (or most of the
    things in there should be here!) */
