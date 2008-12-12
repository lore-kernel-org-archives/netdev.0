From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Fri, 12 Dec 2008 16:31:56 +1100
Message-ID: <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59010 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757960AbYLLFcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:32:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool: Add GGRO and SGRO ops

This patch adds the ethtool ops to enable and disable GRO.  It also
makes GRO depend on RX checksum offload much the same as how TSO
depends on SG support.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/ethtool.h |    2 +
 net/core/ethtool.c      |   53 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b4b038b..27c67a5 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -467,6 +467,8 @@ struct ethtool_ops {
 
 #define	ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
 #define	ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
+#define ETHTOOL_GGRO		0x0000002b /* Get GRO enable (ethtool_value) */
+#define ETHTOOL_SGRO		0x0000002c /* Set GRO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 14ada53..947710a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -528,6 +528,22 @@ static int ethtool_set_tx_csum(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->set_tx_csum(dev, edata.data);
 }
 
+static int ethtool_set_rx_csum(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->set_rx_csum)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	if (!edata.data && dev->ethtool_ops->set_sg)
+		dev->features &= ~NETIF_F_GRO;
+
+	return dev->ethtool_ops->set_rx_csum(dev, edata.data);
+}
+
 static int ethtool_set_sg(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata;
@@ -599,6 +615,34 @@ static int ethtool_set_gso(struct net_device *dev, char __user *useraddr)
 	return 0;
 }
 
+static int ethtool_get_gro(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GGRO };
+
+	edata.data = dev->features & NETIF_F_GRO;
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		 return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_gro(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	if (edata.data) {
+		if (!dev->ethtool_ops->get_rx_csum ||
+		    !dev->ethtool_ops->get_rx_csum(dev))
+			return -EINVAL;
+		dev->features |= NETIF_F_GRO;
+	} else
+		dev->features &= ~NETIF_F_GRO;
+
+	return 0;
+}
+
 static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_test test;
@@ -932,8 +976,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 				       dev->ethtool_ops->get_rx_csum);
 		break;
 	case ETHTOOL_SRXCSUM:
-		rc = ethtool_set_value(dev, useraddr,
-				       dev->ethtool_ops->set_rx_csum);
+		rc = ethtool_set_rx_csum(dev, useraddr);
 		break;
 	case ETHTOOL_GTXCSUM:
 		rc = ethtool_get_value(dev, useraddr, ethcmd,
@@ -1014,6 +1057,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SRXFH:
 		rc = ethtool_set_rxhash(dev, useraddr);
 		break;
+	case ETHTOOL_GGRO:
+		rc = ethtool_get_gro(dev, useraddr);
+		break;
+	case ETHTOOL_SGRO:
+		rc = ethtool_set_gro(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
