From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 1/3] ethtool: Add phy statistics
Date: Sun, 27 Dec 2015 12:58:26 +0100
Message-ID: <1451217508-22276-2-git-send-email-andrew@lunn.ch>
References: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50856 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873AbbL0L6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2015 06:58:53 -0500
In-Reply-To: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet PHYs can maintain statistics, for example errors while idle
and receive errors. Add an ethertool mechanism to retrieve these
statistics, using the same model as MAC statistics.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/phy.c        | 35 +++++++++++++++++++++++++++
 include/linux/phy.h          | 11 ++++++++-
 include/uapi/linux/ethtool.h |  3 +++
 net/core/ethtool.c           | 57 +++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 104 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 47cd306dbb3c..fc6a770adf40 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1262,3 +1262,38 @@ void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
 		phydev->drv->get_wol(phydev, wol);
 }
 EXPORT_SYMBOL(phy_ethtool_get_wol);
+
+int phy_get_sset_count(struct phy_device *phydev)
+{
+	int ret;
+
+	if (phydev->drv->get_sset_count &&
+	    phydev->drv->get_strings &&
+	    phydev->drv->get_stats) {
+		mutex_lock(&phydev->lock);
+		ret = phydev->drv->get_sset_count(phydev);
+		mutex_unlock(&phydev->lock);
+
+		return ret;
+	}
+
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL(phy_get_sset_count);
+
+void phy_get_strings(struct phy_device *phydev, u8 *data)
+{
+	mutex_lock(&phydev->lock);
+	phydev->drv->get_strings(phydev, data);
+	mutex_unlock(&phydev->lock);
+}
+EXPORT_SYMBOL(phy_get_strings);
+
+void phy_get_stats(struct phy_device *phydev, struct ethtool_stats *stats,
+		   u64 *data)
+{
+	mutex_lock(&phydev->lock);
+	phydev->drv->get_stats(phydev, stats, data);
+	mutex_unlock(&phydev->lock);
+}
+EXPORT_SYMBOL(phy_get_stats);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 05fde31b6dc6..d457c6efbbd5 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -589,6 +589,12 @@ struct phy_driver {
 	int (*module_eeprom)(struct phy_device *dev,
 			     struct ethtool_eeprom *ee, u8 *data);
 
+	/* Get statistics from the phy using ethtool */
+	int (*get_sset_count)(struct phy_device *dev);
+	void (*get_strings)(struct phy_device *dev, u8 *data);
+	void (*get_stats)(struct phy_device *dev,
+			  struct ethtool_stats *stats, u64 *data);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
@@ -816,7 +822,10 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data);
 int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
 void phy_ethtool_get_wol(struct phy_device *phydev,
 			 struct ethtool_wolinfo *wol);
-
+int phy_get_sset_count(struct phy_device *phydev);
+void phy_get_strings(struct phy_device *phydev, u8 *data);
+void phy_get_stats(struct phy_device *phydev, struct ethtool_stats *stats,
+		   u64 *data);
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
 
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index cd1629170103..57fa39005e79 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -542,6 +542,7 @@ struct ethtool_pauseparam {
  *	now deprecated
  * @ETH_SS_FEATURES: Device feature names
  * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
+ * @ETH_SS_PHY_STATS: Statistic names, for use with %ETHTOOL_GPHYSTATS
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -551,6 +552,7 @@ enum ethtool_stringset {
 	ETH_SS_FEATURES,
 	ETH_SS_RSS_HASH_FUNCS,
 	ETH_SS_TUNABLES,
+	ETH_SS_PHY_STATS,
 };
 
 /**
@@ -1225,6 +1227,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
+#define ETHTOOL_GPHYSTATS	0x0000004a /* get PHY-specific statistics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 09948a726347..ee88bc06ccaf 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -204,6 +204,13 @@ static int __ethtool_get_sset_count(struct net_device *dev, int sset)
 	if (sset == ETH_SS_TUNABLES)
 		return ARRAY_SIZE(tunable_strings);
 
+	if (sset == ETH_SS_PHY_STATS) {
+		if (IS_ENABLED(CONFIG_PHYLIB) && dev->phydev)
+			return phy_get_sset_count(dev->phydev);
+		else
+			return -EOPNOTSUPP;
+	}
+
 	if (ops->get_sset_count && ops->get_strings)
 		return ops->get_sset_count(dev, sset);
 	else
@@ -223,7 +230,12 @@ static void __ethtool_get_strings(struct net_device *dev,
 		       sizeof(rss_hash_func_strings));
 	else if (stringset == ETH_SS_TUNABLES)
 		memcpy(data, tunable_strings, sizeof(tunable_strings));
-	else
+	else if (stringset == ETH_SS_PHY_STATS) {
+		if (IS_ENABLED(CONFIG_PHYLIB) && dev->phydev)
+			phy_get_strings(dev->phydev, data);
+		else
+			return;
+	} else
 		/* ops->get_strings is valid because checked earlier */
 		ops->get_strings(dev, stringset, data);
 }
@@ -1401,6 +1413,45 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 	return ret;
 }
 
+static int ethtool_get_phy_stats(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_stats stats;
+	struct phy_device *phydev = dev->phydev;
+	u64 *data;
+	int ret, n_stats;
+
+	if (!IS_ENABLED(CONFIG_PHYLIB) || !phydev)
+		return -EOPNOTSUPP;
+
+	n_stats = phy_get_sset_count(phydev);
+
+	if (n_stats < 0)
+		return n_stats;
+	WARN_ON(n_stats == 0);
+
+	if (copy_from_user(&stats, useraddr, sizeof(stats)))
+		return -EFAULT;
+
+	stats.n_stats = n_stats;
+	data = kmalloc_array(n_stats, sizeof(u64), GFP_USER);
+	if (!data)
+		return -ENOMEM;
+
+	phy_get_stats(phydev, &stats, data);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &stats, sizeof(stats)))
+		goto out;
+	useraddr += sizeof(stats);
+	if (copy_to_user(useraddr, data, stats.n_stats * sizeof(u64)))
+		goto out;
+	ret = 0;
+
+ out:
+	kfree(data);
+	return ret;
+}
+
 static int ethtool_get_perm_addr(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_perm_addr epaddr;
@@ -1779,6 +1830,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GSSET_INFO:
 	case ETHTOOL_GSTRINGS:
 	case ETHTOOL_GSTATS:
+	case ETHTOOL_GPHYSTATS:
 	case ETHTOOL_GTSO:
 	case ETHTOOL_GPERMADDR:
 	case ETHTOOL_GUFO:
@@ -1991,6 +2043,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_STUNABLE:
 		rc = ethtool_set_tunable(dev, useraddr);
 		break;
+	case ETHTOOL_GPHYSTATS:
+		rc = ethtool_get_phy_stats(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.6.4
