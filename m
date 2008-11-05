From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/3] bonding: send IPv6 neighbor advertisement on failover
Date: Tue,  4 Nov 2008 17:51:14 -0800
Message-ID: <1225849876-8930-2-git-send-email-fubar@us.ibm.com>
References: <1225849876-8930-1-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Brian Haley <brian.haley@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:55663 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045AbYKEBvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 20:51:21 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id mA51pKTH015894
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:20 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA51pKMT118822
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:20 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA51pJUm019852
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2008 20:51:20 -0500
In-Reply-To: <1225849876-8930-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>

This patch adds better IPv6 failover support for bonding devices,
especially when in active-backup mode and there are only IPv6 addresses
configured, as reported by Alex Sidorenko.

- Creates a new file, net/drivers/bonding/bond_ipv6.c, for the
   IPv6-specific routines.  Both regular bonds and VLANs over bonds
   are supported.

- Adds a new tunable, num_unsol_na, to limit the number of unsolicited
   IPv6 Neighbor Advertisements that are sent on a failover event.
   Default is 1.

- Creates two new IPv6 neighbor discovery functions:

   ndisc_build_skb()
   ndisc_send_skb()

   These were required to support VLANs since we have to be able to
   add the VLAN id to the skb since ndisc_send_na() and friends
   shouldn't be asked to do this.  These two routines are basically
   __ndisc_send() split into two pieces, in a slightly different order.

- Updates Documentation/networking/bonding.txt and bumps the rev of bond
   support to 3.4.0.

On failover, this new code will generate one packet:

- An unsolicited IPv6 Neighbor Advertisement, which helps the switch
   learn that the address has moved to the new slave.

Testing has shown that sending just the NA results in pretty good
behavior when in active-back mode, I saw no lost ping packets for example.

Signed-off-by: Brian Haley <brian.haley@hp.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 Documentation/networking/bonding.txt |   10 ++
 drivers/net/Kconfig                  |    1 +
 drivers/net/bonding/Makefile         |    3 +
 drivers/net/bonding/bond_ipv6.c      |  218 ++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_main.c      |   33 +++++-
 drivers/net/bonding/bond_sysfs.c     |   42 +++++++
 drivers/net/bonding/bonding.h        |   34 +++++-
 include/net/ndisc.h                  |   14 ++
 net/ipv6/ndisc.c                     |   92 ++++++++++----
 9 files changed, 416 insertions(+), 31 deletions(-)
 create mode 100644 drivers/net/bonding/bond_ipv6.c

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index d733a42..3f4d0fa 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -551,6 +551,16 @@ num_grat_arp
 	affects only the active-backup mode.  This option was added for
 	bonding version 3.3.0.
 
+num_unsol_na
+
+	Specifies the number of unsolicited IPv6 Neighbor Advertisements
+	to be issued after a failover event.  One unsolicited NA is issued
+	immediately after the failover.
+
+	The valid range is 0 - 255; the default value is 1.  This option
+	affects only the active-backup mode.  This option was added for
+	bonding version 3.4.0.
+
 primary
 
 	A string (eth0, eth2, etc) specifying which slave is the
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0f3e6b2..f1d0a13 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -61,6 +61,7 @@ config DUMMY
 config BONDING
 	tristate "Bonding driver support"
 	depends on INET
+	depends on IPV6 || IPV6=n
 	---help---
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
 	  Channels together. This is called 'Etherchannel' by Cisco,
diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 5cdae2b..6f9c6fa 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -6,3 +6,6 @@ obj-$(CONFIG_BONDING) += bonding.o
 
 bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
 
+ipv6-$(subst m,y,$(CONFIG_IPV6)) += bond_ipv6.o
+bonding-objs += $(ipv6-y)
+
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
new file mode 100644
index 0000000..7c78b7b
--- /dev/null
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -0,0 +1,218 @@
+/*
+ * Copyright(c) 2008 Hewlett-Packard Development Company, L.P.
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
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ */
+
+//#define BONDING_DEBUG 1
+
+#include <linux/types.h>
+#include <linux/if_vlan.h>
+#include <net/ipv6.h>
+#include <net/ndisc.h>
+#include <net/addrconf.h>
+#include "bonding.h"
+
+/*
+ * Assign bond->master_ipv6 to the next IPv6 address in the list, or
+ * zero it out if there are none.
+ */
+static void bond_glean_dev_ipv6(struct net_device *dev, struct in6_addr *addr)
+{
+	struct inet6_dev *idev;
+	struct inet6_ifaddr *ifa;
+
+	if (!dev)
+		return;
+
+	idev = in6_dev_get(dev);
+	if (!idev)
+		return;
+
+	read_lock_bh(&idev->lock);
+	ifa = idev->addr_list;
+	if (ifa)
+		ipv6_addr_copy(addr, &ifa->addr);
+	else
+		ipv6_addr_set(addr, 0, 0, 0, 0);
+
+	read_unlock_bh(&idev->lock);
+
+	in6_dev_put(idev);
+}
+
+static void bond_na_send(struct net_device *slave_dev,
+			 struct in6_addr *daddr,
+			 int router,
+			 unsigned short vlan_id)
+{
+	struct in6_addr mcaddr;
+	struct icmp6hdr icmp6h = {
+		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
+	};
+	struct sk_buff *skb;
+
+	icmp6h.icmp6_router = router;
+	icmp6h.icmp6_solicited = 0;
+	icmp6h.icmp6_override = 1;
+
+	addrconf_addr_solict_mult(daddr, &mcaddr);
+
+	dprintk("ipv6 na on slave %s: dest %pI6, src %pI6\n",
+	       slave->name, &mcaddr, daddr);
+
+	skb = ndisc_build_skb(slave_dev, &mcaddr, daddr, &icmp6h, daddr,
+			      ND_OPT_TARGET_LL_ADDR);
+
+	if (!skb) {
+		printk(KERN_ERR DRV_NAME ": NA packet allocation failed\n");
+		return;
+	}
+
+	if (vlan_id) {
+		skb = vlan_put_tag(skb, vlan_id);
+		if (!skb) {
+			printk(KERN_ERR DRV_NAME ": failed to insert VLAN tag\n");
+			return;
+		}
+	}
+
+	ndisc_send_skb(skb, slave_dev, NULL, &mcaddr, daddr, &icmp6h);
+}
+
+/*
+ * Kick out an unsolicited Neighbor Advertisement for an IPv6 address on
+ * the bonding master.  This will help the switch learn our address
+ * if in active-backup mode.
+ *
+ * Caller must hold curr_slave_lock for read or better
+ */
+void bond_send_unsolicited_na(struct bonding *bond)
+{
+	struct slave *slave = bond->curr_active_slave;
+	struct vlan_entry *vlan;
+	struct inet6_dev *idev;
+	int is_router;
+
+	dprintk("bond_send_unsol_na: bond %s slave %s\n", bond->dev->name,
+				slave ? slave->dev->name : "NULL");
+
+	if (!slave || !bond->send_unsol_na ||
+	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
+		return;
+
+	bond->send_unsol_na--;
+
+	idev = in6_dev_get(bond->dev);
+	if (!idev)
+		return;
+
+	is_router = !!idev->cnf.forwarding;
+
+	in6_dev_put(idev);
+
+	if (!ipv6_addr_any(&bond->master_ipv6))
+		bond_na_send(slave->dev, &bond->master_ipv6, is_router, 0);
+
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+		if (!ipv6_addr_any(&vlan->vlan_ipv6)) {
+			bond_na_send(slave->dev, &vlan->vlan_ipv6, is_router,
+				     vlan->vlan_id);
+		}
+	}
+}
+
+/*
+ * bond_inet6addr_event: handle inet6addr notifier chain events.
+ *
+ * We keep track of device IPv6 addresses primarily to use as source
+ * addresses in NS probes.
+ *
+ * We track one IPv6 for the main device (if it has one).
+ */
+static int bond_inet6addr_event(struct notifier_block *this,
+				unsigned long event,
+				void *ptr)
+{
+	struct inet6_ifaddr *ifa = ptr;
+	struct net_device *vlan_dev, *event_dev = ifa->idev->dev;
+	struct bonding *bond;
+	struct vlan_entry *vlan;
+
+	if (dev_net(event_dev) != &init_net)
+		return NOTIFY_DONE;
+
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+		if (bond->dev == event_dev) {
+			switch (event) {
+			case NETDEV_UP:
+				if (ipv6_addr_any(&bond->master_ipv6))
+					ipv6_addr_copy(&bond->master_ipv6,
+						       &ifa->addr);
+				return NOTIFY_OK;
+			case NETDEV_DOWN:
+				if (ipv6_addr_equal(&bond->master_ipv6,
+						    &ifa->addr))
+					bond_glean_dev_ipv6(bond->dev,
+							    &bond->master_ipv6);
+				return NOTIFY_OK;
+			default:
+				return NOTIFY_DONE;
+			}
+		}
+
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+			vlan_dev = vlan_group_get_device(bond->vlgrp,
+							 vlan->vlan_id);
+			if (vlan_dev == event_dev) {
+				switch (event) {
+				case NETDEV_UP:
+					if (ipv6_addr_any(&vlan->vlan_ipv6))
+						ipv6_addr_copy(&vlan->vlan_ipv6,
+							       &ifa->addr);
+					return NOTIFY_OK;
+				case NETDEV_DOWN:
+					if (ipv6_addr_equal(&vlan->vlan_ipv6,
+							    &ifa->addr))
+						bond_glean_dev_ipv6(vlan_dev,
+								    &vlan->vlan_ipv6);
+					return NOTIFY_OK;
+				default:
+					return NOTIFY_DONE;
+				}
+			}
+		}
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block bond_inet6addr_notifier = {
+	.notifier_call = bond_inet6addr_event,
+};
+
+void bond_register_ipv6_notifier(void)
+{
+	register_inet6addr_notifier(&bond_inet6addr_notifier);
+}
+
+void bond_unregister_ipv6_notifier(void)
+{
+	unregister_inet6addr_notifier(&bond_inet6addr_notifier);
+}
+
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 39575d7..798d98c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -89,6 +89,7 @@
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int num_grat_arp = 1;
+static int num_unsol_na = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
 static int updelay	= 0;
 static int downdelay	= 0;
@@ -107,6 +108,8 @@ module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
 module_param(num_grat_arp, int, 0644);
 MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packets to send on failover event");
+module_param(num_unsol_na, int, 0644);
+MODULE_PARM_DESC(num_unsol_na, "Number of unsolicited IPv6 Neighbor Advertisements packets to send on failover event");
 module_param(miimon, int, 0);
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 module_param(updelay, int, 0);
@@ -242,14 +245,13 @@ static int bond_add_vlan(struct bonding *bond, unsigned short vlan_id)
 	dprintk("bond: %s, vlan id %d\n",
 		(bond ? bond->dev->name: "None"), vlan_id);
 
-	vlan = kmalloc(sizeof(struct vlan_entry), GFP_KERNEL);
+	vlan = kzalloc(sizeof(struct vlan_entry), GFP_KERNEL);
 	if (!vlan) {
 		return -ENOMEM;
 	}
 
 	INIT_LIST_HEAD(&vlan->vlan_list);
 	vlan->vlan_id = vlan_id;
-	vlan->vlan_ip = 0;
 
 	write_lock_bh(&bond->lock);
 
@@ -1208,6 +1210,9 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			bond->send_grat_arp = bond->params.num_grat_arp;
 			bond_send_gratuitous_arp(bond);
 
+			bond->send_unsol_na = bond->params.num_unsol_na;
+			bond_send_unsolicited_na(bond);
+
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
 
@@ -2463,6 +2468,12 @@ void bond_mii_monitor(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
+	if (bond->send_unsol_na) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_unsolicited_na(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (bond_miimon_inspect(bond)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3158,6 +3169,12 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
+	if (bond->send_unsol_na) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_unsolicited_na(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3827,6 +3844,7 @@ static int bond_close(struct net_device *bond_dev)
 	write_lock_bh(&bond->lock);
 
 	bond->send_grat_arp = 0;
+	bond->send_unsol_na = 0;
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
@@ -4542,6 +4560,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
 	bond->send_grat_arp = 0;
+	bond->send_unsol_na = 0;
 	bond->setup_by_slave = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
@@ -4791,6 +4810,13 @@ static int bond_check_params(struct bond_params *params)
 		num_grat_arp = 1;
 	}
 
+	if (num_unsol_na < 0 || num_unsol_na > 255) {
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: num_unsol_na (%d) not in range 0-255 so it "
+		       "was reset to 1 \n", num_unsol_na);
+		num_unsol_na = 1;
+	}
+
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
 		if (!miimon) {
@@ -4992,6 +5018,7 @@ static int bond_check_params(struct bond_params *params)
 	params->xmit_policy = xmit_hashtype;
 	params->miimon = miimon;
 	params->num_grat_arp = num_grat_arp;
+	params->num_unsol_na = num_unsol_na;
 	params->arp_interval = arp_interval;
 	params->arp_validate = arp_validate_value;
 	params->updelay = updelay;
@@ -5144,6 +5171,7 @@ static int __init bonding_init(void)
 
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
+	bond_register_ipv6_notifier();
 
 	goto out;
 err:
@@ -5166,6 +5194,7 @@ static void __exit bonding_exit(void)
 {
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
+	bond_unregister_ipv6_notifier();
 
 	bond_destroy_sysfs();
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index e400d7d..8788e3e 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -983,6 +983,47 @@ out:
 	return ret;
 }
 static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR, bonding_show_n_grat_arp, bonding_store_n_grat_arp);
+
+/*
+ * Show and set the number of unsolicted NA's to send after a failover event.
+ */
+static ssize_t bonding_show_n_unsol_na(struct device *d,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.num_unsol_na);
+}
+
+static ssize_t bonding_store_n_unsol_na(struct device *d,
+					struct device_attribute *attr,
+					const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: no num_unsol_na value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (new_value < 0 || new_value > 255) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Invalid num_unsol_na value %d not in range 0-255; rejected.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		bond->params.num_unsol_na = new_value;
+	}
+out:
+	return ret;
+}
+static DEVICE_ATTR(num_unsol_na, S_IRUGO | S_IWUSR, bonding_show_n_unsol_na, bonding_store_n_unsol_na);
+
 /*
  * Show and set the MII monitor interval.  There are two tricky bits
  * here.  First, if MII monitoring is activated, then we must disable
@@ -1420,6 +1461,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_lacp_rate.attr,
 	&dev_attr_xmit_hash_policy.attr,
 	&dev_attr_num_grat_arp.attr,
+	&dev_attr_num_unsol_na.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
 	&dev_attr_use_carrier.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ffb668d..0491c7c 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -19,16 +19,19 @@
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
 #include <linux/kobject.h>
+#include <linux/in6.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.3.0"
-#define DRV_RELDATE	"June 10, 2008"
+#define DRV_VERSION	"3.4.0"
+#define DRV_RELDATE	"October 7, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
 #define BOND_MAX_ARP_TARGETS	16
 
+extern struct list_head bond_dev_list;
+
 #ifdef BONDING_DEBUG
 #define dprintk(fmt, args...) \
 	printk(KERN_DEBUG     \
@@ -126,6 +129,7 @@ struct bond_params {
 	int xmit_policy;
 	int miimon;
 	int num_grat_arp;
+	int num_unsol_na;
 	int arp_interval;
 	int arp_validate;
 	int use_carrier;
@@ -148,6 +152,9 @@ struct vlan_entry {
 	struct list_head vlan_list;
 	__be32 vlan_ip;
 	unsigned short vlan_id;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct in6_addr vlan_ipv6;
+#endif
 };
 
 struct slave {
@@ -195,6 +202,7 @@ struct bonding {
 	rwlock_t curr_slave_lock;
 	s8       kill_timers;
 	s8	 send_grat_arp;
+	s8	 send_unsol_na;
 	s8	 setup_by_slave;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
@@ -218,6 +226,9 @@ struct bonding {
 	struct   delayed_work arp_work;
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	struct   in6_addr master_ipv6;
+#endif
 };
 
 /**
@@ -341,5 +352,24 @@ extern struct bond_parm_tbl xmit_hashtype_tbl[];
 extern struct bond_parm_tbl arp_validate_tbl[];
 extern struct bond_parm_tbl fail_over_mac_tbl[];
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+void bond_send_unsolicited_na(struct bonding *bond);
+void bond_register_ipv6_notifier(void);
+void bond_unregister_ipv6_notifier(void);
+#else
+static inline void bond_send_unsolicited_na(struct bonding *bond)
+{
+	return;
+}
+static inline void bond_register_ipv6_notifier(void)
+{
+	return;
+}
+static inline void bond_unregister_ipv6_notifier(void)
+{
+	return;
+}
+#endif
+
 #endif /* _LINUX_BONDING_H */
 
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 11dd013..ce532f2 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -108,6 +108,20 @@ extern void			ndisc_send_redirect(struct sk_buff *skb,
 
 extern int			ndisc_mc_map(struct in6_addr *addr, char *buf, struct net_device *dev, int dir);
 
+extern struct sk_buff		*ndisc_build_skb(struct net_device *dev,
+						 const struct in6_addr *daddr,
+						 const struct in6_addr *saddr,
+						 struct icmp6hdr *icmp6h,
+						 const struct in6_addr *target,
+						 int llinfo);
+
+extern void			ndisc_send_skb(struct sk_buff *skb,
+					       struct net_device *dev,
+					       struct neighbour *neigh,
+					       const struct in6_addr *daddr,
+					       const struct in6_addr *saddr,
+					       struct icmp6hdr *icmp6h);
+
 
 
 /*
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2a6752d..fbf451c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -437,38 +437,20 @@ static void pndisc_destructor(struct pneigh_entry *n)
 	ipv6_dev_mc_dec(dev, &maddr);
 }
 
-/*
- *	Send a Neighbour Advertisement
- */
-static void __ndisc_send(struct net_device *dev,
-			 struct neighbour *neigh,
-			 const struct in6_addr *daddr,
-			 const struct in6_addr *saddr,
-			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
-			 int llinfo)
+struct sk_buff *ndisc_build_skb(struct net_device *dev,
+				const struct in6_addr *daddr,
+				const struct in6_addr *saddr,
+				struct icmp6hdr *icmp6h,
+				const struct in6_addr *target,
+				int llinfo)
 {
-	struct flowi fl;
-	struct dst_entry *dst;
 	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
-	struct inet6_dev *idev;
 	int len;
 	int err;
-	u8 *opt, type;
-
-	type = icmp6h->icmp6_type;
-
-	icmpv6_flow_init(sk, &fl, type, saddr, daddr, dev->ifindex);
-
-	dst = icmp6_dst_alloc(dev, neigh, daddr);
-	if (!dst)
-		return;
-
-	err = xfrm_lookup(&dst, &fl, NULL, 0);
-	if (err < 0)
-		return;
+	u8 *opt;
 
 	if (!dev->addr_len)
 		llinfo = 0;
@@ -485,8 +467,7 @@ static void __ndisc_send(struct net_device *dev,
 		ND_PRINTK0(KERN_ERR
 			   "ICMPv6 ND: %s() failed to allocate an skb.\n",
 			   __func__);
-		dst_release(dst);
-		return;
+		return NULL;
 	}
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
@@ -513,6 +494,42 @@ static void __ndisc_send(struct net_device *dev,
 					   csum_partial((__u8 *) hdr,
 							len, 0));
 
+	return skb;
+}
+
+EXPORT_SYMBOL(ndisc_build_skb);
+
+void ndisc_send_skb(struct sk_buff *skb,
+		    struct net_device *dev,
+		    struct neighbour *neigh,
+		    const struct in6_addr *daddr,
+		    const struct in6_addr *saddr,
+		    struct icmp6hdr *icmp6h)
+{
+	struct flowi fl;
+	struct dst_entry *dst;
+	struct net *net = dev_net(dev);
+	struct sock *sk = net->ipv6.ndisc_sk;
+	struct inet6_dev *idev;
+	int err;
+	u8 type;
+
+	type = icmp6h->icmp6_type;
+
+	icmpv6_flow_init(sk, &fl, type, saddr, daddr, dev->ifindex);
+
+	dst = icmp6_dst_alloc(dev, neigh, daddr);
+	if (!dst) {
+		kfree_skb(skb);
+		return;
+	}
+
+	err = xfrm_lookup(&dst, &fl, NULL, 0);
+	if (err < 0) {
+		kfree_skb(skb);
+		return;
+	}
+
 	skb->dst = dst;
 
 	idev = in6_dev_get(dst->dev);
@@ -529,6 +546,27 @@ static void __ndisc_send(struct net_device *dev,
 		in6_dev_put(idev);
 }
 
+EXPORT_SYMBOL(ndisc_send_skb);
+
+/*
+ *	Send a Neighbour Discover packet
+ */
+static void __ndisc_send(struct net_device *dev,
+			 struct neighbour *neigh,
+			 const struct in6_addr *daddr,
+			 const struct in6_addr *saddr,
+			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
+			 int llinfo)
+{
+	struct sk_buff *skb;
+
+	skb = ndisc_build_skb(dev, daddr, saddr, icmp6h, target, llinfo);
+	if (!skb)
+		return;
+
+	ndisc_send_skb(skb, dev, neigh, daddr, saddr, icmp6h);
+}
+
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 			  const struct in6_addr *daddr,
 			  const struct in6_addr *solicited_addr,
-- 
1.6.0.2

