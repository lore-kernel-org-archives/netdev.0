From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 4/10 Rev4] [ethtool] Add ethtool support
Date: Wed, 22 Aug 2007 13:59:54 +0530
Message-ID: <20070822082954.11964.9626.sendpatchset@localhost.localdomain>
References: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	xma@us.ibm.com, gaagaan@gmail.com, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:50121 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206AbXHVI20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 04:28:26 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7M8SPVd004753
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:28:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7M8SP48532054
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:28:25 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7M8SMJB026036
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:28:25 -0400
In-Reply-To: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ethtool support to enable/disable batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/ethtool.h   |    2 ++
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   36 ++++++++++++++++++++++++++++++++++++
 net/core/ethtool.c        |   27 +++++++++++++++++++++++++++
 4 files changed, 67 insertions(+)

diff -ruNp org/include/linux/ethtool.h new/include/linux/ethtool.h
--- org/include/linux/ethtool.h	2007-08-20 14:26:35.000000000 +0530
+++ new/include/linux/ethtool.h	2007-08-22 08:37:35.000000000 +0530
@@ -440,6 +440,8 @@ struct ethtool_ops {
 #define ETHTOOL_SFLAGS		0x00000026 /* Set flags bitmap(ethtool_value) */
 #define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
 #define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
+#define ETHTOOL_GBATCH		0x00000029 /* Get Batching (ethtool_value) */
+#define ETHTOOL_SBATCH		0x00000030 /* Set Batching (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
--- org/include/linux/netdevice.h	2007-08-20 14:26:36.000000000 +0530
+++ new/include/linux/netdevice.h	2007-08-22 08:42:10.000000000 +0530
@@ -1152,6 +1152,8 @@ extern void		dev_set_promiscuity(struct 
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
+extern int		dev_change_tx_batch_skb(struct net_device *dev,
+						unsigned long new_batch_skb);
 /* Load a device via the kmod */
 extern void		dev_load(const char *name);
 extern void		dev_mcast_init(void);
diff -ruNp org/net/core/dev.c new/net/core/dev.c
--- org/net/core/dev.c  2007-08-20 14:26:37.000000000 +0530
+++ new/net/core/dev.c  2007-08-22 10:49:22.000000000 +0530
@@ -908,6 +908,42 @@ static void free_batching(struct net_dev
 	}
 }
 
+int dev_change_tx_batch_skb(struct net_device *dev, unsigned long new_batch_skb)
+{
+	int ret = 0;
+	struct sk_buff_head *blist;
+
+	if (!(dev->features & NETIF_F_BATCH_SKBS)) {
+		/* Driver doesn't support batching skb API */
+		ret = -ENOTSUPP;
+		goto out;
+	}
+
+	/*
+	 * Check if new value is same as the current (paranoia to use !! for
+	 * new_batch_skb as that should always be boolean).
+	 */
+	if (!!dev->skb_blist == !!new_batch_skb)
+		goto out;
+
+	if (new_batch_skb &&
+	    (blist = kmalloc(sizeof *blist, GFP_KERNEL)) == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	spin_lock_bh(&dev->queue_lock);
+	if (new_batch_skb) {
+		skb_queue_head_init(blist);
+		dev->skb_blist = blist;
+	} else
+		free_batching(dev);
+	spin_unlock_bh(&dev->queue_lock);
+
+out:
+	return ret;
+}
+
 /**
  *	dev_load 	- load a network module
  *	@name: name of interface
diff -ruNp org/net/core/ethtool.c new/net/core/ethtool.c
--- org/net/core/ethtool.c	2007-08-20 14:26:37.000000000 +0530
+++ new/net/core/ethtool.c	2007-08-22 08:36:07.000000000 +0530
@@ -556,6 +556,26 @@ static int ethtool_set_gso(struct net_de
 	return 0;
 }
 
+static int ethtool_get_batch(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GBATCH };
+
+	edata.data = dev->skb_blist != NULL;
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		 return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_batch(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev_change_tx_batch_skb(dev, edata.data);
+}
+
 static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_test test;
@@ -813,6 +833,7 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_GGSO:
 	case ETHTOOL_GFLAGS:
 	case ETHTOOL_GPFLAGS:
+	case ETHTOOL_GBATCH:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -956,6 +977,12 @@ int dev_ethtool(struct ifreq *ifr)
 		rc = ethtool_set_value(dev, useraddr,
 				       dev->ethtool_ops->set_priv_flags);
 		break;
+	case ETHTOOL_GBATCH:
+		rc = ethtool_get_batch(dev, useraddr);
+		break;
+	case ETHTOOL_SBATCH:
+		rc = ethtool_set_batch(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
