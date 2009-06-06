From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 4/7] initdev:kernel:Await network init device discovery, v3
Date: Fri, 5 Jun 2009 19:34:09 -0700
Message-ID: <20090606023409.GA5721@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:62814 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbZFFDAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 23:00:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delay IP autoconfiguration until network boot devices have been initialized.
This depends on the boot device discovery code and on the asynchronous
function call infrastructure.

History
v3	Ignore return value from async_schedule call to ip_auto_config_async.
	Change BOOTDEV_* to INITDEV_*.
v2	Change bootdev_* to initdev_*
v1	Initial release

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 net/core/dev.c      |    2 +
 net/ipv4/ipconfig.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 56 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 308a7d0..2796764 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -93,6 +93,7 @@
 #include <linux/ethtool.h>
 #include <linux/notifier.h>
 #include <linux/skbuff.h>
+#include <linux/device.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
@@ -4497,6 +4498,7 @@ int register_netdevice(struct net_device *dev)
 		dev->reg_state = NETREG_UNREGISTERED;
 	}
 
+	initdev_registered(INITDEV_NETDEV_TYPE);
 out:
 	return ret;
 
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 90d22ae..3b1a381 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -53,6 +53,7 @@
 #include <linux/root_dev.h>
 #include <linux/delay.h>
 #include <linux/nfs_fs.h>
+#include <linux/async.h>
 #include <net/net_namespace.h>
 #include <net/arp.h>
 #include <net/ip.h>
@@ -182,12 +183,48 @@ struct ic_device {
 static struct ic_device *ic_first_dev __initdata = NULL;/* List of open device */
 static struct net_device *ic_dev __initdata = NULL;	/* Selected device */
 
+/*
+ * Wait for required network devices to come up
+ * If the networking device name was specified on the kernel command line
+ * and that device is now registered, we have the device we want to configure
+ * and we return true. Otherwise, we return false. So, if no device was
+ * specified on the command line, we wait for all possible network devices to
+ * be initialized.
+ */
+static bool have_all_netdevs(void)
+{
+	struct net_device *dev;
+	bool	result = false;
+
+	rtnl_lock();
+
+	for_each_netdev(&init_net, dev) {
+		if (dev->flags & IFF_LOOPBACK)
+			continue;
+
+		/* If a specific device name was specified and that name is
+		 * registered, we have the device we need. */
+		if (user_dev_name[0] && !strcmp(dev->name, user_dev_name)) {
+			result = true;
+			break;
+		}
+	}
+
+	rtnl_unlock();
+
+	return result;
+
+}
+
 static int __init ic_open_devs(void)
 {
 	struct ic_device *d, **last;
 	struct net_device *dev;
 	unsigned short oflags;
 
+	/* Wait for networking devices */
+	initdev_wait(INITDEV_NETDEV_TYPE, have_all_netdevs);
+
 	last = &ic_first_dev;
 	rtnl_lock();
 
@@ -1263,6 +1300,7 @@ __be32 __init root_nfs_parse_addr(char *name)
 
 /*
  *	IP Autoconfig dispatcher.
+ *	Return zero on success, negative one on failure
  */
 
 static int __init ip_auto_config(void)
@@ -1397,7 +1435,22 @@ static int __init ip_auto_config(void)
 	return 0;
 }
 
-late_initcall(ip_auto_config);
+static void __init ip_auto_config_async(void *data, async_cookie_t cookie)
+{
+	ip_auto_config();
+}
+
+/*
+ * Start a thread to do IP autoconfiguration
+ */
+static int __init ip_auto_configurator(void)
+{
+	async_schedule(ip_auto_config_async, NULL);
+
+	return 0;
+}
+
+late_initcall(ip_auto_configurator);
 
 
 /*
