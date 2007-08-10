From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 3/4] Add ETHTOOL_[GS]PFLAGS sub-ioctls
Date: Fri, 10 Aug 2007 16:26:30 -0400
Message-ID: <20070810202630.GB25095@havoc.gtf.org>
References: <20070810202426.GA25050@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:42987 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757427AbXHJU0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:26:31 -0400
Content-Disposition: inline
In-Reply-To: <20070810202426.GA25050@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Driver-private flags.  Driver writer's guide will follow in a reply to this
patch.

commit 4901236cec047029b970261b95e47d6be60f523e
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Aug 10 15:52:06 2007 -0400

    [ETHTOOL] Introduce ->{get,set}_priv_flags, ETHTOOL_[GS]PFLAGS
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 include/linux/ethtool.h |    8 +++++++-
 net/core/ethtool.c      |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 1 deletion(-)

4901236cec047029b970261b95e47d6be60f523e
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index f617998..71d4ada 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -39,7 +39,8 @@ struct ethtool_drvinfo {
 	char	bus_info[ETHTOOL_BUSINFO_LEN];	/* Bus info for this IF. */
 				/* For PCI devices, use pci_name(pci_dev). */
 	char	reserved1[32];
-	char	reserved2[16];
+	char	reserved2[12];
+	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
 	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
 	__u32	testinfo_len;
 	__u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM (bytes) */
@@ -219,6 +220,7 @@ struct ethtool_pauseparam {
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
 	ETH_SS_STATS,
+	ETH_SS_PRIV_FLAGS,
 };
 
 /* for passing string sets for data tagging */
@@ -386,6 +388,8 @@ struct ethtool_ops {
 	int     (*set_ufo)(struct net_device *, u32);
 	u32     (*get_flags)(struct net_device *);
 	int     (*set_flags)(struct net_device *, u32);
+	u32     (*get_priv_flags)(struct net_device *);
+	int     (*set_priv_flags)(struct net_device *, u32);
 	int	(*get_sset_count)(struct net_device *, int);
 
 	/* the following hooks are obsolete */
@@ -434,6 +438,8 @@ struct ethtool_ops {
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 #define ETHTOOL_GFLAGS		0x00000025 /* Get flags bitmap(ethtool_value) */
 #define ETHTOOL_SFLAGS		0x00000026 /* Set flags bitmap(ethtool_value) */
+#define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
+#define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 2b366a5..f721e38 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -188,6 +188,9 @@ static int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 		rc = ops->get_sset_count(dev, ETH_SS_STATS);
 		if (rc >= 0)
 			info.n_stats = rc;
+		rc = ops->get_sset_count(dev, ETH_SS_PRIV_FLAGS);
+		if (rc >= 0)
+			info.n_priv_flags = rc;
 	} else {
 		/* code path for obsolete hooks */
 
@@ -881,6 +884,33 @@ static int ethtool_set_flags(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_flags(dev, edata.data);
 }
 
+static int ethtool_get_priv_flags(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GPFLAGS };
+
+	if (!dev->ethtool_ops->get_priv_flags)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->ethtool_ops->get_priv_flags(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_priv_flags(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->set_priv_flags)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_priv_flags(dev, edata.data);
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct ifreq *ifr)
@@ -915,6 +945,8 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_GPERMADDR:
 	case ETHTOOL_GUFO:
 	case ETHTOOL_GGSO:
+	case ETHTOOL_GFLAGS:
+	case ETHTOOL_GPFLAGS:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -1039,6 +1071,12 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SFLAGS:
 		rc = ethtool_set_flags(dev, useraddr);
 		break;
+	case ETHTOOL_GPFLAGS:
+		rc = ethtool_get_priv_flags(dev, useraddr);
+		break;
+	case ETHTOOL_SPFLAGS:
+		rc = ethtool_set_priv_flags(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
