From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [RFC PATCH 6/6] ppp: add rtnetlink device creation support
Date: Tue, 5 Apr 2016 02:56:30 +0200
Message-ID: <dc5fd88775581dba073d0051bbfb4c2c9c5c2d23.1459807527.git.g.nault@alphalink.fr>
References: <cover.1459807527.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55853 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366AbcDEA4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 20:56:36 -0400
Content-Disposition: inline
In-Reply-To: <cover.1459807527.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define PPP device handlers for use with rtnetlink.
The only PPP specific attribute is IFLA_PPP_DEV_FD. It is mandatory and
contains the file descriptor of the associated /dev/ppp instance (the
file descriptor which would have been used for ioctl(PPPIOCNEWUNIT) in
the ioctl-based API). The PPP device is removed when this file
descriptor is released (same behaviour as with ioctl based PPP
devices).

PPP devices created with the rtnetlink API behave like the ones created
with ioctl(PPPIOCNEWUNIT). In particular existing ioctls work the same
way, no matter how the PPP device was created.

However, there are a few differences between rtnl and ioctl based PPP
devices. Rtnl based PPP devices can be removed with RTM_DELLINK
messages (e.g. with "ip link del"), while the ones created with
ioctl(PPPIOCNEWUNIT) can't.
The interface name is also built differently: the number following the
"ppp" prefix corresponds to the PPP unit number for ioctl based
devices, while it is just an unrelated incrementing index for rtnl
ones.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 143 +++++++++++++++++++++++++++++++++++++-----
 include/uapi/linux/if_link.h  |   8 +++
 2 files changed, 136 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 516f8dc..ae40368 100644
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
@@ -185,7 +186,9 @@ struct channel {
 
 struct ppp_config {
 	struct file *file;
+	s32 fd;
 	s32 unit;
+	bool ifname_is_set;
 };
 
 /*
@@ -286,6 +289,7 @@ static int unit_get(struct idr *p, void *ptr);
 static int unit_set(struct idr *p, void *ptr, int n);
 static void unit_put(struct idr *p, int n);
 static void *unit_find(struct idr *p, int n);
+static void ppp_setup(struct net_device *dev);
 
 static const struct net_device_ops ppp_netdev_ops;
 
@@ -989,7 +993,7 @@ static struct pernet_operations ppp_net_ops = {
 	.size = sizeof(struct ppp_net),
 };
 
-static int ppp_unit_register(struct ppp *ppp, int unit)
+static int ppp_unit_register(struct ppp *ppp, int unit, bool ifname_is_set)
 {
 	struct ppp_net *pn = ppp_pernet(ppp->ppp_net);
 	int ret;
@@ -1019,7 +1023,8 @@ static int ppp_unit_register(struct ppp *ppp, int unit)
 	}
 	ppp->file.index = ret;
 
-	snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
+	if (!ifname_is_set)
+		snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
 
 	ret = register_netdevice(ppp->dev);
 	if (ret < 0)
@@ -1043,12 +1048,39 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
 			     const struct ppp_config *conf)
 {
 	struct ppp *ppp = netdev_priv(dev);
+	struct file *file;
 	int indx;
+	int err;
+
+	if (conf->fd < 0) {
+		file = conf->file;
+		if (!file) {
+			err = -EBADF;
+			goto out;
+		}
+	} else {
+		file = fget(conf->fd);
+		if (!file) {
+			err = -EBADF;
+			goto out;
+		}
+
+		if (file->f_op != &ppp_device_fops) {
+			err = -EBADF;
+			goto out;
+		}
+	}
+
+	mutex_lock(&ppp_mutex);
+	if (file->private_data) {
+		err = -ENOTTY;
+		goto out_mutex;
+	}
 
 	ppp->dev = dev;
 	ppp->mru = PPP_MRU;
 	ppp->ppp_net = src_net;
-	ppp->owner = conf->file;
+	ppp->owner = file;
 
 	init_ppp_file(&ppp->file, INTERFACE);
 	ppp->file.hdrlen = PPP_HDRLEN - 2; /* don't count proto bytes */
@@ -1067,9 +1099,88 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
 	ppp->active_filter = NULL;
 #endif /* CONFIG_PPP_FILTER */
 
-	return ppp_unit_register(ppp, conf->unit);
+	err = ppp_unit_register(ppp, conf->unit, conf->ifname_is_set);
+	if (err < 0)
+		goto out_mutex;
+
+	file->private_data = &ppp->file;
+
+out_mutex:
+	mutex_unlock(&ppp_mutex);
+out:
+	if (conf->fd >= 0 && file)
+		fput(file);
+
+	return err;
 }
 
+static const struct nla_policy ppp_nl_policy[IFLA_PPP_MAX + 1] = {
+	[IFLA_PPP_DEV_FD]       = { .type = NLA_S32 },
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
+		.file = NULL,
+		.unit = -1,
+		.ifname_is_set = true,
+	};
+
+	conf.fd = nla_get_s32(data[IFLA_PPP_DEV_FD]);
+
+	return ppp_dev_configure(src_net, dev, &conf);
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
@@ -1098,11 +1209,19 @@ static int __init ppp_init(void)
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
@@ -2846,7 +2965,9 @@ static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 {
 	struct ppp_config conf = {
 		.file = file,
+		.fd = -1,
 		.unit = *unit,
+		.ifname_is_set = false,
 	};
 	struct net_device *dev;
 	struct ppp *ppp;
@@ -2861,27 +2982,17 @@ static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 	dev_net_set(dev, net);
 
 	rtnl_lock();
-	mutex_lock(&ppp_mutex);
-	if (file->private_data) {
-		err = -ENOTTY;
-		goto err_dev;
-	}
-
 	err = ppp_dev_configure(net, dev, &conf);
 	if (err < 0)
 		goto err_dev;
+	rtnl_unlock();
 
 	ppp = netdev_priv(dev);
 	*unit = ppp->file.index;
-	file->private_data = &ppp->file;
-
-	mutex_unlock(&ppp_mutex);
-	rtnl_unlock();
 
 	return 0;
 
 err_dev:
-	mutex_unlock(&ppp_mutex);
 	rtnl_unlock();
 	free_netdev(dev);
 err:
@@ -3074,6 +3185,7 @@ static void __exit ppp_cleanup(void)
 	/* should never happen */
 	if (atomic_read(&ppp_unit_count) || atomic_read(&channel_count))
 		pr_err("PPP: removing module but units remain!\n");
+	rtnl_link_unregister(&ppp_link_ops);
 	unregister_chrdev(PPP_MAJOR, "ppp");
 	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
 	class_destroy(ppp_class);
@@ -3132,4 +3244,5 @@ EXPORT_SYMBOL(ppp_register_compressor);
 EXPORT_SYMBOL(ppp_unregister_compressor);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_CHARDEV(PPP_MAJOR, 0);
+MODULE_ALIAS_RTNL_LINK("ppp");
 MODULE_ALIAS("devname:ppp");
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c488066..f238de9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -515,6 +515,14 @@ enum {
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
 
+/* PPP section */
+enum {
+	IFLA_PPP_UNSPEC,
+	IFLA_PPP_DEV_FD,
+	__IFLA_PPP_MAX,
+};
+#define IFLA_PPP_MAX (__IFLA_PPP_MAX - 1)
+
 /* Bonding section */
 
 enum {
-- 
2.8.0.rc3
