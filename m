From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] kill drivers/net/net_init.c
Date: Sun, 14 Nov 2004 11:16:37 +0100
Message-ID: <20041114101637.GA31739@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After the last patch only three routines are left in this file, but all
of the fir into net/core/dev.c much better:

 - {un,}register_netdev are just wrappers around {un,}register_netdevice
   from dev.c
 - alloc_netdev's counterpart, free_netdev is in dev.c aswell.

So move over the remaining contents and add some kerneldoc comments
describing the functions.


--- 1.87/drivers/net/Makefile	2004-11-11 09:34:32 +01:00
+++ edited/drivers/net/Makefile	2004-11-14 10:36:00 +01:00
@@ -66,7 +66,7 @@
 
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
-obj-$(CONFIG_NET) += Space.o net_init.o loopback.o
+obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_ETHERTAP) += ethertap.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
--- 1.25/drivers/net/net_init.c	2004-11-11 23:40:09 +01:00
+++ edited/drivers/net/net_init.c	2004-11-14 10:35:50 +01:00
@@ -1,152 +0,0 @@
-/* net_init.c: Initialization for network devices. */
-/*
-	Written 1993,1994,1995 by Donald Becker.
-
-	The author may be reached as becker@scyld.com, or C/O
-	Scyld Computing Corporation
-	410 Severn Ave., Suite 210
-	Annapolis MD 21403
-
-	This file contains the initialization for the "pl14+" style ethernet
-	drivers.  It should eventually replace most of drivers/net/Space.c.
-	It's primary advantage is that it's able to allocate low-memory buffers.
-	A secondary advantage is that the dangerous NE*000 netcards can reserve
-	their I/O port region before the SCSI probes start.
-
-	Modifications/additions by Bjorn Ekwall <bj0rn@blox.se>:
-		ethdev_index[MAX_ETH_CARDS]
-		register_netdev() / unregister_netdev()
-		
-	Modifications by Wolfgang Walter
-		Use dev_close cleanly so we always shut things down tidily.
-		
-	Changed 29/10/95, Alan Cox to pass sockaddr's around for mac addresses.
-	
-	14/06/96 - Paul Gortmaker:	Add generic eth_change_mtu() function. 
-	24/09/96 - Paul Norton: Add token-ring variants of the netdev functions. 
-	
-	08/11/99 - Alan Cox: Got fed up of the mess in this file and cleaned it
-			up. We now share common code and have regularised name
-			allocation setups. Abolished the 16 card limits.
-	03/19/2000 - jgarzik and Urban Widmark: init_etherdev 32-byte align
-	03/21/2001 - jgarzik: alloc_etherdev and friends
-
-*/
-
-#include <linux/config.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/fs.h>
-#include <linux/slab.h>
-#include <linux/if_ether.h>
-#include <linux/string.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/fddidevice.h>
-#include <linux/hippidevice.h>
-#include <linux/trdevice.h>
-#include <linux/fcdevice.h>
-#include <linux/if_arp.h>
-#include <linux/if_ltalk.h>
-#include <linux/rtnetlink.h>
-#include <net/neighbour.h>
-
-/* The network devices currently exist only in the socket namespace, so these
-   entries are unused.  The only ones that make sense are
-    open	start the ethercard
-    close	stop  the ethercard
-    ioctl	To get statistics, perhaps set the interface port (AUI, BNC, etc.)
-   One can also imagine getting raw packets using
-    read & write
-   but this is probably better handled by a raw packet socket.
-
-   Given that almost all of these functions are handled in the current
-   socket-based scheme, putting ethercard devices in /dev/ seems pointless.
-   
-   [Removed all support for /dev network devices. When someone adds
-    streams then by magic we get them, but otherwise they are un-needed
-	and a space waste]
-*/
-
-
-struct net_device *alloc_netdev(int sizeof_priv, const char *mask,
-				       void (*setup)(struct net_device *))
-{
-	void *p;
-	struct net_device *dev;
-	int alloc_size;
-
-	/* ensure 32-byte alignment of both the device and private area */
-
-	alloc_size = (sizeof(struct net_device) + NETDEV_ALIGN_CONST)
-			& ~NETDEV_ALIGN_CONST;
-	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
-
-	p = kmalloc (alloc_size, GFP_KERNEL);
-	if (!p) {
-		printk(KERN_ERR "alloc_dev: Unable to allocate device.\n");
-		return NULL;
-	}
-
-	memset(p, 0, alloc_size);
-
-	dev = (struct net_device *)(((long)p + NETDEV_ALIGN_CONST)
-				& ~NETDEV_ALIGN_CONST);
-	dev->padded = (char *)dev - (char *)p;
-
-	if (sizeof_priv)
-		dev->priv = netdev_priv(dev);
-
-	setup(dev);
-	strcpy(dev->name, mask);
-
-	return dev;
-}
-EXPORT_SYMBOL(alloc_netdev);
-
-int register_netdev(struct net_device *dev)
-{
-	int err;
-
-	rtnl_lock();
-
-	/*
-	 *	If the name is a format string the caller wants us to
-	 *	do a name allocation
-	 */
-	 
-	if (strchr(dev->name, '%'))
-	{
-		err = dev_alloc_name(dev, dev->name);
-		if (err < 0)
-			goto out;
-	}
-	
-	/*
-	 *	Back compatibility hook. Kill this one in 2.5
-	 */
-	
-	if (dev->name[0]==0 || dev->name[0]==' ')
-	{
-		err = dev_alloc_name(dev, "eth%d");
-		if (err < 0)
-			goto out;
-	}
-
-	err = register_netdevice(dev);
-
-out:
-	rtnl_unlock();
-	return err;
-}
-
-void unregister_netdev(struct net_device *dev)
-{
-	rtnl_lock();
-	unregister_netdevice(dev);
-	rtnl_unlock();
-}
-
-EXPORT_SYMBOL(register_netdev);
-EXPORT_SYMBOL(unregister_netdev);
--- 1.174/net/core/dev.c	2004-11-10 01:12:00 +01:00
+++ edited/net/core/dev.c	2004-11-14 10:35:45 +01:00
@@ -2677,8 +2677,7 @@
  *	chain. 0 is returned on success. A negative errno code is returned
  *	on a failure to set up the device, or if the name is a duplicate.
  *
- *	Callers must hold the rtnl semaphore.  See the comment at the
- *	end of Space.c for details about the locking.  You may want
+ *	Callers must hold the rtnl semaphore. You may want
  *	register_netdev() instead of this.
  *
  *	BUGS:
@@ -2799,6 +2798,51 @@
 	goto out;
 }
 
+/**
+ *	register_netdev	- register a network device
+ *	@dev: device to register
+ *
+ *	Take a completed network device structure and add it to the kernel
+ *	interfaces. A %NETDEV_REGISTER message is sent to the netdev notifier
+ *	chain. 0 is returned on success. A negative errno code is returned
+ *	on a failure to set up the device, or if the name is a duplicate.
+ *
+ *	This is a wrapper around register_netdev that takes the rtnl semaphore
+ *	and expands the device name if you passed a format string to
+ *	alloc_netdev.
+ */
+int register_netdev(struct net_device *dev)
+{
+	int err;
+
+	rtnl_lock();
+
+	/*
+	 * If the name is a format string the caller wants us to do a
+	 * name allocation.
+	 */
+	if (strchr(dev->name, '%')) {
+		err = dev_alloc_name(dev, dev->name);
+		if (err < 0)
+			goto out;
+	}
+	
+	/*
+	 * Back compatibility hook. Kill this one in 2.5
+	 */
+	if (dev->name[0] == 0 || dev->name[0] == ' ') {
+		err = dev_alloc_name(dev, "eth%d");
+		if (err < 0)
+			goto out;
+	}
+
+	err = register_netdevice(dev);
+out:
+	rtnl_unlock();
+	return err;
+}
+EXPORT_SYMBOL(register_netdev);
+
 /*
  * netdev_wait_allrefs - wait until all references are gone.
  *
@@ -2942,6 +2986,46 @@
 }
 
 /**
+ *	alloc_netdev - allocate network device
+ *	@sizeof_priv:	size of private data to allocate space for
+ *	@name:		device name format string
+ *	@setup:		callback to initialize device
+ *
+ *	Allocates a struct net_device with private data area for driver use
+ *	and performs basic initialization.
+ */
+struct net_device *alloc_netdev(int sizeof_priv, const char *name,
+		void (*setup)(struct net_device *))
+{
+	void *p;
+	struct net_device *dev;
+	int alloc_size;
+
+	/* ensure 32-byte alignment of both the device and private area */
+	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
+	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
+
+	p = kmalloc(alloc_size, GFP_KERNEL);
+	if (!p) {
+		printk(KERN_ERR "alloc_dev: Unable to allocate device.\n");
+		return NULL;
+	}
+	memset(p, 0, alloc_size);
+
+	dev = (struct net_device *)
+		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
+	dev->padded = (char *)dev - (char *)p;
+
+	if (sizeof_priv)
+		dev->priv = netdev_priv(dev);
+
+	setup(dev);
+	strcpy(dev->name, name);
+	return dev;
+}
+EXPORT_SYMBOL(alloc_netdev);
+
+/**
  *	free_netdev - free network device
  *	@dev: device
  *
@@ -2983,8 +3067,7 @@
  *	from the kernel tables. On success 0 is returned, on a failure
  *	a negative errno code is returned.
  *
- *	Callers must hold the rtnl semaphore.  See the comment at the
- *	end of Space.c for details about the locking.  You may want
+ *	Callers must hold the rtnl semaphore.  You may want
  *	unregister_netdev() instead of this.
  */
 
@@ -3061,6 +3144,27 @@
 	dev_put(dev);
 	return 0;
 }
+
+/**
+ *	unregister_netdev - remove device from the kernel
+ *	@dev: device
+ *
+ *	This function shuts down a device interface and removes it
+ *	from the kernel tables. On success 0 is returned, on a failure
+ *	a negative errno code is returned.
+ *
+ *	This is just a wrapper for unregister_netdevice that takes
+ *	the rtnl semaphore.  In general you want to use this and not
+ *	unregister_netdevice.
+ */
+void unregister_netdev(struct net_device *dev)
+{
+	rtnl_lock();
+	unregister_netdevice(dev);
+	rtnl_unlock();
+}
+
+EXPORT_SYMBOL(unregister_netdev);
 
 #ifdef CONFIG_HOTPLUG_CPU
 static int dev_cpu_callback(struct notifier_block *nfb,
