From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH/RFC] enabling netdev boot options
Date: Sat, 8 Nov 2003 18:51:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031108185123.2fb8f1ac.rddunlap@osdl.org>
References: <20031108160416.236ec29d.rddunlap@osdl.org>
	<20031108162248.5846ab46.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, saw@saw.sw.com.sg
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031108162248.5846ab46.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 8 Nov 2003 16:22:48 -0800 Andrew Morton <akpm@osdl.org> wrote:

| "Randy.Dunlap" <rddunlap@osdl.org> wrote:
| >
| > 
| > I have modified 3c59x.c (for 2.4.22 and 2.6.0-test9) and eepro100
| > (for 2.6.0-test9 only) to check for netdev= boot options.
| 
| A worthy project, thanks.
| 
| > +	rtnl_lock();
| > +
| > +	retval = dev_alloc_name(dev, dev->name);
| > +	if (retval < 0)
| > +		goto err_free_unlock;
| > +
| > +	rtnl_unlock();
| 
| It would be better to move this locking into the core net layer. 
| Call dev_alloc_name_which_takes_rtnl_lock() here ;)

[snip]

| This causes an rtnl_unlock() imbalance if vortex_probe1() takes the
| `goto free_region' path, does it not??

Yes, that's right.  Updated patch is below (for 2.4.22), still using
rtnl_lock() and rtnl_unlock().  I'll make a locking version of
dev_alloc_name() next [for 2.6], as well as 2.6.0-test9 patch updates.
I'll make a locking version of dev_alloc_name() for 2.4.2x if it's
wanted.

Thanks.
--
~Randy


description:      enable 3c59x driver to recognize 'netdev=' boot options
changelog:        use dev_alloc_name() to assign an interface name,
		  then use netdev_boot_setup_check() to check for boot
		  options for that interface (name);
maintainer:       Andrew Morton et al
product_versions: Linux 2.4.22

diffstat:=
 drivers/net/3c59x.c |   13 +++++++++++++
 1 files changed, 13 insertions(+)

diff -Naurp ./drivers/net/3c59x.c~boot-setup ./drivers/net/3c59x.c
--- ./drivers/net/3c59x.c~boot-setup	2003-08-25 04:44:42.000000000 -0700
+++ ./drivers/net/3c59x.c	2003-11-08 18:42:01.000000000 -0800
@@ -250,6 +250,7 @@ static int vortex_debug = 1;
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <linux/ethtool.h>
 #include <linux/highmem.h>
@@ -1017,6 +1018,18 @@ static int __devinit vortex_probe1(struc
 	SET_MODULE_OWNER(dev);
 	vp = dev->priv;
 
+	rtnl_lock();
+
+	retval = dev_alloc_name(dev, dev->name);
+	if (retval < 0) {
+		rtnl_unlock();
+		goto free_region;
+	}
+
+	rtnl_unlock();
+
+	netdev_boot_setup_check(dev);
+
 	/* The lower four bits are the media type. */
 	if (dev->mem_start) {
 		/*
