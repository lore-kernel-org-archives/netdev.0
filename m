From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/2] net: ethtool: Add support for PHY packet generators
Date: Wed, 17 Feb 2016 21:32:06 +0100
Message-ID: <1455741127-25453-2-git-send-email-andrew@lunn.ch>
References: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50597 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964970AbcBQUcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 15:32:14 -0500
In-Reply-To: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some PHY devices contain a simple packet generator. Features vary, but
often they can be used to generate packets of different sizes,
different contents, with or without errors, and with different inter
packet gaps. Add support to the core ethtool code to support this.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/linux/phy.h          |  4 ++++
 include/uapi/linux/ethtool.h | 26 ++++++++++++++++++++++++++
 net/core/ethtool.c           | 22 ++++++++++++++++++++++
 3 files changed, 52 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index d6f3641e7933..f7770c687b4e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -589,6 +589,10 @@ struct phy_driver {
 	void (*get_strings)(struct phy_device *dev, u8 *data);
 	void (*get_stats)(struct phy_device *dev,
 			  struct ethtool_stats *stats, u64 *data);
+
+	/* Make use of the PHY packet generator */
+	int (*pkt_gen)(struct phy_device *dev,
+		       struct ethtool_phy_pkt_gen *pkt_gen);
 };
 #define to_phy_driver(d) container_of(to_mdio_common_driver(d),		\
 				      struct phy_driver, mdiodrv)
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 190aea0faaf4..bce6c95f458c 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1167,6 +1167,31 @@ struct ethtool_ts_info {
 	__u32	rx_reserved[3];
 };
 
+enum ethtool_phy_pkg_gen_flags {
+	ETH_PKT_RANDOM	= (1 << 0),
+	ETH_PKT_ERROR	= (1 << 1),
+};
+
+/**
+ * struct ethtool_phy_pkt_get - command to request the phy to generate packets.
+ * @cmd: command number = %ETHTOOL_PHY_PKT_GEN
+ * @count: number of packets to generate
+ * @len: length of generated packets
+ * @ipg: inter packet gap in bytes.
+ * @flags: a bitmask of flags from &enum ethtool_phy_pkg_gen_flags
+ *
+ * PHY drivers may not support all of these parameters. If the
+ * requested parameter value cannot be supported an error should be
+ * returned.
+ */
+struct ethtool_phy_pkt_gen {
+	__u32	cmd;
+	__u32	count;
+	__u32	len;
+	__u32	ipg;
+	__u32	flags;
+};
+
 /*
  * %ETHTOOL_SFEATURES changes features present in features[].valid to the
  * values of corresponding bits in features[].requested. Bits in .requested
@@ -1284,6 +1309,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 #define ETHTOOL_GPHYSTATS	0x0000004a /* get PHY-specific statistics */
+#define ETHTOOL_PHY_PKT_GEN	0x0000004b /* Gnerate packets in the PHY */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c2d3118b1395..d5e8cd6a26e9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1541,6 +1541,25 @@ static int ethtool_get_phy_stats(struct net_device *dev, void __user *useraddr)
 	return ret;
 }
 
+static int ethtool_phy_pkt_gen(struct net_device *dev, void __user *useraddr)
+{
+	struct phy_device *phydev = dev->phydev;
+	struct ethtool_phy_pkt_gen pkt_gen;
+	int err;
+
+	if (!phydev || !phydev->drv->pkt_gen)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&pkt_gen, useraddr, sizeof(pkt_gen)))
+		return -EFAULT;
+
+	mutex_lock(&phydev->lock);
+	err = phydev->drv->pkt_gen(phydev, &pkt_gen);
+	mutex_unlock(&phydev->lock);
+
+	return err;
+}
+
 static int ethtool_get_perm_addr(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_perm_addr epaddr;
@@ -2135,6 +2154,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GPHYSTATS:
 		rc = ethtool_get_phy_stats(dev, useraddr);
 		break;
+	case ETHTOOL_PHY_PKT_GEN:
+		rc = ethtool_phy_pkt_gen(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
2.7.0
