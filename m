From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 2/3] ethtool: NUMA affinity control
Date: Mon, 20 Sep 2010 13:45:53 +0100
Message-ID: <1284986753.2282.46.camel@achroite.uk.solarflarecom.com>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
	 <1283356463.2556.351.camel@edumazet-laptop>
	 <AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
	 <20100901.183251.106803238.davem@davemloft.net>
	 <1284673961.2283.57.camel@achroite.uk.solarflarecom.com>
	 <20100919172451.GA12878@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38792 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753105Ab0ITMp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 08:45:57 -0400
In-Reply-To: <20100919172451.GA12878@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define operations to get and set the numbers of channels belonging to
a net device.  A channel is defined as the combination of an IRQ and
all the queues that can trigger that IRQ.  Channels are identified by
type and index, similarly to the naming scheme used for IRQ handlers.

Define operations to get and set the NUMA affinity of objects
associated with a channel.
---
 include/linux/ethtool.h |   56 ++++++++++++++++
 net/core/ethtool.c      |  165 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 221 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b67af60..0eaae5d 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -517,6 +517,47 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
 
+/* Network channel information.  A network channel is the combination of
+ * an IRQ and all the queues that can trigger that IRQ. */
+struct ethtool_channels {
+	__u32	cmd;
+	__u32	combined_count;		/* number of multi-purpose channels */
+	__u32	rx_count;		/* number of RX-only channels */
+	__u32	tx_count;		/* number of TX-only channels */
+	__u32	other_count;		/* number of additional channels */
+};
+
+/* Channel ID is made up of a type and an index */
+enum ethtool_channel_id {
+	ETH_CHAN_INDEX_MASK	= 0x0fffffff,
+	ETH_CHAN_TYPE_MASK	= 0xc0000000,
+	ETH_CHAN_TYPE_COMBINED	= 0x00000000,
+	ETH_CHAN_TYPE_RX	= 0x40000000,
+	ETH_CHAN_TYPE_TX	= 0x80000000,
+	ETH_CHAN_TYPE_OTHER	= 0xc0000000,
+	ETH_CHAN_ALL		= 0xffffffff	/* special: operate on all */
+};
+
+/* Special NUMA node IDs */
+enum ethtool_numa_node {
+	ETH_NUMA_NODE_UNSET	= -1,	/* get/set: no affinity set */
+	ETH_NUMA_NODE_N_A	= -2,	/* get/set: not applicable; channel
+					 * doesn't have this object */
+	ETH_NUMA_NODE_IRQ	= -3,	/* set: match current IRQ affinity */
+	ETH_NUMA_NODE_DEV	= -4,	/* set: match device affinity */
+};
+
+struct ethtool_affinity {
+	__u32	cmd;
+	__u32	channel_id;		/* channel type and index; may be
+					 * ETH_CHAN_ALL when setting */
+	__s32	rx_ring_node;		/* affinity of RX descriptor ring */
+	__s32	tx_ring_node;		/* affinity of TX descriptor ring */
+	__s32	event_ring_node;	/* affinity of event/completion ring */
+	__s32	handler_data_node;	/* affinity of IRQ/NAPI handler's
+					 * software structures */
+};
+
 #ifdef __KERNEL__
 
 #include <linux/rculist.h>
@@ -551,6 +592,9 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data);
 u32 ethtool_op_get_flags(struct net_device *dev);
 int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);
 void ethtool_ntuple_flush(struct net_device *dev);
+#ifdef CONFIG_NUMA
+int ethtool_affinity_resolve(s32 node_id, struct net_device *dev, unsigned irq);
+#endif
 
 /**
  * &ethtool_ops - Alter and report network device settings
@@ -672,6 +716,14 @@ struct ethtool_ops {
 				  struct ethtool_rxfh_indir *);
 	int	(*set_rxfh_indir)(struct net_device *,
 				  const struct ethtool_rxfh_indir *);
+	int	(*get_channels)(struct net_device *, struct ethtool_channels *);
+	int	(*set_channels)(struct net_device *,
+				const struct ethtool_channels *);
+#ifdef CONFIG_NUMA
+	int	(*get_affinity)(struct net_device *, struct ethtool_affinity *);
+	int	(*set_affinity)(struct net_device *,
+				const struct ethtool_affinity *);
+#endif
 };
 #endif /* __KERNEL__ */
 
@@ -735,6 +787,10 @@ struct ethtool_ops {
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
+#define ETHTOOL_GCHANNELS	0x0000003a /* Get numbers of channels */
+#define ETHTOOL_SCHANNELS	0x0000003b /* Set numbers of channels */
+#define ETHTOOL_GAFFINITY	0x0000003c /* Get NUMA affinity */
+#define ETHTOOL_SAFFINITY	0x0000003d /* Set NUMA affinity */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 34fae15..753a186 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -20,6 +20,8 @@
 #include <linux/bitops.h>
 #include <linux/uaccess.h>
 #include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/numa.h>
 
 /*
  * Some useful ethtool_ops methods that're device independent.
@@ -1429,6 +1431,155 @@ static noinline_for_stack int ethtool_flash_device(struct net_device *dev,
 	return dev->ethtool_ops->flash_device(dev, &efl);
 }
 
+static noinline_for_stack int ethtool_get_channels(struct net_device *dev,
+						   char __user *useraddr)
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
+
+	return 0;
+}
+
+static noinline_for_stack int ethtool_set_channels(struct net_device *dev,
+						   char __user *useraddr)
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
+#ifdef CONFIG_NUMA
+
+static int ethtool_check_channel_id(struct net_device *dev, u32 channel_id)
+{
+	struct ethtool_channels channels;
+	u32 channel_count;
+	int rc;
+
+	if (!dev->ethtool_ops->get_channels)
+		return -EOPNOTSUPP;
+
+	memset(&channels, 0, sizeof(channels));
+	channels.cmd = ETHTOOL_GCHANNELS;
+	rc = dev->ethtool_ops->get_channels(dev, &channels);
+	if (rc)
+		return rc;
+
+	switch (channel_id & ETH_CHAN_TYPE_MASK) {
+	case ETH_CHAN_TYPE_COMBINED:
+		channel_count = channels.combined_count;
+		break;
+	case ETH_CHAN_TYPE_RX:
+		channel_count = channels.rx_count;
+		break;
+	case ETH_CHAN_TYPE_TX:
+		channel_count = channels.tx_count;
+		break;
+	case ETH_CHAN_TYPE_OTHER:
+	default:
+		channel_count = channels.other_count;
+		break;
+	}
+	if ((channel_id & ETH_CHAN_INDEX_MASK) >= channel_count)
+		return -EINVAL;
+
+	return 0;
+}
+
+static noinline_for_stack int ethtool_get_affinity(struct net_device *dev,
+						   char __user *useraddr)
+{
+	struct ethtool_affinity affin;
+	int rc;
+
+	if (!dev->ethtool_ops->get_affinity)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&affin, useraddr, sizeof(affin)))
+		return -EFAULT;
+
+	rc = ethtool_check_channel_id(dev, affin.channel_id);
+	if (rc)
+		return rc;
+
+	rc = dev->ethtool_ops->get_affinity(dev, &affin);
+	if (rc)
+		return rc;
+
+	if (copy_to_user(useraddr, &affin, sizeof(affin)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static noinline_for_stack int ethtool_set_affinity(struct net_device *dev,
+						   char __user *useraddr)
+{
+	struct ethtool_affinity affin;
+	int rc;
+
+	if (!dev->ethtool_ops->set_affinity)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&affin, useraddr, sizeof(affin)))
+		return -EFAULT;
+
+	if (affin.channel_id != ETH_CHAN_ALL) {
+		rc = ethtool_check_channel_id(dev, affin.channel_id);
+		if (rc)
+			return rc;
+	}
+
+	return dev->ethtool_ops->set_affinity(dev, &affin);
+}
+
+/**
+ * ethtool_affinity_resolve - resolve the NUMA node ID for a channel
+ * @node_id:		User-specified node ID
+ * @dev:		The channel's net device
+ * @irq:		The channel's IRQ
+ *
+ * This resolves the special node IDs %ETH_NUMA_NODE_IRQ,
+ * %ETH_NUMA_NODE_DEV and %ETH_NUMA_NODE_UNSET and validates that any
+ * other specified node ID is in the valid range.  It returns either a
+ * specific node ID, %NUMA_NO_NODE or a negative error code (less than
+ * %NUMA_NO_NODE).
+ */
+int ethtool_affinity_resolve(s32 node_id, struct net_device *dev, unsigned irq)
+{
+	if (node_id == ETH_NUMA_NODE_IRQ)
+		return irq_get_numa_node(irq);
+	if (node_id == ETH_NUMA_NODE_DEV && dev->dev.parent)
+		return dev_to_node(dev->dev.parent);
+	if (node_id == ETH_NUMA_NODE_UNSET)
+		return NUMA_NO_NODE;
+	if (node_id >= 0 && node_id < MAX_NUMNODES && nr_cpus_node(node_id))
+		return node_id;
+	return -EINVAL;
+}
+EXPORT_SYMBOL(ethtool_affinity_resolve);
+
+#endif /* CONFIG_NUMA */
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1673,6 +1824,20 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SRXFHINDIR:
 		rc = ethtool_set_rxfh_indir(dev, useraddr);
 		break;
+	case ETHTOOL_GCHANNELS:
+		rc = ethtool_get_channels(dev, useraddr);
+		break;
+	case ETHTOOL_SCHANNELS:
+		rc = ethtool_set_channels(dev, useraddr);
+		break;
+#ifdef CONFIG_NUMA
+	case ETHTOOL_GAFFINITY:
+		rc = ethtool_get_affinity(dev, useraddr);
+		break;
+	case ETHTOOL_SAFFINITY:
+		rc = ethtool_set_affinity(dev, useraddr);
+		break;
+#endif
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

