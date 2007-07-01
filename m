From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 1/4] [IrDA] Netlink layer
Date: Mon, 02 Jul 2007 01:14:28 +0300
Message-ID: <20070701221705.099529494@sortiz.org>
References: <20070701221427.101308704@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=0011-IrDA-Initial-netlink-layer.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

First IrDA configuration netlink layer implementation.
Currently, we only support the set/get mode commands.

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 include/linux/irda.h     |   20 ++++++
 include/net/irda/irda.h  |    3 +
 include/net/irda/irlap.h |    2 +
 net/irda/Makefile        |    2 +-
 net/irda/irmod.c         |   46 ++++++++++++-
 net/irda/irnetlink.c     |  162 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 230 insertions(+), 5 deletions(-)
 create mode 100644 net/irda/irnetlink.c

Index: net-2.6-quilt/include/linux/irda.h
===================================================================
--- net-2.6-quilt.orig/include/linux/irda.h	2007-05-24 09:51:05.000000000 +0300
+++ net-2.6-quilt/include/linux/irda.h	2007-05-29 09:34:36.000000000 +0300
@@ -216,6 +216,33 @@
 #define ifr_dtr       ifr_ifru.ifru_line.dtr
 #define ifr_rts       ifr_ifru.ifru_line.rts
 
+
+/* IrDA netlink definitions */
+#define IRDA_NL_NAME "irda"
+#define IRDA_NL_VERSION 1
+
+enum irda_nl_commands {
+	IRDA_NL_CMD_UNSPEC,
+	IRDA_NL_CMD_SET_MODE,
+	IRDA_NL_CMD_GET_MODE,
+
+	__IRDA_NL_CMD_AFTER_LAST
+};
+#define IRDA_NL_CMD_MAX (__IRDA_NL_CMD_AFTER_LAST - 1)
+
+enum nl80211_attrs {
+	IRDA_NL_ATTR_UNSPEC,
+	IRDA_NL_ATTR_IFNAME,
+	IRDA_NL_ATTR_MODE,
+
+	__IRDA_NL_ATTR_AFTER_LAST
+};
+#define IRDA_NL_ATTR_MAX (__IRDA_NL_ATTR_AFTER_LAST - 1)
+
+/* IrDA modes */
+#define IRDA_MODE_PRIMARY   0x1
+#define IRDA_MODE_SECONDARY 0x2
+
 #endif /* KERNEL_IRDA_H */
 
 
Index: net-2.6-quilt/include/net/irda/irda.h
===================================================================
--- net-2.6-quilt.orig/include/net/irda/irda.h	2007-05-24 09:51:05.000000000 +0300
+++ net-2.6-quilt/include/net/irda/irda.h	2007-05-24 09:51:21.000000000 +0300
@@ -125,6 +125,9 @@
 extern int irsock_init(void);
 extern void irsock_cleanup(void);
 
+extern int irda_nl_register(void);
+extern void irda_nl_unregister(void);
+
 extern int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 			    struct packet_type *ptype,
 			    struct net_device *orig_dev);
Index: net-2.6-quilt/include/net/irda/irlap.h
===================================================================
--- net-2.6-quilt.orig/include/net/irda/irlap.h	2007-05-24 09:51:21.000000000 +0300
+++ net-2.6-quilt/include/net/irda/irlap.h	2007-05-24 09:51:21.000000000 +0300
@@ -208,6 +208,8 @@
 	int    xbofs_delay;   /* Nr of XBOF's used to MTT */
 	int    bofs_count;    /* Negotiated extra BOFs */
 	int    next_bofs;     /* Negotiated extra BOFs after next frame */
+
+	int    mode;     /* IrLAP mode (primary, secondary or monitor) */
 };
 
 /* 
Index: net-2.6-quilt/net/irda/Makefile
===================================================================
--- net-2.6-quilt.orig/net/irda/Makefile	2007-05-24 09:51:05.000000000 +0300
+++ net-2.6-quilt/net/irda/Makefile	2007-05-24 09:51:21.000000000 +0300
@@ -10,6 +10,6 @@
 irda-y := iriap.o iriap_event.o irlmp.o irlmp_event.o irlmp_frame.o \
           irlap.o irlap_event.o irlap_frame.o timer.o qos.o irqueue.o \
           irttp.o irda_device.o irias_object.o wrapper.o af_irda.o \
-	  discovery.o parameters.o irmod.o
+	  discovery.o parameters.o irnetlink.o irmod.o
 irda-$(CONFIG_PROC_FS) += irproc.o
 irda-$(CONFIG_SYSCTL) += irsysctl.o
Index: net-2.6-quilt/net/irda/irmod.c
===================================================================
--- net-2.6-quilt.orig/net/irda/irmod.c	2007-05-24 09:51:05.000000000 +0300
+++ net-2.6-quilt/net/irda/irmod.c	2007-05-24 09:51:21.000000000 +0300
@@ -88,16 +88,23 @@
  */
 static int __init irda_init(void)
 {
+	int ret = 0;
+
 	IRDA_DEBUG(0, "%s()\n", __FUNCTION__);
 
 	/* Lower layer of the stack */
 	irlmp_init();
 	irlap_init();
 
+	/* Driver/dongle support */
+	irda_device_init();
+
 	/* Higher layers of the stack */
 	iriap_init();
 	irttp_init();
-	irsock_init();
+	ret = irsock_init();
+	if (ret < 0)
+		goto out_err_1;
 
 	/* Add IrDA packet type (Start receiving packets) */
 	dev_add_pack(&irda_packet_type);
@@ -107,13 +114,44 @@
 	irda_proc_register();
 #endif
 #ifdef CONFIG_SYSCTL
-	irda_sysctl_register();
+	ret = irda_sysctl_register();
+	if (ret < 0)
+		goto out_err_2;
 #endif
 
-	/* Driver/dongle support */
-	irda_device_init();
+	ret = irda_nl_register();
+	if (ret < 0)
+		goto out_err_3;
 
 	return 0;
+
+ out_err_3:
+#ifdef CONFIG_SYSCTL
+	irda_sysctl_unregister();
+#endif
+ out_err_2:
+#ifdef CONFIG_PROC_FS
+	irda_proc_unregister();
+#endif
+
+	/* Remove IrDA packet type (stop receiving packets) */
+	dev_remove_pack(&irda_packet_type);
+
+	/* Remove higher layers */
+	irsock_cleanup();
+ out_err_1:
+	irttp_cleanup();
+	iriap_cleanup();
+
+	/* Remove lower layers */
+	irda_device_cleanup();
+	irlap_cleanup(); /* Must be done before irlmp_cleanup()! DB */
+
+	/* Remove middle layer */
+	irlmp_cleanup();
+
+
+	return ret;
 }
 
 /*
@@ -125,6 +163,8 @@
 static void __exit irda_cleanup(void)
 {
 	/* Remove External APIs */
+	irda_nl_unregister();
+
 #ifdef CONFIG_SYSCTL
 	irda_sysctl_unregister();
 #endif
Index: net-2.6-quilt/net/irda/irnetlink.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-2.6-quilt/net/irda/irnetlink.c	2007-05-24 09:51:21.000000000 +0300
@@ -0,0 +1,170 @@
+/*
+ * IrDA netlink layer, for stack configuration.
+ *
+ * Copyright (c) 2007 Samuel Ortiz <samuel@sortiz>
+ *
+ * Partly based on the 802.11 nelink implementation
+ * (see net/wireless/nl80211.c) which is:
+ * Copyright 2006 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/socket.h>
+#include <linux/irda.h>
+#include <net/sock.h>
+#include <net/irda/irda.h>
+#include <net/irda/irlap.h>
+#include <net/genetlink.h>
+
+
+
+static struct genl_family irda_nl_family = {
+	.id = GENL_ID_GENERATE,
+	.name = IRDA_NL_NAME,
+	.hdrsize = 0,
+	.version = IRDA_NL_VERSION,
+	.maxattr = IRDA_NL_CMD_MAX,
+};
+
+static struct net_device * ifname_to_netdev(struct genl_info *info)
+{
+	char * ifname;
+
+	if (!info->attrs[IRDA_NL_ATTR_IFNAME])
+		return NULL;
+
+	ifname = nla_data(info->attrs[IRDA_NL_ATTR_IFNAME]);
+
+	IRDA_DEBUG(5, "%s(): Looking for %s\n", __FUNCTION__, ifname);
+
+	return dev_get_by_name(ifname);
+}
+
+static int irda_nl_set_mode(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device * dev;
+	struct irlap_cb * irlap;
+	u32 mode;
+
+	if (!info->attrs[IRDA_NL_ATTR_MODE])
+		return -EINVAL;
+
+	mode = nla_get_u32(info->attrs[IRDA_NL_ATTR_MODE]);
+
+	IRDA_DEBUG(5, "%s(): Switching to mode: %d\n", __FUNCTION__, mode);
+
+	dev = ifname_to_netdev(info);
+	if (!dev)
+		return -ENODEV;
+
+	irlap = (struct irlap_cb *)dev->atalk_ptr;
+	if (!irlap) {
+		dev_put(dev);
+		return -ENODEV;
+	}
+
+	irlap->mode = mode;
+
+	dev_put(dev);
+
+	return 0;
+}
+
+static int irda_nl_get_mode(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device * dev;
+	struct irlap_cb * irlap;
+	struct sk_buff *msg;
+	void *hdr;
+	int ret = -ENOBUFS;
+
+	dev = ifname_to_netdev(info);
+	if (!dev)
+		return -ENODEV;
+
+	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!msg) {
+		dev_put(dev);
+		return -ENOMEM;
+	}
+
+	irlap = (struct irlap_cb *)dev->atalk_ptr;
+	if (!irlap) {
+		ret = -ENODEV;
+		goto err_out;
+	}
+
+	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
+			  &irda_nl_family, 0,  IRDA_NL_CMD_GET_MODE);
+	if (IS_ERR(hdr)) {
+		ret = PTR_ERR(hdr);
+		goto err_out;
+	}
+
+	if(nla_put_string(msg, IRDA_NL_ATTR_IFNAME,
+			  dev->name));
+		goto err_out;
+
+	if(nla_put_u32(msg, IRDA_NL_ATTR_MODE, irlap->mode))
+		goto err_out;
+
+	genlmsg_end(msg, hdr);
+
+	return genlmsg_unicast(msg, info->snd_pid);
+
+ err_out:
+	nlmsg_free(msg);
+	dev_put(dev);
+
+	return ret;
+}
+
+static struct nla_policy irda_nl_policy[IRDA_NL_ATTR_MAX + 1] = {
+	[IRDA_NL_ATTR_IFNAME] = { .type = NLA_NUL_STRING,
+				  .len = IFNAMSIZ-1 },
+	[IRDA_NL_ATTR_MODE] = { .type = NLA_U32 },
+};
+
+static struct genl_ops irda_nl_ops[] = {
+	{
+		.cmd = IRDA_NL_CMD_SET_MODE,
+		.doit = irda_nl_set_mode,
+		.policy = irda_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = IRDA_NL_CMD_GET_MODE,
+		.doit = irda_nl_get_mode,
+		.policy = irda_nl_policy,
+		/* can be retrieved by unprivileged users */
+	},
+
+};
+
+int irda_nl_register(void)
+{
+	int err, i;
+
+	err = genl_register_family(&irda_nl_family);
+	if (err)
+		return err;
+
+	for (i = 0; i < ARRAY_SIZE(irda_nl_ops); i++) {
+		err = genl_register_ops(&irda_nl_family, &irda_nl_ops[i]);
+		if (err)
+			goto err_out;
+	}
+	return 0;
+ err_out:
+	genl_unregister_family(&irda_nl_family);
+	return err;
+}
+
+void irda_nl_unregister(void)
+{
+	genl_unregister_family(&irda_nl_family);
+}

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
