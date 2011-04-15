From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/3] bonding,ipv4,ipv6,vlan: Handle
 NETDEV_BONDING_FAILOVER like NETDEV_NOTIFY_PEERS
Date: Sat, 16 Apr 2011 00:47:51 +0100
Message-ID: <1302911271.2845.41.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6808 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab1DOXrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 19:47:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is undesirable for the bonding driver to be poking into higher
level protocols, and notifiers provide a way to avoid that.  This does
mean removing the ability to configure reptitition of gratuitous ARPs
and unsolicited NAs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/bonding/Makefile     |    3 -
 drivers/net/bonding/bond_ipv6.c  |  225 --------------------------------------
 drivers/net/bonding/bond_main.c  |   96 ----------------
 drivers/net/bonding/bond_sysfs.c |   80 --------------
 drivers/net/bonding/bonding.h    |   29 -----
 net/8021q/vlan.c                 |    3 +-
 net/ipv4/devinet.c               |    1 +
 net/ipv6/ndisc.c                 |    1 +
 8 files changed, 4 insertions(+), 434 deletions(-)
 delete mode 100644 drivers/net/bonding/bond_ipv6.c

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 3c5c014..4c21bf6 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -9,6 +9,3 @@ bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o bond_debugfs.o
 proc-$(CONFIG_PROC_FS) += bond_procfs.o
 bonding-objs += $(proc-y)
 
-ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
-bonding-objs += $(ipv6-y)
-
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
deleted file mode 100644
index 84fbd4e..0000000
--- a/drivers/net/bonding/bond_ipv6.c
+++ /dev/null
@@ -1,225 +0,0 @@
-/*
- * Copyright(c) 2008 Hewlett-Packard Development Company, L.P.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License as published by the
- * Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
- * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
- * for more details.
- *
- * You should have received a copy of the GNU General Public License along
- * with this program; if not, write to the Free Software Foundation, Inc.,
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- */
-
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
-#include <linux/types.h>
-#include <linux/if_vlan.h>
-#include <net/ipv6.h>
-#include <net/ndisc.h>
-#include <net/addrconf.h>
-#include <net/netns/generic.h>
-#include "bonding.h"
-
-/*
- * Assign bond->master_ipv6 to the next IPv6 address in the list, or
- * zero it out if there are none.
- */
-static void bond_glean_dev_ipv6(struct net_device *dev, struct in6_addr *addr)
-{
-	struct inet6_dev *idev;
-
-	if (!dev)
-		return;
-
-	idev = in6_dev_get(dev);
-	if (!idev)
-		return;
-
-	read_lock_bh(&idev->lock);
-	if (!list_empty(&idev->addr_list)) {
-		struct inet6_ifaddr *ifa
-			= list_first_entry(&idev->addr_list,
-					   struct inet6_ifaddr, if_list);
-		ipv6_addr_copy(addr, &ifa->addr);
-	} else
-		ipv6_addr_set(addr, 0, 0, 0, 0);
-
-	read_unlock_bh(&idev->lock);
-
-	in6_dev_put(idev);
-}
-
-static void bond_na_send(struct net_device *slave_dev,
-			 struct in6_addr *daddr,
-			 int router,
-			 unsigned short vlan_id)
-{
-	struct in6_addr mcaddr;
-	struct icmp6hdr icmp6h = {
-		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
-	};
-	struct sk_buff *skb;
-
-	icmp6h.icmp6_router = router;
-	icmp6h.icmp6_solicited = 0;
-	icmp6h.icmp6_override = 1;
-
-	addrconf_addr_solict_mult(daddr, &mcaddr);
-
-	pr_debug("ipv6 na on slave %s: dest %pI6, src %pI6\n",
-		 slave_dev->name, &mcaddr, daddr);
-
-	skb = ndisc_build_skb(slave_dev, &mcaddr, daddr, &icmp6h, daddr,
-			      ND_OPT_TARGET_LL_ADDR);
-
-	if (!skb) {
-		pr_err("NA packet allocation failed\n");
-		return;
-	}
-
-	if (vlan_id) {
-		/* The Ethernet header is not present yet, so it is
-		 * too early to insert a VLAN tag.  Force use of an
-		 * out-of-line tag here and let dev_hard_start_xmit()
-		 * insert it if the slave hardware can't.
-		 */
-		skb = __vlan_hwaccel_put_tag(skb, vlan_id);
-		if (!skb) {
-			pr_err("failed to insert VLAN tag\n");
-			return;
-		}
-	}
-
-	ndisc_send_skb(skb, slave_dev, NULL, &mcaddr, daddr, &icmp6h);
-}
-
-/*
- * Kick out an unsolicited Neighbor Advertisement for an IPv6 address on
- * the bonding master.  This will help the switch learn our address
- * if in active-backup mode.
- *
- * Caller must hold curr_slave_lock for read or better
- */
-void bond_send_unsolicited_na(struct bonding *bond)
-{
-	struct slave *slave = bond->curr_active_slave;
-	struct vlan_entry *vlan;
-	struct inet6_dev *idev;
-	int is_router;
-
-	pr_debug("%s: bond %s slave %s\n", bond->dev->name,
-		 __func__, slave ? slave->dev->name : "NULL");
-
-	if (!slave || !bond->send_unsol_na ||
-	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
-		return;
-
-	bond->send_unsol_na--;
-
-	idev = in6_dev_get(bond->dev);
-	if (!idev)
-		return;
-
-	is_router = !!idev->cnf.forwarding;
-
-	in6_dev_put(idev);
-
-	if (!ipv6_addr_any(&bond->master_ipv6))
-		bond_na_send(slave->dev, &bond->master_ipv6, is_router, 0);
-
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		if (!ipv6_addr_any(&vlan->vlan_ipv6)) {
-			bond_na_send(slave->dev, &vlan->vlan_ipv6, is_router,
-				     vlan->vlan_id);
-		}
-	}
-}
-
-/*
- * bond_inet6addr_event: handle inet6addr notifier chain events.
- *
- * We keep track of device IPv6 addresses primarily to use as source
- * addresses in NS probes.
- *
- * We track one IPv6 for the main device (if it has one).
- */
-static int bond_inet6addr_event(struct notifier_block *this,
-				unsigned long event,
-				void *ptr)
-{
-	struct inet6_ifaddr *ifa = ptr;
-	struct net_device *vlan_dev, *event_dev = ifa->idev->dev;
-	struct bonding *bond;
-	struct vlan_entry *vlan;
-	struct bond_net *bn = net_generic(dev_net(event_dev), bond_net_id);
-
-	list_for_each_entry(bond, &bn->dev_list, bond_list) {
-		if (bond->dev == event_dev) {
-			switch (event) {
-			case NETDEV_UP:
-				if (ipv6_addr_any(&bond->master_ipv6))
-					ipv6_addr_copy(&bond->master_ipv6,
-						       &ifa->addr);
-				return NOTIFY_OK;
-			case NETDEV_DOWN:
-				if (ipv6_addr_equal(&bond->master_ipv6,
-						    &ifa->addr))
-					bond_glean_dev_ipv6(bond->dev,
-							    &bond->master_ipv6);
-				return NOTIFY_OK;
-			default:
-				return NOTIFY_DONE;
-			}
-		}
-
-		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			if (!bond->vlgrp)
-				continue;
-			vlan_dev = vlan_group_get_device(bond->vlgrp,
-							 vlan->vlan_id);
-			if (vlan_dev == event_dev) {
-				switch (event) {
-				case NETDEV_UP:
-					if (ipv6_addr_any(&vlan->vlan_ipv6))
-						ipv6_addr_copy(&vlan->vlan_ipv6,
-							       &ifa->addr);
-					return NOTIFY_OK;
-				case NETDEV_DOWN:
-					if (ipv6_addr_equal(&vlan->vlan_ipv6,
-							    &ifa->addr))
-						bond_glean_dev_ipv6(vlan_dev,
-								    &vlan->vlan_ipv6);
-					return NOTIFY_OK;
-				default:
-					return NOTIFY_DONE;
-				}
-			}
-		}
-	}
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block bond_inet6addr_notifier = {
-	.notifier_call = bond_inet6addr_event,
-};
-
-void bond_register_ipv6_notifier(void)
-{
-	register_inet6addr_notifier(&bond_inet6addr_notifier);
-}
-
-void bond_unregister_ipv6_notifier(void)
-{
-	unregister_inet6addr_notifier(&bond_inet6addr_notifier);
-}
-
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b51e021..5cd4766 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -89,8 +89,6 @@
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int tx_queues	= BOND_DEFAULT_TX_QUEUES;
-static int num_grat_arp = 1;
-static int num_unsol_na = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
 static int updelay;
 static int downdelay;
@@ -113,10 +111,6 @@ module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
 module_param(tx_queues, int, 0);
 MODULE_PARM_DESC(tx_queues, "Max number of transmit queues (default = 16)");
-module_param(num_grat_arp, int, 0644);
-MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packets to send on failover event");
-module_param(num_unsol_na, int, 0644);
-MODULE_PARM_DESC(num_unsol_na, "Number of unsolicited IPv6 Neighbor Advertisements packets to send on failover event");
 module_param(miimon, int, 0);
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 module_param(updelay, int, 0);
@@ -234,7 +228,6 @@ struct bond_parm_tbl ad_select_tbl[] = {
 
 /*-------------------------- Forward declarations ---------------------------*/
 
-static void bond_send_gratuitous_arp(struct bonding *bond);
 static int bond_init(struct net_device *bond_dev);
 static void bond_uninit(struct net_device *bond_dev);
 
@@ -1160,14 +1153,6 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 				bond_do_fail_over_mac(bond, new_active,
 						      old_active);
 
-			if (netif_running(bond->dev)) {
-				bond->send_grat_arp = bond->params.num_grat_arp;
-				bond_send_gratuitous_arp(bond);
-
-				bond->send_unsol_na = bond->params.num_unsol_na;
-				bond_send_unsolicited_na(bond);
-			}
-
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
 
@@ -2578,18 +2563,6 @@ void bond_mii_monitor(struct work_struct *work)
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
-	if (bond->send_grat_arp) {
-		read_lock(&bond->curr_slave_lock);
-		bond_send_gratuitous_arp(bond);
-		read_unlock(&bond->curr_slave_lock);
-	}
-
-	if (bond->send_unsol_na) {
-		read_lock(&bond->curr_slave_lock);
-		bond_send_unsolicited_na(bond);
-		read_unlock(&bond->curr_slave_lock);
-	}
-
 	if (bond_miimon_inspect(bond)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -2751,44 +2724,6 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 	}
 }
 
-/*
- * Kick out a gratuitous ARP for an IP on the bonding master plus one
- * for each VLAN above us.
- *
- * Caller must hold curr_slave_lock for read or better
- */
-static void bond_send_gratuitous_arp(struct bonding *bond)
-{
-	struct slave *slave = bond->curr_active_slave;
-	struct vlan_entry *vlan;
-	struct net_device *vlan_dev;
-
-	pr_debug("bond_send_grat_arp: bond %s slave %s\n",
-		 bond->dev->name, slave ? slave->dev->name : "NULL");
-
-	if (!slave || !bond->send_grat_arp ||
-	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
-		return;
-
-	bond->send_grat_arp--;
-
-	if (bond->master_ip) {
-		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
-				bond->master_ip, 0);
-	}
-
-	if (!bond->vlgrp)
-		return;
-
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
-		if (vlan->vlan_ip) {
-			bond_arp_send(slave->dev, ARPOP_REPLY, vlan->vlan_ip,
-				      vlan->vlan_ip, vlan->vlan_id);
-		}
-	}
-}
-
 static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32 sip, __be32 tip)
 {
 	int i;
@@ -3255,18 +3190,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
-	if (bond->send_grat_arp) {
-		read_lock(&bond->curr_slave_lock);
-		bond_send_gratuitous_arp(bond);
-		read_unlock(&bond->curr_slave_lock);
-	}
-
-	if (bond->send_unsol_na) {
-		read_lock(&bond->curr_slave_lock);
-		bond_send_unsolicited_na(bond);
-		read_unlock(&bond->curr_slave_lock);
-	}
-
 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3645,9 +3568,6 @@ static int bond_close(struct net_device *bond_dev)
 
 	write_lock_bh(&bond->lock);
 
-	bond->send_grat_arp = 0;
-	bond->send_unsol_na = 0;
-
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
 
@@ -4724,18 +4644,6 @@ static int bond_check_params(struct bond_params *params)
 		use_carrier = 1;
 	}
 
-	if (num_grat_arp < 0 || num_grat_arp > 255) {
-		pr_warning("Warning: num_grat_arp (%d) not in range 0-255 so it was reset to 1\n",
-			   num_grat_arp);
-		num_grat_arp = 1;
-	}
-
-	if (num_unsol_na < 0 || num_unsol_na > 255) {
-		pr_warning("Warning: num_unsol_na (%d) not in range 0-255 so it was reset to 1\n",
-			   num_unsol_na);
-		num_unsol_na = 1;
-	}
-
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
 		if (!miimon) {
@@ -4925,8 +4833,6 @@ static int bond_check_params(struct bond_params *params)
 	params->mode = bond_mode;
 	params->xmit_policy = xmit_hashtype;
 	params->miimon = miimon;
-	params->num_grat_arp = num_grat_arp;
-	params->num_unsol_na = num_unsol_na;
 	params->arp_interval = arp_interval;
 	params->arp_validate = arp_validate_value;
 	params->updelay = updelay;
@@ -5121,7 +5027,6 @@ static int __init bonding_init(void)
 
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
-	bond_register_ipv6_notifier();
 out:
 	return res;
 err:
@@ -5136,7 +5041,6 @@ static void __exit bonding_exit(void)
 {
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
-	bond_unregister_ipv6_notifier();
 
 	bond_destroy_sysfs();
 	bond_destroy_debugfs();
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index de87aea..259ff32 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -874,84 +874,6 @@ static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR,
 		   bonding_show_ad_select, bonding_store_ad_select);
 
 /*
- * Show and set the number of grat ARP to send after a failover event.
- */
-static ssize_t bonding_show_n_grat_arp(struct device *d,
-				   struct device_attribute *attr,
-				   char *buf)
-{
-	struct bonding *bond = to_bond(d);
-
-	return sprintf(buf, "%d\n", bond->params.num_grat_arp);
-}
-
-static ssize_t bonding_store_n_grat_arp(struct device *d,
-				    struct device_attribute *attr,
-				    const char *buf, size_t count)
-{
-	int new_value, ret = count;
-	struct bonding *bond = to_bond(d);
-
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no num_grat_arp value specified.\n",
-		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-	if (new_value < 0 || new_value > 255) {
-		pr_err("%s: Invalid num_grat_arp value %d not in range 0-255; rejected.\n",
-		       bond->dev->name, new_value);
-		ret = -EINVAL;
-		goto out;
-	} else {
-		bond->params.num_grat_arp = new_value;
-	}
-out:
-	return ret;
-}
-static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR,
-		   bonding_show_n_grat_arp, bonding_store_n_grat_arp);
-
-/*
- * Show and set the number of unsolicited NA's to send after a failover event.
- */
-static ssize_t bonding_show_n_unsol_na(struct device *d,
-				       struct device_attribute *attr,
-				       char *buf)
-{
-	struct bonding *bond = to_bond(d);
-
-	return sprintf(buf, "%d\n", bond->params.num_unsol_na);
-}
-
-static ssize_t bonding_store_n_unsol_na(struct device *d,
-					struct device_attribute *attr,
-					const char *buf, size_t count)
-{
-	int new_value, ret = count;
-	struct bonding *bond = to_bond(d);
-
-	if (sscanf(buf, "%d", &new_value) != 1) {
-		pr_err("%s: no num_unsol_na value specified.\n",
-		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
-	}
-
-	if (new_value < 0 || new_value > 255) {
-		pr_err("%s: Invalid num_unsol_na value %d not in range 0-255; rejected.\n",
-		       bond->dev->name, new_value);
-		ret = -EINVAL;
-		goto out;
-	} else
-		bond->params.num_unsol_na = new_value;
-out:
-	return ret;
-}
-static DEVICE_ATTR(num_unsol_na, S_IRUGO | S_IWUSR,
-		   bonding_show_n_unsol_na, bonding_store_n_unsol_na);
-
-/*
  * Show and set the MII monitor interval.  There are two tricky bits
  * here.  First, if MII monitoring is activated, then we must disable
  * ARP monitoring.  Second, if the timer isn't running, we must
@@ -1650,8 +1572,6 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_lacp_rate.attr,
 	&dev_attr_ad_select.attr,
 	&dev_attr_xmit_hash_policy.attr,
-	&dev_attr_num_grat_arp.attr,
-	&dev_attr_num_unsol_na.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
 	&dev_attr_primary_reselect.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 90736cb..77180b1 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -149,8 +149,6 @@ struct bond_params {
 	int mode;
 	int xmit_policy;
 	int miimon;
-	int num_grat_arp;
-	int num_unsol_na;
 	int arp_interval;
 	int arp_validate;
 	int use_carrier;
@@ -178,9 +176,6 @@ struct vlan_entry {
 	struct list_head vlan_list;
 	__be32 vlan_ip;
 	unsigned short vlan_id;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct in6_addr vlan_ipv6;
-#endif
 };
 
 struct slave {
@@ -234,8 +229,6 @@ struct bonding {
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
 	s8       kill_timers;
-	s8	 send_grat_arp;
-	s8	 send_unsol_na;
 	s8	 setup_by_slave;
 	s8       igmp_retrans;
 #ifdef CONFIG_PROC_FS
@@ -260,9 +253,6 @@ struct bonding {
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
 	struct   delayed_work mcast_work;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	struct   in6_addr master_ipv6;
-#endif
 #ifdef CONFIG_DEBUG_FS
 	/* debugging suport via debugfs */
 	struct	 dentry *debug_dir;
@@ -459,23 +449,4 @@ extern const struct bond_parm_tbl fail_over_mac_tbl[];
 extern const struct bond_parm_tbl pri_reselect_tbl[];
 extern struct bond_parm_tbl ad_select_tbl[];
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-void bond_send_unsolicited_na(struct bonding *bond);
-void bond_register_ipv6_notifier(void);
-void bond_unregister_ipv6_notifier(void);
-#else
-static inline void bond_send_unsolicited_na(struct bonding *bond)
-{
-	return;
-}
-static inline void bond_register_ipv6_notifier(void)
-{
-	return;
-}
-static inline void bond_unregister_ipv6_notifier(void)
-{
-	return;
-}
-#endif
-
 #endif /* _LINUX_BONDING_H */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b2ff70f..969e700 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -501,13 +501,14 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		return NOTIFY_BAD;
 
 	case NETDEV_NOTIFY_PEERS:
+	case NETDEV_BONDING_FAILOVER:
 		/* Propagate to vlan devices */
 		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
 
-			call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, vlandev);
+			call_netdevice_notifiers(event, vlandev);
 		}
 		break;
 	}
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5345b0b..acf553f 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1203,6 +1203,7 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 			break;
 		/* fall through */
 	case NETDEV_NOTIFY_PEERS:
+	case NETDEV_BONDING_FAILOVER:
 		/* Send gratuitous ARP to notify of link change */
 		inetdev_send_gratuitous_arp(dev, in_dev);
 		break;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index a51fa74c..6f7d491 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1746,6 +1746,7 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
 		fib6_run_gc(~0UL, net);
 		break;
 	case NETDEV_NOTIFY_PEERS:
+	case NETDEV_BONDING_FAILOVER:
 		ndisc_send_unsol_na(dev);
 		break;
 	default:
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

