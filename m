From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH RFC 1/2] ethtool: Add get actual port speed
Date: Wed,  2 Nov 2016 17:35:13 +0200
Message-ID: <1478100914-23610-2-git-send-email-galp@mellanox.com>
References: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Cc: David Decotigny <decot@googlers.com>,
        Ben Hutchings <ben@decadent.org.uk>,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47729 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755791AbcKBPgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:36:48 -0400
In-Reply-To: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an additional actual speed field when using ethtool DEVNAME.
Actual speed will show the actual bandwidth exposed for the machine,
which may be different from the HCA operating speed.

Signed-off-by: Gal Pressman <galp@mellanox.com>
---
 include/linux/ethtool.h      |  1 +
 include/uapi/linux/ethtool.h |  2 ++
 net/core/ethtool.c           | 20 ++++++++++++++++++++
 3 files changed, 23 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9ded8c6..215baa1 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -311,6 +311,7 @@ struct ethtool_ops {
 	void	(*set_msglevel)(struct net_device *, u32);
 	int	(*nway_reset)(struct net_device *);
 	u32	(*get_link)(struct net_device *);
+	int	(*get_actual_speed)(struct net_device *);
 	int	(*get_eeprom_len)(struct net_device *);
 	int	(*get_eeprom)(struct net_device *,
 			      struct ethtool_eeprom *, u8 *);
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 099a420..63057a2 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1315,6 +1315,8 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
 #define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
 
+#define ETHTOOL_GASPD		0x0000004e /* Get port actual speed */
+
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9774898..a1921fd 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1516,6 +1516,22 @@ static int ethtool_get_link(struct net_device *dev, char __user *useraddr)
 	return 0;
 }
 
+static int ethtool_get_actual_speed(struct net_device *dev,
+				    char __user *useraddr)
+{
+	struct ethtool_value edata = { .cmd = ETHTOOL_GASPD };
+
+	if (!dev->ethtool_ops->get_actual_speed)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->ethtool_ops->get_actual_speed(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+
+	return 0;
+}
+
 static int ethtool_get_any_eeprom(struct net_device *dev, void __user *useraddr,
 				  int (*getter)(struct net_device *,
 						struct ethtool_eeprom *, u8 *),
@@ -2450,6 +2466,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GDRVINFO:
 	case ETHTOOL_GMSGLVL:
 	case ETHTOOL_GLINK:
+	case ETHTOOL_GASPD:
 	case ETHTOOL_GCOALESCE:
 	case ETHTOOL_GRINGPARAM:
 	case ETHTOOL_GPAUSEPARAM:
@@ -2531,6 +2548,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GLINK:
 		rc = ethtool_get_link(dev, useraddr);
 		break;
+	case ETHTOOL_GASPD:
+		rc = ethtool_get_actual_speed(dev, useraddr);
+		break;
 	case ETHTOOL_GEEPROM:
 		rc = ethtool_get_eeprom(dev, useraddr);
 		break;
-- 
2.7.4
