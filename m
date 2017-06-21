From: Gal Pressman <galp@mellanox.com>
Subject: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Wed, 21 Jun 2017 16:04:44 +0300
Message-ID: <1498050286-17141-2-git-send-email-galp@mellanox.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34683 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751118AbdFUNFV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 09:05:21 -0400
In-Reply-To: <1498050286-17141-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, drivers can only tell whether the link is up/down through
ETHTOOL_GLINK callback, but no additional information is given in case
of link down.
This patch provides an infrastructure that allows drivers to hint
the user with the reason why the link is down, in order to ease the
debug process.

Reasons are separated to two types, generic and vendor specific.
Drivers can reply with a generic reason using the enums provided in this
patch (and the ones that will be added in the future), which will be
translated to strings by the userspace ethtool.
In case of a vendor specific reason (not suitable for most vendors),
drivers can reply with ETHTOOL_VENDOR_SPECIFIC reason, in this case the
vendor_reason field should be filled with a vendor specific status code
which will be parsed by the vendor specific userspace parser if one is
available.

This kind of information can save system administrators precious time
which will not be wasted trying to understand why the link won't go
up.

For example, when the cable is unplugged:
$ ethtool ethXX
...
Link detected: no (Cable unplugged)

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/ethtool.h      |  2 ++
 include/uapi/linux/ethtool.h | 33 +++++++++++++++++++++++++++++++++
 net/core/ethtool.c           | 24 ++++++++++++++++++++++++
 3 files changed, 59 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 83cc986..d472047 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -374,5 +374,7 @@ struct ethtool_ops {
 				      struct ethtool_link_ksettings *);
 	int	(*set_link_ksettings)(struct net_device *,
 				      const struct ethtool_link_ksettings *);
+	int	(*get_link_down_reason)(struct net_device *,
+					struct ethtool_link_down_reason *);
 };
 #endif /* _LINUX_ETHTOOL_H */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 7d4a594..8cf9d2c 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -550,6 +550,13 @@ struct ethtool_pauseparam {
 
 #define ETH_GSTRING_LEN		32
 
+struct ethtool_link_down_reason {
+	__u32	cmd;
+	__u32	reason;
+	__u32	vendor_reason;
+	__u32	reserved[4];
+};
+
 /**
  * enum ethtool_stringset - string set ID
  * @ETH_SS_TEST: Self-test result names, for use with %ETHTOOL_TEST
@@ -1331,6 +1338,8 @@ struct ethtool_per_queue_op {
 #define ETHTOOL_PHY_GTUNABLE	0x0000004e /* Get PHY tunable configuration */
 #define ETHTOOL_PHY_STUNABLE	0x0000004f /* Set PHY tunable configuration */
 
+#define ETHTOOL_GLINK_DOWN_RSN	0x00000050 /* Get link down reason */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
@@ -1766,4 +1775,28 @@ struct ethtool_link_settings {
 	 * __u32 map_lp_advertising[link_mode_masks_nwords];
 	 */
 };
+
+enum {
+	ETHTOOL_LINK_VENDOR_SPECIFIC = -1, /* Vendor specific issue provided in vendor_reason */
+	ETHTOOL_LINK_NO_ISSUE, /* No issue observed with link */
+	ETHTOOL_LINK_REASON_UNKNOWN, /* Unknown reason */
+	ETHTOOL_LINK_NETDEV_CARRIER_DOWN, /* Netdev carrier is down */
+	ETHTOOL_LINK_ADMIN_DOWN, /* Admin down */
+	ETHTOOL_LINK_AN_FAILED, /* Auto negotiation failed */
+	ETHTOOL_LINK_TRAINING_FAILED, /* Link training failed */
+	ETHTOOL_LINK_RMT_FAULT, /* Remote fault indication */
+	ETHTOOL_LINK_BAD_SIGNAL_INTEGRITY, /* Bad signal integrity */
+	ETHTOOL_LINK_CABLE_MISMATCH, /* Cable protocol mismatch */
+	ETHTOOL_LINK_INTERNAL_ERR, /* Internal error */
+	ETHTOOL_LINK_CABLE_UNPLUGGED, /* Cable unplugged */
+	ETHTOOL_LINK_UNSUPP_MODULE, /* Unsupported module */
+	ETHTOOL_LINK_I2C_BUS_ERR, /* I2C bus error */
+	ETHTOOL_LINK_UNSUPP_EEPROM, /* Unsupported EEPROM */
+	ETHTOOL_LINK_OVERTEMP, /* Over temperature */
+	ETHTOOL_LINK_PWR_BUDGET_EXC, /* Power budget exceeded */
+	ETHTOOL_LINK_MODULE_ADMIN_DOWN, /* Module admin down */
+
+	ETHTOOL_LINK_REASONS_COUNT
+};
+
 #endif /* _UAPI_LINUX_ETHTOOL_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 03111a2..b818ad4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2523,6 +2523,26 @@ static int set_phy_tunable(struct net_device *dev, void __user *useraddr)
 	return ret;
 }
 
+static int get_link_down_reason(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_link_down_reason ldr;
+	int ret;
+
+	if (!dev->ethtool_ops->get_link_down_reason)
+		return -EOPNOTSUPP;
+
+	memset(&ldr, 0, sizeof(ldr));
+	ldr.cmd = ETHTOOL_GLINK_DOWN_RSN;
+	ret = dev->ethtool_ops->get_link_down_reason(dev, &ldr);
+	if (ret)
+		return ret;
+
+	if (copy_to_user(useraddr, &ldr, sizeof(ldr)))
+		return -EFAULT;
+
+	return 0;
+}
+
 /* The main entry point in this file.  Called from net/core/dev_ioctl.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -2582,6 +2602,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GTUNABLE:
 	case ETHTOOL_PHY_GTUNABLE:
 	case ETHTOOL_GLINKSETTINGS:
+	case ETHTOOL_GLINK_DOWN_RSN:
 		break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -2793,6 +2814,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_PHY_STUNABLE:
 		rc = set_phy_tunable(dev, useraddr);
 		break;
+	case ETHTOOL_GLINK_DOWN_RSN:
+		rc = get_link_down_reason(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.7.4
