From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH/RFC] enabling netdev boot options
Date: Sat, 8 Nov 2003 16:04:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031108160416.236ec29d.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: saw@saw.sw.com.sg, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I have modified 3c59x.c (for 2.4.22 and 2.6.0-test9) and eepro100
(for 2.6.0-test9 only) to check for netdev= boot options.

I have verified that this change works (on 2.6.0-test9) when using
an Intel PRO/100 NIC.

netdev_boot_setup_check() needs to know the interface name to check
for boot options, so I added calls to dev_alloc_name() so that the
interface name would be assigned before calling
netdev_boot_setup_check().

Other options include wedging some function so that netdev_boot_setup_check()
is called automatically, but it needs to be done very soon after
dev_alloc_name() so that dev->{irq, base_addr, mem_start, mem_end}
are not clobbered.

(Here are some other options that I've considered.)

Option 3:  with an API change, it could pass back a struct ifmap instead
of clobbering the dev-> fields.

Option 4:  use something other than interface name to save and lookup
netdev boot options.  Possibly a unique identifier, like a MAC address.

Option 5:  I expect that the long-term solution is to use sysfs (2.6.x
or 2.7).  Any comments/preferences about that?

3c59x patch for 2.4.22 is below.  2.6.0-test9 patch follows in next
email.

--
~Randy


description:      enable 3c59x driver to recognize 'netdev=' boot options
changelog:        use dev_alloc_name() to assign an interface name,
		  then use netdev_boot_setup_check() to check for boot
		  options for that interface (name);
maintainer:       Andrew Morton et al
product_versions: Linux 2.4.22
patch_name:       3c59x-boot-setup.patch
patch_version:    2003-11-08.15:22:30

diffstat:=
 drivers/net/3c59x.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletion(-)

diff -Naurp ./drivers/net/3c59x.c~boot-setup ./drivers/net/3c59x.c
--- ./drivers/net/3c59x.c~boot-setup	2003-08-25 04:44:42.000000000 -0700
+++ ./drivers/net/3c59x.c	2003-11-08 15:20:15.000000000 -0800
@@ -250,6 +250,7 @@ static int vortex_debug = 1;
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <linux/ethtool.h>
 #include <linux/highmem.h>
@@ -1017,6 +1018,16 @@ static int __devinit vortex_probe1(struc
 	SET_MODULE_OWNER(dev);
 	vp = dev->priv;
 
+	rtnl_lock();
+
+	retval = dev_alloc_name(dev, dev->name);
+	if (retval < 0)
+		goto err_free_unlock;
+
+	rtnl_unlock();
+
+	netdev_boot_setup_check(dev);
+
 	/* The lower four bits are the media type. */
 	if (dev->mem_start) {
 		/*
@@ -1351,8 +1362,10 @@ free_ring:
 free_region:
 	if (vp->must_free_region)
 		release_region(ioaddr, vci->io_size);
-	kfree (dev);
+err_free_unlock:
 	printk(KERN_ERR PFX "vortex_probe1 fails.  Returns %d\n", retval);
+	rtnl_unlock();
+	kfree (dev);
 out:
 	return retval;
 }
