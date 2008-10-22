From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 4/4] netns: sysfs: add netns suffix to net devices sysfs
 entries
Date: Wed, 22 Oct 2008 17:22:24 +0200
Message-ID: <20081022152145.128767713@theryb.frec.bull.fr>
References: <20081022152144.351965414@theryb.frec.bull.fr>
Cc: Eric Biederman <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:37132 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756203AbYJVPXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 11:23:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reminder: what we want is being able to create network interfaces with
the same name in different network namespaces (eg. the loopback). The
remaining issues are in sysfs.

This patch dissociates network devices actual names (stored in struct 
net_device and seen by ifconfig/ip tools) and network device names 
stored in sysfs. 

When adding a network device in child net namespace (!init_net), when
registering it in sysfs, a suffix unique to the current netns is 
appended to the actual device name. Currently this suffix is the netns
ida ID in hexa form separated by a '@' char.

In sysfs, we see all the network devices of all netns.

# ll /sys/devices/virtual/net/
...
drwxr-xr-x 4 root root 0 2008-10-13 14:08 lo
drwxr-xr-x 4 root root 0 2008-10-13 16:31 lo@1
...
drwxr-xr-x 4 root root 0 2008-10-13 16:31 lo@e5
...

Then, in the child network namespace we can filter the contents of 
/sys/class/net with:

* mount -t tmpfs /sys/class/net 
* and  manually link the right devices from /sys/devices/virtual/net
  (ln -s ../../devices/virtual/net/lo@1 lo)

Thus, /sys/class/net appears to be fine for the applications running
in this namespace.

FUSE can also be used to alter the view of /sys/class/net in the 
namespace.

Issues:
-------

* The suffix

  We only have four characters left (BUS_ID_SIZE - IFNAMSIZ) to build the
  suffix: add a separator and encode the netns ID.
  By encoding the ID in hexa, it introduces a limit of 4095 (0xFFF)
  sub-network namespaces running at the same time.

* This approach reduces isolation between network namespaces

  Everyone can see all the devices in each namespaces by exploring 
  /sys/devices/../.. or /sys/class/net (if it's not re-mounted as tmpfs).

* Does not work very well with CONFIG_SYSFS_DEPRECATED=y 

  The filtering of /sys/class/net with CONFIG_SYSFS_DEPRECATED=y is more
  difficult to do because in this case /sys/class/net contains 
  the actual directories (not symlinks).


Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Tested-by: Serge Hallyn <serue@us.ibm.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 net/Kconfig          |    2 +-
 net/core/dev.c       |    4 +++-
 net/core/net-sysfs.c |   34 +++++++++++++++++++++++++++++++++-
 net/core/net-sysfs.h |    1 +
 4 files changed, 38 insertions(+), 3 deletions(-)

Index: net-next-2.6/net/Kconfig
===================================================================
--- net-next-2.6.orig/net/Kconfig
+++ net-next-2.6/net/Kconfig
@@ -27,7 +27,7 @@ menu "Networking options"
 config NET_NS
 	bool "Network namespace support"
 	default n
-	depends on EXPERIMENTAL && !SYSFS && NAMESPACES
+	depends on EXPERIMENTAL && NAMESPACES
 	help
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
Index: net-next-2.6/net/core/dev.c
===================================================================
--- net-next-2.6.orig/net/core/dev.c
+++ net-next-2.6/net/core/dev.c
@@ -894,6 +894,7 @@ int dev_alloc_name(struct net_device *de
 int dev_change_name(struct net_device *dev, const char *newname)
 {
 	char oldname[IFNAMSIZ];
+	char devname[BUS_ID_SIZE];
 	int err = 0;
 	int ret;
 	struct net *net;
@@ -924,7 +925,8 @@ int dev_change_name(struct net_device *d
 		strlcpy(dev->name, newname, IFNAMSIZ);
 
 rollback:
-	err = device_rename(&dev->dev, dev->name);
+	netdev_fill_bus_id_name(devname, dev);
+	err = device_rename(&dev->dev, devname);
 	if (err) {
 		memcpy(dev->name, oldname, IFNAMSIZ);
 		return err;
Index: net-next-2.6/net/core/net-sysfs.c
===================================================================
--- net-next-2.6.orig/net/core/net-sysfs.c
+++ net-next-2.6/net/core/net-sysfs.c
@@ -468,6 +468,38 @@ static struct class net_class = {
 #endif
 };
 
+/* Fill device bus_id name from net device name
+ * When registering a device for a child network namespace,
+ * a suffix is added to the name stored in "struct device"
+ * bus_id.
+ *
+ * devname size must be at least BUS_ID_SIZE
+ */
+void netdev_fill_bus_id_name(char *devname, struct net_device *netdev)
+{
+#ifndef CONFIG_NET_NS
+	strlcpy(devname, netdev->name, BUS_ID_SIZE);
+#else
+	struct net *net = dev_net(netdev);
+
+	if (net_eq(net, &init_net))
+		strlcpy(devname, netdev->name, BUS_ID_SIZE);
+	else {
+		/*
+		 * To allow registration of net devices with the same name in
+		 * different namespaces, append the netns identifier to the
+		 * device name in sysfs using the 4 bytes left in bus_id
+		 * (BUS_ID_SIZE - IFNAMSIZ).
+		 *
+		 * devname is in the form: device_name@XXX
+		 * the netns identifier is an integer < 4095, thus encodable
+		 * in hexa in 3 characters ("FFF").
+		 */
+		snprintf(devname, BUS_ID_SIZE, "%s@%x", netdev->name, net->id);
+	}
+#endif
+}
+
 /* Delete sysfs entries but hold kobject reference until after all
  * netdev references are gone.
  */
@@ -490,7 +522,7 @@ int netdev_register_kobject(struct net_d
 	dev->groups = groups;
 
 	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
-	strlcpy(dev->bus_id, netdev->name, BUS_ID_SIZE);
+	netdev_fill_bus_id_name(dev->bus_id, netdev);
 
 #ifdef CONFIG_SYSFS
 	*groups++ = &netstat_group;
Index: net-next-2.6/net/core/net-sysfs.h
===================================================================
--- net-next-2.6.orig/net/core/net-sysfs.h
+++ net-next-2.6/net/core/net-sysfs.h
@@ -5,4 +5,5 @@ int netdev_kobject_init(void);
 int netdev_register_kobject(struct net_device *);
 void netdev_unregister_kobject(struct net_device *);
 void netdev_initialize_kobject(struct net_device *);
+void netdev_fill_bus_id_name(char *, struct net_device *);
 #endif

-- 
