From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] net: ethtool support to configure number of RX rings
Date: Wed, 30 Mar 2011 03:59:34 -0700
Message-ID: <1301482774-2173-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:3535 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932128Ab1C3K7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2011 06:59:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Ethtool hook to configure number of RX rings.
o Implementation is scalable to support configuring TX rings.
o There exist ETHTOOL_GRXRINGS command for getting number of RX rings,
  but it is tigtly coupled with RX flow hash configuration.
o Patches for qlcnic and netxen_nic driver supporting this features
  will follow soon.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 include/linux/ethtool.h |   20 ++++++++++++++++++++
 net/core/ethtool.c      |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index aac3e2e..de0decd 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -226,6 +226,21 @@ struct ethtool_ringparam {
 	__u32	tx_pending;
 };
 
+/* for configuring number of RX ring */
+struct ethtool_ring {
+	__u32	cmd;	/* ETHTOOL_{G,S}RING */
+
+	/* Read only attributes.  These indicate the maximum number
+	 * of RX rings the driver will allow the user to set.
+	 */
+	__u32	rx_max;
+
+	/* Values changeable by the user.  The valid values are
+	 * in the range 1 to the "*_max" counterpart above.
+	 */
+	__u32	rx_pending;
+};
+
 /* for configuring link flow control parameters */
 struct ethtool_pauseparam {
 	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
@@ -764,6 +779,9 @@ struct ethtool_ops {
 				  struct ethtool_rxfh_indir *);
 	int	(*set_rxfh_indir)(struct net_device *,
 				  const struct ethtool_rxfh_indir *);
+	void	(*get_rings)(struct net_device *, struct ethtool_ring *);
+	int	(*set_rings)(struct net_device *, struct ethtool_ring *);
+
 };
 #endif /* __KERNEL__ */
 
@@ -832,6 +850,8 @@ struct ethtool_ops {
 
 #define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
+#define ETHTOOL_GRINGS		0x0000003c /* Get no of rings */
+#define ETHTOOL_SRINGS		0x0000003d /* Set no of rings */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..2d96b4d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1426,6 +1426,33 @@ static int ethtool_set_ringparam(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_ringparam(dev, &ringparam);
 }
 
+static int ethtool_get_rings(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_ring ring_val = { .cmd = ETHTOOL_GRINGS };
+
+	if (!dev->ethtool_ops->get_rings)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_rings(dev, &ring_val);
+
+	if (copy_to_user(useraddr, &ring_val, sizeof(ring_val)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_rings(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_ring ring_val;
+
+	if (!dev->ethtool_ops->set_rings)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&ring_val, useraddr, sizeof(ring_val)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_rings(dev, &ring_val);
+}
+
 static int ethtool_get_pauseparam(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_pauseparam pauseparam = { ETHTOOL_GPAUSEPARAM };
@@ -1935,6 +1962,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SGRO:
 		rc = ethtool_set_one_feature(dev, useraddr, ethcmd);
 		break;
+	case ETHTOOL_GRINGS:
+		rc = ethtool_get_rings(dev, useraddr);
+		break;
+	case ETHTOOL_SRINGS:
+		rc = ethtool_set_rings(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.3.2

