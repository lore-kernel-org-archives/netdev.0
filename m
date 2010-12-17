From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH RFC v3 2/2] bonding: add multi-link mode
Date: Thu, 16 Dec 2010 17:35:26 -0800
Message-ID: <1292549726-15957-3-git-send-email-fubar@us.ibm.com>
References: <1292549726-15957-1-git-send-email-fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:58389 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114Ab0LQBfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 20:35:37 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBH1JJX0027732
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 20:19:19 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BF22A4DE803B
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 20:33:25 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBH1ZYKX183650
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 20:35:34 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBH1ZYPF028974
	for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 18:35:34 -0700
In-Reply-To: <1292549726-15957-1-git-send-email-fubar@us.ibm.com>
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

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/Makefile       |    2 +-
 drivers/net/bonding/bond_main.c    |   34 ++-
 drivers/net/bonding/bond_ml.c      |  638 ++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_ml.h      |   88 +++++
 drivers/net/bonding/bond_netlink.c |  134 ++++++++
 drivers/net/bonding/bond_netlink.h |    5 +
 drivers/net/bonding/bonding.h      |   13 +
 include/linux/if.h                 |    1 +
 include/linux/if_bonding.h         |   15 +
 net/core/dev.c                     |   37 ++-
 10 files changed, 955 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/bonding/bond_ml.c
 create mode 100644 drivers/net/bonding/bond_ml.h

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index b5fba40..ef3fab4 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -5,7 +5,7 @@
 obj-$(CONFIG_BONDING) += bonding.o
 
 bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o \
-	bond_netlink.o
+	bond_netlink.o bond_ml.o
 
 ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
 bonding-objs += $(ipv6-y)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ac1c2f0..9b93248 100644
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
 
@@ -3358,6 +3363,8 @@ static void bond_info_show_master(struct seq_file *seq)
 			seq_printf(seq, "\tPartner Mac Address: %pM\n",
 				   ad_info.partner_system);
 		}
+	} else if (bond->params.mode == BOND_MODE_ML) {
+		bond_ml_show_proc(seq, bond);
 	}
 }
 
@@ -3846,6 +3853,11 @@ static int bond_open(struct net_device *bond_dev)
 		bond_3ad_initiate_agg_selection(bond, 1);
 	}
 
+	if (bond->params.mode == BOND_MODE_ML) {
+		INIT_DELAYED_WORK(&bond->ml_work, bond_ml_monitor);
+		queue_delayed_work(bond->wq, &bond->ml_work, 0);
+	}
+
 	return 0;
 }
 
@@ -3887,6 +3899,9 @@ static int bond_close(struct net_device *bond_dev)
 	case BOND_MODE_ALB:
 		cancel_delayed_work(&bond->alb_work);
 		break;
+	case BOND_MODE_ML:
+		cancel_delayed_work(&bond->ml_work);
+		break;
 	default:
 		break;
 	}
@@ -4605,6 +4620,8 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	case BOND_MODE_ALB:
 	case BOND_MODE_TLB:
 		return bond_alb_xmit(skb, dev);
+	case BOND_MODE_ML:
+		return bond_xmit_ml(skb, dev);
 	default:
 		/* Should never happen, mode already checked */
 		pr_err("%s: Error: Unknown bonding mode %d\n",
@@ -4642,6 +4659,11 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
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
@@ -4716,7 +4738,6 @@ void bond_setup(struct net_device *bond_dev)
 	ether_setup(bond_dev);
 	bond_dev->netdev_ops = &bond_netdev_ops;
 	bond_dev->ethtool_ops = &bond_ethtool_ops;
-	bond_set_mode_ops(bond, bond->params.mode);
 
 	bond_dev->destructor = bond_destructor;
 
@@ -4729,6 +4750,8 @@ void bond_setup(struct net_device *bond_dev)
 	if (bond->params.arp_interval)
 		bond_dev->priv_flags |= IFF_MASTER_ARPMON;
 
+	bond_set_mode_ops(bond, bond->params.mode);
+
 	/* At first, we block adding VLANs. That's the only way to
 	 * prevent problems that occur when adding VLANs over an
 	 * empty bond. The block will be removed once non-challenged
@@ -4776,6 +4799,10 @@ static void bond_work_cancel_all(struct bonding *bond)
 	    delayed_work_pending(&bond->ad_work))
 		cancel_delayed_work(&bond->ad_work);
 
+	if (bond->params.mode == BOND_MODE_ML &&
+	    delayed_work_pending(&bond->ml_work))
+		cancel_delayed_work(&bond->ml_work);
+
 	if (delayed_work_pending(&bond->mcast_work))
 		cancel_delayed_work(&bond->mcast_work);
 }
@@ -4863,6 +4890,7 @@ static int bond_check_params(struct bond_params *params)
 
 	if (xmit_hash_policy) {
 		if ((bond_mode != BOND_MODE_XOR) &&
+		    (bond_mode != BOND_MODE_ML) &&
 		    (bond_mode != BOND_MODE_8023AD)) {
 			pr_info("xmit_hash_policy param is irrelevant in mode %s\n",
 			       bond_mode_name(bond_mode));
diff --git a/drivers/net/bonding/bond_ml.c b/drivers/net/bonding/bond_ml.c
new file mode 100644
index 0000000..264df06
--- /dev/null
+++ b/drivers/net/bonding/bond_ml.c
@@ -0,0 +1,638 @@
+/*
+ * Multi-link mode support for bonding
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
+ * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright IBM Corporation, 2010
+ *
+ * Author: Jay Vosburgh <fubar@us.ibm.com>
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ip.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/if_bonding.h>
+#include <linux/in.h>
+#include <net/arp.h>
+#include <net/route.h>
+#include <net/genetlink.h>
+
+#include "bonding.h"
+#include "bond_netlink.h"
+
+static u32 bond_ml_salt __read_mostly;
+
+static inline int bond_ml_hash(const __be32 mladdr)
+{
+	return jhash_1word(mladdr, bond_ml_salt) & (BOND_ML_HASH_SZ - 1);
+}
+
+/*
+ * Create new ml_route entry, insert into hash table.
+ *
+ * Caller holds bond->lock for write.
+ */
+static struct ml_route *bond_mlr_create(struct bonding *bond, __be32 mladdr)
+{
+	struct ml_route *mlr, *head;
+	int hash;
+
+	mlr = kzalloc(sizeof(*mlr), GFP_ATOMIC);
+	if (!mlr)
+		return NULL;
+
+	mlr->state = MLRT_EMPTY;
+	hash = bond_ml_hash(mladdr);
+
+	head = bond->ml_info.ml_rtable[hash];
+	mlr->next = head;
+	bond->ml_info.ml_rtable[hash] = mlr;
+
+	return mlr;
+}
+
+/*
+ * Destroy ml_route entry.  Remove from hash table if necessary, then free.
+ * Caller responsible for freeing ml_dest table.
+ *
+ * Caller holds bond->lock for write.
+ */
+static void bond_mlr_destroy(struct bonding *bond, struct ml_route *mlr)
+{
+	struct ml_route *mlr_prev;
+	int hash;
+
+	hash = bond_ml_hash(mlr->ml_ipaddr.addr.s_addr);
+	pr_debug("bmd: ip %x h %x rt[h] %p\n", mlr->ml_ipaddr.addr.s_addr,
+		 hash, bond->ml_info.ml_rtable[hash]);
+
+	if (bond->ml_info.ml_rtable[hash] == mlr) {
+		bond->ml_info.ml_rtable[hash] = mlr->next;
+		goto out;
+	}
+
+	mlr_prev = bond->ml_info.ml_rtable[hash];
+	while (mlr_prev) {
+		if (mlr_prev->next == mlr) {
+			mlr_prev->next = mlr->next;
+			goto out;
+		}
+	}
+
+	pr_err("%s: bond_mlr_destroy: mlr %p has next, but not in table\n",
+	       bond->dev->name, mlr);
+
+out:
+	kfree(mlr);
+}
+
+/*
+ * Look up ml_route entry for supplied ML IP address.
+ *
+ * Caller holds bond->lock for read or better.
+ */
+static struct ml_route *bond_ml_route_output(struct bonding *bond,
+					     __be32 mladdr)
+{
+	struct ml_route *mlr;
+	int hash;
+
+	hash = bond_ml_hash(mladdr);
+	mlr = bond->ml_info.ml_rtable[hash];
+
+	while (mlr) {
+		if (mlr->state == MLRT_COMPLETE &&
+		    mlr->ml_ipaddr.addr.s_addr == mladdr)
+			return mlr;
+		mlr = mlr->next;
+	}
+
+	return NULL;
+}
+
+/*
+ * Find "nth" ml_dest in supplied ml_route, where nth is zero-based.  Used
+ * by TX to find suitable slave to send on.  N must be less than
+ * mlr->num_dest.
+ */
+static struct ml_dest *bond_mlr_dest_output(struct ml_route *mlr, int nth)
+{
+	int b;
+
+	b = find_next_bit(&mlr->ml_dest_map, BOND_ML_NDEST, 0);
+	while (nth--)
+		b = find_next_bit(&mlr->ml_dest_map, BOND_ML_NDEST, b + 1);
+
+	return mlr->ml_dest[b];
+}
+
+/*
+ * Find ml_dest in supplied ml_route.  Also match against laddr or raddr
+ * if nonzero.
+ */
+static struct ml_dest *bond_mlr_dest_find(struct ml_route *mlr,
+					  __be32 laddr, __be32 raddr)
+{
+	struct ml_dest *mld;
+	int i;
+
+	for (i = 0; i < BOND_ML_NDEST; i++) {
+		mld = mlr->ml_dest[i];
+		if (!mld)
+			continue;
+		if (laddr && (laddr != mld->laddr))
+			continue;
+		if (raddr && (raddr != mld->raddr))
+			continue;
+
+		return mld;
+	}
+	return NULL;
+}
+
+static void bond_mlr_dest_free(struct bonding *bond, struct ml_route *mlr,
+			       struct ml_dest *mld)
+{
+	int i;
+
+	pr_debug("dest_free: s %s l %pI4 r %pI4 ml %pI4\n",
+		 mld->slave->dev->name, &mld->laddr, &mld->raddr,
+		 &mlr->ml_ipaddr.addr);
+
+	for (i = 0; i < BOND_ML_NDEST; i++) {
+		if (mlr->ml_dest[i] == mld)
+			break;
+	}
+
+	if (i == BOND_ML_NDEST) {
+		pr_debug("bond_mlr_dest_free: mld not found in mlr\n");
+		return;
+	}
+
+	mlr->ml_dest[i] = NULL;
+	mlr->num_dest--;
+
+	if (mld->neigh)
+		neigh_release(mld->neigh);
+
+	kfree(mld);
+
+	clear_bit(i, &mlr->ml_dest_map);
+	if (mlr->ml_dest_map)
+		return;
+
+	mlr->state = MLRT_INCOMPLETE;
+	mlr->ml_ipaddr.flag = MLDD_IF_DOWN;
+}
+
+static struct ml_dest *bond_mlr_dest_new(struct ml_route *mlr)
+{
+	struct ml_dest *mld;
+	int n;
+
+	n = find_first_zero_bit(&mlr->ml_dest_map, BOND_ML_NDEST);
+	if (n == BOND_ML_NDEST)
+		return NULL;
+
+	mld = kzalloc(sizeof(*mld), GFP_ATOMIC);
+	if (!mld)
+		return NULL;
+
+	set_bit(n, &mlr->ml_dest_map);
+
+	mlr->num_dest++;
+	mlr->ml_dest[n] = mld;
+	return mld;
+}
+
+int bond_ml_delrt(struct bonding *bond, struct in_addr laddr,
+		  struct in_addr raddr, struct in_addr mladdr,
+		  struct slave *slave)
+{
+	struct ml_route *mlr;
+	struct ml_dest *mld;
+	int rv = 0;
+
+	pr_debug("ml_delrt: l %pI4 r %pI4 ml %pI4\n", &laddr, &raddr, &mladdr);
+	write_lock_bh(&bond->lock);
+
+	mlr = bond_ml_route_output(bond, mladdr.s_addr);
+	if (!mlr) {
+		rv = -ENOENT;
+		goto out;
+	}
+	mld = bond_mlr_dest_find(mlr, laddr.s_addr, raddr.s_addr);
+	if (!mld) {
+		rv = -ENOENT;
+		goto out;
+	}
+
+	bond_mlr_dest_free(bond, mlr, mld);
+
+out:
+	write_unlock_bh(&bond->lock);
+	return rv;
+}
+
+int bond_ml_addrt(struct bonding *bond, struct in_addr laddr,
+		  struct in_addr raddr, struct in_addr mladdr,
+		  struct slave *slave)
+{
+	struct ml_route *mlr;
+	struct ml_dest *mld;
+	struct neighbour *n;
+	int rv = 0, alloc_mlr = 0;
+
+	pr_debug("ml_addrt: %s l %pI4 r %pI4 m %pI4 s %s\n", bond->dev->name,
+		 &laddr, &raddr, &mladdr, slave->dev->name);
+
+	write_lock_bh(&bond->lock);
+
+	mlr = bond_ml_route_output(bond, mladdr.s_addr);
+	if (mlr) {
+		mld = bond_mlr_dest_find(mlr, laddr.s_addr, raddr.s_addr);
+		if (mld) {
+			rv = -EEXIST;
+			goto out;
+		}
+	}
+
+	if (!mlr) {
+		mlr = bond_mlr_create(bond, mladdr.s_addr);
+		if (!mlr) {
+			rv = -ENOMEM;
+			goto out;
+		}
+		alloc_mlr++;
+	}
+
+	mld = bond_mlr_dest_new(mlr);
+	if (!mld) {
+		rv = -ENOSPC;
+		goto out;
+	}
+
+	mld->slave = bond_get_slave_by_dev(bond, slave->dev);
+	if (!mld->slave) {
+		pr_debug("%s: %s not slave\n", bond->dev->name,
+			 slave->dev->name);
+		rv = -EINVAL;
+		goto out;
+	}
+
+	mld->laddr = laddr.s_addr;
+	mld->raddr = raddr.s_addr;
+
+	n = __neigh_lookup(&arp_tbl, &mld->raddr, mld->slave->dev, 1);
+	if (!n) {
+		rv = -ENOMEM;
+		goto out;
+	}
+
+	n->used = jiffies;
+	neigh_event_send(n, NULL);
+	mld->neigh = n;
+
+	mlr->state = MLRT_COMPLETE;
+	mlr->ml_ipaddr.addr.s_addr = mladdr.s_addr;
+	mlr->ml_ipaddr.flag = MLDD_IF_UP;
+
+out:
+	if (rv && alloc_mlr)
+		bond_mlr_destroy(bond, mlr);
+
+	write_unlock_bh(&bond->lock);
+	return rv;
+}
+
+void bond_ml_rt_flush(struct bonding *bond)
+{
+	int i, j;
+	struct ml_route *mlr, *next;
+	struct ml_dest *mld;
+
+	write_lock_bh(&bond->lock);
+
+	for (i = 0; i < BOND_ML_HASH_SZ; i++) {
+		mlr = bond->ml_info.ml_rtable[i];
+
+		while (mlr) {
+			for (j = 0; j < BOND_ML_NDEST; j++) {
+				mld = mlr->ml_dest[j];
+				if (mld)
+					bond_mlr_dest_free(bond, mlr, mld);
+			}
+
+			next = mlr->next;
+			bond_mlr_destroy(bond, mlr);
+			mlr = next;
+		}
+	}
+
+	write_unlock_bh(&bond->lock);
+}
+
+
+/*
+ * Send DISCOVERY message to daemon
+ *
+ * For DISCOVERY, MLADDR is the remote MLADDR we need to resolve.
+ */
+static int bond_ml_discovery(struct bonding *bond, __be32 mladdr)
+{
+	struct sk_buff *skb;
+	void *msg;
+	int rv;
+
+	skb = genlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	msg = genlmsg_put(skb, 0, bond_nl_seq++, &bond_genl_family, 0,
+			  BOND_GENL_ML_CMD_DISCOVERY);
+	if (!msg)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(skb, BOND_GENL_ATTR_ML_MLADDR, mladdr);
+	NLA_PUT_U32(skb, BOND_GENL_ATTR_MASTER_INDEX, bond->dev->ifindex);
+
+	rv = genlmsg_end(skb, msg);
+	if (rv < 0)
+		goto nla_put_failure;
+
+	return genlmsg_multicast(skb, 0, bond_genl_mcgrp.id, GFP_ATOMIC);
+
+nla_put_failure:
+	nlmsg_free(skb);
+	return -EMSGSIZE;
+}
+
+/*
+ * Look up skb's IP destination in ML route table
+ * If exists, send the packet via the found ML destination
+ * If not, initiate ML discovery
+ */
+int bond_xmit_ml(struct sk_buff *skb, struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct ml_route *mlr;
+	struct ml_dest *mld;
+	struct iphdr *iph;
+	struct neighbour *n;
+	struct net_device *slave_dev;
+	int rv = 1;
+	int sl;
+
+	read_lock(&bond->lock);
+
+	if (!BOND_IS_OK(bond))
+		goto out;
+
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		iph = ip_hdr(skb);
+		if (!iph) {
+			pr_debug("b_x_ml: no iph\n");
+			goto out;
+		}
+
+		mlr = bond_ml_route_output(bond, iph->daddr);
+		if (!mlr) {
+			rv = bond_ml_discovery(bond, iph->daddr);
+			pr_debug("b_x_ml: %s disco s %pI4 d %pI4 rv %d\n",
+				 bond->dev->name, &iph->saddr, &iph->daddr, rv);
+			goto out;
+		}
+
+		sl = bond->xmit_hash_policy(skb, mlr->num_dest);
+		mld = bond_mlr_dest_output(mlr, sl);
+		if (!mld) {
+			pr_debug("b_x_ml: no mld sl %d n_d %d\n", sl,
+				 mlr->num_dest);
+			goto out;
+		}
+		if (!mld->slave) {
+			pr_debug("b_x_ml: no slave\n");
+			goto out;
+		}
+
+		n = mld->neigh;
+		if (n) {
+			slave_dev = mld->slave->dev;
+			rv = dev_hard_header(skb, slave_dev,
+					     ntohs(skb->protocol), n->ha,
+					     slave_dev->dev_addr, skb->len);
+		} else {
+			pr_debug("b_x_ml: no n\n");
+		}
+
+		rv = bond_dev_queue_xmit(bond, skb, mld->slave->dev);
+		break;
+
+	case htons(ETH_P_ARP):
+		pr_debug("b_x_ml: UNEXPECTED ARP\n");
+		break;
+
+	default:
+		rv = bond_dev_queue_xmit(bond, skb, bond->first_slave->dev);
+		break;
+	}
+
+out:
+	read_unlock(&bond->lock);
+	if (rv) {
+		pr_debug("xmit_ml rv %d\n", rv);
+		dev_kfree_skb(skb);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+static char *mlr_state_nm(int s)
+{
+	switch (s) {
+	case MLRT_COMPLETE:
+		return "C";
+	case MLRT_INCOMPLETE:
+		return "I";
+	case MLRT_EMPTY:
+		return "E";
+	default:
+		return "?";
+	}
+}
+
+static char *mlr_ipaddr_flag_nm(int f)
+{
+	switch (f) {
+	case MLDD_IF_UP:
+		return "UP";
+	case MLDD_IF_DOWN:
+		return "DN";
+	default:
+		return "??";
+	}
+}
+
+void bond_ml_show_proc_mlr(struct seq_file *seq, struct ml_route *mlr)
+{
+	struct ml_dest *mld;
+	int j;
+
+	for (j = 0; j < BOND_ML_NDEST; j++) {
+		mld = mlr->ml_dest[j];
+		if (mld)
+			seq_printf(seq, "   D %02d s %s l %pI4 r %pI4\n",
+				   j, mld->slave->dev->name,
+				   &mld->laddr, &mld->raddr);
+	}
+}
+
+void bond_ml_show_proc(struct seq_file *seq, struct bonding *bond)
+{
+	struct ml_route *mlr;
+	int i;
+
+	read_lock(&bond->lock);
+
+	for (i = 0; i < BOND_ML_HASH_SZ; i++) {
+		mlr = bond->ml_info.ml_rtable[i];
+
+		while (mlr) {
+			seq_printf(seq, "%02d s %s ndest %d ml_i: f %s %pI4\n",
+				   i, mlr_state_nm(mlr->state), mlr->num_dest,
+				   mlr_ipaddr_flag_nm(mlr->ml_ipaddr.flag),
+				   &mlr->ml_ipaddr.addr.s_addr);
+
+			if (mlr->state == MLRT_COMPLETE)
+				bond_ml_show_proc_mlr(seq, mlr);
+
+			mlr = mlr->next;
+		}
+	}
+
+	read_unlock(&bond->lock);
+}
+
+static const int ml_delta_in_ticks = HZ * 10;
+
+/*
+ * ML periodic monitor
+ *
+ * Walk the ML routing table.  For each entry, check its state.  Insure
+ * that ARP entries for ML routing entries are kept up to date.
+ */
+void bond_ml_monitor(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    ml_work.work);
+	struct ml_route *mlr;
+	struct ml_dest *mld;
+	struct neighbour *n;
+	int i, j, rv;
+
+	read_lock(&bond->lock);
+
+	if (bond->kill_timers)
+		goto out;
+
+	for (i = 0; i < BOND_ML_HASH_SZ; i++) {
+		mlr = bond->ml_info.ml_rtable[i];
+
+		while (mlr) {
+			if (mlr->state == MLRT_EMPTY) {
+				mlr = mlr->next;
+				continue;
+			}
+
+			for (j = 0; j < BOND_ML_NDEST; j++) {
+				mld = mlr->ml_dest[j];
+				if (!mld)
+					break;
+
+				n = __neigh_lookup(&arp_tbl, &mld->raddr,
+						   mld->slave->dev, 1);
+				if (n) {
+					n->used = jiffies;
+					rv = neigh_event_send(n, NULL);
+					neigh_release(n);
+				} else {
+					pr_debug("bmm: no n r %pI4 s %s\n",
+						 &mld->raddr,
+						 mld->slave->dev->name);
+				}
+			}
+
+			mlr = mlr->next;
+		}
+	}
+
+	queue_delayed_work(bond->wq, &bond->ml_work, ml_delta_in_ticks);
+out:
+	read_unlock(&bond->lock);
+}
+
+/*
+ * Use a limited set of header_ops.  At packet transmit time, we'll use
+ * the selected slave's ops to fill in the hard_header.
+ */
+static const struct header_ops bond_ml_header_ops = {
+	.create		= NULL,
+	.rebuild	= eth_rebuild_header,
+	.parse		= eth_header_parse,
+	.cache		= NULL,
+	.cache_update	= NULL,
+};
+
+/*
+ * called with bond->lock held for write
+ */
+void bond_ml_unbind_slave(struct bonding *bond, struct slave *slave)
+{
+	struct ml_route *mlr;
+	struct ml_dest *mld;
+	int i, j;
+
+	for (i = 0; i < BOND_ML_HASH_SZ; i++) {
+		mlr = bond->ml_info.ml_rtable[i];
+
+		while (mlr) {
+			for (j = 0; j < BOND_ML_NDEST; j++) {
+				mld = mlr->ml_dest[j];
+				if (mld && mld->slave == slave)
+					bond_mlr_dest_free(bond, mlr, mld);
+			}
+			mlr = mlr->next;
+		}
+	}
+}
+
+void bond_ml_init(struct bonding *bond)
+{
+	struct net_device *bond_dev = bond->dev;
+
+	memset(&bond->ml_info, 0, sizeof(bond->ml_info));
+
+	bond_dev->flags |= IFF_NOARP;
+	bond_dev->flags &= ~(IFF_MULTICAST | IFF_BROADCAST);
+	bond_dev->header_ops = &bond_ml_header_ops;
+
+	get_random_bytes(&bond_ml_salt, sizeof(bond_ml_salt));
+}
diff --git a/drivers/net/bonding/bond_ml.h b/drivers/net/bonding/bond_ml.h
new file mode 100644
index 0000000..0f7e417
--- /dev/null
+++ b/drivers/net/bonding/bond_ml.h
@@ -0,0 +1,88 @@
+/*
+ *
+ */
+#ifndef __BOND_ML_H__
+#define __BOND_ML_H__
+
+#define MLDD_IF_DOWN	0xc0
+#define MLDD_IF_UP	0xc1
+
+struct ml_ipaddr {
+	u8 ip_version;
+	u8 flag;
+	u16 tick;
+	struct in_addr addr;
+};
+
+#define MLDD_BCAST_REPLY	0xf0
+#define MLDD_UCAST_REPLY	0xf1
+#define MLDD_REQUEST		0xf2
+#define MLDD_LOOKUP		0xf3
+
+struct ml_msg {
+	u8 version;
+	u8 op;
+	u16 reserved1;
+	u32 num;
+	s32 request_index;
+	s32 reply_index;
+	struct ml_ipaddr ml_ipaddr;
+	u16 req_net;
+	u16 rep_net;
+};
+
+struct ml_dest {
+	struct slave *slave;
+	struct neighbour *neigh;
+	__be32 laddr;
+	__be32 raddr;
+};
+
+#define MLRT_COMPLETE	0xa0
+#define MLRT_INCOMPLETE 0xa1
+#define MLRT_EMPTY	0xa2
+
+/*
+ * The ML protocol is limited to 16 destinations per ML route.
+ */
+#define BOND_ML_NDEST 16
+
+/*
+ * An ML route contains one peer IP address, the "ML IP" address of the
+ * peer system.  Within that route are one or more destination entries
+ * that specify the various possible paths to reach the ML IP peer.  Each
+ * destination entry includes the local slave and the peer interface IP
+ * address at the destination.
+ */
+struct ml_route {
+	struct ml_route *next;
+	u16 state;
+	struct ml_ipaddr ml_ipaddr;
+	int num_dest;
+	unsigned long ml_dest_map;
+	struct ml_dest *ml_dest[BOND_ML_NDEST];
+};
+
+/*
+ * Hash by ML IP address
+ */
+#define BOND_ML_HASH_SZ		31
+
+struct ml_bond_info {
+	struct ml_route *ml_rtable[BOND_ML_HASH_SZ];
+};
+
+extern int bond_xmit_ml(struct sk_buff *skb, struct net_device *bond_dev);
+extern int bond_ml_changelink(struct bonding *bond, struct bond_ml_route *bmr);
+extern void bond_ml_monitor(struct work_struct *work);
+extern void bond_ml_show_proc(struct seq_file *, struct bonding *);
+extern void bond_ml_init(struct bonding *);
+extern int bond_ml_addrt(struct bonding *, struct in_addr, struct in_addr,
+			 struct in_addr, struct slave *);
+extern int bond_ml_delrt(struct bonding *, struct in_addr, struct in_addr,
+			 struct in_addr, struct slave *);
+extern void bond_ml_unbind_slave(struct bonding *bond, struct slave *slave);
+extern void bond_ml_rt_flush(struct bonding *bond);
+
+
+#endif /* __BOND_ML_H__ */
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index b77c772..754c475 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -57,6 +57,21 @@ static int bond_genl_validate(struct genl_info *info)
 		if (!info->attrs[BOND_GENL_ATTR_MASTER_INDEX])
 			return -EINVAL;
 		break;
+	case BOND_GENL_ML_CMD_RT_ADD:
+	case BOND_GENL_ML_CMD_RT_DEL:
+		if (!info->attrs[BOND_GENL_ATTR_ML_MLADDR])
+			return -EINVAL;
+		if (!info->attrs[BOND_GENL_ATTR_ML_LADDR])
+			return -EINVAL;
+		if (!info->attrs[BOND_GENL_ATTR_ML_RADDR])
+			return -EINVAL;
+		if (!info->attrs[BOND_GENL_ATTR_ML_INDEX])
+			return -EINVAL;
+		break;
+	case BOND_GENL_ML_CMD_RT_FLUSH:
+		if (!info->attrs[BOND_GENL_ATTR_MASTER_INDEX])
+			return -EINVAL;
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -139,11 +154,115 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static int bond_genl_ml_flush_route(struct sk_buff *skb, struct genl_info *info)
+{
+	struct bonding *bond;
+	struct net_device *bond_dev;
+	struct sk_buff *rep_skb = NULL;
+	void *reply;
+	u32 m_idx;
+	int rv;
+
+	rv = bond_genl_validate(info);
+	if (rv)
+		return rv;
+
+	m_idx = nla_get_u32(info->attrs[BOND_GENL_ATTR_MASTER_INDEX]);
+	bond_dev = dev_get_by_index(&init_net, m_idx);
+	if (!bond_dev || !(bond_dev->flags & IFF_MASTER) ||
+	    !(bond_dev->priv_flags & IFF_BONDING)) {
+		rv = -EINVAL;
+		goto out_err;
+	}
+
+	bond = netdev_priv(bond_dev);
+	bond_ml_rt_flush(bond);
+
+	rep_skb = genlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!rep_skb)
+		goto out_err;
+
+	reply = genlmsg_put_reply(rep_skb, info, &bond_genl_family, 0,
+				  info->genlhdr->cmd);
+	if (!reply)
+		goto out_err;
+
+	rv = genlmsg_end(rep_skb, reply);
+	if (rv < 0)
+		goto out_err;
+
+	return genlmsg_reply(rep_skb, info);
+
+out_err:
+	if (bond_dev)
+		dev_put(bond_dev);
+	if (rep_skb)
+		nlmsg_free(rep_skb);
+
+	return rv;
+}
+
+static int bond_genl_ml_chg_route(struct sk_buff *skb, struct genl_info *info)
+{
+	struct in_addr laddr, raddr, mladdr;
+	u32 l_idx;
+	struct net_device *slave_dev, *bond_dev;
+	struct bonding *bond;
+	struct slave *slave;
+	int rv, cmd;
+
+	rv = bond_genl_validate(info);
+	if (rv)
+		return rv;
+
+	laddr.s_addr = nla_get_u32(info->attrs[BOND_GENL_ATTR_ML_LADDR]);
+	raddr.s_addr = nla_get_u32(info->attrs[BOND_GENL_ATTR_ML_RADDR]);
+	mladdr.s_addr = nla_get_u32(info->attrs[BOND_GENL_ATTR_ML_MLADDR]);
+	l_idx = nla_get_u32(info->attrs[BOND_GENL_ATTR_ML_INDEX]);
+
+	cmd = info->genlhdr->cmd;
+
+	pr_debug("ml_route: cmd %d l %pI4 r %pI4 m %pI4 i %u\n",
+		 cmd, &laddr, &raddr, &mladdr, l_idx);
+
+	slave_dev = dev_get_by_index(&init_net, l_idx);
+	if (!slave_dev || !(slave_dev->priv_flags & IFF_BONDING))
+		return -EINVAL;
+
+	bond_dev = slave_dev->master;
+	if (!bond_dev || !(bond_dev->priv_flags & IFF_BONDING))
+		return -EINVAL;
+
+	bond = netdev_priv(bond_dev);
+
+	slave = bond_get_slave_by_dev(bond, slave_dev);
+	if (!slave)
+		return -EINVAL;
+
+	switch (cmd) {
+	case BOND_GENL_ML_CMD_RT_ADD:
+		rv = bond_ml_addrt(bond, laddr, raddr, mladdr, slave);
+		break;
+	case BOND_GENL_ML_CMD_RT_DEL:
+		rv = bond_ml_delrt(bond, laddr, raddr, mladdr, slave);
+		break;
+	default:
+		pr_debug("bond_genl_ml_route: impossible cmd %d\n", cmd);
+		return -EINVAL;
+	}
+
+	return rv;
+}
+
 static struct nla_policy bond_genl_policy[BOND_GENL_ATTR_MAX + 1] = {
 	[BOND_GENL_ATTR_MASTER_INDEX] = { .type = NLA_U32 },
 	[BOND_GENL_ATTR_SLAVE_INDEX] = { .type = NLA_U32 },
 	[BOND_GENL_ATTR_MODE] = { .type = NLA_U32 },
 	[BOND_GENL_ATTR_SLAVE_LINK] = { .type = NLA_U32 },
+	[BOND_GENL_ATTR_ML_LADDR] = { .type = NLA_U32 },
+	[BOND_GENL_ATTR_ML_RADDR] = { .type = NLA_U32 },
+	[BOND_GENL_ATTR_ML_MLADDR] = { .type = NLA_U32 },
+	[BOND_GENL_ATTR_ML_INDEX] = { .type = NLA_U32 },
 };
 
 static struct genl_ops bond_genl_ops[] = {
@@ -152,6 +271,21 @@ static struct genl_ops bond_genl_ops[] = {
 		.doit = bond_genl_get_mode,
 		.policy = bond_genl_policy,
 	},
+	{
+		.cmd = BOND_GENL_ML_CMD_RT_ADD,
+		.doit = bond_genl_ml_chg_route,
+		.policy = bond_genl_policy,
+	},
+	{
+		.cmd = BOND_GENL_ML_CMD_RT_DEL,
+		.doit = bond_genl_ml_chg_route,
+		.policy = bond_genl_policy,
+	},
+	{
+		.cmd = BOND_GENL_ML_CMD_RT_FLUSH,
+		.doit = bond_genl_ml_flush_route,
+		.policy = bond_genl_policy,
+	},
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/drivers/net/bonding/bond_netlink.h b/drivers/net/bonding/bond_netlink.h
index 030c2af..c979cdd 100644
--- a/drivers/net/bonding/bond_netlink.h
+++ b/drivers/net/bonding/bond_netlink.h
@@ -1,6 +1,11 @@
 
+extern struct genl_family bond_genl_family;
+extern struct genl_multicast_group bond_genl_mcgrp;
+extern int bond_nl_seq;
+
 extern int bond_nl_link_change(struct bonding *bond, struct slave *slave,
 			       int state);
 extern void bond_set_rtnl_link_ops(struct net_device *bond_dev);
 extern int bond_netlink_init(void);
 extern void bond_netlink_fini(void);
+
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ed09a79..e6bbd07 100644
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
@@ -365,6 +368,16 @@ static inline void bond_unset_master_alb_flags(struct bonding *bond)
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

