From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [RFC PATCH v3 2/2] ppp: add rtnetlink device creation support
Date: Thu, 21 Apr 2016 18:22:52 +0200
Message-ID: <e117645b05479ca75c70eb0e543f779767cf2416.1461251392.git.g.nault@alphalink.fr>
References: <cover.1461251392.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	walter harms <wharms@bfs.de>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1461251392.git.g.nault@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Define PPP device handler for use with rtnetlink.
The only PPP specific attribute is IFLA_PPP_DEV_FD. It is mandatory and
contains the file descriptor of the associated /dev/ppp instance (the
file descriptor which would have been used for ioctl(PPPIOCNEWUNIT) in
the ioctl-based API). The PPP device is removed when this file
descriptor is released (same behaviour as with ioctl based PPP
devices).

PPP devices created with the rtnetlink API behave like the ones created
with ioctl(PPPIOCNEWUNIT). In particular existing ioctls work the same
way, no matter how the PPP device was created.
The rtnl callbacks are also assigned to ioctl based PPP devices. This
way, rtnl messages have the same effect on any PPP devices.
The immediate effect is that all PPP devices, even ioctl-based
ones, can now be removed with "ip link del".

A minor difference still exists between ioctl and rtnl based PPP
interfaces: in the device name, the number following the "ppp" prefix
corresponds to the PPP unit number for ioctl based devices, while it is
just an unrelated incrementing index for rtnl ones.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 115 ++++++++++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h  |   8 +++
 2 files changed, 120 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index f581a77..8b3db3a 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -46,6 +46,7 @@
 #include <linux/device.h>
 #include <linux/mutex.h>
 #include <linux/slab.h>
+#include <linux/file.h>
 #include <asm/unaligned.h>
 #include <net/slhc_vj.h>
 #include <linux/atomic.h>
@@ -186,6 +187,7 @@ struct channel {
 struct ppp_config {
 	struct file *file;
 	s32 unit;
+	bool ifname_is_set;
 };
 
 /*
@@ -286,6 +288,7 @@ static int unit_get(struct idr *p, void *ptr);
 static int unit_set(struct idr *p, void *ptr, int n);
 static void unit_put(struct idr *p, int n);
 static void *unit_find(struct idr *p, int n);
+static void ppp_setup(struct net_device *dev);
 
 static const struct net_device_ops ppp_netdev_ops;
 
@@ -964,7 +967,7 @@ static struct pernet_operations ppp_net_ops = {
 	.size = sizeof(struct ppp_net),
 };
 
-static int ppp_unit_register(struct ppp *ppp, int unit)
+static int ppp_unit_register(struct ppp *ppp, int unit, bool ifname_is_set)
 {
 	struct ppp_net *pn = ppp_pernet(ppp->ppp_net);
 	int ret;
@@ -994,7 +997,8 @@ static int ppp_unit_register(struct ppp *ppp, int unit)
 	}
 	ppp->file.index = ret;
 
-	snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
+	if (!ifname_is_set)
+		snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
 
 	ret = register_netdevice(ppp->dev);
 	if (ret < 0)
@@ -1043,7 +1047,7 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
 	ppp->active_filter = NULL;
 #endif /* CONFIG_PPP_FILTER */
 
-	err = ppp_unit_register(ppp, conf->unit);
+	err = ppp_unit_register(ppp, conf->unit, conf->ifname_is_set);
 	if (err < 0)
 		return err;
 
@@ -1052,6 +1056,99 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
 	return 0;
 }
 
+static const struct nla_policy ppp_nl_policy[IFLA_PPP_MAX + 1] = {
+	[IFLA_PPP_DEV_FD]	= { .type = NLA_S32 },
+};
+
+static int ppp_nl_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (!data)
+		return -EINVAL;
+
+	if (!data[IFLA_PPP_DEV_FD])
+		return -EINVAL;
+	if (nla_get_s32(data[IFLA_PPP_DEV_FD]) < 0)
+		return -EBADF;
+
+	return 0;
+}
+
+static int ppp_nl_newlink(struct net *src_net, struct net_device *dev,
+			  struct nlattr *tb[], struct nlattr *data[])
+{
+	struct ppp_config conf = {
+		.unit = -1,
+		.ifname_is_set = true,
+	};
+	struct file *file;
+	int err;
+
+	file = fget(nla_get_s32(data[IFLA_PPP_DEV_FD]));
+	if (!file)
+		return -EBADF;
+
+	/* rtnl_lock is already held here, but ppp_create_interface() locks
+	 * ppp_mutex before holding rtnl_lock. Using mutex_trylock() avoids
+	 * possible deadlock due to lock order inversion, at the cost of
+	 * pushing the problem back to userspace.
+	 */
+	if (!mutex_trylock(&ppp_mutex)) {
+		err = -EBUSY;
+		goto out;
+	}
+
+	if (file->f_op != &ppp_device_fops || file->private_data) {
+		err = -EBADF;
+		goto out_unlock;
+	}
+
+	conf.file = file;
+	err = ppp_dev_configure(src_net, dev, &conf);
+
+out_unlock:
+	mutex_unlock(&ppp_mutex);
+out:
+	fput(file);
+
+	return err;
+}
+
+static void ppp_nl_dellink(struct net_device *dev, struct list_head *head)
+{
+	unregister_netdevice_queue(dev, head);
+}
+
+static size_t ppp_nl_get_size(const struct net_device *dev)
+{
+	return 0;
+}
+
+static int ppp_nl_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	return 0;
+}
+
+static struct net *ppp_nl_get_link_net(const struct net_device *dev)
+{
+	struct ppp *ppp = netdev_priv(dev);
+
+	return ppp->ppp_net;
+}
+
+static struct rtnl_link_ops ppp_link_ops __read_mostly = {
+	.kind		= "ppp",
+	.maxtype	= IFLA_PPP_MAX,
+	.policy		= ppp_nl_policy,
+	.priv_size	= sizeof(struct ppp),
+	.setup		= ppp_setup,
+	.validate	= ppp_nl_validate,
+	.newlink	= ppp_nl_newlink,
+	.dellink	= ppp_nl_dellink,
+	.get_size	= ppp_nl_get_size,
+	.fill_info	= ppp_nl_fill_info,
+	.get_link_net	= ppp_nl_get_link_net,
+};
+
 #define PPP_MAJOR	108
 
 /* Called at boot time if ppp is compiled into the kernel,
@@ -1080,11 +1177,19 @@ static int __init ppp_init(void)
 		goto out_chrdev;
 	}
 
+	err = rtnl_link_register(&ppp_link_ops);
+	if (err) {
+		pr_err("failed to register rtnetlink PPP handler\n");
+		goto out_class;
+	}
+
 	/* not a big deal if we fail here :-) */
 	device_create(ppp_class, NULL, MKDEV(PPP_MAJOR, 0), NULL, "ppp");
 
 	return 0;
 
+out_class:
+	class_destroy(ppp_class);
 out_chrdev:
 	unregister_chrdev(PPP_MAJOR, "ppp");
 out_net:
@@ -2829,6 +2934,7 @@ static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 	struct ppp_config conf = {
 		.file = file,
 		.unit = *unit,
+		.ifname_is_set = false,
 	};
 	struct ppp *ppp;
 	struct net_device *dev;
@@ -2840,6 +2946,7 @@ static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 		goto err;
 	}
 	dev_net_set(dev, net);
+	dev->rtnl_link_ops = &ppp_link_ops;
 
 	rtnl_lock();
 
@@ -3046,6 +3153,7 @@ static void __exit ppp_cleanup(void)
 	/* should never happen */
 	if (atomic_read(&ppp_unit_count) || atomic_read(&channel_count))
 		pr_err("PPP: removing module but units remain!\n");
+	rtnl_link_unregister(&ppp_link_ops);
 	unregister_chrdev(PPP_MAJOR, "ppp");
 	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
 	class_destroy(ppp_class);
@@ -3104,4 +3212,5 @@ EXPORT_SYMBOL(ppp_register_compressor);
 EXPORT_SYMBOL(ppp_unregister_compressor);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_CHARDEV(PPP_MAJOR, 0);
+MODULE_ALIAS_RTNL_LINK("ppp");
 MODULE_ALIAS("devname:ppp");
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ba69d44..6b2ec17 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -517,6 +517,14 @@ enum {
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
 
+/* PPP section */
+enum {
+	IFLA_PPP_UNSPEC,
+	IFLA_PPP_DEV_FD,
+	__IFLA_PPP_MAX
+};
+#define IFLA_PPP_MAX (__IFLA_PPP_MAX - 1)
+
 /* Bonding section */
 
 enum {
-- 
2.8.1

