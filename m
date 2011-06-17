From: greearb@candelatech.com
Subject: [RFC 1/2] net:  Support getting/setting RX-FCS in drivers.
Date: Thu, 16 Jun 2011 21:30:06 -0700
Message-ID: <1308285007-11302-2-git-send-email-greearb@candelatech.com>
References: <1308285007-11302-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56836 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab1FQEaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:30:21 -0400
In-Reply-To: <1308285007-11302-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This will allow us to enable/disable having the Ethernet
frame checksum appended to the skb.  Enabling this is
useful when sniffing packets.

In particular, this can be used to test logic that allows
a NIC to receive all frames, even ones with bad checksums.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 439b173... e5e8747... M	include/linux/ethtool.h
:100644 100644 fd14116... b36bac7... M	net/core/ethtool.c
 include/linux/ethtool.h |    5 +++++
 net/core/ethtool.c      |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 439b173..e5e8747 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -955,6 +955,8 @@ struct ethtool_ops {
 	int	(*get_dump_data)(struct net_device *,
 				 struct ethtool_dump *, void *);
 	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
+	int	(*set_save_fcs)(struct net_device *, u32);
+	int	(*get_save_fcs)(struct net_device *, u32 *);
 
 };
 #endif /* __KERNEL__ */
@@ -1029,6 +1031,9 @@ struct ethtool_ops {
 #define ETHTOOL_SET_DUMP	0x0000003e /* Set dump settings */
 #define ETHTOOL_GET_DUMP_FLAG	0x0000003f /* Get dump settings */
 #define ETHTOOL_GET_DUMP_DATA	0x00000040 /* Get dump data */
+#define ETHTOOL_GETRXFCS	0x00000041 /* Get RX Save Frame Checksum */
+#define ETHTOOL_SETRXFCS	0x00000042 /* Set RX Save Frame Checksum */
+
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index fd14116..b36bac7 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1927,6 +1927,38 @@ out:
 	return ret;
 }
 
+static int ethtool_get_rx_fcs(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_value edata;
+	int rv = 0;
+
+	if (!dev->ethtool_ops->get_save_fcs)
+		return -EOPNOTSUPP;
+
+	rv = dev->ethtool_ops->get_save_fcs(dev, &edata.data);
+	if (rv < 0)
+		return rv;
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+
+static int ethtool_set_rx_fcs(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_value id;
+
+	if (!dev->ethtool_ops->set_save_fcs)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&id, useraddr, sizeof(id)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_save_fcs(dev, id.data);
+}
+
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -2152,6 +2184,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_DUMP_DATA:
 		rc = ethtool_get_dump_data(dev, useraddr);
 		break;
+	case ETHTOOL_SETRXFCS:
+		rc = ethtool_set_rx_fcs(dev, useraddr);
+		break;
+	case ETHTOOL_GETRXFCS:
+		rc = ethtool_get_rx_fcs(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.3.4

