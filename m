From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [RFC][PATCH][v4] net/ethtool: Add support for the ethtool feature
	to flash firmware image from a specified file.
Date: Thu, 20 Aug 2009 22:46:43 +0530
Message-ID: <20090820171631.GA19783@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:8873 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754835AbZHTRQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 13:16:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to flash a firmware image to a device using ethtool.
The driver gets the filename of the firmware image and flashes the image
using the request firmware path.

The region "on the chip" to be flashed can be specified by an option.
It is upto the device driver to enumerate the region number passed by ethtool,
to the region to be flashed.

The default behavior is to flash all the regions on the chip.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 include/linux/ethtool.h |   14 ++++++++++++++
 net/core/ethtool.c      |   17 +++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 90c4a36..7614267 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -362,6 +362,18 @@ struct ethtool_rxnfc {
 	__u32				rule_locs[0];
 };
 
+#define ETHTOOL_FLASH_MAX_FILENAME	128
+enum ethtool_flash_op_type {
+	ETHTOOL_FLASH_ALL_REGIONS	= 0,
+};
+
+/* for passing firmware flashing related parameters */
+struct ethtool_flash {
+	__u32	cmd;
+	__u32	region;
+	char	data[ETHTOOL_FLASH_MAX_FILENAME];
+};
+
 #ifdef __KERNEL__
 
 struct net_device;
@@ -489,6 +501,7 @@ struct ethtool_ops {
 	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
 	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
+	int     (*flash_device)(struct net_device *, u8 *);
 };
 #endif /* __KERNEL__ */
 
@@ -545,6 +558,7 @@ struct ethtool_ops {
 #define	ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
 #define	ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
+#define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 44e5711..fbcd9f7 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -898,6 +898,20 @@ static int ethtool_set_value(struct net_device *dev, char __user *useraddr,
 	return actor(dev, edata.data);
 }
 
+static int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
+{
+	int err;
+	struct ethtool_flash efl;
+
+	if (copy_from_user(&efl, useraddr, sizeof(efl)))
+		return -EFAULT;
+
+	if (!dev->ethtool_ops->flash_device)
+		return -EOPNOTSUPP;
+
+	return dev->ethtool_ops->flash_device(dev, &efl);
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1111,6 +1125,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SGRO:
 		rc = ethtool_set_gro(dev, useraddr);
 		break;
+	case ETHTOOL_FLASHDEV:
+		rc = ethtool_flash_device(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.6.0.4

