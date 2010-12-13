From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [RFC PATCH 2/2] bonding: add multi-link mode
Date: Mon, 13 Dec 2010 14:07:35 -0800
Message-ID: <1292278055-2842-3-git-send-email-fubar@us.ibm.com>
References: <1292278055-2842-1-git-send-email-fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49002 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758042Ab0LMWHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 17:07:55 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBDM25HC024589
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:02:05 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBDM7ipD112386
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:07:48 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBDM7hLN022792
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:07:43 -0700
In-Reply-To: <1292278055-2842-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Adds multi-link mode for bonding.

	This mode performs per-subnet balancing, wherein each slave is
typically a member of a discrete IP subnet, and the multi-link (ML)
addresses exist in a subnet of their own.  A user space daemon runs the
ML discovery protocol, which locates other ML hosts and exchanges link
information.  The daemon then informs bonding of the appropriate set of
slaves to reach a particular ML destination.  The ML daemon also monitors
the links to insure continued availabilty.

	Note that ML slaves maintain their assigned IP addresses, and
may operate outside the scope of the bond.
---
 drivers/net/bonding/Makefile    |    3 ++-
 drivers/net/bonding/bond_main.c |   34 +++++++++++++++++++++++++++++++---
 drivers/net/bonding/bonding.h   |   13 +++++++++++++
 include/linux/if.h              |    1 +
 include/linux/if_bonding.h      |   15 +++++++++++++++
 net/core/dev.c                  |   37 +++++++++++++++++++++++++++++--------
 6 files changed, 91 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 26848a2..0b6ed50 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -4,7 +4,8 @@
 
 obj-$(CONFIG_BONDING) += bonding.o
 
-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_netlink.o
+bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_netlink.o \
+	bond_ml.o
 
 ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
 bonding-objs += $(ipv6-y)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4d3a2c8..1399949 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -200,6 +200,7 @@ const struct bond_parm_tbl bond_mode_tbl[] = {
 {	"802.3ad",		BOND_MODE_8023AD},
 {	"balance-tlb",		BOND_MODE_TLB},
 {	"balance-alb",		BOND_MODE_ALB},
+{	"multi-link",		BOND_MODE_ML},
 {	NULL,			-1},
 };
 
@@ -257,9 +258,10 @@ static const char *bond_mode_name(int mode)
 		[BOND_MODE_8023AD] = "IEEE 802.3ad Dynamic link aggregation",
 		[BOND_MODE_TLB] = "transmit load balancing",
 		[BOND_MODE_ALB] = "adaptive load balancing",
+		[BOND_MODE_ML] = "multi-link",
 	};
 
-	if (mode < 0 || mode > BOND_MODE_ALB)
+	if (mode < 0 || mode > BOND_MODE_ML)
 		return "unknown";
 
 	return names[mode];
@@ -1603,7 +1605,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);
 
-	if (!bond->params.fail_over_mac) {
+	if (!bond->params.fail_over_mac && bond->params.mode != BOND_MODE_ML) {
 		/*
 		 * Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
@@ -2097,6 +2099,9 @@ static int bond_release_all(struct net_device *bond_dev)
 		if (bond->params.mode == BOND_MODE_8023AD)
 			bond_3ad_unbind_slave(slave);
 
+		if (bond->params.mode == BOND_MODE_ML)
+			bond_ml_unbind_slave(bond, slave);
+
 		slave_dev = slave->dev;
 		bond_detach_slave(bond, slave);
 
@@ -3357,6 +3362,8 @@ static void bond_info_show_master(struct seq_file *seq)
 			seq_printf(seq, "\tPartner Mac Address: %pM\n",
 				   ad_info.partner_system);
 		}
+	} else if (bond->params.mode == BOND_MODE_ML) {
+		bond_ml_show_proc(seq, bond);
 	}
 }
 
@@ -3843,6 +3850,11 @@ static int bond_open(struct net_device *bond_dev)
 		bond_3ad_initiate_agg_selection(bond, 1);
 	}
 
+	if (bond->params.mode == BOND_MODE_ML) {
+		INIT_DELAYED_WORK(&bond->ml_work, bond_ml_monitor);
+		queue_delayed_work(bond->wq, &bond->ml_work, 0);
+	}
+
 	return 0;
 }
 
@@ -3884,6 +3896,9 @@ static int bond_close(struct net_device *bond_dev)
 	case BOND_MODE_ALB:
 		cancel_delayed_work(&bond->alb_work);
 		break;
+	case BOND_MODE_ML:
+		cancel_delayed_work(&bond->ml_work);
+		break;
 	default:
 		break;
 	}
@@ -4602,6 +4617,8 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	case BOND_MODE_ALB:
 	case BOND_MODE_TLB:
 		return bond_alb_xmit(skb, dev);
+	case BOND_MODE_ML:
+		return bond_xmit_ml(skb, dev);
 	default:
 		/* Should never happen, mode already checked */
 		pr_err("%s: Error: Unknown bonding mode %d\n",
@@ -4639,6 +4656,11 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 		/* FALLTHRU */
 	case BOND_MODE_TLB:
 		break;
+	case BOND_MODE_ML:
+		bond_set_xmit_hash_policy(bond);
+		bond_set_master_ml_flags(bond);
+		bond_ml_init(bond);
+		break;
 	default:
 		/* Should never happen, mode already checked */
 		pr_err("%s: Error: Unknown bonding mode %d\n",
@@ -4713,7 +4735,6 @@ void bond_setup(struct net_device *bond_dev)
 	ether_setup(bond_dev);
 	bond_dev->netdev_ops = &bond_netdev_ops;
 	bond_dev->ethtool_ops = &bond_ethtool_ops;
-	bond_set_mode_ops(bond, bond->params.mode);
 
 	bond_dev->destructor = bond_destructor;
 
@@ -4726,6 +4747,8 @@ void bond_setup(struct net_device *bond_dev)
 	if (bond->params.arp_interval)
 		bond_dev->priv_flags |= IFF_MASTER_ARPMON;
 
+	bond_set_mode_ops(bond, bond->params.mode);
+
 	/* At first, we block adding VLANs. That's the only way to
 	 * prevent problems that occur when adding VLANs over an
 	 * empty bond. The block will be removed once non-challenged
@@ -4773,6 +4796,10 @@ static void bond_work_cancel_all(struct bonding *bond)
 	    delayed_work_pending(&bond->ad_work))
 		cancel_delayed_work(&bond->ad_work);
 
+	if (bond->params.mode == BOND_MODE_ML &&
+	    delayed_work_pending(&bond->ml_work))
+		cancel_delayed_work(&bond->ml_work);
+
 	if (delayed_work_pending(&bond->mcast_work))
 		cancel_delayed_work(&bond->mcast_work);
 }
@@ -4858,6 +4885,7 @@ static int bond_check_params(struct bond_params *params)
 
 	if (xmit_hash_policy) {
 		if ((bond_mode != BOND_MODE_XOR) &&
+		    (bond_mode != BOND_MODE_ML) &&
 		    (bond_mode != BOND_MODE_8023AD)) {
 			pr_info("xmit_hash_policy param is irrelevant in mode %s\n",
 			       bond_mode_name(bond_mode));
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index db7bb06..13b9dd5 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -23,6 +23,7 @@
 #include <linux/in6.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
+#include "bond_ml.h"
 
 #define DRV_VERSION	"3.7.0"
 #define DRV_RELDATE	"June 2, 2010"
@@ -246,6 +247,7 @@ struct bonding {
 	u16      rr_tx_counter;
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
+	struct   ml_bond_info ml_info;
 	struct   bond_params params;
 	struct   list_head vlan_list;
 	struct   vlan_group *vlgrp;
@@ -255,6 +257,7 @@ struct bonding {
 	struct   delayed_work arp_work;
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
+	struct   delayed_work ml_work;
 	struct   delayed_work mcast_work;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct   in6_addr master_ipv6;
@@ -361,6 +364,16 @@ static inline void bond_unset_master_alb_flags(struct bonding *bond)
 	bond->dev->priv_flags &= ~IFF_MASTER_ALB;
 }
 
+static inline void bond_set_master_ml_flags(struct bonding *bond)
+{
+	bond->dev->priv_flags |= IFF_MASTER_ML;
+}
+
+static inline void bond_unset_master_ml_flags(struct bonding *bond)
+{
+	bond->dev->priv_flags &= ~IFF_MASTER_ML;
+}
+
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(struct net *net, const char *name);
diff --git a/include/linux/if.h b/include/linux/if.h
index 1239599..826b06f 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -77,6 +77,7 @@
 #define IFF_BRIDGE_PORT	0x8000		/* device used as bridge port */
 #define IFF_OVS_DATAPATH	0x10000	/* device used as Open vSwitch
 					 * datapath port */
+#define IFF_MASTER_ML	0x20000		/* bonding master, multi-link */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index b03d832..15c8773 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -70,6 +70,7 @@
 #define BOND_MODE_8023AD        4
 #define BOND_MODE_TLB           5
 #define BOND_MODE_ALB		6 /* TLB + RLB (receive load balancing) */
+#define BOND_MODE_ML		7
 
 /* each slave's link has 4 states */
 #define BOND_LINK_UP    0           /* link is up and running */
@@ -114,12 +115,22 @@ struct ad_info {
 	__u8 partner_system[ETH_ALEN];
 };
 
+struct bond_ml_route {
+	__u16 lif_index;
+	struct in_addr laddr;
+	struct in_addr raddr;
+};
+
 enum {
 	BOND_GENL_ATTR_UNSPEC = 0,
 	BOND_GENL_ATTR_MASTER_INDEX,
 	BOND_GENL_ATTR_SLAVE_INDEX,
 	BOND_GENL_ATTR_MODE,
 	BOND_GENL_ATTR_SLAVE_LINK,
+	BOND_GENL_ATTR_ML_LADDR,
+	BOND_GENL_ATTR_ML_RADDR,
+	BOND_GENL_ATTR_ML_MLADDR,
+	BOND_GENL_ATTR_ML_INDEX,
 	__BOND_GENL_ATTR_MAX,
 };
 
@@ -129,6 +140,10 @@ enum {
 	BOND_GENL_CMD_UNSPEC = 0,
 	BOND_GENL_CMD_GET_MODE,
 	BOND_GENL_SLAVE_LINK,
+	BOND_GENL_ML_CMD_RT_ADD,
+	BOND_GENL_ML_CMD_RT_DEL,
+	BOND_GENL_ML_CMD_RT_FLUSH,
+	BOND_GENL_ML_CMD_DISCOVERY,
 	__BOND_GENL_MAX,
 };
 
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..02b653b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2921,10 +2921,28 @@ static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
 /* On bonding slaves other than the currently active slave, suppress
  * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, and
  * ARP on active-backup slaves with arp_validate enabled.
+ * Additionally, set skb->dev appropriately for the mode / action.
  */
 int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
 {
 	struct net_device *dev = skb->dev;
+	struct iphdr *iph;
+
+	if (master->priv_flags & IFF_MASTER_ML) {
+		if (skb->protocol == htons(ETH_P_IP)) {
+			iph = ip_hdr(skb);
+			if (!iph)
+				goto out;
+
+			/* For ML, assign to master only if traffic is for
+			 * master, as slaves keep their assigned IP addresses
+			 */
+			if (!ip_route_input(skb, iph->daddr, iph->saddr, 0,
+					    master))
+				skb->dev = master;
+		}
+		return 0;
+	}
 
 	if (master->priv_flags & IFF_MASTER_ARPMON)
 		dev->last_rx = jiffies;
@@ -2941,19 +2959,22 @@ int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *master)
 	if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
 		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
 		    skb->protocol == __cpu_to_be16(ETH_P_ARP))
-			return 0;
+			goto out;
 
 		if (master->priv_flags & IFF_MASTER_ALB) {
 			if (skb->pkt_type != PACKET_BROADCAST &&
 			    skb->pkt_type != PACKET_MULTICAST)
-				return 0;
+				goto out;
 		}
 		if (master->priv_flags & IFF_MASTER_8023AD &&
 		    skb->protocol == __cpu_to_be16(ETH_P_SLOW))
-			return 0;
+			goto out;
 
 		return 1;
 	}
+
+out:
+	skb->dev = master;
 	return 0;
 }
 EXPORT_SYMBOL(__skb_bond_should_drop);
@@ -2981,6 +3002,10 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (!skb->skb_iif)
 		skb->skb_iif = skb->dev->ifindex;
 
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb->mac_len = skb->network_header - skb->mac_header;
+
 	/*
 	 * bonding note: skbs received on inactive slaves should only
 	 * be delivered to pkt handlers that are exact matches.  Also
@@ -2997,14 +3022,10 @@ static int __netif_receive_skb(struct sk_buff *skb)
 		if (skb_bond_should_drop(skb, master)) {
 			skb->deliver_no_wcard = 1;
 			null_or_orig = orig_dev; /* deliver only exact match */
-		} else
-			skb->dev = master;
+		}
 	}
 
 	__this_cpu_inc(softnet_data.processed);
-	skb_reset_network_header(skb);
-	skb_reset_transport_header(skb);
-	skb->mac_len = skb->network_header - skb->mac_header;
 
 	pt_prev = NULL;
 
-- 
1.6.0.2

