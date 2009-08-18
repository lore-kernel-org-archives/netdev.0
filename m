From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [net-next-2.6 PATCH] net/ethtool: Add support for the ethtool
	feature to flash firmware image from a specified file.
Date: Tue, 18 Aug 2009 16:55:49 +0530
Message-ID: <20090818112526.GA22088@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:13377 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758059AbZHRLZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 07:25:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to flash a firmware image to a device using ethtool.
The driver gets the filename of the firmware image and flashes the image
using the request firmware path.

The region to be flashed - like redboot, phy will also be passed to the driver.
More options for other flash regions can be added in future.
The default behavior is to flash all the regions on the chip.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 include/linux/ethtool.h |   15 +++++++++++++++
 net/core/ethtool.c      |   17 +++++++++++++++++
 2 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 90c4a36..7a5800e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -362,6 +362,19 @@ struct ethtool_rxnfc {
 	__u32				rule_locs[0];
 };
 
+enum ethtool_flash_op_type {
+	ETHTOOL_FLASH_ALL		= 0,
+	ETHTOOL_FLASH_PHY,
+	ETHTOOL_FLASH_REDBOOT,
+};
+
+/* for passing firmware flashing related parameters */
+struct ethtool_flash {
+	__u32	cmd;
+	__u32	op_type;
+	char	data[256];
+};
+
 #ifdef __KERNEL__
 
 struct net_device;
@@ -489,6 +502,7 @@ struct ethtool_ops {
 	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
 	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
+	int     (*flash_device)(struct net_device *, u8 *, u32);
 };
 #endif /* __KERNEL__ */
 
@@ -545,6 +559,7 @@ struct ethtool_ops {
 #define	ETHTOOL_GRXCLSRLALL	0x00000030 /* Get all RX classification rule */
 #define	ETHTOOL_SRXCLSRLDEL	0x00000031 /* Delete RX classification rule */
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
+#define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 44e5711..fbdaade 100644
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
+	return dev->ethtool_ops->flash_device(dev, &efl.data, efl.op_type);
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

