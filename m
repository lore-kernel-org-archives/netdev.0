From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] ethtool: Introduce n-tuple filter
	programming support
Date: Thu, 04 Feb 2010 22:21:49 -0800
Message-ID: <20100205062131.20910.10580.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:35839 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932119Ab0BEGWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 01:22:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patchset enables the ethtool layer to program n-tuple
filters to an underlying device.  The idea is to allow capable
hardware to have static rules applied that can assist steering
flows into appropriate queues.

Hardware that is known to support these types of filters today
are ixgbe and niu.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/ethtool.h   |   49 +++++++
 include/linux/netdevice.h |    3 
 net/core/dev.c            |    9 +
 net/core/ethtool.c        |  335 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 395 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index ef4a2d8..446c91e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -14,6 +14,7 @@
 #define _LINUX_ETHTOOL_H
 
 #include <linux/types.h>
+#include <linux/rculist.h>
 
 /* This should work for both 32 and 64 bit userland. */
 struct ethtool_cmd {
@@ -242,6 +243,7 @@ enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
+	ETH_SS_NTUPLE_FILTERS,
 };
 
 /* for passing string sets for data tagging */
@@ -290,6 +292,7 @@ struct ethtool_perm_addr {
  */
 enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
+	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
 };
 
 /* The following structures are for supporting RX network flow
@@ -363,6 +366,47 @@ struct ethtool_rxnfc {
 	__u32				rule_locs[0];
 };
 
+struct ethtool_rx_ntuple_flow_spec {
+	__u32		 flow_type;
+	union {
+		struct ethtool_tcpip4_spec		tcp_ip4_spec;
+		struct ethtool_tcpip4_spec		udp_ip4_spec;
+		struct ethtool_tcpip4_spec		sctp_ip4_spec;
+		struct ethtool_ah_espip4_spec		ah_ip4_spec;
+		struct ethtool_ah_espip4_spec		esp_ip4_spec;
+		struct ethtool_rawip4_spec		raw_ip4_spec;
+		struct ethtool_ether_spec		ether_spec;
+		struct ethtool_usrip4_spec		usr_ip4_spec;
+		__u8					hdata[64];
+	} h_u, m_u; /* entry, mask */
+
+	__u16	        vlan_tag;
+	__u16	        vlan_tag_mask;
+	__u64		data;      /* user-defined flow spec data */
+	__u64		data_mask; /* user-defined flow spec mask */
+
+	/* signed to distinguish between queue and actions (DROP) */
+	__s32		action;
+#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
+};
+
+struct ethtool_rx_ntuple_flow_spec_container {
+	struct ethtool_rx_ntuple_flow_spec fs;
+	struct list_head list;
+};
+
+struct ethtool_rx_ntuple_list {
+#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
+#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
+	struct list_head	list;
+	int			count;
+};
+
+struct ethtool_rx_ntuple {
+	__u32					cmd;
+	struct ethtool_rx_ntuple_flow_spec	fs;
+};
+
 #define ETHTOOL_FLASH_MAX_FILENAME	128
 enum ethtool_flash_op_type {
 	ETHTOOL_FLASH_ALL_REGIONS	= 0,
@@ -500,6 +544,8 @@ struct ethtool_ops {
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
+	int	(*set_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *);
+	int	(*get_rx_ntuple)(struct net_device *, u32 stringset, void *);
 };
 #endif /* __KERNEL__ */
 
@@ -559,6 +605,9 @@ struct ethtool_ops {
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
 
+#define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
+#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e535700..cdf53a8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -746,6 +746,7 @@ struct net_device {
 #define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
 #define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
 #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
+#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -954,6 +955,8 @@ struct net_device {
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
+	/* n-tuple filter list attached to this device */
+	struct ethtool_rx_ntuple_list ethtool_ntuple_list;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 94c1eee..4593abe 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5419,6 +5419,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	netdev_init_queues(dev);
 
+	INIT_LIST_HEAD(&dev->ethtool_ntuple_list.list);
+	dev->ethtool_ntuple_list.count = 0;
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
@@ -5447,6 +5449,7 @@ EXPORT_SYMBOL(alloc_netdev_mq);
 void free_netdev(struct net_device *dev)
 {
 	struct napi_struct *p, *n;
+	struct ethtool_rx_ntuple_flow_spec_container *fsc, *f;
 
 	release_net(dev_net(dev));
 
@@ -5455,6 +5458,12 @@ void free_netdev(struct net_device *dev)
 	/* Flush device addresses */
 	dev_addr_flush(dev);
 
+	/* Clear ethtool n-tuple list */
+	list_for_each_entry_safe(fsc, f, &dev->ethtool_ntuple_list.list, list) {
+		list_del(&fsc->list);
+	}
+	dev->ethtool_ntuple_list.count = 0;
+
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d8aee58..fa703c6 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -120,7 +120,7 @@ int ethtool_op_set_ufo(struct net_device *dev, u32 data)
  * NETIF_F_xxx values in include/linux/netdevice.h
  */
 static const u32 flags_dup_features =
-	ETH_FLAG_LRO;
+	(ETH_FLAG_LRO | ETH_FLAG_NTUPLE);
 
 u32 ethtool_op_get_flags(struct net_device *dev)
 {
@@ -139,6 +139,11 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data)
 	else
 		dev->features &= ~NETIF_F_LRO;
 
+	if (data & ETH_FLAG_NTUPLE)
+		dev->features |= NETIF_F_NTUPLE;
+	else
+		dev->features &= ~NETIF_F_NTUPLE;
+
 	return 0;
 }
 
@@ -266,6 +271,313 @@ err_out:
 	return ret;
 }
 
+static int __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
+                                  struct ethtool_rx_ntuple_flow_spec *spec)
+{
+	struct ethtool_rx_ntuple_flow_spec_container *fsc;
+	int alloc_size;
+
+	/* don't add filters forever */
+	if (list->count >= ETHTOOL_MAX_NTUPLE_LIST_ENTRY)
+		return 0;
+
+	list_for_each_entry(fsc, &list->list, list) { /* run to end */ }
+
+	alloc_size = sizeof(*fsc);
+	if (alloc_size < L1_CACHE_BYTES)
+		alloc_size = L1_CACHE_BYTES;
+	fsc = kmalloc(alloc_size, GFP_ATOMIC);
+	if (!fsc)
+		return -ENOMEM;
+
+	/* Copy the whole filter over */
+	fsc->fs.flow_type = spec->flow_type;
+	memcpy(&fsc->fs.h_u, &spec->h_u, sizeof(spec->h_u));
+	memcpy(&fsc->fs.m_u, &spec->m_u, sizeof(spec->m_u));
+
+	fsc->fs.vlan_tag = spec->vlan_tag;
+	fsc->fs.vlan_tag_mask = spec->vlan_tag_mask;
+	fsc->fs.data = spec->data;
+	fsc->fs.data_mask = spec->data_mask;
+	fsc->fs.action = spec->action;
+
+	/* add to the list */
+	list_add_tail_rcu(&fsc->list, &list->list);
+	list->count++;
+
+	return 0;
+}
+
+static int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_rx_ntuple cmd;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	int ret;
+
+	if (!ops->set_rx_ntuple)
+		return -EOPNOTSUPP;
+
+	if (!(dev->features & NETIF_F_NTUPLE))
+		return -EINVAL;
+
+	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+		return -EFAULT;
+
+	ret = ops->set_rx_ntuple(dev, &cmd);
+
+	/*
+	 * Cache filter in dev struct for GET operation only if
+	 * the underlying driver doesn't have its own GET operation, and
+	 * only if the filter was added successfully.
+	 */
+	if (!ops->get_rx_ntuple && !ret)
+		if (__rx_ntuple_filter_add(&dev->ethtool_ntuple_list, &cmd.fs))
+			return -ENOMEM;
+
+	return ret;
+}
+
+static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_gstrings gstrings;
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct ethtool_rx_ntuple_flow_spec_container *fsc;
+	u8 *data;
+	char *p;
+	int ret, i, num_strings = 0;
+
+	if (!ops->get_sset_count)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
+		return -EFAULT;
+
+	ret = ops->get_sset_count(dev, gstrings.string_set);
+	if (ret < 0)
+		return ret;
+
+	gstrings.len = ret;
+
+	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
+	if (!data)
+		return -ENOMEM;
+
+	if (ops->get_rx_ntuple) {
+		/* driver-specific filter grab */
+		ret = ops->get_rx_ntuple(dev, gstrings.string_set, data);
+		goto copy;
+	}
+
+	/* default ethtool filter grab */
+	i = 0;
+	p = (char *)data;
+	list_for_each_entry(fsc, &dev->ethtool_ntuple_list.list, list) {
+		sprintf(p, "Filter %d:\n", i);
+		p += ETH_GSTRING_LEN;
+		num_strings++;
+
+		switch (fsc->fs.flow_type) {
+		case TCP_V4_FLOW:
+			sprintf(p, "\tFlow Type: TCP\n");
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case UDP_V4_FLOW:
+			sprintf(p, "\tFlow Type: UDP\n");
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case SCTP_V4_FLOW:
+			sprintf(p, "\tFlow Type: SCTP\n");
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case AH_ESP_V4_FLOW:
+			sprintf(p, "\tFlow Type: AH ESP\n");
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case ESP_V4_FLOW:
+			sprintf(p, "\tFlow Type: ESP\n");
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case IP_USER_FLOW:
+			sprintf(p, "\tFlow Type: Raw IP\n");
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case IPV4_FLOW:
+			sprintf(p, "\tFlow Type: IPv4\n");
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		default:
+			sprintf(p, "\tFlow Type: Unknown\n");
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			goto unknown_filter;
+		};
+
+		/* now the rest of the filters */
+		switch (fsc->fs.flow_type) {
+		case TCP_V4_FLOW:
+		case UDP_V4_FLOW:
+		case SCTP_V4_FLOW:
+			sprintf(p, "\tSrc IP addr: 0x%x\n",
+			        fsc->fs.h_u.tcp_ip4_spec.ip4src);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tSrc IP mask: 0x%x\n",
+			        fsc->fs.m_u.tcp_ip4_spec.ip4src);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest IP addr: 0x%x\n",
+			        fsc->fs.h_u.tcp_ip4_spec.ip4dst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest IP mask: 0x%x\n",
+			        fsc->fs.m_u.tcp_ip4_spec.ip4dst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tSrc Port: %d, mask: 0x%x\n",
+			        fsc->fs.h_u.tcp_ip4_spec.psrc,
+			        fsc->fs.m_u.tcp_ip4_spec.psrc);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest Port: %d, mask: 0x%x\n",
+			        fsc->fs.h_u.tcp_ip4_spec.pdst,
+			        fsc->fs.m_u.tcp_ip4_spec.pdst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
+			        fsc->fs.h_u.tcp_ip4_spec.tos,
+			        fsc->fs.m_u.tcp_ip4_spec.tos);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case AH_ESP_V4_FLOW:
+		case ESP_V4_FLOW:
+			sprintf(p, "\tSrc IP addr: 0x%x\n",
+			        fsc->fs.h_u.ah_ip4_spec.ip4src);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tSrc IP mask: 0x%x\n",
+			        fsc->fs.m_u.ah_ip4_spec.ip4src);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest IP addr: 0x%x\n",
+			        fsc->fs.h_u.ah_ip4_spec.ip4dst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest IP mask: 0x%x\n",
+			        fsc->fs.m_u.ah_ip4_spec.ip4dst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tSPI: %d, mask: 0x%x\n",
+			        fsc->fs.h_u.ah_ip4_spec.spi,
+			        fsc->fs.m_u.ah_ip4_spec.spi);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
+			        fsc->fs.h_u.ah_ip4_spec.tos,
+			        fsc->fs.m_u.ah_ip4_spec.tos);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case IP_USER_FLOW:
+			sprintf(p, "\tSrc IP addr: 0x%x\n",
+			        fsc->fs.h_u.raw_ip4_spec.ip4src);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tSrc IP mask: 0x%x\n",
+			        fsc->fs.m_u.raw_ip4_spec.ip4src);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest IP addr: 0x%x\n",
+			        fsc->fs.h_u.raw_ip4_spec.ip4dst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest IP mask: 0x%x\n",
+			        fsc->fs.m_u.raw_ip4_spec.ip4dst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		case IPV4_FLOW:
+			sprintf(p, "\tSrc IP addr: 0x%x\n",
+			        fsc->fs.h_u.usr_ip4_spec.ip4src);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tSrc IP mask: 0x%x\n",
+			        fsc->fs.m_u.usr_ip4_spec.ip4src);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest IP addr: 0x%x\n",
+			        fsc->fs.h_u.usr_ip4_spec.ip4dst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tDest IP mask: 0x%x\n",
+			        fsc->fs.m_u.usr_ip4_spec.ip4dst);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tL4 bytes: 0x%x, mask: 0x%x\n",
+			        fsc->fs.h_u.usr_ip4_spec.l4_4_bytes,
+			        fsc->fs.m_u.usr_ip4_spec.l4_4_bytes);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
+			        fsc->fs.h_u.usr_ip4_spec.tos,
+			        fsc->fs.m_u.usr_ip4_spec.tos);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tIP Version: %d, mask: 0x%x\n",
+			        fsc->fs.h_u.usr_ip4_spec.ip_ver,
+			        fsc->fs.m_u.usr_ip4_spec.ip_ver);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			sprintf(p, "\tProtocol: %d, mask: 0x%x\n",
+			        fsc->fs.h_u.usr_ip4_spec.proto,
+			        fsc->fs.m_u.usr_ip4_spec.proto);
+			p += ETH_GSTRING_LEN;
+			num_strings++;
+			break;
+		};
+		sprintf(p, "\tVLAN: %d, mask: 0x%x\n",
+		        fsc->fs.vlan_tag, fsc->fs.vlan_tag_mask);
+		p += ETH_GSTRING_LEN;
+		num_strings++;
+		sprintf(p, "\tUser-defined: 0x%Lx\n", fsc->fs.data);
+		p += ETH_GSTRING_LEN;
+		num_strings++;
+		sprintf(p, "\tUser-defined mask: 0x%Lx\n", fsc->fs.data_mask);
+		p += ETH_GSTRING_LEN;
+		num_strings++;
+		if (fsc->fs.action == ETHTOOL_RXNTUPLE_ACTION_DROP)
+			sprintf(p, "\tAction: Drop\n");
+		else
+			sprintf(p, "\tAction: Direct to queue %d\n",
+			        fsc->fs.action);
+		p += ETH_GSTRING_LEN;
+		num_strings++;
+unknown_filter:
+		i++;
+	}
+copy:
+	/* indicate to userspace how many strings we actually have */
+	gstrings.len = num_strings;
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &gstrings, sizeof(gstrings)))
+		goto out;
+	useraddr += sizeof(gstrings);
+	if (copy_to_user(useraddr, data, gstrings.len * ETH_GSTRING_LEN))
+		goto out;
+	ret = 0;
+
+out:
+	kfree(data);
+	return ret;
+}
+
 static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_regs regs;
@@ -305,6 +617,7 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 static int ethtool_reset(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value reset;
+	struct ethtool_rx_ntuple_flow_spec_container *fsc, *f;
 	int ret;
 
 	if (!dev->ethtool_ops->reset)
@@ -313,6 +626,12 @@ static int ethtool_reset(struct net_device *dev, char __user *useraddr)
 	if (copy_from_user(&reset, useraddr, sizeof(reset)))
 		return -EFAULT;
 
+	/* Clear ethtool n-tuple list */
+	list_for_each_entry_safe(fsc, f, &dev->ethtool_ntuple_list.list, list) {
+		list_del(&fsc->list);
+	}
+	dev->ethtool_ntuple_list.count = 0;
+
 	ret = dev->ethtool_ops->reset(dev, &reset.data);
 	if (ret)
 		return ret;
@@ -351,9 +670,17 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
 
 static int ethtool_nway_reset(struct net_device *dev)
 {
+	struct ethtool_rx_ntuple_flow_spec_container *fsc, *f;
+
 	if (!dev->ethtool_ops->nway_reset)
 		return -EOPNOTSUPP;
 
+	/* Clear ethtool n-tuple list */
+	list_for_each_entry_safe(fsc, f, &dev->ethtool_ntuple_list.list, list) {
+		list_del(&fsc->list);
+	}
+	dev->ethtool_ntuple_list.count = 0;
+
 	return dev->ethtool_ops->nway_reset(dev);
 }
 
@@ -1112,6 +1439,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_RESET:
 		rc = ethtool_reset(dev, useraddr);
 		break;
+	case ETHTOOL_SRXNTUPLE:
+		rc = ethtool_set_rx_ntuple(dev, useraddr);
+		break;
+	case ETHTOOL_GRXNTUPLE:
+		rc = ethtool_get_rx_ntuple(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}

