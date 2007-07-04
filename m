From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -mm 9/9] netconsole: Support dynamic reconfiguration using configfs
Date: Wed, 04 Jul 2007 16:38:24 +0530
Message-ID: <20070704110824.28520.11661.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:57170 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759132AbXGDLIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:05 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[9/9] netconsole: Support dynamic reconfiguration using configfs

This patch introduces support for dynamic reconfiguration (adding, removing
and/or modifying parameters of netconsole targets at runtime) using a
userspace interface exported via configfs.

Issues and brief design overview:

(1) Kernel-initiated creation / destruction of kernel objects is not
possible with configfs -- the lifetimes of the "config items" is managed
exclusively from userspace. But netconsole must support boot/module params
too, and these are parsed in kernel and hence netpolls must be setup from
the kernel. I initially thought of extending configfs with this functionality
(item creation/destroy by kernel subsystems) but Joel Becker pointed me to
the locking and refcounting complexities such a project would entail.

After more discussion, Joel suggested the idea to separately manage the
lifetimes of the two kinds of netconsole_target objects, those created while
parsing boot/module options and those created via configfs mkdir(2) from
userspace, in my driver itself. That adds a little bit of complexity and
redundancy (multiple item creation and destruction points) in this driver.
Note that the latter type (configfs-created netconsole_targets) can be
modified / updated / destroyed at runtime from userspace but the former
(param string created) cannot, as they are not exposed through our configfs
namespace. However, this is not really a problem and is similar to current
behaviour in any case.

(2) Enhancing the semantics of the "enabled" attribute. In the original
patchset submitted, "enabled" was just an on / off knob to switch logging
to particular targets on or off in the console->write() function itself.

But there is a problem. The original patchset had interface device name
as a read-only attribute and assumed ioctl()'s were to be used to create
new targets. This worked only because ioctl()'s deal with full structures
and we can fill out the structure members (including local interface) in
the special userspace program that implements that ioctl(). But configfs
does this with simple mkdir's that can be run off the shell -- and the
corresponding kernel object is created as result of the mkdir(2) call
chain in our driver subsystem. But at that point we don't really know
what interface device should the netpoll be attached.

So, let's solve it this way: newly-created netconsole_target's are not
automatically enabled, and their parameters are not parsed (and the
netpoll_setup() not called). Then, the user may set values to the
various attributes, ending with setting "1" to "enabled" itself. The
netpoll_setup() is then called on the set parameters in the context of
_this_ write(2) on the "enabled" attribute.

The upside of this solution is that existing netconsole_targets can be
reconfigured to be attached to newly-come-up interfaces, that might not
have even existed when netconsole was loaded, or even when the targets
were originally created. Also, we are able to completely get rid of the
custom ioctl()'s based solution.

(3) Ultra-paranoid configfs attribute show() and store() operations, with
sanity and input range checking, using only safe string primitives, and
compliant with the recommendations in Documentation/filesystems/sysfs.txt.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

---

 drivers/net/Kconfig      |   10
 drivers/net/netconsole.c |  601 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 596 insertions(+), 15 deletions(-)

---

diff -ruNp a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2007-07-04 13:56:32.000000000 +0530
+++ b/drivers/net/Kconfig	2007-07-04 13:58:03.000000000 +0530
@@ -3030,6 +3030,16 @@ config NETCONSOLE
 	If you want to log kernel messages over the network, enable this.
 	See <file:Documentation/networking/netconsole.txt> for details.
 
+config NETCONSOLE_DYNAMIC
+	bool "Dynamic reconfiguration of logging targets (EXPERIMENTAL)"
+	depends on NETCONSOLE && SYSFS && EXPERIMENTAL
+	select CONFIGFS_FS
+	help
+	  This option enables the ability to dynamically reconfigure target
+	  parameters (interface, IP addresses, port numbers, MAC addresses)
+	  at runtime through a userspace interface exported using configfs.
+	  See <file:Documentation/networking/netconsole.txt> for details.
+
 config NETPOLL
 	def_bool NETCONSOLE
 
diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-07-04 12:06:47.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-04 13:53:14.000000000 +0530
@@ -41,6 +41,8 @@
 #include <linux/moduleparam.h>
 #include <linux/string.h>
 #include <linux/netpoll.h>
+#include <linux/inet.h>
+#include <linux/configfs.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
@@ -69,6 +71,9 @@ static LIST_HEAD(target_list);
 /* This needs to be a spinlock because write_msg() cannot sleep */
 static DEFINE_SPINLOCK(target_list_lock);
 
+/* Target ids. Only for information, we don't care about wrap-wround */
+static atomic_t monotonic_count = ATOMIC_INIT(0);
+
 /*
  * Why no net_dev_is_up() in netdevice.h? The kernel could lose a lot of
  * weight if only netdevice.h had the good sense to export such a function.
@@ -82,25 +87,88 @@ static inline int net_dev_is_up(struct n
 /**
  * struct netconsole_target - Represents a configured netconsole target.
  * @list:	Links this target into the target_list.
+ * @item:	Links us into the configfs subsystem hierarchy.
+ * @id:		Unique identifier for this target.
+ *		Visible from userspace (read-only).
+ * @enabled:	On / off knob to enable / disable target.
+ *		Visible from userspace (read-write).
+ *		Note that we maintain a strict, reliable 1:1 correspondence
+ *		between this and whether netpoll is active / inactive.
+ *		Also, other parameters of a target may be modified at
+ *		runtime only when it is disabled (enabled = 0).
  * @dev_status:	Tracks whether the underlying interface is up or down.
+ *		Not visible from userspace.
  * @np:		The netpoll structure for this target.
+ *		Contains the other userspace visible parameters, namely:
+ *		dev_name	(read-write)
+ *		local_ip	(read-write)
+ *		remote_ip	(read-write)
+ *		local_port	(read-write)
+ *		remote_port	(read-write)
+ *		local_mac	(read-only)
+ *		remote_mac	(read-write)
  */
 struct netconsole_target {
 	struct list_head	list;
+	struct config_item	item;
+	int			id;
+	int			enabled;
 	int			dev_status;
 	struct netpoll		np;
 };
 
+#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+
+/*
+ * Targets that were created by parsing the boot/module option string
+ * do not exist in the configfs hierarchy and will never go away (and
+ * have zeroed-out config_item members). So make these a no-op for them.
+ */
+static void netconsole_target_get(struct netconsole_target *nt)
+{
+	static struct config_item empty_item;	/* Zeroed-out config_item */
+
+	if (memcmp(&nt->item, &empty_item, sizeof(struct config_item)))
+		config_item_get(&nt->item);
+}
+
+static void netconsole_target_put(struct netconsole_target *nt)
+{
+	static struct config_item empty_item;	/* Zeroed-out config_item */
+
+	if (memcmp(&nt->item, &empty_item, sizeof(struct config_item)))
+		config_item_put(&nt->item);
+}
+
+#else	/* !CONFIG_NETCONSOLE_DYNAMIC */
+
 /*
- * Allocate new target and setup netpoll for it.
+ * No danger of targets going away from under us when dynamic
+ * reconfigurability is off.
+ */
+static void netconsole_target_get(struct netconsole_target *nt)
+{
+}
+
+static void netconsole_target_put(struct netconsole_target *nt)
+{
+}
+
+#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
+
+/*
+ * Allocate new target (from boot/module param) and setup netpoll for it.
  * Caller must then add this to target_list itself.
  */
-static struct netconsole_target *alloc_target(char *target_config)
+static struct netconsole_target *alloc_param_target(char *target_config)
 {
 	int err = -ENOMEM;
 	struct netconsole_target *nt;
 
-	/* Allocate and initialize with defaults */
+	/*
+	 * Allocate and initialize with defaults.
+	 * Note that these targets get their config_item fields zeroed-out.
+	 */
 	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
 	if (!nt) {
 		printk(KERN_ERR "netconsole: failed to allocate memory\n");
@@ -122,7 +190,9 @@ static struct netconsole_target *alloc_t
 	if (err)
 		goto fail;
 
+	nt->id = atomic_inc_return(&monotonic_count);
 	nt->dev_status = net_dev_is_up(nt->np.dev);
+	nt->enabled = 1;
 
 	return nt;
 
@@ -132,15 +202,485 @@ fail:
 }
 
 /*
- * Cleanup netpoll for given target and free it.
+ * Cleanup netpoll for given target (from boot/module param) and free it.
  * Caller must have removed this from target_list already.
  */
-static void free_target(struct netconsole_target *nt)
+static void free_param_target(struct netconsole_target *nt)
 {
 	netpoll_cleanup(&nt->np);
 	kfree(nt);
 }
 
+#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+
+/*
+ * Our subsystem hierarchy is:
+ *
+ * /config/netconsole/
+ *		     |
+ *		     <target>/
+ *		     |	     id
+ *		     |	     enabled
+ *		     |	     dev_name
+ *		     |	     local_port
+ *		     |	     remote_port
+ *		     |	     local_ip
+ *		     |	     remote_ip
+ *		     |	     local_mac
+ *		     |	     remote_mac
+ *		     |
+ *		     <target>/...
+ */
+
+struct netconsole_target_attr {
+	struct configfs_attribute	attr;
+	ssize_t				(*show)(struct netconsole_target *nt,
+						char *buf);
+	ssize_t				(*store)(struct netconsole_target *nt,
+						 const char *buf,
+						 size_t count);
+};
+
+static struct netconsole_target *to_target(struct config_item *item)
+{
+	return item ?
+		container_of(item, struct netconsole_target, item) :
+		NULL;
+}
+
+/*
+ * Wrapper over simple_strtol (base 10) with sanity and range checking.
+ * We return (signed) long only because we may want to return errors.
+ * Thus, do not use this to convert numbers that are allowed to be negative.
+ */
+static long strtol10_check_range(const char *cp, long min, long max)
+{
+	long ret;
+	char *p = (char *) cp;
+
+	WARN_ON(min < 0);
+	WARN_ON(max < min);
+
+	ret = simple_strtol(p, &p, 10);
+
+	if (*p && (*p != '\n')) {
+		printk(KERN_ERR "netconsole: invalid input\n");
+		return -EINVAL;
+	}
+	if ((ret < min) || (ret > max)) {
+		printk(KERN_ERR "netconsole: input %ld must be between "
+				"%ld and %ld\n", ret, min, max);
+		return -EINVAL;
+	}
+
+	return ret;
+}
+
+/*
+ * Attribute operations for netconsole_target.
+ */
+
+static ssize_t show_id(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n", nt->id);
+}
+
+static ssize_t show_enabled(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n", nt->enabled);
+}
+
+static ssize_t show_dev_name(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n", nt->np.dev_name);
+}
+
+static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d.%d.%d.%d\n",
+			HIPQUAD(nt->np.local_ip));
+}
+
+static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d.%d.%d.%d\n",
+			HIPQUAD(nt->np.remote_ip));
+}
+
+static ssize_t show_local_port(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n", nt->np.local_port);
+}
+
+static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n", nt->np.remote_port);
+}
+
+static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%02x:%02x:%02x:%02x:%02x:%02x\n",
+			nt->np.local_mac[0], nt->np.local_mac[1],
+			nt->np.local_mac[2], nt->np.local_mac[3],
+			nt->np.local_mac[4], nt->np.local_mac[5]);
+}
+
+static ssize_t show_remote_mac(struct netconsole_target *nt, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%02x:%02x:%02x:%02x:%02x:%02x\n",
+			nt->np.remote_mac[0], nt->np.remote_mac[1],
+			nt->np.remote_mac[2], nt->np.remote_mac[3],
+			nt->np.remote_mac[4], nt->np.remote_mac[5]);
+}
+
+/*
+ * This one's special and important -- targets created through the
+ * configfs interface are not enabled / netpoll activated by default.
+ * The user is expected to set the desired parameters first (which
+ * would enable him to dynamically add new netpoll targets for new
+ * network interfaces as and when they come up).
+ */
+static ssize_t store_enabled(struct netconsole_target *nt,
+			     const char *buf,
+			     size_t count)
+{
+	int err;
+	long enabled;
+	struct netpoll *np = &nt->np;
+
+	enabled = strtol10_check_range(buf, 0, 1);
+	if (enabled < 0)
+		return enabled;
+
+	if (enabled) {	/* 1 */
+
+		/*
+		 * Skip netpoll_parse_options() -- all the attributes are
+		 * already configured in nt->np through configfs. But at
+		 * least let's print the useful stuff it used to output :-)
+		 */
+		printk(KERN_INFO "%s: local port %d\n",
+				 np->name, np->local_port);
+		printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
+				 np->name, HIPQUAD(np->local_ip));
+		printk(KERN_INFO "%s: interface %s\n",
+				 np->name, np->dev_name);
+		printk(KERN_INFO "%s: remote port %d\n",
+				 np->name, np->remote_port);
+		printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
+				 np->name, HIPQUAD(np->remote_ip));
+		printk(KERN_INFO "%s: remote ethernet address "
+				 "%02x:%02x:%02x:%02x:%02x:%02x\n",
+				 np->name,
+				 np->remote_mac[0], np->remote_mac[1],
+				 np->remote_mac[2], np->remote_mac[3],
+				 np->remote_mac[4], np->remote_mac[5]);
+
+		err = netpoll_setup(np);
+		if (err)
+			return err;
+
+		nt->dev_status = net_dev_is_up(np->dev);
+		printk(KERN_INFO "netconsole: network logging started\n");
+
+	} else {	/* 0 */
+		netpoll_cleanup(np);
+	}
+
+	nt->enabled = enabled;
+
+	return strnlen(buf, count);
+}
+
+static ssize_t store_dev_name(struct netconsole_target *nt,
+			      const char *buf,
+			      size_t count)
+{
+	if (nt->enabled) {
+		printk(KERN_ERR "netconsole: target (id %d) is enabled, "
+				"disable to update parameters\n", nt->id);
+		return -EINVAL;
+	}
+
+	strlcpy(nt->np.dev_name, buf, IFNAMSIZ);
+
+	return strnlen(buf, count);
+}
+
+static ssize_t store_local_port(struct netconsole_target *nt,
+				const char *buf,
+				size_t count)
+{
+	long local_port;
+#define __U16_MAX	((__u16) ~0U)
+
+	if (nt->enabled) {
+		printk(KERN_ERR "netconsole: target (id %d) is enabled, "
+				"disable to update parameters\n", nt->id);
+		return -EINVAL;
+	}
+
+	local_port = strtol10_check_range(buf, 0, __U16_MAX);
+	if (local_port < 0)
+		return local_port;
+
+	nt->np.local_port = local_port;
+
+	return strnlen(buf, count);
+}
+
+static ssize_t store_remote_port(struct netconsole_target *nt,
+				 const char *buf,
+				 size_t count)
+{
+	long remote_port;
+#define __U16_MAX	((__u16) ~0U)
+
+	if (nt->enabled) {
+		printk(KERN_ERR "netconsole: target (id %d) is enabled, "
+				"disable to update parameters\n", nt->id);
+		return -EINVAL;
+	}
+
+	remote_port = strtol10_check_range(buf, 0, __U16_MAX);
+	if (remote_port < 0)
+		return remote_port;
+
+	nt->np.remote_port = remote_port;
+
+	return strnlen(buf, count);
+}
+
+static ssize_t store_local_ip(struct netconsole_target *nt,
+			      const char *buf,
+			      size_t count)
+{
+	if (nt->enabled) {
+		printk(KERN_ERR "netconsole: target (id %d) is enabled, "
+				"disable to update parameters\n", nt->id);
+		return -EINVAL;
+	}
+
+	nt->np.local_ip = ntohl(in_aton(buf));
+
+	return strnlen(buf, count);
+}
+
+static ssize_t store_remote_ip(struct netconsole_target *nt,
+			       const char *buf,
+			       size_t count)
+{
+	if (nt->enabled) {
+		printk(KERN_ERR "netconsole: target (id %d) is enabled, "
+				"disable to update parameters\n", nt->id);
+		return -EINVAL;
+	}
+
+	nt->np.remote_ip = ntohl(in_aton(buf));
+
+	return strnlen(buf, count);
+}
+
+static ssize_t store_remote_mac(struct netconsole_target *nt,
+				const char *buf,
+				size_t count)
+{
+	u8 remote_mac[ETH_ALEN];
+	char *p = (char *) buf;
+	int i;
+
+	if (nt->enabled) {
+		printk(KERN_ERR "netconsole: target (id %d) is enabled, "
+				"disable to update parameters\n", nt->id);
+		return -EINVAL;
+	}
+
+	for (i = 0; i < ETH_ALEN - 1; i++) {
+		remote_mac[i] = simple_strtoul(p, &p, 16);
+		if (*p != ':')
+			goto invalid;
+		p++;
+	}
+	remote_mac[ETH_ALEN - 1] = simple_strtoul(p, &p, 16);
+	if (*p && (*p != '\n'))
+		goto invalid;
+
+	memcpy(nt->np.remote_mac, remote_mac, ETH_ALEN);
+
+	return strnlen(buf, count);
+
+invalid:
+	printk(KERN_ERR "netconsole: invalid input\n");
+	return -EINVAL;
+}
+
+/*
+ * Attribute definitions for netconsole_target.
+ */
+
+#define NETCONSOLE_TARGET_ATTR_RO(_name)				\
+static struct netconsole_target_attr netconsole_target_##_name =	\
+__CONFIGFS_ATTR(_name, S_IRUGO, show_##_name, NULL)
+
+#define NETCONSOLE_TARGET_ATTR_RW(_name)				\
+static struct netconsole_target_attr netconsole_target_##_name =	\
+__CONFIGFS_ATTR(_name, S_IRUGO | S_IWUSR, show_##_name, store_##_name)
+
+NETCONSOLE_TARGET_ATTR_RO(id);
+NETCONSOLE_TARGET_ATTR_RW(enabled);
+NETCONSOLE_TARGET_ATTR_RW(dev_name);
+NETCONSOLE_TARGET_ATTR_RW(local_port);
+NETCONSOLE_TARGET_ATTR_RW(remote_port);
+NETCONSOLE_TARGET_ATTR_RW(local_ip);
+NETCONSOLE_TARGET_ATTR_RW(remote_ip);
+NETCONSOLE_TARGET_ATTR_RO(local_mac);
+NETCONSOLE_TARGET_ATTR_RW(remote_mac);
+
+static struct configfs_attribute *netconsole_target_attrs[] = {
+	&netconsole_target_id.attr,
+	&netconsole_target_enabled.attr,
+	&netconsole_target_dev_name.attr,
+	&netconsole_target_local_port.attr,
+	&netconsole_target_remote_port.attr,
+	&netconsole_target_local_ip.attr,
+	&netconsole_target_remote_ip.attr,
+	&netconsole_target_local_mac.attr,
+	&netconsole_target_remote_mac.attr,
+	NULL,
+};
+
+/*
+ * Item operations and type for netconsole_target.
+ */
+
+static void netconsole_target_release(struct config_item *item)
+{
+	kfree(to_target(item));
+}
+
+static ssize_t netconsole_target_attr_show(struct config_item *item,
+					   struct configfs_attribute *attr,
+					   char *buf)
+{
+	ssize_t ret = -EINVAL;
+	struct netconsole_target *nt = to_target(item);
+	struct netconsole_target_attr *na =
+		container_of(attr, struct netconsole_target_attr, attr);
+
+	if (na->show)
+		ret = na->show(nt, buf);
+
+	return ret;
+}
+
+static ssize_t netconsole_target_attr_store(struct config_item *item,
+					    struct configfs_attribute *attr,
+					    const char *buf,
+					    size_t count)
+{
+	ssize_t ret = -EINVAL;
+	struct netconsole_target *nt = to_target(item);
+	struct netconsole_target_attr *na =
+		container_of(attr, struct netconsole_target_attr, attr);
+
+	if (na->store)
+		ret = na->store(nt, buf, count);
+
+	return ret;
+}
+
+static struct configfs_item_operations netconsole_target_item_ops = {
+	.release		= netconsole_target_release,
+	.show_attribute		= netconsole_target_attr_show,
+	.store_attribute	= netconsole_target_attr_store,
+};
+
+static struct config_item_type netconsole_target_type = {
+	.ct_attrs		= netconsole_target_attrs,
+	.ct_item_ops		= &netconsole_target_item_ops,
+	.ct_owner		= THIS_MODULE,
+};
+
+/*
+ * Group operations and type for netconsole_subsys.
+ */
+
+static struct config_item *make_netconsole_target(struct config_group *group,
+						  const char *name)
+{
+	unsigned long flags;
+	struct netconsole_target *nt;
+
+	/*
+	 * Allocate and initialize with defaults.
+	 * Note that ->enabled and ->dev_status would be zero.
+	 */
+	nt = kzalloc(sizeof(*nt), GFP_KERNEL);
+	if (!nt) {
+		printk(KERN_ERR "netconsole: failed to allocate memory\n");
+		return NULL;
+	}
+
+	nt->np.name = "netconsole";
+	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
+	nt->np.local_port = 6665;
+	nt->np.remote_port = 6666;
+	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
+
+	/* Get an id, fill out config_item and attach us to the filesystem */
+	nt->id = atomic_inc_return(&monotonic_count);
+	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
+
+	/* Adding ourselves, but netpoll is not active and we're disabled */
+	spin_lock_irqsave(&target_list_lock, flags);
+	list_add(&nt->list, &target_list);
+	spin_unlock_irqrestore(&target_list_lock, flags);
+
+	return &nt->item;
+}
+
+static void drop_netconsole_target(struct config_group *group,
+				   struct config_item *item)
+{
+	unsigned long flags;
+	struct netconsole_target *nt = to_target(item);
+
+	spin_lock_irqsave(&target_list_lock, flags);
+	list_del(&nt->list);
+	spin_unlock_irqrestore(&target_list_lock, flags);
+
+	/*
+	 * The target may have never been enabled, or was manually disabled
+	 * before being removed so netpoll may have already been cleaned up.
+	 */
+	if (nt->enabled)
+		netpoll_cleanup(&nt->np);
+
+	config_item_put(&nt->item);
+}
+
+static struct configfs_group_operations netconsole_subsys_group_ops = {
+	.make_item	= make_netconsole_target,
+	.drop_item	= drop_netconsole_target,
+};
+
+static struct config_item_type netconsole_subsys_type = {
+	.ct_group_ops	= &netconsole_subsys_group_ops,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* The netconsole configfs subsystem */
+static struct configfs_subsystem netconsole_subsys = {
+	.su_group	= {
+		.cg_item	= {
+			.ci_namebuf	= "netconsole",
+			.ci_type	= &netconsole_subsys_type,
+		},
+	},
+};
+
+#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
+
 /* Handle network interface device notifications */
 static int netconsole_netdev_event(struct notifier_block *this,
 				   unsigned long event,
@@ -156,6 +696,7 @@ static int netconsole_netdev_event(struc
 
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
+		netconsole_target_get(nt);
 		if (nt->np.dev == dev) {
 			switch (event) {
 			case NETDEV_UP:
@@ -172,6 +713,7 @@ static int netconsole_netdev_event(struc
 				break;
 			}
 		}
+		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 
@@ -196,7 +738,8 @@ static void write_msg(struct console *co
 
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
-		if (nt->dev_status) {
+		netconsole_target_get(nt);
+		if (nt->enabled && nt->dev_status) {
 			/*
 			 * Note the double-loop nesting (for-in-buffer inside
 			 * for-all-targets) and use of temporary buf pointer.
@@ -212,6 +755,7 @@ static void write_msg(struct console *co
 				left -= frag;
 			}
 		}
+		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 }
@@ -235,11 +779,12 @@ static int __init init_netconsole(void)
 	}
 
 	/*
-	 * Neither the netdev notifier, nor the console have been
-	 * registered so far. Nobody's racing us, so skip the lock.
+	 * Neither the netdev notifier, not the configfs subsystem and
+	 * nor the console have been registered so far. Nobody's racing us,
+	 * so skip the lock.
 	 */
 	while ((target_config = strsep(&input, ";"))) {
-		nt = alloc_target(target_config);
+		nt = alloc_param_target(target_config);
 		if (IS_ERR(nt)) {
 			err = PTR_ERR(nt);
 			goto fail;
@@ -251,6 +796,17 @@ static int __init init_netconsole(void)
 	if (err)
 		goto fail;
 
+#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+	config_group_init(&netconsole_subsys.su_group);
+	mutex_init(&netconsole_subsys.su_mtx);
+
+	err = configfs_register_subsystem(&netconsole_subsys);
+	if (err) {
+		unregister_netdevice_notifier(&netconsole_netdev_notifier);
+		goto fail;
+	}
+#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
+
 	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
 
@@ -261,13 +817,17 @@ fail:
 	printk(KERN_ERR "netconsole: cleaning up\n");
 
 	/*
-	 * Remove all targets and destroy them.
-	 * The notifier is off, so nobody's racing us. So let's skip
+	 * Remove all targets and destroy them -- note that we failed
+	 * while initing the module, so only targets created while parsing
+	 * the boot/module option string could exist (this is important
+	 * because we cannot destroy configfs items from within kernel).
+	 *
+	 * Also, the notifier is off, so nobody's racing us. So let's skip
 	 * the lock, netpoll_cleanup() wants to sleep anyway.
 	 */
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		list_del(&nt->list);
-		free_target(nt);
+		free_param_target(nt);
 	}
 
 	return err;
@@ -278,16 +838,27 @@ static void __exit cleanup_netconsole(vo
 	struct netconsole_target *nt, *tmp;
 
 	unregister_console(&netconsole);
+
+#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+	configfs_unregister_subsystem(&netconsole_subsys);
+#endif	/* CONFIG_NETCONSOLE_DYNAMIC */
+
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 
 	/*
-	 * Remove all targets and destroy them.
-	 * Nobody's racing us, and netpoll_cleanup() wants to
+	 * Targets created via configfs would have pinned references on
+	 * our module and wouldn't let us unload at all. They would first
+	 * need to be rmdir(2)'ed from userspace (and hence would be
+	 * removed and released already when we reach here). Only those
+	 * targets that were allocated for the boot/module option string
+	 * are left, remove and destroy them.
+	 *
+	 * Again, nobody's racing us, and netpoll_cleanup() wants to
 	 * sleep -- so skip the lock.
 	 */
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		list_del(&nt->list);
-		free_target(nt);
+		free_param_target(nt);
 	}
 }
 
