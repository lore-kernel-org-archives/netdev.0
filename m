From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/2] ethtool: Add support for control of RX
 flow hash indirection
Date: Wed, 30 Jun 2010 16:05:23 +0100
Message-ID: <1277910323.2082.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7871 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377Ab0F3PF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 11:05:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many NICs use an indirection table to map an RX flow hash value to one
of an arbitrary number of queues (not necessarily a power of 2).  It
can be useful to remove some queues from this indirection table so
that they are only used for flows that are specifically filtered
there.  It may also be useful to weight the mapping to account for
user processes with the same CPU-affinity as the RX interrupts.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   15 +++++++++
 net/core/ethtool.c      |   80 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 2c8af09..3b089d8 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -384,6 +384,15 @@ struct ethtool_rxnfc {
 	__u32				rule_locs[0];
 };
 
+struct ethtool_rxfh_indir {
+	__u32	cmd;
+	/* On entry, this is the array size of the user buffer.  On
+	 * return from ETHTOOL_GRXFHINDIR, this is the array size of
+	 * the hardware indirection table. */
+	__u32	size;
+	__u32	ring_index[0];	/* ring/queue index for each hash value */
+};
+
 struct ethtool_rx_ntuple_flow_spec {
 	__u32		 flow_type;
 	union {
@@ -576,6 +585,10 @@ struct ethtool_ops {
 	int	(*set_rx_ntuple)(struct net_device *,
 				 struct ethtool_rx_ntuple *);
 	int	(*get_rx_ntuple)(struct net_device *, u32 stringset, void *);
+	int	(*get_rxfh_indir)(struct net_device *,
+				  struct ethtool_rxfh_indir *);
+	int	(*set_rxfh_indir)(struct net_device *,
+				  const struct ethtool_rxfh_indir *);
 };
 #endif /* __KERNEL__ */
 
@@ -637,6 +650,8 @@ struct ethtool_ops {
 #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
 #define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
+#define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
+#define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a0f4964..d978096 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -376,6 +376,80 @@ err_out:
 	return ret;
 }
 
+static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *dev,
+						     void __user *useraddr)
+{
+	struct ethtool_rxfh_indir *indir;
+	u32 table_size;
+	size_t full_size;
+	int ret;
+
+	if (!dev->ethtool_ops->get_rxfh_indir)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&table_size,
+			   useraddr + offsetof(struct ethtool_rxfh_indir, size),
+			   sizeof(table_size)))
+		return -EFAULT;
+
+	if (table_size >
+	    (KMALLOC_MAX_SIZE - sizeof(*indir)) / sizeof(*indir->ring_index))
+		return -ENOMEM;
+	full_size = sizeof(*indir) + sizeof(*indir->ring_index) * table_size;
+	indir = kmalloc(full_size, GFP_USER);
+	if (!indir)
+		return -ENOMEM;
+
+	indir->cmd = ETHTOOL_GRXFHINDIR;
+	indir->size = table_size;
+	ret = dev->ethtool_ops->get_rxfh_indir(dev, indir);
+	if (ret)
+		goto out;
+
+	if (copy_to_user(useraddr, indir, full_size))
+		ret = -EFAULT;
+
+out:
+	kfree(indir);
+	return ret;
+}
+
+static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
+						     void __user *useraddr)
+{
+	struct ethtool_rxfh_indir *indir;
+	u32 table_size;
+	size_t full_size;
+	int ret;
+
+	if (!dev->ethtool_ops->set_rxfh_indir)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&table_size,
+			   useraddr + offsetof(struct ethtool_rxfh_indir, size),
+			   sizeof(table_size)))
+		return -EFAULT;
+
+	if (table_size >
+	    (KMALLOC_MAX_SIZE - sizeof(*indir)) / sizeof(*indir->ring_index))
+		return -ENOMEM;
+	full_size = sizeof(*indir) + sizeof(*indir->ring_index) * table_size;
+	indir = kmalloc(full_size, GFP_USER);
+	if (!indir)
+		return -ENOMEM;
+
+	if (copy_from_user(indir, useraddr, full_size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	ret = dev->ethtool_ops->set_rxfh_indir(dev, indir);
+
+out:
+	kfree(indir);
+	return ret;
+}
+
 static void __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
 			struct ethtool_rx_ntuple_flow_spec *spec,
 			struct ethtool_rx_ntuple_flow_spec_container *fsc)
@@ -1544,6 +1618,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GSSET_INFO:
 		rc = ethtool_get_sset_info(dev, useraddr);
 		break;
+	case ETHTOOL_GRXFHINDIR:
+		rc = ethtool_get_rxfh_indir(dev, useraddr);
+		break;
+	case ETHTOOL_SRXFHINDIR:
+		rc = ethtool_set_rxfh_indir(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

