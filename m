From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] enabling netdev boot options (2.6.0-t9)
Date: Sun, 9 Nov 2003 15:26:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031109152643.73688224.rddunlap@osdl.org>
References: <20031108160441.3a0a5505.rddunlap@osdl.org>
	<20031108204406.5dbbdc87.rddunlap@osdl.org>
	<20031109115535.A1282@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, saw@saw.sw.com.sg, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031109115535.A1282@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 9 Nov 2003 11:55:35 +0100 Rask Ingemann Lambertsen <rask@sygehus.dk> wrote:

| I don't like that name for the function. dev_alloc_name_lock() makes it
| natural to think that there is a matching dev_alloc_name_unlock() function
| which you should call afterwards. How about dev_alloc_name_locked() or
| dev_alloc_name_with_lock() instead?

I didn't like that name either.  Now changed to
dev_alloc_name_locked() and exported.

Take 3 below.  More comments?

--
~Randy


description:      enable eepro100 and 3c59x drivers to recognize
		  'netdev=' boot options:
		  use dev_alloc_name() to assign an interface name if
		  rtnl lock is already held (eepro100);
		  use [new] dev_alloc_name_locked() to assign interface
		  name if required lock is not already held;
		  then use netdev_boot_setup_check() to check for boot
		  options for that interface (name);
		  add dev_alloc_name_locked() to net/core/dev.c;
		  export dev_alloc_name_locked() for modules;

maintainer:       Andrey V. Savochkin (saw@saw.sw.com.sg);
		  Andrew Morton (akpm@osdl.org) et al

product_versions: Linux 2.6.0-test9

diffstat:=
 drivers/net/3c59x.c       |    6 ++++++
 drivers/net/eepro100.c    |   12 +++++++-----
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   24 ++++++++++++++++++++++++
 4 files changed, 38 insertions(+), 5 deletions(-)

diff -Naurp ./drivers/net/eepro100.c~netdev ./drivers/net/eepro100.c
--- ./drivers/net/eepro100.c~netdev	2003-10-25 11:44:01.000000000 -0700
+++ ./drivers/net/eepro100.c	2003-11-08 20:05:38.000000000 -0800
@@ -681,17 +681,19 @@ static int __devinit speedo_found1(struc
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (dev->mem_start > 0)
+	rtnl_lock();
+
+	if (dev_alloc_name(dev, dev->name) < 0) 
+		goto err_free_unlock;
+
+	if (netdev_boot_setup_check(dev) && dev->mem_start > 0) {
 		option = dev->mem_start;
+	}
 	else if (card_idx >= 0  &&  options[card_idx] >= 0)
 		option = options[card_idx];
 	else
 		option = 0;
 
-	rtnl_lock();
-	if (dev_alloc_name(dev, dev->name) < 0) 
-		goto err_free_unlock;
-
 	/* Read the station address EEPROM before doing the reset.
 	   Nominally his should even be done before accepting the device, but
 	   then we wouldn't have a device name with which to report the error.
diff -Naurp ./drivers/net/3c59x.c~netdev ./drivers/net/3c59x.c
--- ./drivers/net/3c59x.c~netdev	2003-10-25 11:42:42.000000000 -0700
+++ ./drivers/net/3c59x.c	2003-11-09 15:13:01.000000000 -0800
@@ -1110,6 +1110,12 @@ static int __devinit vortex_probe1(struc
 	SET_NETDEV_DEV(dev, gendev);
 	vp = dev->priv;
 
+	retval = dev_alloc_name_locked(dev, dev->name);
+	if (retval < 0)
+		goto free_region;
+
+	netdev_boot_setup_check(dev);
+
 	option = global_options;
 
 	/* The lower four bits are the media type. */
diff -Naurp ./net/core/dev.c~netdev ./net/core/dev.c
--- ./net/core/dev.c~netdev	2003-10-25 11:43:39.000000000 -0700
+++ ./net/core/dev.c	2003-11-09 15:04:10.000000000 -0800
@@ -635,6 +635,29 @@ int dev_alloc_name(struct net_device *de
 }
 
 /**
+ *	dev_alloc_name_locked - allocate a name for a device,
+ *		with required locking
+ *	@dev: device
+ *	@name: name format string
+ *
+ *	Passed a format string - eg "lt%d" it will try and find a suitable
+ *	id. Not efficient for many devices, not called a lot.
+ *	This function takes the rtnl lock while allocating the name and
+ *	adding the device in order to avoid duplicates.
+ *	Returns the number of the unit assigned or a negative errno code.
+ */
+
+int dev_alloc_name_locked(struct net_device *dev, const char *name)
+{
+	int ret;
+
+	rtnl_lock();
+	ret = dev_alloc_name(dev, name);
+	rtnl_unlock();
+	return ret;
+}
+
+/**
  *	dev_alloc - allocate a network device and name
  *	@name: name format string
  *	@err: error return pointer
@@ -3035,6 +3058,7 @@ EXPORT_SYMBOL(call_netdevice_notifiers);
 EXPORT_SYMBOL(dev_add_pack);
 EXPORT_SYMBOL(__dev_alloc);
 EXPORT_SYMBOL(dev_alloc_name);
+EXPORT_SYMBOL(dev_alloc_name_locked);
 EXPORT_SYMBOL(dev_close);
 EXPORT_SYMBOL(dev_get_by_flags);
 EXPORT_SYMBOL(dev_get_by_index);
diff -Naurp ./include/linux/netdevice.h~netdev ./include/linux/netdevice.h
--- ./include/linux/netdevice.h~netdev	2003-10-25 11:44:45.000000000 -0700
+++ ./include/linux/netdevice.h	2003-11-09 15:13:41.000000000 -0800
@@ -518,6 +518,7 @@ static inline __deprecated struct net_de
 	return __dev_alloc(name, err);
 }
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
+extern int		dev_alloc_name_locked(struct net_device *dev, const char *name);
 extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
