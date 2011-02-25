From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 04/10] [RFC] ethtool: remove support for
	ETHTOOL_GRXNTUPLE
Date: Fri, 25 Feb 2011 15:33:00 -0800
Message-ID: <20110225233300.7920.94727.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39055 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932986Ab1BYXdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:33:00 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to remove all support for displaying an ntuple as
strings via ETHTOOL_GRXNTUPLE.  The reason for this change is due to the
fact that multiple issues have been found including:
 - Multiple buffer overruns for strings being displayed.
 - Incorrect filters displayed, cleared filters with ring of -2 are displayed
 - Setting get_rx_ntuple displays no rules if defined.
 - Endianess wrong on displayed values.
 - Hard limit of 1024 filters makes display functionality extremely limited

In order to address this I am proposing moving the displaying of rules over
to the ETHTOOL_GRXCLSRLCNT/ETHTOOL_GRXCLSRULE/ETHTOOL_GRXCLSRULEALL
interfaces and will have a follow-on patch to allow this.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/ethtool.h   |    7 -
 include/linux/netdevice.h |    3 
 net/core/dev.c            |    5 -
 net/core/ethtool.c        |  299 ---------------------------------------------
 4 files changed, 1 insertions(+), 313 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 3d1f8e0..2f2f27c 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -250,7 +250,6 @@ enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
-	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
 };
 
@@ -637,8 +636,6 @@ struct ethtool_rx_ntuple_flow_spec_container {
 };
 
 struct ethtool_rx_ntuple_list {
-#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
-#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
 	struct list_head	list;
 	unsigned int		count;
 };
@@ -659,7 +656,6 @@ u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
 u32 ethtool_op_get_flags(struct net_device *dev);
 int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);
-void ethtool_ntuple_flush(struct net_device *dev);
 
 /**
  * &ethtool_ops - Alter and report network device settings
@@ -776,7 +772,6 @@ struct ethtool_ops {
 	int	(*reset)(struct net_device *, u32 *);
 	int	(*set_rx_ntuple)(struct net_device *,
 				 struct ethtool_rx_ntuple *);
-	int	(*get_rx_ntuple)(struct net_device *, u32 stringset, void *);
 	int	(*get_rxfh_indir)(struct net_device *,
 				  struct ethtool_rxfh_indir *);
 	int	(*set_rxfh_indir)(struct net_device *,
@@ -842,7 +837,7 @@ struct ethtool_ops {
 #define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define ETHTOOL_RESET		0x00000034 /* Reset hardware */
 #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
-#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+/* ETHTOOL_GRXNTUPLE		0x00000036 disabled due to multiple issues */
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ffe56c1..f20fabe 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1246,9 +1246,6 @@ struct net_device {
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
-	/* n-tuple filter list attached to this device */
-	struct ethtool_rx_ntuple_list ethtool_ntuple_list;
-
 	/* phy device may attach itself for hardware timestamping */
 	struct phy_device *phydev;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 69a3c08..c788c98 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5886,8 +5886,6 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 
-	INIT_LIST_HEAD(&dev->ethtool_ntuple_list.list);
-	dev->ethtool_ntuple_list.count = 0;
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
 	INIT_LIST_HEAD(&dev->link_watch_list);
@@ -5951,9 +5949,6 @@ void free_netdev(struct net_device *dev)
 	/* Flush device addresses */
 	dev_addr_flush(dev);
 
-	/* Clear ethtool n-tuple list */
-	ethtool_ntuple_flush(dev);
-
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 4843674..3c5ba60 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -152,18 +152,6 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
 }
 EXPORT_SYMBOL(ethtool_op_set_flags);
 
-void ethtool_ntuple_flush(struct net_device *dev)
-{
-	struct ethtool_rx_ntuple_flow_spec_container *fsc, *f;
-
-	list_for_each_entry_safe(fsc, f, &dev->ethtool_ntuple_list.list, list) {
-		list_del(&fsc->list);
-		kfree(fsc);
-	}
-	dev->ethtool_ntuple_list.count = 0;
-}
-EXPORT_SYMBOL(ethtool_ntuple_flush);
-
 /* Handlers for each ethtool command */
 
 #define ETHTOOL_DEV_FEATURE_WORDS	1
@@ -825,34 +813,6 @@ out:
 	return ret;
 }
 
-static void __rx_ntuple_filter_add(struct ethtool_rx_ntuple_list *list,
-			struct ethtool_rx_ntuple_flow_spec *spec,
-			struct ethtool_rx_ntuple_flow_spec_container *fsc)
-{
-
-	/* don't add filters forever */
-	if (list->count >= ETHTOOL_MAX_NTUPLE_LIST_ENTRY) {
-		/* free the container */
-		kfree(fsc);
-		return;
-	}
-
-	/* Copy the whole filter over */
-	fsc->fs.flow_type = spec->flow_type;
-	memcpy(&fsc->fs.h_u, &spec->h_u, sizeof(spec->h_u));
-	memcpy(&fsc->fs.m_u, &spec->m_u, sizeof(spec->m_u));
-
-	fsc->fs.vlan_tag = spec->vlan_tag;
-	fsc->fs.vlan_tag_mask = spec->vlan_tag_mask;
-	fsc->fs.data = spec->data;
-	fsc->fs.data_mask = spec->data_mask;
-	fsc->fs.action = spec->action;
-
-	/* add to the list */
-	list_add_tail_rcu(&fsc->list, &list->list);
-	list->count++;
-}
-
 /*
  * ethtool does not (or did not) set masks for flow parameters that are
  * not specified, so if both value and mask are 0 then this must be
@@ -904,268 +864,12 @@ static noinline_for_stack int ethtool_set_rx_ntuple(struct net_device *dev,
 
 	rx_ntuple_fix_masks(&cmd.fs);
 
-	/*
-	 * Cache filter in dev struct for GET operation only if
-	 * the underlying driver doesn't have its own GET operation, and
-	 * only if the filter was added successfully.  First make sure we
-	 * can allocate the filter, then continue if successful.
-	 */
-	if (!ops->get_rx_ntuple) {
-		fsc = kmalloc(sizeof(*fsc), GFP_ATOMIC);
-		if (!fsc)
-			return -ENOMEM;
-	}
-
 	ret = ops->set_rx_ntuple(dev, &cmd);
 	if (ret) {
 		kfree(fsc);
 		return ret;
 	}
 
-	if (!ops->get_rx_ntuple)
-		__rx_ntuple_filter_add(&dev->ethtool_ntuple_list, &cmd.fs, fsc);
-
-	return ret;
-}
-
-static int ethtool_get_rx_ntuple(struct net_device *dev, void __user *useraddr)
-{
-	struct ethtool_gstrings gstrings;
-	const struct ethtool_ops *ops = dev->ethtool_ops;
-	struct ethtool_rx_ntuple_flow_spec_container *fsc;
-	u8 *data;
-	char *p;
-	int ret, i, num_strings = 0;
-
-	if (!ops->get_sset_count)
-		return -EOPNOTSUPP;
-
-	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
-		return -EFAULT;
-
-	ret = ops->get_sset_count(dev, gstrings.string_set);
-	if (ret < 0)
-		return ret;
-
-	gstrings.len = ret;
-
-	data = kzalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
-	if (!data)
-		return -ENOMEM;
-
-	if (ops->get_rx_ntuple) {
-		/* driver-specific filter grab */
-		ret = ops->get_rx_ntuple(dev, gstrings.string_set, data);
-		goto copy;
-	}
-
-	/* default ethtool filter grab */
-	i = 0;
-	p = (char *)data;
-	list_for_each_entry(fsc, &dev->ethtool_ntuple_list.list, list) {
-		sprintf(p, "Filter %d:\n", i);
-		p += ETH_GSTRING_LEN;
-		num_strings++;
-
-		switch (fsc->fs.flow_type) {
-		case TCP_V4_FLOW:
-			sprintf(p, "\tFlow Type: TCP\n");
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case UDP_V4_FLOW:
-			sprintf(p, "\tFlow Type: UDP\n");
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case SCTP_V4_FLOW:
-			sprintf(p, "\tFlow Type: SCTP\n");
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case AH_ESP_V4_FLOW:
-			sprintf(p, "\tFlow Type: AH ESP\n");
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case ESP_V4_FLOW:
-			sprintf(p, "\tFlow Type: ESP\n");
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case IP_USER_FLOW:
-			sprintf(p, "\tFlow Type: Raw IP\n");
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case IPV4_FLOW:
-			sprintf(p, "\tFlow Type: IPv4\n");
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		default:
-			sprintf(p, "\tFlow Type: Unknown\n");
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			goto unknown_filter;
-		}
-
-		/* now the rest of the filters */
-		switch (fsc->fs.flow_type) {
-		case TCP_V4_FLOW:
-		case UDP_V4_FLOW:
-		case SCTP_V4_FLOW:
-			sprintf(p, "\tSrc IP addr: 0x%x\n",
-				fsc->fs.h_u.tcp_ip4_spec.ip4src);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tSrc IP mask: 0x%x\n",
-				fsc->fs.m_u.tcp_ip4_spec.ip4src);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest IP addr: 0x%x\n",
-				fsc->fs.h_u.tcp_ip4_spec.ip4dst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest IP mask: 0x%x\n",
-				fsc->fs.m_u.tcp_ip4_spec.ip4dst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tSrc Port: %d, mask: 0x%x\n",
-				fsc->fs.h_u.tcp_ip4_spec.psrc,
-				fsc->fs.m_u.tcp_ip4_spec.psrc);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest Port: %d, mask: 0x%x\n",
-				fsc->fs.h_u.tcp_ip4_spec.pdst,
-				fsc->fs.m_u.tcp_ip4_spec.pdst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
-				fsc->fs.h_u.tcp_ip4_spec.tos,
-				fsc->fs.m_u.tcp_ip4_spec.tos);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case AH_ESP_V4_FLOW:
-		case ESP_V4_FLOW:
-			sprintf(p, "\tSrc IP addr: 0x%x\n",
-				fsc->fs.h_u.ah_ip4_spec.ip4src);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tSrc IP mask: 0x%x\n",
-				fsc->fs.m_u.ah_ip4_spec.ip4src);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest IP addr: 0x%x\n",
-				fsc->fs.h_u.ah_ip4_spec.ip4dst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest IP mask: 0x%x\n",
-				fsc->fs.m_u.ah_ip4_spec.ip4dst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tSPI: %d, mask: 0x%x\n",
-				fsc->fs.h_u.ah_ip4_spec.spi,
-				fsc->fs.m_u.ah_ip4_spec.spi);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
-				fsc->fs.h_u.ah_ip4_spec.tos,
-				fsc->fs.m_u.ah_ip4_spec.tos);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case IP_USER_FLOW:
-			sprintf(p, "\tSrc IP addr: 0x%x\n",
-				fsc->fs.h_u.usr_ip4_spec.ip4src);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tSrc IP mask: 0x%x\n",
-				fsc->fs.m_u.usr_ip4_spec.ip4src);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest IP addr: 0x%x\n",
-				fsc->fs.h_u.usr_ip4_spec.ip4dst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest IP mask: 0x%x\n",
-				fsc->fs.m_u.usr_ip4_spec.ip4dst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		case IPV4_FLOW:
-			sprintf(p, "\tSrc IP addr: 0x%x\n",
-				fsc->fs.h_u.usr_ip4_spec.ip4src);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tSrc IP mask: 0x%x\n",
-				fsc->fs.m_u.usr_ip4_spec.ip4src);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest IP addr: 0x%x\n",
-				fsc->fs.h_u.usr_ip4_spec.ip4dst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tDest IP mask: 0x%x\n",
-				fsc->fs.m_u.usr_ip4_spec.ip4dst);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tL4 bytes: 0x%x, mask: 0x%x\n",
-				fsc->fs.h_u.usr_ip4_spec.l4_4_bytes,
-				fsc->fs.m_u.usr_ip4_spec.l4_4_bytes);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tTOS: %d, mask: 0x%x\n",
-				fsc->fs.h_u.usr_ip4_spec.tos,
-				fsc->fs.m_u.usr_ip4_spec.tos);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tIP Version: %d, mask: 0x%x\n",
-				fsc->fs.h_u.usr_ip4_spec.ip_ver,
-				fsc->fs.m_u.usr_ip4_spec.ip_ver);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			sprintf(p, "\tProtocol: %d, mask: 0x%x\n",
-				fsc->fs.h_u.usr_ip4_spec.proto,
-				fsc->fs.m_u.usr_ip4_spec.proto);
-			p += ETH_GSTRING_LEN;
-			num_strings++;
-			break;
-		}
-		sprintf(p, "\tVLAN: %d, mask: 0x%x\n",
-			fsc->fs.vlan_tag, fsc->fs.vlan_tag_mask);
-		p += ETH_GSTRING_LEN;
-		num_strings++;
-		sprintf(p, "\tUser-defined: 0x%Lx\n", fsc->fs.data);
-		p += ETH_GSTRING_LEN;
-		num_strings++;
-		sprintf(p, "\tUser-defined mask: 0x%Lx\n", fsc->fs.data_mask);
-		p += ETH_GSTRING_LEN;
-		num_strings++;
-		if (fsc->fs.action == ETHTOOL_RXNTUPLE_ACTION_DROP)
-			sprintf(p, "\tAction: Drop\n");
-		else
-			sprintf(p, "\tAction: Direct to queue %d\n",
-				fsc->fs.action);
-		p += ETH_GSTRING_LEN;
-		num_strings++;
-unknown_filter:
-		i++;
-	}
-copy:
-	/* indicate to userspace how many strings we actually have */
-	gstrings.len = num_strings;
-	ret = -EFAULT;
-	if (copy_to_user(useraddr, &gstrings, sizeof(gstrings)))
-		goto out;
-	useraddr += sizeof(gstrings);
-	if (copy_to_user(useraddr, data, gstrings.len * ETH_GSTRING_LEN))
-		goto out;
-	ret = 0;
-
-out:
-	kfree(data);
 	return ret;
 }
 
@@ -1902,9 +1606,6 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SRXNTUPLE:
 		rc = ethtool_set_rx_ntuple(dev, useraddr);
 		break;
-	case ETHTOOL_GRXNTUPLE:
-		rc = ethtool_get_rx_ntuple(dev, useraddr);
-		break;
 	case ETHTOOL_GSSET_INFO:
 		rc = ethtool_get_sset_info(dev, useraddr);
 		break;

