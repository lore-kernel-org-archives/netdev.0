From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 16:09:09 -0500
Message-ID: <20091009210909.GA9836@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@dell.com, jordan_hargrave@dell.com
To: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091009140000.GA18765@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 09, 2009 at 09:00:01AM -0500, Narendra K wrote:
> On Fri, Oct 09, 2009 at 07:12:07PM +0530, K, Narendra wrote:
> > > example udev config:
> > > SUBSYSTEM=="net",
> > SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
> > 
> > work as well.  But coupling the ifindex to the MAC address like this
> > doesn't work.  (In general, coupling any two unrelated attributes when
> > trying to do persistent names doesn't work.)
> > 
> Attaching the latest patch incorporating review comments.

Same patch, rebased to linux-next.

By creating character devices for every network device, we can use
udev to maintain alternate naming policies for devices, including
additional names for the same device, without interfering with the
name that the kernel assigns a device.

This is conditionalized on CONFIG_NET_CDEV.  If enabled (the default),
device nodes will automatically be created in /dev/netdev/ for each
network device.  (/dev/net/ is already populated by the tun device.)

These device nodes are not functional at the moment - open() returns
-ENOSYS.  Their only purpose is to provide userspace with a kernel
name to ifindex mapping, in a form that udev can easily manage.

Signed-off-by: Jordan Hargrave <Jordan_Hargrave@dell.com>
Signed-off-by: Narendra K <Narendra_K@dell.com>
Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>

---
 include/linux/netdevice.h |    4 ++++
 net/Kconfig               |   10 ++++++++++
 net/core/Makefile         |    1 +
 net/core/cdev.c           |   42 ++++++++++++++++++++++++++++++++++++++++++
 net/core/cdev.h           |   13 +++++++++++++
 net/core/dev.c            |   10 ++++++++++
 net/core/net-sysfs.c      |   13 +++++++++++++
 7 files changed, 93 insertions(+), 0 deletions(-)
 create mode 100644 net/core/cdev.c
 create mode 100644 net/core/cdev.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b332eef..a2f23b4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -44,6 +44,7 @@
 #include <linux/workqueue.h>
 
 #include <linux/ethtool.h>
+#include <linux/cdev.h>
 #include <net/net_namespace.h>
 #include <net/dsa.h>
 #ifdef CONFIG_DCB
@@ -916,6 +917,9 @@ struct net_device
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
+#ifdef CONFIG_NET_CDEV
+	struct cdev cdev;
+#endif
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/net/Kconfig b/net/Kconfig
index 041c35e..bdc5bd7 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -43,6 +43,16 @@ config COMPAT_NETLINK_MESSAGES
 	  Newly written code should NEVER need this option but do
 	  compat-independent messages instead!
 
+config NET_CDEV
+       bool "/dev files for network devices"
+       default y
+       help
+         This option causes /dev entries to be created for each
+         network device.  This allows the use of udev to create
+         alternate device naming policies.
+
+	 If unsure, say Y.
+
 menu "Networking options"
 
 source "net/packet/Kconfig"
diff --git a/net/core/Makefile b/net/core/Makefile
index 796f46e..0b40d2c 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -19,4 +19,5 @@ obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
+obj-$(CONFIG_NET_CDEV) += cdev.o
 
diff --git a/net/core/cdev.c b/net/core/cdev.c
new file mode 100644
index 0000000..1f36076
--- /dev/null
+++ b/net/core/cdev.c
@@ -0,0 +1,42 @@
+#include <linux/fs.h>
+#include <linux/cdev.h>
+#include <linux/netdevice.h>
+#include <linux/device.h>
+
+/* Used for network dynamic major number */
+static dev_t netdev_devt;
+
+static int netdev_cdev_open(struct inode *inode, struct file *filep)
+{
+	/* no operations on this device are implemented */
+	return -ENOSYS;
+}
+
+static const struct file_operations netdev_cdev_fops = {
+	.owner = THIS_MODULE,
+	.open = netdev_cdev_open,
+};
+
+void netdev_cdev_alloc(void)
+{
+	alloc_chrdev_region(&netdev_devt, 0, 1<<20, "net");
+}
+
+void netdev_cdev_init(struct net_device *dev)
+{
+	cdev_init(&dev->cdev, &netdev_cdev_fops);
+	cdev_add(&dev->cdev, MKDEV(MAJOR(netdev_devt), dev->ifindex), 1);
+
+}
+
+void netdev_cdev_del(struct net_device *dev)
+{
+	if (dev->cdev.dev)
+		cdev_del(&dev->cdev);
+}
+
+void netdev_cdev_kobj_init(struct device *dev, struct net_device *net)
+{
+	if (net->cdev.dev)
+		dev->devt = net->cdev.dev;
+}
diff --git a/net/core/cdev.h b/net/core/cdev.h
new file mode 100644
index 0000000..9cf5a90
--- /dev/null
+++ b/net/core/cdev.h
@@ -0,0 +1,13 @@
+#include <linux/netdevice.h>
+
+#ifdef CONFIG_NET_CDEV
+void netdev_cdev_alloc(void);
+void netdev_cdev_init(struct net_device *dev);
+void netdev_cdev_del(struct net_device *dev);
+void netdev_cdev_kobj_init(struct device *dev, struct net_device *net);
+#else
+static inline void netdev_cdev_alloc(void) {}
+static inline void netdev_cdev_init(struct net_device *dev) {}
+static inline void netdev_cdev_del(struct net_device *dev) {}
+static inline void netdev_cdev_kobj_init(struct device *dev, struct net_device *net) {}
+#endif
diff --git a/net/core/dev.c b/net/core/dev.c
index a74c8fd..d771438 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -129,6 +129,7 @@
 #include <trace/events/napi.h>
 
 #include "net-sysfs.h"
+#include "cdev.h"
 
 /* Instead of increasing this, you should create a hash table. */
 #define MAX_GRO_SKBS 8
@@ -4684,6 +4685,7 @@ static void rollback_registered(struct net_device *dev)
 
 	/* Remove entries from kobject tree */
 	netdev_unregister_kobject(dev);
+	netdev_cdev_del(dev);
 
 	synchronize_net();
 
@@ -4835,6 +4837,8 @@ int register_netdevice(struct net_device *dev)
 	if (dev->features & NETIF_F_SG)
 		dev->features |= NETIF_F_GSO;
 
+	netdev_cdev_init(dev);
+
 	netdev_initialize_kobject(dev);
 
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
@@ -4870,6 +4874,7 @@ out:
 	return ret;
 
 err_uninit:
+	netdev_cdev_del(dev);
 	if (dev->netdev_ops->ndo_uninit)
 		dev->netdev_ops->ndo_uninit(dev);
 	goto out;
@@ -5377,6 +5382,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_addr_discard(dev);
 
 	netdev_unregister_kobject(dev);
+	netdev_cdev_del(dev);
 
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
@@ -5393,6 +5399,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 			dev->iflink = dev->ifindex;
 	}
 
+	netdev_cdev_init(dev);
+
 	/* Fixup kobjects */
 	err = netdev_register_kobject(dev);
 	WARN_ON(err);
@@ -5626,6 +5634,8 @@ static int __init net_dev_init(void)
 
 	BUG_ON(!dev_boot_phase);
 
+	netdev_cdev_alloc();
+
 	if (dev_proc_init())
 		goto out;
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 753c420..f4ee557 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -19,6 +19,7 @@
 #include <net/wext.h>
 
 #include "net-sysfs.h"
+#include "cdev.h"
 
 #ifdef CONFIG_SYSFS
 static const char fmt_hex[] = "%#x\n";
@@ -501,6 +502,14 @@ static void netdev_release(struct device *d)
 	kfree((char *)dev - dev->padded);
 }
 
+#ifdef CONFIG_NET_CDEV
+static char *netdev_devnode(struct device *d, mode_t *mode)
+{
+	struct net_device *dev = to_net_dev(d);
+	return kasprintf(GFP_KERNEL, "netdev/%s", dev->name);
+}
+#endif
+
 static struct class net_class = {
 	.name = "net",
 	.dev_release = netdev_release,
@@ -510,6 +519,9 @@ static struct class net_class = {
 #ifdef CONFIG_HOTPLUG
 	.dev_uevent = netdev_uevent,
 #endif
+#ifdef CONFIG_NET_CDEV
+	.devnode = netdev_devnode,
+#endif
 };
 
 /* Delete sysfs entries but hold kobject reference until after all
@@ -536,6 +548,7 @@ int netdev_register_kobject(struct net_device *net)
 	dev->class = &net_class;
 	dev->platform_data = net;
 	dev->groups = groups;
+	netdev_cdev_kobj_init(dev, net);
 
 	dev_set_name(dev, "%s", net->name);
 
-- 
1.6.0.6

