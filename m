From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [NET] ethtool: Add support for multiple queues
Date: Tue, 31 Jul 2007 13:21:48 -0700
Message-ID: <20070731202148.15794.99084.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57688 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757353AbXGaUVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 16:21:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 include/linux/ethtool.h |   23 +++++++++++++++++++++++
 net/core/ethtool.c      |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index ab9d688..aefd580 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -196,6 +196,23 @@ struct ethtool_ringparam {
 	__u32	tx_pending;
 };
 
+/* for configuring RX/TX queue count */
+struct ethtool_queueparam {
+	__u32	cmd;	/* ETHTOOL_{G,S}QUEUEPARAM */
+
+	/* Read only attributes.  These indicate the maximum number
+	 * of RX/TX queues the driver will allow the user to set.
+	 */
+	__u32	rx_max;
+	__u32	tx_max;
+
+	/* Values changeable by the user.  The valid values are
+	 * in the range 1 to the "*_max" counterpart above.
+	 */
+	__u32	rx;
+	__u32	tx;
+};
+
 /* for configuring link flow control parameters */
 struct ethtool_pauseparam {
 	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
@@ -295,6 +312,8 @@ int ethtool_op_set_lro(struct net_device *dev, u32 data);
  * set_coalesce: Set interrupt coalescing parameters
  * get_ringparam: Report ring sizes
  * set_ringparam: Set ring sizes
+ * get_queueparam: Report ring sizes
+ * set_queueparam: Set ring sizes
  * get_pauseparam: Report pause parameters
  * set_pauseparam: Set pause paramters
  * get_rx_csum: Report whether receive checksums are turned on or off
@@ -356,6 +375,8 @@ struct ethtool_ops {
 	int	(*set_coalesce)(struct net_device *, struct ethtool_coalesce *);
 	void	(*get_ringparam)(struct net_device *, struct ethtool_ringparam *);
 	int	(*set_ringparam)(struct net_device *, struct ethtool_ringparam *);
+	void	(*get_queueparam)(struct net_device *, struct ethtool_queueparam *);
+	int	(*set_queueparam)(struct net_device *, struct ethtool_queueparam *);
 	void	(*get_pauseparam)(struct net_device *, struct ethtool_pauseparam*);
 	int	(*set_pauseparam)(struct net_device *, struct ethtool_pauseparam*);
 	u32	(*get_rx_csum)(struct net_device *);
@@ -422,6 +443,8 @@ struct ethtool_ops {
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 #define ETHTOOL_GLRO		0x00000025 /* Get LRO enable (ethtool_value) */
 #define ETHTOOL_SLRO		0x00000026 /* Set LRO enable (ethtool_value) */
+#define ETHTOOL_GQUEUEPARAM	0x00000027 /* Get queue parameters */
+#define ETHTOOL_SQUEUEPARAM	0x00000028 /* Set queue parameters. */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 23ccaa1..f1a1234 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -443,6 +443,33 @@ static int ethtool_set_ringparam(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_ringparam(dev, &ringparam);
 }
 
+static int ethtool_get_queueparam(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_queueparam queueparam = { ETHTOOL_GQUEUEPARAM };
+
+	if (!dev->ethtool_ops->get_queueparam)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_queueparam(dev, &queueparam);
+
+	if (copy_to_user(useraddr, &queueparam, sizeof(queueparam)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_queueparam(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_queueparam queueparam;
+
+	if (!dev->ethtool_ops->set_queueparam)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&queueparam, useraddr, sizeof(queueparam)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_queueparam(dev, &queueparam);
+}
+
 static int ethtool_get_pauseparam(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_pauseparam pauseparam = { ETHTOOL_GPAUSEPARAM };
@@ -875,6 +902,7 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_GMSGLVL:
 	case ETHTOOL_GCOALESCE:
 	case ETHTOOL_GRINGPARAM:
+	case ETHTOOL_GQUEUEPARAM:
 	case ETHTOOL_GPAUSEPARAM:
 	case ETHTOOL_GRXCSUM:
 	case ETHTOOL_GTXCSUM:
@@ -946,6 +974,12 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SRINGPARAM:
 		rc = ethtool_set_ringparam(dev, useraddr);
 		break;
+	case ETHTOOL_GQUEUEPARAM:
+		rc = ethtool_get_queueparam(dev, useraddr);
+		break;
+	case ETHTOOL_SQUEUEPARAM:
+		rc = ethtool_set_queueparam(dev, useraddr);
+		break;
 	case ETHTOOL_GPAUSEPARAM:
 		rc = ethtool_get_pauseparam(dev, useraddr);
 		break;
