From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 1/1] net: ethtool support to configure number of channels
Date: Fri,  1 Apr 2011 21:51:15 -0700
Message-ID: <1301719875-24888-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:8392 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750865Ab1DBEvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 00:51:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Instead of cluttering struct ethtool_channels, defined channel type in
  struct ethtool_channels, making it scalable for addition future channels.
  Application needs to send different ioctl for each channel type.
o There exist ETHTOOL_GRXRINGS command for getting number of RX rings,
  but it is tigtly coupled with RX flow hash configuration.
o New channel id can be added in ethtool_channel_id to make it configurable.
o Patches for qlcnic and netxen_nic driver supporting rx channel will follow
  soon.
o This patch is reworked on Ben Hutchings "ethtool: NUMA affinity control" patch,
  dropping the affinity control from it.

Ben Hutching:
o define 'combined' and 'other' types.  Most multiqueue drivers pair up RX and TX
  queues so that most channels combine RX and TX work.
o Please could you use a kernel-doc comment to describe the structure.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 include/linux/ethtool.h |   41 +++++++++++++++++++++++++++++++++++++++++
 net/core/ethtool.c      |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c8fcbdd..3c4d968 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -229,6 +229,42 @@ struct ethtool_ringparam {
 	__u32	tx_pending;
 };
 
+/**
+ * struct ethtool_channels - configuring number of network channel
+ * @cmd: ETHTOOL_{G,S}CHANNELS
+ * @type: Channel type defined in ethtool_channel_type
+ * @max_XX: Read only. Maximum number of channel the driver support
+ * @XX_count: Valid values are in the range 1 to the "max_XX" counterpart above.
+ *
+ * This can be used to configure RX,TX and other channels.
+ */
+
+struct ethtool_channels {
+	__u32	cmd;
+	__u32	type;
+	__u32	max_rx;
+	__u32	max_tx;
+	__u32	max_other;
+	__u32	rx_count;
+	__u32	tx_count;
+	__u32	other_count;
+};
+
+/* Channel type */
+/* Channel type should be pass in type field of ethtool_channels.
+ * TYPE_ALL indicates set all channels to XX_count values.
+ * TYPE_RX and TYPE_TX is to get and set RX and TX channels correspondingly.
+ * TYPE_COMBINED is to set both RX and TX channels to rx_count and tx_count
+ * correspondingly. TYPE_OTHER is to configure other channel.
+ */
+enum ethtool_channel_type {
+	ETH_CHAN_TYPE_ALL	= 0,
+	ETH_CHAN_TYPE_RX,
+	ETH_CHAN_TYPE_TX,
+	ETH_CHAN_TYPE_COMBINED,
+	ETH_CHAN_TYPE_OTHER,
+};
+
 /* for configuring link flow control parameters */
 struct ethtool_pauseparam {
 	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
@@ -802,6 +838,9 @@ struct ethtool_ops {
 				  struct ethtool_rxfh_indir *);
 	int	(*set_rxfh_indir)(struct net_device *,
 				  const struct ethtool_rxfh_indir *);
+	int	(*get_channels)(struct net_device *, struct ethtool_channels *);
+	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
+
 };
 #endif /* __KERNEL__ */
 
@@ -870,6 +909,8 @@ struct ethtool_ops {
 
 #define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
+#define ETHTOOL_GCHANNELS	0x0000003c /* Get no of channels */
+#define ETHTOOL_SCHANNELS	0x0000003d /* Set no of channels */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 74ead9e..91c3c6d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1441,6 +1441,41 @@ static int ethtool_set_ringparam(struct net_device *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_ringparam(dev, &ringparam);
 }
 
+static noinline_for_stack int ethtool_get_channels(struct net_device *dev,
+						   void __user *useraddr)
+{
+	struct ethtool_channels channels;
+	int rc;
+
+	if (!dev->ethtool_ops->get_channels)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&channels, useraddr, sizeof(channels)))
+		return -EFAULT;
+
+	rc = dev->ethtool_ops->get_channels(dev, &channels);
+	if (rc)
+		return rc;
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
@@ -1953,6 +1988,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
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

