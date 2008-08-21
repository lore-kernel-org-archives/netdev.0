From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 7/8] netns: Enable tagging for net_class directories in sysfs
Date: Wed, 20 Aug 2008 23:39:13 -0700
Message-ID: <m1r68izxbi.fsf_-_@frodo.ebiederm.org>
References: <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>
	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>
	<m1d4luihea.fsf_-_@frodo.ebiederm.org>
	<m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<20080820021754.GA25182@kroah.com>
	<m1od3m282j.fsf_-_@frodo.ebiederm.org>
	<m1hc9e27ya.fsf_-_@frodo.ebiederm.org>
	<m1d4k227wg.fsf_-_@frodo.ebiederm.org>
	<m18wuq27uj.fsf_-_@frodo.ebiederm.org>
	<m14p5e27tb.fsf_-_@frodo.ebiederm.org>
	<m1vdxuzxco.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60869 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbYHUGoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:44:02 -0400
In-Reply-To: <m1vdxuzxco.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 20 Aug 2008 23:38:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The problem.  Network devices show up in sysfs and with the network
namespace active multiple devices with the same name can show up in
the same directory, ouch!

To avoid that problem and allow existing applications in network namespaces
to see the same interface that is currently presented in sysfs, this
patch enables the tagging directory support in sysfs.

By using the network namespace pointers as tags to separate out the
the sysfs directory entries we ensure that we don't have conflicts
in the directories and applications only see a limited set of
the network devices.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sysfs.h |    1 +
 net/Kconfig           |    2 +-
 net/core/net-sysfs.c  |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 4e1bfdb..6d7eb50 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -82,6 +82,7 @@ struct sysfs_dirent;
 
 enum sysfs_tag_type {
 	SYSFS_TAG_TYPE_NONE = 0,
+	SYSFS_TAG_TYPE_NETNS,
 	SYSFS_TAG_TYPES
 };
 
diff --git a/net/Kconfig b/net/Kconfig
index 7612cc8..29e7e09 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -27,7 +27,7 @@ menu "Networking options"
 config NET_NS
 	bool "Network namespace support"
 	default n
-	depends on EXPERIMENTAL && !SYSFS && NAMESPACES
+	depends on EXPERIMENTAL && NAMESPACES
 	help
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index c9968f1..e4687af 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -13,7 +13,9 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
+#include <linux/nsproxy.h>
 #include <net/sock.h>
+#include <net/net_namespace.h>
 #include <linux/rtnetlink.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
@@ -385,6 +387,24 @@ static struct attribute_group wireless_group = {
 };
 #endif
 
+static const void *net_sysfs_mount_tag(void)
+{
+	return current->nsproxy->net_ns;
+}
+
+static struct sysfs_tag_type_operations net_tag_type_operations = {
+	.mount_tag = net_sysfs_mount_tag,
+};
+
+static void net_sysfs_net_exit(struct net *net)
+{
+	sysfs_exit_tag(SYSFS_TAG_TYPE_NETNS, net);
+}
+
+static struct pernet_operations sysfs_net_ops = {
+	.exit = net_sysfs_net_exit,
+};
+
 #endif /* CONFIG_SYSFS */
 
 #ifdef CONFIG_HOTPLUG
@@ -421,6 +441,13 @@ static void netdev_release(struct device *d)
 	kfree((char *)dev - dev->padded);
 }
 
+static const void *net_sysfs_tag(struct device *d)
+{
+	struct net_device *dev;
+	dev = container_of(d, struct net_device, dev);
+	return dev_net(dev);
+}
+
 static struct class net_class = {
 	.name = "net",
 	.dev_release = netdev_release,
@@ -430,6 +457,8 @@ static struct class net_class = {
 #ifdef CONFIG_HOTPLUG
 	.dev_uevent = netdev_uevent,
 #endif
+	.tag_type = SYSFS_TAG_TYPE_NETNS,
+	.sysfs_tag = net_sysfs_tag,
 };
 
 /* Delete sysfs entries but hold kobject reference until after all
@@ -484,5 +513,9 @@ EXPORT_SYMBOL(netdev_class_remove_file);
 
 int netdev_kobject_init(void)
 {
+#ifdef CONFIG_SYSFS
+	sysfs_register_tag_type(SYSFS_TAG_TYPE_NETNS, &net_tag_type_operations);
+	register_pernet_subsys(&sysfs_net_ops);
+#endif
 	return class_register(&net_class);
 }
-- 
1.5.3.rc6.17.g1911

