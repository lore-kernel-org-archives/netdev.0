From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v3 2/5] ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE
Date: Tue, 15 Nov 2016 11:20:01 +0100
Message-ID: <1479205204-27768-3-git-send-email-allan.nielsen@microsemi.com>
References: <1479205204-27768-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0075.outbound.protection.outlook.com ([104.47.38.75]:56128
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S941399AbcKOK2j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 05:28:39 -0500
In-Reply-To: <1479205204-27768-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Adding get_tunable/set_tunable function pointer to the phy_driver
structure, and uses these function pointers to implement the
ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE ioctls.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 include/linux/phy.h |  7 +++++
 net/core/ethtool.c  | 87 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 94 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 9880d73..3d35c36 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -611,6 +611,13 @@ struct phy_driver {
 	void (*get_strings)(struct phy_device *dev, u8 *data);
 	void (*get_stats)(struct phy_device *dev,
 			  struct ethtool_stats *stats, u64 *data);
+
+	/* Get and Set PHY tunables */
+	int (*get_tunable)(struct phy_device *dev,
+			   struct ethtool_tunable *tuna, void *data);
+	int (*set_tunable)(struct phy_device *dev,
+			    struct ethtool_tunable *tuna,
+			    const void *data);
 };
 #define to_phy_driver(d) container_of(to_mdio_common_driver(d),		\
 				      struct phy_driver, mdiodrv)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9774898..61aebdf 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -119,6 +119,11 @@ tunable_strings[__ETHTOOL_TUNABLE_COUNT][ETH_GSTRING_LEN] = {
 	[ETHTOOL_TX_COPYBREAK]	= "tx-copybreak",
 };
 
+static const char
+phy_tunable_strings[__ETHTOOL_PHY_TUNABLE_COUNT][ETH_GSTRING_LEN] = {
+	[ETHTOOL_ID_UNSPEC]     = "Unspec",
+};
+
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_gfeatures cmd = {
@@ -227,6 +232,9 @@ static int __ethtool_get_sset_count(struct net_device *dev, int sset)
 	if (sset == ETH_SS_TUNABLES)
 		return ARRAY_SIZE(tunable_strings);
 
+	if (sset == ETH_SS_PHY_TUNABLES)
+		return ARRAY_SIZE(phy_tunable_strings);
+
 	if (sset == ETH_SS_PHY_STATS) {
 		if (dev->phydev)
 			return phy_get_sset_count(dev->phydev);
@@ -253,6 +261,8 @@ static void __ethtool_get_strings(struct net_device *dev,
 		       sizeof(rss_hash_func_strings));
 	else if (stringset == ETH_SS_TUNABLES)
 		memcpy(data, tunable_strings, sizeof(tunable_strings));
+	else if (stringset == ETH_SS_PHY_TUNABLES)
+		memcpy(data, phy_tunable_strings, sizeof(phy_tunable_strings));
 	else if (stringset == ETH_SS_PHY_STATS) {
 		struct phy_device *phydev = dev->phydev;
 
@@ -2422,6 +2432,76 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
 	};
 }
 
+static int ethtool_phy_tunable_valid(const struct ethtool_tunable *tuna)
+{
+	switch (tuna->id) {
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int get_phy_tunable(struct net_device *dev, void __user *useraddr)
+{
+	int ret;
+	struct ethtool_tunable tuna;
+	struct phy_device *phydev = dev->phydev;
+	void *data;
+
+	if (!(phydev && phydev->drv && phydev->drv->get_tunable))
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&tuna, useraddr, sizeof(tuna)))
+		return -EFAULT;
+	ret = ethtool_phy_tunable_valid(&tuna);
+	if (ret)
+		return ret;
+	data = kmalloc(tuna.len, GFP_USER);
+	if (!data)
+		return -ENOMEM;
+	ret = phydev->drv->get_tunable(phydev, &tuna, data);
+	if (ret)
+		goto out;
+	useraddr += sizeof(tuna);
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, data, tuna.len))
+		goto out;
+	ret = 0;
+
+out:
+	kfree(data);
+	return ret;
+}
+
+static int set_phy_tunable(struct net_device *dev, void __user *useraddr)
+{
+	int ret;
+	struct ethtool_tunable tuna;
+	struct phy_device *phydev = dev->phydev;
+	void *data;
+
+	if (!(phydev && phydev->drv && phydev->drv->set_tunable))
+		return -EOPNOTSUPP;
+	if (copy_from_user(&tuna, useraddr, sizeof(tuna)))
+		return -EFAULT;
+	ret = ethtool_phy_tunable_valid(&tuna);
+	if (ret)
+		return ret;
+	data = kmalloc(tuna.len, GFP_USER);
+	if (!data)
+		return -ENOMEM;
+	useraddr += sizeof(tuna);
+	ret = -EFAULT;
+	if (copy_from_user(data, useraddr, tuna.len))
+		goto out;
+	ret = phydev->drv->set_tunable(phydev, &tuna, data);
+
+out:
+	kfree(data);
+	return ret;
+}
+
 /* The main entry point in this file.  Called from net/core/dev_ioctl.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -2479,6 +2559,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_TS_INFO:
 	case ETHTOOL_GEEE:
 	case ETHTOOL_GTUNABLE:
+	case ETHTOOL_PHY_GTUNABLE:
 		break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -2684,6 +2765,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SLINKSETTINGS:
 		rc = ethtool_set_link_ksettings(dev, useraddr);
 		break;
+	case ETHTOOL_PHY_GTUNABLE:
+		rc = get_phy_tunable(dev, useraddr);
+		break;
+	case ETHTOOL_PHY_STUNABLE:
+		rc = set_phy_tunable(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.7.3
