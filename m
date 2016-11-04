From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 2/5] ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE
Date: Fri, 4 Nov 2016 11:35:39 +0100
Message-ID: <1478255742-25693-3-git-send-email-allan.nielsen@microsemi.com>
References: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>,
        "Raju Lakkaraju" <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0062.outbound.protection.outlook.com ([104.47.37.62]:9920
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755134AbcKDKgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:36:25 -0400
In-Reply-To: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Adding get_tunable/set_tunable function pointer to the phy_driver
structure, and uses these function pointers to implement the
ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE ioctls.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 include/linux/phy.h |  7 +++++
 net/core/ethtool.c  | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index e7e1fd3..d30daf8 100644
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
index 9774898..75f19ab 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -2422,6 +2422,76 @@ static int ethtool_set_per_queue(struct net_device *dev, void __user *useraddr)
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
@@ -2479,6 +2549,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GET_TS_INFO:
 	case ETHTOOL_GEEE:
 	case ETHTOOL_GTUNABLE:
+	case ETHTOOL_PHY_GTUNABLE:
 		break;
 	default:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -2684,6 +2755,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
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
