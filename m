From: Russell King <rmk@arm.linux.org.uk>
Subject: [PATCH] Prevent "eth0: driver changed get_stats after register" lying
Date: Sat, 18 Oct 2003 21:46:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031018214622.B25375@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

There appears to be a race condition between netdev_register_sysfs
and hotplug.  I'm seeing the message in the subject upon initialisation
of pcnet_cs.

We set "dev->last_stats" after we have registered the class device.
During class device registration, we trigger the hotplug scripts,
which can in turn bring up the interface.  This in turn checks to
see if "dev->last_stats == dev->get_stats", and, since we haven't
set dev->last_stats yet, we complain.

Here is a patch against 2.6.0-test8 which moves the initialisation
of last_stats such that we avoid the race.

--- orig/net/core/net-sysfs.c	Sat Oct 18 00:00:38 2003
+++ linux/net/core/net-sysfs.c	Sat Oct 18 21:23:15 2003
@@ -408,6 +408,7 @@
 
 	class_dev->class = &net_class;
 	class_dev->class_data = net;
+	net->last_stats = net->get_stats;
 
 	strlcpy(class_dev->class_id, net->name, BUS_ID_SIZE);
 	if ((ret = class_device_register(class_dev)))
@@ -419,7 +420,6 @@
 	}
 
 
-	net->last_stats = net->get_stats;
 	if (net->get_stats &&
 	    (ret = sysfs_create_group(&class_dev->kobj, &netstat_group)))
 		goto out_unreg; 


-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
