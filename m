From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get NCSI topology
Date: Wed,  3 May 2017 14:44:35 +1000
Message-ID: <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54948 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751209AbdECEps (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:45:48 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v434hsp6082019
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 00:45:48 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a77wes2bh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 00:45:47 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Wed, 3 May 2017 14:45:45 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v434jZ0o2097600
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:43 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v434j82J003114
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:09 +1000
In-Reply-To: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds ethtool command (ETHTOOL_GNCSICHANNELS) to retrieve the
NCSI channels that are associated with the specified netdev. The
ethtool operation (get_ncsi_channels()) is initialized or destroyed
when the NCSI device is registerred or unregistered. The userspace
and kernel has to negotiate on the total number of NCSI channels
so that userspace can allocate enough memory to convey data. Here
is the example output from modified (private) ethtool:

 # ethtool --ncsi eth0 channels
 2 channels:
 0:0     Active
 0:1

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 include/linux/ethtool.h      |  2 ++
 include/uapi/linux/ethtool.h | 17 ++++++++++
 net/core/ethtool.c           | 40 ++++++++++++++++++++++
 net/ncsi/Makefile            |  3 +-
 net/ncsi/internal.h          |  4 +++
 net/ncsi/ncsi-ethtool.c      | 80 ++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c       |  6 ++++
 7 files changed, 151 insertions(+), 1 deletion(-)
 create mode 100644 net/ncsi/ncsi-ethtool.c

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 83cc986..720bb4d 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -374,5 +374,7 @@ struct ethtool_ops {
 				      struct ethtool_link_ksettings *);
 	int	(*set_link_ksettings)(struct net_device *,
 				      const struct ethtool_link_ksettings *);
+	int	(*get_ncsi_channels)(struct net_device *,
+				     struct ethtool_ncsi_channels *);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 5f4ea28..e43aacf 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1331,6 +1331,8 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
 #define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
+#define ETHTOOL_GNCSICHANNELS	0x00000050 /* Get NCSI channels */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
@@ -1763,4 +1765,19 @@ struct ethtool_link_settings {
 	 * __u32 map_lp_advertising[link_mode_masks_nwords];
 	 */
 };
+
+/**
+ * struct ethtool_ncsi_channels - NCSI channels
+ *
+ * @cmd: Command number = %ETHTOOL_GNCSICHANNELS
+ * @nr_channels: Number of available channels
+ * @id: Array of NCSI channel IDs
+ */
+struct ethtool_ncsi_channels {
+	__u32	cmd;
+	__s16	nr_channels;
+	__u32	id[0];
+#define ETHTOOL_NCSI_CHANNEL_ACTIVE	(1 << 8)
+#define ETHTOOL_NCSI_CHANNEL_FLAGS	0x100
+};
 #endif /* _UAPI_LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 03111a2..7644765 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -756,6 +756,43 @@ static int ethtool_set_link_ksettings(struct net_device *dev,
 	return dev->ethtool_ops->set_link_ksettings(dev, &link_ksettings);
 }
 
+static int ethtool_get_ncsi_channels(struct net_device *dev,
+				     void __user *useraddr)
+{
+	struct ethtool_ncsi_channels *enc;
+	short nr_channels;
+	ssize_t size = 0;
+	int ret;
+
+	if (!dev->ethtool_ops->get_ncsi_channels)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&nr_channels, useraddr + sizeof(enc->cmd),
+			   sizeof(nr_channels)))
+		return -EFAULT;
+
+	size = sizeof(*enc);
+	if (nr_channels > 0)
+		size += nr_channels * sizeof(enc->id[0]);
+
+	enc = kzalloc(size, GFP_KERNEL);
+	if (!enc)
+		return -ENOMEM;
+
+	if (copy_from_user(enc, useraddr, size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	ret = dev->ethtool_ops->get_ncsi_channels(dev, enc);
+	if (copy_to_user(useraddr, enc, size))
+		ret = -EFAULT;
+
+out:
+	kfree(enc);
+	return ret;
+}
+
 static void
 warn_incomplete_ethtool_legacy_settings_conversion(const char *details)
 {
@@ -2793,6 +2830,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_PHY_STUNABLE:
 		rc = set_phy_tunable(dev, useraddr);
 		break;
+	case ETHTOOL_GNCSICHANNELS:
+		rc = ethtool_get_ncsi_channels(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
diff --git a/net/ncsi/Makefile b/net/ncsi/Makefile
index dd12b56..71a258a 100644
--- a/net/ncsi/Makefile
+++ b/net/ncsi/Makefile
@@ -1,4 +1,5 @@
 #
 # Makefile for NCSI API
 #
-obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-rsp.o ncsi-aen.o ncsi-manage.o
+obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-rsp.o ncsi-aen.o ncsi-manage.o \
+			  ncsi-ethtool.o
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 1308a56..09a7ba7 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -337,4 +337,8 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 		 struct packet_type *pt, struct net_device *orig_dev);
 int ncsi_aen_handler(struct ncsi_dev_priv *ndp, struct sk_buff *skb);
 
+/* ethtool */
+void ncsi_ethtool_register_dev(struct net_device *dev);
+void ncsi_ethtool_unregister_dev(struct net_device *dev);
+
 #endif /* __NCSI_INTERNAL_H__ */
diff --git a/net/ncsi/ncsi-ethtool.c b/net/ncsi/ncsi-ethtool.c
new file mode 100644
index 0000000..747aab6
--- /dev/null
+++ b/net/ncsi/ncsi-ethtool.c
@@ -0,0 +1,80 @@
+/*
+ * Copyright Gavin Shan, IBM Corporation 2017.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+
+#include <net/ncsi.h>
+
+#include "internal.h"
+#include "ncsi-pkt.h"
+
+static int ncsi_get_channels(struct net_device *dev,
+			     struct ethtool_ncsi_channels *enc)
+{
+	struct ncsi_dev *nd;
+	struct ncsi_dev_priv *ndp;
+	struct ncsi_package *np;
+	struct ncsi_channel *nc;
+	bool fill_data = !!(enc->nr_channels > 0);
+	short nr_channels = 0;
+	unsigned long flags;
+
+	nd = ncsi_find_dev(dev);
+	if (!nd)
+		return -ENXIO;
+
+	ndp = TO_NCSI_DEV_PRIV(nd);
+	NCSI_FOR_EACH_PACKAGE(ndp, np) {
+		NCSI_FOR_EACH_CHANNEL(np, nc) {
+			if (!fill_data) {
+				nr_channels++;
+				continue;
+			}
+
+			enc->id[nr_channels] = NCSI_TO_CHANNEL(np->id, nc->id);
+			spin_lock_irqsave(&nc->lock, flags);
+			if (nc->state == NCSI_CHANNEL_ACTIVE)
+				enc->id[nr_channels] |=
+					ETHTOOL_NCSI_CHANNEL_ACTIVE;
+			spin_unlock_irqrestore(&nc->lock, flags);
+			nr_channels++;
+		}
+	}
+
+	if (!fill_data)
+		enc->nr_channels = nr_channels;
+
+	return 0;
+}
+
+void ncsi_ethtool_register_dev(struct net_device *dev)
+{
+	struct ethtool_ops *ops;
+
+	ops = (struct ethtool_ops *)(dev->ethtool_ops);
+	if (!ops)
+		return;
+
+	ops->get_ncsi_channels = ncsi_get_channels;
+}
+
+void ncsi_ethtool_unregister_dev(struct net_device *dev)
+{
+	struct ethtool_ops *ops;
+
+	ops = (struct ethtool_ops *)(dev->ethtool_ops);
+	if (!ops)
+		return;
+
+	ops->get_ncsi_channels = NULL;
+}
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 13ad1f26..f1c10f0 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -1260,6 +1260,9 @@ struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 	list_add_tail_rcu(&ndp->node, &ncsi_dev_list);
 	spin_unlock_irqrestore(&ncsi_dev_lock, flags);
 
+	/* Change ethtool operations */
+	ncsi_ethtool_register_dev(dev);
+
 	/* Register NCSI packet Rx handler */
 	ndp->ptype.type = cpu_to_be16(ETH_P_NCSI);
 	ndp->ptype.func = ncsi_rcv_rsp;
@@ -1331,6 +1334,9 @@ void ncsi_unregister_dev(struct ncsi_dev *nd)
 
 	dev_remove_pack(&ndp->ptype);
 
+	/* Restore ethtool operations */
+	ncsi_ethtool_unregister_dev(nd->dev);
+
 	list_for_each_entry_safe(np, tmp, &ndp->packages, node)
 		ncsi_remove_package(np);
 
-- 
2.7.4
