From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 07/10] net/ncsi: Ethtool operation to get NCSI sw statistics
Date: Wed,  3 May 2017 14:44:38 +1000
Message-ID: <1493786681-27468-8-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:36248 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751592AbdECEqR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:46:17 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v434iEJn064045
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 00:46:11 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a73gvt5m0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 00:46:11 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Wed, 3 May 2017 14:46:08 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v434jwPF10682428
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:46:06 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v434jWdU031155
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 14:45:33 +1000
In-Reply-To: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds ethtool command (ETHTOOL_GNCSISWSTATS) to retrieve the
NCSI software statistics. The simplified output of this command is
shown as follows from the modified (private) ethtool.

 COMMAND      OK       TIMEOUT  ERROR
 ====================================
 CIS          32       29       0
 SP           10       7        0
 DP           17       14       0
 EC           1        0        0
 ECNT         1        0        0
 AE           1        0        0
 GLS          10       0        0
 SMA          1        0        0
 DBF          1        0        0
 GC           2        0        0
 GP           2        0        0

 RESPONSE     OK       TIMEOUT  ERROR
 ====================================
 CIS          3        0        0
 SP           3        0        0
 DP           2        0        1
 EC           1        0        0
 ECNT         1        0        0
 AE           1        0        0
 GLS          10       0        0
 SMA          1        0        0
 DBF          1        0        0
 GC           0        0        2
 GP           2        0        0

 AEN          OK       TIMEOUT  ERROR
 ====================================

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 include/linux/ethtool.h      |  2 ++
 include/uapi/linux/ethtool.h | 20 ++++++++++++++++++++
 net/core/ethtool.c           | 29 ++++++++++++++++++++++++++++
 net/ncsi/Kconfig             |  9 +++++++++
 net/ncsi/Makefile            |  1 +
 net/ncsi/internal.h          | 13 +++++++++++++
 net/ncsi/ncsi-aen.c          | 14 +++++++++++++-
 net/ncsi/ncsi-cmd.c          | 12 +++++++++++-
 net/ncsi/ncsi-debug.c        | 45 ++++++++++++++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-ethtool.c      | 34 +++++++++++++++++++++++++++++++++
 net/ncsi/ncsi-manage.c       |  4 ++++
 net/ncsi/ncsi-rsp.c          | 19 ++++++++++++++++++-
 12 files changed, 199 insertions(+), 3 deletions(-)
 create mode 100644 net/ncsi/ncsi-debug.c

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 6d712ca..eb57142 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -380,5 +380,7 @@ struct ethtool_ops {
 					 struct ethtool_ncsi_channel_info *);
 	int	(*get_ncsi_stats)(struct net_device *,
 				  struct ethtool_ncsi_stats *);
+	int	(*get_ncsi_sw_stats)(struct net_device *,
+				     struct ethtool_ncsi_sw_stats *);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 472773c..bf6fa2b 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1334,6 +1334,7 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_GNCSICHANNELS	0x00000050 /* Get NCSI channels */
 #define ETHTOOL_GNCSICINFO	0x00000051 /* Get NCSI channel information */
 #define ETHTOOL_GNCSISTATS	0x00000052 /* Get NCSI HW statistics */
+#define ETHTOOL_GNCSISWSTATS	0x00000053 /* Get NCSI software statistics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -2055,4 +2056,23 @@ struct ethtool_ncsi_stats {
 	__u64	pt_rx_us_err;
 	__u64	pt_rx_os_err;
 };
+
+/**
+ * struct ethtool_ncsi_sw_stats - NCSI software statistics
+ *
+ * @cmd: Command number = %ETHTOOL_GNCSISWSTATS
+ * @command: Statistics for sent command packets
+ * @response: Statistics for received response packets
+ * @aen: Statistics for received AEN packets
+ */
+struct ethtool_ncsi_sw_stats {
+	__u32	cmd;
+#define ETHTOOL_NCSI_SW_STAT_OK		0
+#define ETHTOOL_NCSI_SW_STAT_TIMEOUT	1
+#define ETHTOOL_NCSI_SW_STAT_ERROR	2
+#define ETHTOOL_NCSI_SW_STAT_MAX	3
+	__u64	command[128][ETHTOOL_NCSI_SW_STAT_MAX];
+	__u64	response[128][ETHTOOL_NCSI_SW_STAT_MAX];
+	__u64	aen[256][ETHTOOL_NCSI_SW_STAT_MAX];
+};
 #endif /* _UAPI_LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f26aa36..998d29b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -838,6 +838,32 @@ static int ethtool_get_ncsi_stats(struct net_device *dev,
 	return ret;
 }
 
+static int ethtool_get_ncsi_sw_stats(struct net_device *dev,
+				     void __user *useraddr)
+{
+	struct ethtool_ncsi_sw_stats *enss;
+	int ret;
+
+	if (!dev->ethtool_ops->get_ncsi_sw_stats)
+		return -EOPNOTSUPP;
+
+	enss = kzalloc(sizeof(*enss), GFP_KERNEL);
+	if (!enss)
+		return -ENOMEM;
+
+	if (copy_from_user(&enss->cmd, useraddr, sizeof(enss->cmd))) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	ret = dev->ethtool_ops->get_ncsi_sw_stats(dev, enss);
+	if (!ret && copy_to_user(useraddr, enss, sizeof(*enss)))
+		ret = -EFAULT;
+out:
+	kfree(enss);
+	return ret;
+}
+
 static void
 warn_incomplete_ethtool_legacy_settings_conversion(const char *details)
 {
@@ -2884,6 +2910,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GNCSISTATS:
 		rc = ethtool_get_ncsi_stats(dev, useraddr);
 		break;
+	case ETHTOOL_GNCSISWSTATS:
+		rc = ethtool_get_ncsi_sw_stats(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
diff --git a/net/ncsi/Kconfig b/net/ncsi/Kconfig
index 08a8a60..9e59145 100644
--- a/net/ncsi/Kconfig
+++ b/net/ncsi/Kconfig
@@ -10,3 +10,12 @@ config NET_NCSI
 	  support. Enable this only if your system connects to a network
 	  device via NCSI and the ethernet driver you're using supports
 	  the protocol explicitly.
+
+config NET_NCSI_DEBUG
+	bool "Enable NCSI debugging"
+	depends on NET_NCSI && DEBUG_FS
+	default n
+	---help---
+	  This enables the interfaces (e.g. debugfs) for NCSI debugging purpose.
+
+	  If unsure, say N.
diff --git a/net/ncsi/Makefile b/net/ncsi/Makefile
index 71a258a..4e0c5d2 100644
--- a/net/ncsi/Makefile
+++ b/net/ncsi/Makefile
@@ -3,3 +3,4 @@
 #
 obj-$(CONFIG_NET_NCSI) += ncsi-cmd.o ncsi-rsp.o ncsi-aen.o ncsi-manage.o \
 			  ncsi-ethtool.o
+obj-$(CONFIG_NET_NCSI_DEBUG) += ncsi-debug.o
diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 09a7ba7..5a6cd74 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -275,6 +275,9 @@ struct ncsi_dev_priv {
 	struct list_head    channel_queue;   /* Config queue of channels   */
 	struct work_struct  work;            /* For channel management     */
 	struct packet_type  ptype;           /* NCSI packet Rx handler     */
+#ifdef CONFIG_NET_NCSI_DEBUG
+	struct ethtool_ncsi_sw_stats stats;  /* NCSI software statistics   */
+#endif /* CONFIG_NET_NCSI_DEBUG */
 	struct list_head    node;            /* Form NCSI device list      */
 };
 
@@ -341,4 +344,14 @@ int ncsi_aen_handler(struct ncsi_dev_priv *ndp, struct sk_buff *skb);
 void ncsi_ethtool_register_dev(struct net_device *dev);
 void ncsi_ethtool_unregister_dev(struct net_device *dev);
 
+/* Debugging functionality */
+#ifdef CONFIG_NET_NCSI_DEBUG
+void ncsi_dev_update_stats(struct ncsi_dev_priv *ndp,
+			   int type, int subtype, int errno);
+#else
+static inline void ncsi_dev_update_stats(struct ncsi_dev_priv *ndp,
+					 int type, int subtype, int errno)
+{
+}
+#endif /* CONFIG_NET_NCSI_DEBUG */
 #endif /* __NCSI_INTERNAL_H__ */
diff --git a/net/ncsi/ncsi-aen.c b/net/ncsi/ncsi-aen.c
index 6898e72..7a3d181 100644
--- a/net/ncsi/ncsi-aen.c
+++ b/net/ncsi/ncsi-aen.c
@@ -206,16 +206,28 @@ int ncsi_aen_handler(struct ncsi_dev_priv *ndp, struct sk_buff *skb)
 	}
 
 	if (!nah) {
+		ncsi_dev_update_stats(ndp, NCSI_PKT_AEN, h->type,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
 		netdev_warn(ndp->ndev.dev, "Invalid AEN (0x%x) received\n",
 			    h->type);
 		return -ENOENT;
 	}
 
 	ret = ncsi_validate_aen_pkt(h, nah->payload);
-	if (ret)
+	if (ret) {
+		ncsi_dev_update_stats(ndp, NCSI_PKT_AEN, h->type,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
 		goto out;
+	}
 
 	ret = nah->handler(ndp, h);
+	if (!ret) {
+		ncsi_dev_update_stats(ndp, NCSI_PKT_AEN, h->type,
+				      ETHTOOL_NCSI_SW_STAT_OK);
+	} else {
+		ncsi_dev_update_stats(ndp, NCSI_PKT_AEN, h->type,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
+	}
 out:
 	consume_skb(skb);
 	return ret;
diff --git a/net/ncsi/ncsi-cmd.c b/net/ncsi/ncsi-cmd.c
index db7083b..875ff07 100644
--- a/net/ncsi/ncsi-cmd.c
+++ b/net/ncsi/ncsi-cmd.c
@@ -323,6 +323,8 @@ int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca)
 	}
 
 	if (!nch) {
+		ncsi_dev_update_stats(nca->ndp, nca->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
 		netdev_err(nca->ndp->ndev.dev,
 			   "Cannot send packet with type 0x%02x\n", nca->type);
 		return -ENOENT;
@@ -331,13 +333,18 @@ int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca)
 	/* Get packet payload length and allocate the request */
 	nca->payload = nch->payload;
 	nr = ncsi_alloc_command(nca);
-	if (!nr)
+	if (!nr) {
+		ncsi_dev_update_stats(nca->ndp, nca->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
 		return -ENOMEM;
+	}
 
 	/* Prepare the packet */
 	nca->id = nr->id;
 	ret = nch->handler(nr->cmd, nca);
 	if (ret) {
+		ncsi_dev_update_stats(nca->ndp, nca->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
 		ncsi_free_request(nr);
 		return ret;
 	}
@@ -359,9 +366,12 @@ int ncsi_xmit_cmd(struct ncsi_cmd_arg *nca)
 	skb_get(nr->cmd);
 	ret = dev_queue_xmit(nr->cmd);
 	if (ret < 0) {
+		ncsi_dev_update_stats(nca->ndp, nca->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
 		ncsi_free_request(nr);
 		return ret;
 	}
 
+	ncsi_dev_update_stats(nca->ndp, nca->type, 0, ETHTOOL_NCSI_SW_STAT_OK);
 	return 0;
 }
diff --git a/net/ncsi/ncsi-debug.c b/net/ncsi/ncsi-debug.c
new file mode 100644
index 0000000..0e6c038
--- /dev/null
+++ b/net/ncsi/ncsi-debug.c
@@ -0,0 +1,45 @@
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
+#include <linux/atomic.h>
+#include <linux/netdevice.h>
+#include <linux/debugfs.h>
+#include <linux/skbuff.h>
+
+#include <net/ncsi.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+
+#include "internal.h"
+#include "ncsi-pkt.h"
+
+void ncsi_dev_update_stats(struct ncsi_dev_priv *ndp,
+			   int type, int subtype, int errno)
+{
+	unsigned long flags;
+
+	if (errno >= ETHTOOL_NCSI_SW_STAT_MAX)
+		return;
+
+	spin_lock_irqsave(&ndp->lock, flags);
+
+	if (type == NCSI_PKT_AEN) {
+		if (subtype < 256)
+			ndp->stats.aen[subtype][errno]++;
+	} else if (type < 128) {
+		ndp->stats.command[type][errno]++;
+	} else if (type < 256) {
+		ndp->stats.response[type - 128][errno]++;
+	}
+
+	spin_unlock_irqrestore(&ndp->lock, flags);
+}
diff --git a/net/ncsi/ncsi-ethtool.c b/net/ncsi/ncsi-ethtool.c
index 1ccdb50..82642ae 100644
--- a/net/ncsi/ncsi-ethtool.c
+++ b/net/ncsi/ncsi-ethtool.c
@@ -260,6 +260,38 @@ static int ncsi_get_stats(struct net_device *dev,
 	return 0;
 }
 
+#ifdef CONFIG_NET_NCSI_DEBUG
+static int ncsi_get_sw_stats(struct net_device *dev,
+			     struct ethtool_ncsi_sw_stats *enss)
+{
+	struct ncsi_dev *nd;
+	struct ncsi_dev_priv *ndp;
+	unsigned long flags;
+
+	nd = ncsi_find_dev(dev);
+	if (!nd)
+		return -ENXIO;
+
+	ndp = TO_NCSI_DEV_PRIV(nd);
+	spin_lock_irqsave(&ndp->lock, flags);
+	memcpy(enss->command, ndp->stats.command,
+	       128 * ETHTOOL_NCSI_SW_STAT_MAX * sizeof(enss->command[0][0]));
+	memcpy(enss->response, ndp->stats.response,
+	       128 * ETHTOOL_NCSI_SW_STAT_MAX * sizeof(enss->response[0][0]));
+	memcpy(enss->aen, ndp->stats.aen,
+	       256 * ETHTOOL_NCSI_SW_STAT_MAX * sizeof(enss->aen[0][0]));
+	spin_unlock_irqrestore(&ndp->lock, flags);
+
+	return 0;
+}
+#else
+static int ncsi_get_sw_stats(struct net_device *dev,
+			     struct ethtool_ncsi_sw_stats *enss)
+{
+	return -EOPNOTSUPP;
+}
+#endif /* CONFIG_NET_NCSI_DEBUG */
+
 void ncsi_ethtool_register_dev(struct net_device *dev)
 {
 	struct ethtool_ops *ops;
@@ -271,6 +303,7 @@ void ncsi_ethtool_register_dev(struct net_device *dev)
 	ops->get_ncsi_channels = ncsi_get_channels;
 	ops->get_ncsi_channel_info = ncsi_get_channel_info;
 	ops->get_ncsi_stats = ncsi_get_stats;
+	ops->get_ncsi_sw_stats = ncsi_get_sw_stats;
 }
 
 void ncsi_ethtool_unregister_dev(struct net_device *dev)
@@ -284,4 +317,5 @@ void ncsi_ethtool_unregister_dev(struct net_device *dev)
 	ops->get_ncsi_channels = NULL;
 	ops->get_ncsi_channel_info = NULL;
 	ops->get_ncsi_stats = NULL;
+	ops->get_ncsi_sw_stats = NULL;
 }
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index f1c10f0..8365a5b 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -521,6 +521,7 @@ static void ncsi_request_timeout(unsigned long data)
 {
 	struct ncsi_request *nr = (struct ncsi_request *)data;
 	struct ncsi_dev_priv *ndp = nr->ndp;
+	struct ncsi_pkt_hdr *hdr;
 	unsigned long flags;
 
 	/* If the request already had associated response,
@@ -534,6 +535,9 @@ static void ncsi_request_timeout(unsigned long data)
 	}
 	spin_unlock_irqrestore(&ndp->lock, flags);
 
+	hdr = (struct ncsi_pkt_hdr *)skb_network_header(nr->cmd);
+	ncsi_dev_update_stats(ndp, hdr->type, 0, ETHTOOL_NCSI_SW_STAT_TIMEOUT);
+
 	/* Release the request */
 	ncsi_free_request(nr);
 }
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 087db77..d362d2c 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -998,6 +998,8 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (!nrh) {
+		ncsi_dev_update_stats(ndp, hdr->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
 		netdev_err(nd->dev, "Received unrecognized packet (0x%x)\n",
 			   hdr->type);
 		return -ENOENT;
@@ -1008,12 +1010,16 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 	nr = &ndp->requests[hdr->id];
 	if (!nr->used) {
 		spin_unlock_irqrestore(&ndp->lock, flags);
+		ncsi_dev_update_stats(ndp, hdr->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_TIMEOUT);
 		return -ENODEV;
 	}
 
 	nr->rsp = skb;
 	if (!nr->enabled) {
 		spin_unlock_irqrestore(&ndp->lock, flags);
+		ncsi_dev_update_stats(ndp, hdr->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_TIMEOUT);
 		ret = -ENOENT;
 		goto out;
 	}
@@ -1024,11 +1030,22 @@ int ncsi_rcv_rsp(struct sk_buff *skb, struct net_device *dev,
 	if (payload < 0)
 		payload = ntohs(hdr->length);
 	ret = ncsi_validate_rsp_pkt(nr, payload);
-	if (ret)
+	if (ret) {
+		ncsi_dev_update_stats(ndp, hdr->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
 		goto out;
+	}
 
 	/* Process the packet */
 	ret = nrh->handler(nr);
+	if (!ret) {
+		ncsi_dev_update_stats(ndp, hdr->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_OK);
+	} else {
+		ncsi_dev_update_stats(ndp, hdr->type, 0,
+				      ETHTOOL_NCSI_SW_STAT_ERROR);
+	}
+
 out:
 	ncsi_free_request(nr);
 	return ret;
-- 
2.7.4
