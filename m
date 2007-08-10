From: akpm@linux-foundation.org
Subject: [patch 26/28] netconsole: Support dynamic reconfiguration using configfs
Date: Fri, 10 Aug 2007 14:12:09 -0700
Message-ID: <200708102112.l7ALC9oD009457@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	satyam@infradead.org, Joel.Becker@oracle.com,
	k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47425 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764513AbXHJVQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.

This patch introduces support for dynamic reconfiguration (adding, removing
and/or modifying parameters of netconsole targets at runtime) using a
userspace interface exported via configfs.  Documentation is also updated
accordingly.

Issues and brief design overview:

(1) Kernel-initiated creation / destruction of kernel objects is not
    possible with configfs -- the lifetimes of the "config items" is managed
    exclusively from userspace.  But netconsole must support boot/module
    params too, and these are parsed in kernel and hence netpolls must be
    setup from the kernel.  Joel Becker suggested to separately manage the
    lifetimes of the two kinds of netconsole_target objects -- those created
    via configfs mkdir(2) from userspace and those specified from the
    boot/module option string.  This adds complexity and some redundancy here
    and also means that boot/module param-created targets are not exposed
    through the configfs namespace (and hence cannot be updated / destroyed
    dynamically).  However, this saves us from locking / refcounting
    complexities that would need to be introduced in configfs to support
    kernel-initiated item creation / destroy there.

(2) In configfs, item creation takes place in the call chain of the
    mkdir(2) syscall in the driver subsystem.  If we used an ioctl(2) to
    create / destroy objects from userspace, the special userspace program is
    able to fill out the structure to be passed into the ioctl and hence
    specify attributes such as local interface that are required at the time
    we set up the netpoll.  For configfs, this information is not available at
    the time of mkdir(2).  So, we keep all newly-created targets (via
    configfs) disabled by default.  The user is expected to set various
    attributes appropriately (including the local network interface if
    required) and then write(2) "1" to the "enabled" attribute.  Thus,
    netpoll_setup() is then called on the set parameters in the context of
    _this_ write(2) on the "enabled" attribute itself.  This design enables
    the user to reconfigure existing netconsole targets at runtime to be
    attached to newly-come-up interfaces that may not have existed when
    netconsole was loaded or when the targets were actually created.  All this
    effectively enables us to get rid of custom ioctls.

(3) Ultra-paranoid configfs attribute show() and store() operations, with
    sanity and input range checking, using only safe string primitives, and
    compliant with the recommendations in Documentation/filesystems/sysfs.txt.

(4) A new function netpoll_print_options() is created in the netpoll API,
    that just prints out the configured parameters for a netpoll structure. 
    netpoll_parse_options() is modified to use that and it is also exported to
    be used from netconsole.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Joel Becker <Joel.Becker@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/networking/netconsole.txt |   68 ++
 drivers/net/Kconfig                     |   10 
 drivers/net/netconsole.c                |  605 +++++++++++++++++++++-
 include/linux/netpoll.h                 |    1 
 net/core/netpoll.c                      |   44 -
 5 files changed, 683 insertions(+), 45 deletions(-)

diff -puN Documentation/networking/netconsole.txt~netconsole-support-dynamic-reconfiguration-using-configfs Documentation/networking/netconsole.txt
--- a/Documentation/networking/netconsole.txt~netconsole-support-dynamic-reconfiguration-using-configfs
+++ a/Documentation/networking/netconsole.txt
@@ -3,6 +3,10 @@ started by Ingo Molnar <mingo@redhat.com
 2.6 port and netpoll api by Matt Mackall <mpm@selenic.com>, Sep 9 2003
 
 Please send bug reports to Matt Mackall <mpm@selenic.com>
+and Satyam Sharma <satyam.sharma@gmail.com>
+
+Introduction:
+=============
 
 This module logs kernel printk messages over UDP allowing debugging of
 problem where disk logging fails and serial consoles are impractical.
@@ -13,6 +17,9 @@ the specified interface as soon as possi
 capture of early kernel panics, it does capture most of the boot
 process.
 
+Sender and receiver configuration:
+==================================
+
 It takes a string configuration parameter "netconsole" in the
 following format:
 
@@ -46,6 +53,67 @@ address.
 
 The remote host can run either 'netcat -u -l -p <port>' or syslogd.
 
+Dynamic reconfiguration:
+========================
+
+Dynamic reconfigurability is a useful addition to netconsole that enables
+remote logging targets to be dynamically added, removed, or have their
+parameters reconfigured at runtime from a configfs-based userspace interface.
+[ Note that the parameters of netconsole targets that were specified/created
+from the boot/module option are not exposed via this interface, and hence
+cannot be modified dynamically. ]
+
+To include this feature, select CONFIG_NETCONSOLE_DYNAMIC when building the
+netconsole module (or kernel, if netconsole is built-in).
+
+Some examples follow (where configfs is mounted at the /sys/kernel/config
+mountpoint).
+
+To add a remote logging target (target names can be arbitrary):
+
+ cd /sys/kernel/config/netconsole/
+ mkdir target1
+
+Note that newly created targets have default parameter values (as mentioned
+above) and are disabled by default -- they must first be enabled by writing
+"1" to the "enabled" attribute (usually after setting parameters accordingly)
+as described below.
+
+To remove a target:
+
+ rmdir /sys/kernel/config/netconsole/othertarget/
+
+The interface exposes these parameters of a netconsole target to userspace:
+
+	enabled		Is this target currently enabled?	(read-write)
+	dev_name	Local network interface name		(read-write)
+	local_port	Source UDP port to use			(read-write)
+	remote_port	Remote agent's UDP port			(read-write)
+	local_ip	Source IP address to use		(read-write)
+	remote_ip	Remote agent's IP address		(read-write)
+	local_mac	Local interface's MAC address		(read-only)
+	remote_mac	Remote agent's MAC address		(read-write)
+
+The "enabled" attribute is also used to control whether the parameters of
+a target can be updated or not -- you can modify the parameters of only
+disabled targets (i.e. if "enabled" is 0).
+
+To update a target's parameters:
+
+ cat enabled				# check if enabled is 1
+ echo 0 > enabled			# disable the target (if required)
+ echo eth2 > dev_name			# set local interface
+ echo 10.0.0.4 > remote_ip		# update some parameter
+ echo cb:a9:87:65:43:21 > remote_mac	# update more parameters
+ echo 1 > enabled			# enable target again
+
+You can also update the local interface dynamically. This is especially
+useful if you want to use interfaces that have newly come up (and may not
+have existed when netconsole was loaded / initialized).
+
+Miscellaneous notes:
+====================
+
 WARNING: the default target ethernet setting uses the broadcast
 ethernet address to send packets, which can cause increased load on
 other systems on the same ethernet segment.
diff -puN drivers/net/Kconfig~netconsole-support-dynamic-reconfiguration-using-configfs drivers/net/Kconfig
--- a/drivers/net/Kconfig~netconsole-support-dynamic-reconfiguration-using-configfs
+++ a/drivers/net/Kconfig
@@ -3021,6 +3021,16 @@ config NETCONSOLE
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
 
diff -puN drivers/net/netconsole.c~netconsole-support-dynamic-reconfiguration-using-configfs drivers/net/netconsole.c
--- a/drivers/net/netconsole.c~netconsole-support-dynamic-reconfiguration-using-configfs
+++ a/drivers/net/netconsole.c
@@ -41,6 +41,8 @@
 #include <linux/moduleparam.h>
 #include <linux/string.h>
 #include <linux/netpoll.h>
+#include <linux/inet.h>
+#include <linux/configfs.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
@@ -71,20 +73,100 @@ static DEFINE_SPINLOCK(target_list_lock)
 /**
  * struct netconsole_target - Represents a configured netconsole target.
  * @list:	Links this target into the target_list.
+ * @item:	Links us into the configfs subsystem hierarchy.
+ * @enabled:	On / off knob to enable / disable target.
+ *		Visible from userspace (read-write).
+ *		We maintain a strict 1:1 correspondence between this and
+ *		whether the corresponding netpoll is active or inactive.
+ *		Also, other parameters of a target may be modified at
+ *		runtime only when it is disabled (enabled == 0).
  * @np:		The netpoll structure for this target.
+ *		Contains the other userspace visible parameters:
+ *		dev_name	(read-write)
+ *		local_port	(read-write)
+ *		remote_port	(read-write)
+ *		local_ip	(read-write)
+ *		remote_ip	(read-write)
+ *		local_mac	(read-only)
+ *		remote_mac	(read-write)
  */
 struct netconsole_target {
 	struct list_head	list;
+#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+	struct config_item	item;
+#endif
+	int			enabled;
 	struct netpoll		np;
 };
 
-/* Allocate new target and setup netpoll for it */
-static struct netconsole_target *alloc_target(char *target_config)
+#ifdef	CONFIG_NETCONSOLE_DYNAMIC
+
+static struct configfs_subsystem netconsole_subsys;
+
+static int __init dynamic_netconsole_init(void)
+{
+	config_group_init(&netconsole_subsys.su_group);
+	mutex_init(&netconsole_subsys.su_mutex);
+	return configfs_register_subsystem(&netconsole_subsys);
+}
+
+static void __exit dynamic_netconsole_exit(void)
+{
+	configfs_unregister_subsystem(&netconsole_subsys);
+}
+
+/*
+ * Targets that were created by parsing the boot/module option string
+ * do not exist in the configfs hierarchy (and have NULL names) and will
+ * never go away, so make these a no-op for them.
+ */
+static void netconsole_target_get(struct netconsole_target *nt)
+{
+	if (config_item_name(&nt->item))
+		config_item_get(&nt->item);
+}
+
+static void netconsole_target_put(struct netconsole_target *nt)
+{
+	if (config_item_name(&nt->item))
+		config_item_put(&nt->item);
+}
+
+#else	/* !CONFIG_NETCONSOLE_DYNAMIC */
+
+static int __init dynamic_netconsole_init(void)
+{
+	return 0;
+}
+
+static void __exit dynamic_netconsole_exit(void)
+{
+}
+
+/*
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
+/* Allocate new target (from boot/module param) and setup netpoll for it */
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
@@ -106,6 +188,8 @@ static struct netconsole_target *alloc_t
 	if (err)
 		goto fail;
 
+	nt->enabled = 1;
+
 	return nt;
 
 fail:
@@ -113,13 +197,469 @@ fail:
 	return ERR_PTR(err);
 }
 
-/* Cleanup netpoll for given target and free it */
-static void free_target(struct netconsole_target *nt)
+/* Cleanup netpoll for given target (from boot/module param) and free it */
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
+ * /sys/kernel/config/netconsole/
+ *				|
+ *				<target>/
+ *				|	enabled
+ *				|	dev_name
+ *				|	local_port
+ *				|	remote_port
+ *				|	local_ip
+ *				|	remote_ip
+ *				|	local_mac
+ *				|	remote_mac
+ *				|
+ *				<target>/...
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
+ * Do not use this to convert numbers that are allowed to be negative.
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
+ * This one is special -- targets created through the configfs interface
+ * are not enabled (and the corresponding netpoll activated) by default.
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
+
+	enabled = strtol10_check_range(buf, 0, 1);
+	if (enabled < 0)
+		return enabled;
+
+	if (enabled) {	/* 1 */
+
+		/*
+		 * Skip netpoll_parse_options() -- all the attributes are
+		 * already configured via configfs. Just print them out.
+		 */
+		netpoll_print_options(&nt->np);
+
+		err = netpoll_setup(&nt->np);
+		if (err)
+			return err;
+
+		printk(KERN_INFO "netconsole: network logging started\n");
+
+	} else {	/* 0 */
+		netpoll_cleanup(&nt->np);
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
+	size_t len;
+
+	if (nt->enabled) {
+		printk(KERN_ERR "netconsole: target (%s) is enabled, "
+				"disable to update parameters\n",
+				config_item_name(&nt->item));
+		return -EINVAL;
+	}
+
+	strlcpy(nt->np.dev_name, buf, IFNAMSIZ);
+
+	/* Get rid of possible trailing newline from echo(1) */
+	len = strnlen(nt->np.dev_name, IFNAMSIZ);
+	if (nt->np.dev_name[len - 1] == '\n')
+		nt->np.dev_name[len - 1] = '\0';
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
+		printk(KERN_ERR "netconsole: target (%s) is enabled, "
+				"disable to update parameters\n",
+				config_item_name(&nt->item));
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
+		printk(KERN_ERR "netconsole: target (%s) is enabled, "
+				"disable to update parameters\n",
+				config_item_name(&nt->item));
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
+		printk(KERN_ERR "netconsole: target (%s) is enabled, "
+				"disable to update parameters\n",
+				config_item_name(&nt->item));
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
+		printk(KERN_ERR "netconsole: target (%s) is enabled, "
+				"disable to update parameters\n",
+				config_item_name(&nt->item));
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
+		printk(KERN_ERR "netconsole: target (%s) is enabled, "
+				"disable to update parameters\n",
+				config_item_name(&nt->item));
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
+	__CONFIGFS_ATTR(_name, S_IRUGO, show_##_name, NULL)
+
+#define NETCONSOLE_TARGET_ATTR_RW(_name)				\
+static struct netconsole_target_attr netconsole_target_##_name =	\
+	__CONFIGFS_ATTR(_name, S_IRUGO | S_IWUSR, show_##_name, store_##_name)
+
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
+	 * Target is disabled at creation (enabled == 0).
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
+	/* Initialize the config_item member */
+	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
+
+	/* Adding, but it is disabled */
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
@@ -134,6 +674,7 @@ static int netconsole_netdev_event(struc
 
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
+		netconsole_target_get(nt);
 		if (nt->np.dev == dev) {
 			switch (event) {
 			case NETDEV_CHANGEADDR:
@@ -145,6 +686,7 @@ static int netconsole_netdev_event(struc
 				break;
 			}
 		}
+		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 
@@ -169,7 +711,8 @@ static void write_msg(struct console *co
 
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
-		if (netif_running(nt->np.dev)) {
+		netconsole_target_get(nt);
+		if (nt->enabled && netif_running(nt->np.dev)) {
 			/*
 			 * We nest this inside the for-each-target loop above
 			 * so that we're able to get as much logging out to
@@ -184,6 +727,7 @@ static void write_msg(struct console *co
 				left -= frag;
 			}
 		}
+		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 }
@@ -196,48 +740,52 @@ static struct console netconsole = {
 
 static int __init init_netconsole(void)
 {
-	int err = 0;
+	int err;
 	struct netconsole_target *nt, *tmp;
 	unsigned long flags;
 	char *target_config;
 	char *input = config;
 
-	if (!strnlen(input, MAX_PARAM_LENGTH)) {
-		printk(KERN_INFO "netconsole: not configured, aborting\n");
-		goto out;
-	}
-
-	while ((target_config = strsep(&input, ";"))) {
-		nt = alloc_target(target_config);
-		if (IS_ERR(nt)) {
-			err = PTR_ERR(nt);
-			goto fail;
+	if (strnlen(input, MAX_PARAM_LENGTH)) {
+		while ((target_config = strsep(&input, ";"))) {
+			nt = alloc_param_target(target_config);
+			if (IS_ERR(nt)) {
+				err = PTR_ERR(nt);
+				goto fail;
+			}
+			spin_lock_irqsave(&target_list_lock, flags);
+			list_add(&nt->list, &target_list);
+			spin_unlock_irqrestore(&target_list_lock, flags);
 		}
-		spin_lock_irqsave(&target_list_lock, flags);
-		list_add(&nt->list, &target_list);
-		spin_unlock_irqrestore(&target_list_lock, flags);
 	}
 
 	err = register_netdevice_notifier(&netconsole_netdev_notifier);
 	if (err)
 		goto fail;
 
+	err = dynamic_netconsole_init();
+	if (err)
+		goto undonotifier;
+
 	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
 
-out:
 	return err;
 
+undonotifier:
+	unregister_netdevice_notifier(&netconsole_netdev_notifier);
+
 fail:
 	printk(KERN_ERR "netconsole: cleaning up\n");
 
 	/*
-	 * Remove all targets and destroy them. Skipping the list
+	 * Remove all targets and destroy them (only targets created
+	 * from the boot/module option exist here). Skipping the list
 	 * lock is safe here, and netpoll_cleanup() will sleep.
 	 */
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		list_del(&nt->list);
-		free_target(nt);
+		free_param_target(nt);
 	}
 
 	return err;
@@ -248,15 +796,20 @@ static void __exit cleanup_netconsole(vo
 	struct netconsole_target *nt, *tmp;
 
 	unregister_console(&netconsole);
+	dynamic_netconsole_exit();
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 
 	/*
-	 * Remove all targets and destroy them. Skipping the list
-	 * lock is safe here, and netpoll_cleanup() will sleep.
+	 * Targets created via configfs pin references on our module
+	 * and would first be rmdir(2)'ed from userspace. We reach
+	 * here only when they are already destroyed, and only those
+	 * created from the boot/module option are left, so remove and
+	 * destroy them. Skipping the list lock is safe here, and
+	 * netpoll_cleanup() will sleep.
 	 */
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		list_del(&nt->list);
-		free_target(nt);
+		free_param_target(nt);
 	}
 }
 
diff -puN include/linux/netpoll.h~netconsole-support-dynamic-reconfiguration-using-configfs include/linux/netpoll.h
--- a/include/linux/netpoll.h~netconsole-support-dynamic-reconfiguration-using-configfs
+++ a/include/linux/netpoll.h
@@ -35,6 +35,7 @@ struct netpoll_info {
 
 void netpoll_poll(struct netpoll *np);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
+void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
 int netpoll_setup(struct netpoll *np);
 int netpoll_trap(void);
diff -puN net/core/netpoll.c~netconsole-support-dynamic-reconfiguration-using-configfs net/core/netpoll.c
--- a/net/core/netpoll.c~netconsole-support-dynamic-reconfiguration-using-configfs
+++ a/net/core/netpoll.c
@@ -532,6 +532,29 @@ out:
 	return 0;
 }
 
+void netpoll_print_options(struct netpoll *np)
+{
+	printk(KERN_INFO "%s: local port %d\n",
+			 np->name, np->local_port);
+	printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
+			 np->name, HIPQUAD(np->local_ip));
+	printk(KERN_INFO "%s: interface %s\n",
+			 np->name, np->dev_name);
+	printk(KERN_INFO "%s: remote port %d\n",
+			 np->name, np->remote_port);
+	printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
+			 np->name, HIPQUAD(np->remote_ip));
+	printk(KERN_INFO "%s: remote ethernet address "
+			 "%02x:%02x:%02x:%02x:%02x:%02x\n",
+			 np->name,
+			 np->remote_mac[0],
+			 np->remote_mac[1],
+			 np->remote_mac[2],
+			 np->remote_mac[3],
+			 np->remote_mac[4],
+			 np->remote_mac[5]);
+}
+
 int netpoll_parse_options(struct netpoll *np, char *opt)
 {
 	char *cur=opt, *delim;
@@ -544,7 +567,6 @@ int netpoll_parse_options(struct netpoll
 		cur = delim;
 	}
 	cur++;
-	printk(KERN_INFO "%s: local port %d\n", np->name, np->local_port);
 
 	if (*cur != '/') {
 		if ((delim = strchr(cur, '/')) == NULL)
@@ -552,9 +574,6 @@ int netpoll_parse_options(struct netpoll
 		*delim = 0;
 		np->local_ip = ntohl(in_aton(cur));
 		cur = delim;
-
-		printk(KERN_INFO "%s: local IP %d.%d.%d.%d\n",
-		       np->name, HIPQUAD(np->local_ip));
 	}
 	cur++;
 
@@ -568,8 +587,6 @@ int netpoll_parse_options(struct netpoll
 	}
 	cur++;
 
-	printk(KERN_INFO "%s: interface %s\n", np->name, np->dev_name);
-
 	if (*cur != '@') {
 		/* dst port */
 		if ((delim = strchr(cur, '@')) == NULL)
@@ -579,7 +596,6 @@ int netpoll_parse_options(struct netpoll
 		cur = delim;
 	}
 	cur++;
-	printk(KERN_INFO "%s: remote port %d\n", np->name, np->remote_port);
 
 	/* dst ip */
 	if ((delim = strchr(cur, '/')) == NULL)
@@ -588,9 +604,6 @@ int netpoll_parse_options(struct netpoll
 	np->remote_ip = ntohl(in_aton(cur));
 	cur = delim + 1;
 
-	printk(KERN_INFO "%s: remote IP %d.%d.%d.%d\n",
-	       np->name, HIPQUAD(np->remote_ip));
-
 	if (*cur != 0) {
 		/* MAC address */
 		if ((delim = strchr(cur, ':')) == NULL)
@@ -621,15 +634,7 @@ int netpoll_parse_options(struct netpoll
 		np->remote_mac[5] = simple_strtol(cur, NULL, 16);
 	}
 
-	printk(KERN_INFO "%s: remote ethernet address "
-	       "%02x:%02x:%02x:%02x:%02x:%02x\n",
-	       np->name,
-	       np->remote_mac[0],
-	       np->remote_mac[1],
-	       np->remote_mac[2],
-	       np->remote_mac[3],
-	       np->remote_mac[4],
-	       np->remote_mac[5]);
+	netpoll_print_options(np);
 
 	return 0;
 
@@ -831,6 +836,7 @@ void netpoll_set_trap(int trap)
 
 EXPORT_SYMBOL(netpoll_set_trap);
 EXPORT_SYMBOL(netpoll_trap);
+EXPORT_SYMBOL(netpoll_print_options);
 EXPORT_SYMBOL(netpoll_parse_options);
 EXPORT_SYMBOL(netpoll_setup);
 EXPORT_SYMBOL(netpoll_cleanup);
_
