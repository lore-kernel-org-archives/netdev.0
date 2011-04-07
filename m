From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv4 NEXT 1/1] net: ethtool support to configure number of channels
Date: Thu,  7 Apr 2011 04:58:42 -0700
Message-ID: <1302177522-17815-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	sucheta.chakraborty@qlogic.com, anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:8578 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755881Ab1DGL6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 07:58:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethtool support to configure RX, TX and other channels. combined field
in struct ethtool_channels to reflect set of channel (RX, TX or other).
Other channel can be link interrupts, SR-IOV coordination etc.

ETHTOOL_GCHANNELS will report max and current number of RX channels,
max and current number of TX channels, max and current number of other channel
or max and current number of combined channel.

Number of channel can be modify upto max number of channel through
ETHTOOL_SCHANNELS command.

Ben Hutchings:
o define 'combined' and 'other' types.  Most multiqueue drivers pair up RX and TX
  queues so that most channels combine RX and TX work.
o Please could you use a kernel-doc comment to describe the structure.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 include/linux/ethtool.h |   36 ++++++++++++++++++++++++++++++++++++
 net/core/ethtool.c      |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c04d131..9b2d554 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -229,6 +229,34 @@ struct ethtool_ringparam {
 	__u32	tx_pending;
 };
 
+/**
+ * struct ethtool_channels - configuring number of network channel
+ * @cmd: ETHTOOL_{G,S}CHANNELS
+ * @max_rx: Read only. Maximum number of receive channel the driver support.
+ * @max_tx: Read only. Maximum number of transmit channel the driver support.
+ * @max_other: Read only. Maximum number of other channel the driver support.
+ * @max_combined: Read only. Maximum number of combined channel the driver
+ *	support. Set of queues RX, TX or other.
+ * @rx_count: Valid values are in the range 1 to the max_rx.
+ * @tx_count: Valid values are in the range 1 to the max_tx.
+ * @other_count: Valid values are in the range 1 to the max_other.
+ * @combined_count: Valid values are in the range 1 to the max_combined.
+ *
+ * This can be used to configure RX, TX and other channels.
+ */
+
+struct ethtool_channels {
+	__u32	cmd;
+	__u32	max_rx;
+	__u32	max_tx;
+	__u32	max_other;
+	__u32	max_combined;
+	__u32	rx_count;
+	__u32	tx_count;
+	__u32	other_count;
+	__u32	combined_count;
+};
+
 /* for configuring link flow control parameters */
 struct ethtool_pauseparam {
 	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
@@ -809,6 +837,9 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  *	Returns a negative error code or zero.
  * @set_rxfh_indir: Set the contents of the RX flow hash indirection table.
  *	Returns a negative error code or zero.
+ * @get_channels: Get number of channels.
+ * @set_channels: Set number of channels.  Returns a negative error code or
+ *	zero.
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
@@ -882,6 +913,9 @@ struct ethtool_ops {
 				  struct ethtool_rxfh_indir *);
 	int	(*set_rxfh_indir)(struct net_device *,
 				  const struct ethtool_rxfh_indir *);
+	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
+	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
+
 };
 #endif /* __KERNEL__ */
 
@@ -950,6 +984,8 @@ struct ethtool_ops {
 
 #define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
+#define ETHTOOL_GCHANNELS	0x0000003c /* Get no of channels */
+#define ETHTOOL_SCHANNELS	0x0000003d /* Set no of channels */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1b7fa98..456d736 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1443,6 +1443,35 @@ static int ethtool_set_ringparam(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_ringparam(dev, &ringparam);
 }
 
+static noinline_for_stack int ethtool_get_channels(struct net_device *dev,
+						   void __user *useraddr)
+{
+	struct ethtool_channels channels = { .cmd = ETHTOOL_GCHANNELS };
+
+	if (!dev->ethtool_ops->get_channels)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_channels(dev, &channels);
+
+	if (copy_to_user(useraddr, &channels, sizeof(channels)))
+		return -EFAULT;
+	return 0;
+}
+
+static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
+						   void __user *useraddr)
+{
+	struct ethtool_channels channels;
+
+	if (!dev->ethtool_ops->set_channels)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&channels, useraddr, sizeof(channels)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_channels(dev, &channels);
+}
+
 static int ethtool_get_pauseparam(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_pauseparam pauseparam = { ETHTOOL_GPAUSEPARAM };
@@ -2004,6 +2033,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SGRO:
 		rc = ethtool_set_one_feature(dev, useraddr, ethcmd);
 		break;
+	case ETHTOOL_GCHANNELS:
+		rc = ethtool_get_channels(dev, useraddr);
+		break;
+	case ETHTOOL_SCHANNELS:
+		rc = ethtool_set_channels(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.3.2

