From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 4/9 Rev3] [ethtool] Add ethtool support
Date: Wed, 08 Aug 2007 15:01:56 +0530
Message-ID: <20070808093156.15396.80149.sendpatchset@localhost.localdomain>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, general@lists.openfabrics.org, mchan@broadcom.com,
	tgraf@suug.ch, hadi@cyberus.ca, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, xma@us.ibm.com
To: johnpol@2ka.mipt.ru, sri@us.ibm.com,
	shemminger@linux-foundation.org, davem@davemloft.net,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:33405 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932682AbXHHJeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 05:34:14 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l789agSX152550
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:36:51 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l789UnYs1749246
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:30:49 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l789UjYo013544
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:30:48 +1000
In-Reply-To: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ethtool support to enable/disable batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/ethtool.h   |    2 ++
 include/linux/netdevice.h |    2 ++
 net/core/ethtool.c        |   26 ++++++++++++++++++++++++++
 3 files changed, 30 insertions(+)

diff -ruNp ORG/include/linux/ethtool.h NEW/include/linux/ethtool.h
--- ORG/include/linux/ethtool.h	2007-08-06 08:25:37.000000000 +0530
+++ NEW/include/linux/ethtool.h	2007-08-07 13:11:19.000000000 +0530
@@ -410,6 +410,8 @@ struct ethtool_ops {
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
 #define ETHTOOL_GGSO		0x00000023 /* Get GSO enable (ethtool_value) */
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
+#define ETHTOOL_GBATCH		0x00000024 /* Get Batch (ethtool_value) */
+#define ETHTOOL_SBATCH		0x00000025 /* Set Batch (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff -ruNp ORG/include/linux/netdevice.h NEW/include/linux/netdevice.h
--- ORG/include/linux/netdevice.h	2007-08-06 08:25:37.000000000 +0530
+++ NEW/include/linux/netdevice.h	2007-08-07 13:11:19.000000000 +0530
@@ -1112,6 +1112,8 @@ extern void		dev_set_promiscuity(struct 
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
+extern int		dev_change_tx_batch_skb(struct net_device *dev,
+						unsigned long new_batch_skb);
 /* Load a device via the kmod */
 extern void		dev_load(const char *name);
 extern void		dev_mcast_init(void);
diff -ruNp ORG/net/core/ethtool.c NEW/net/core/ethtool.c
--- ORG/net/core/ethtool.c	2007-08-06 08:25:40.000000000 +0530
+++ NEW/net/core/ethtool.c	2007-08-07 13:11:19.000000000 +0530
@@ -638,6 +638,25 @@ static int ethtool_set_gso(struct net_de
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
+static int ethtool_set_gso(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+	return dev_change_tx_batch_skb(dev, edata.data);
+}
+
 static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_test test;
@@ -817,6 +836,7 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_GPERMADDR:
 	case ETHTOOL_GUFO:
 	case ETHTOOL_GGSO:
+	case ETHTOOL_GBATCH:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -935,6 +955,12 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SGSO:
 		rc = ethtool_set_gso(dev, useraddr);
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
