From: Brian Haley <brian.haley@hp.com>
Subject: [RFC] bonding: add better ipv6 failover support
Date: Wed, 24 Sep 2008 22:46:42 -0400
Message-ID: <48DAFB92.7040904@hp.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org> <200809151416.49447.alexandre.sidorenko@hp.com> <48DA71A8.5050900@hp.com> <7958.1222288188@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030108040707040305040006"
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:1949 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbYIYCqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 22:46:45 -0400
In-Reply-To: <7958.1222288188@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030108040707040305040006
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This is an RFC patch to add better IPv6 failover support for bonding 
devices, especially when in active-backup mode, as reported by Alex 
Sidorenko.

What this patch does:

- Creates a new Kconfig option in the IPv6 Networking section to
   compile-in the support in the bonding driver.  This also forces
   IPV6=y since that's required to link everything.

- Creates a new file, net/drivers/bonding/bond_ipv6.c, for the
   IPv6-specific routines.

- Adds a new master_ipv6 address member to the bonding struct to
   hold a copy of the primary IPv6 address on the bond.

- Adds a new tunable, num_grat_ns, to limit the number of gratuitous
   Neighbor Solicitations that are sent on a failover event.  Default
   is 1.

On failover, this new code will generate two packets:

- An MLD report for the bond, on the current active slave.

- An IPv6 "gratuitous" Neighbor Solicitation, which helps the switch
   learn that the address has moved to the new slave.

Testing has shown that sending just the NS results in pretty good 
behavior when in active-back mode, I saw no lost ping packets for 
example.  Sending just the MLD packet didn't seem to have the same 
effect.  Sending both seems like the right thing to do.

Comments welcome.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

--------------030108040707040305040006
Content-Type: text/x-patch;
 name="bonding-ipv6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bonding-ipv6.patch"

diff --git a/drivers/net/bonding/Makefile b/drivers/net/bonding/Makefile
index 5cdae2b..5136115 100644
--- a/drivers/net/bonding/Makefile
+++ b/drivers/net/bonding/Makefile
@@ -6,3 +6,6 @@ obj-$(CONFIG_BONDING) += bonding.o
 
 bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
 
+ipv6-$(CONFIG_IPV6_BONDING) += bond_ipv6.o
+bonding-objs += $(ipv6-y)
+
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
new file mode 100644
index 0000000..931c3c2
--- /dev/null
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -0,0 +1,166 @@
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
+	ifa = idev->addr_list;
+	if (ifa)
+		ipv6_addr_copy(addr, &ifa->addr);
+	else
+		ipv6_addr_set(addr, 0, 0, 0, 0);
+
+	in6_dev_put(idev);
+}
+
+/*
+ * Resend an IPv6 MLD report for the bonding device on the current
+ * active slave.
+ */
+void bond_resend_ipv6_mld_report(struct bonding *bond)
+{
+	struct inet6_dev *in6_dev;
+	struct slave *slave = bond->curr_active_slave;
+
+	dprintk("bond_resend_ipv6_mld_report: bond %s slave %s\n",
+				bond->dev->name,
+				slave ? slave->dev->name : "NULL");
+
+	if (!slave ||
+	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
+		return;
+
+	if (ipv6_addr_any(&bond->master_ipv6))
+		return;
+
+	dprintk("ipv6 mld report on slave %s\n", slave->name);
+
+	in6_dev = in6_dev_get(bond->dev);
+	if (in6_dev) {
+		mld_send_report(in6_dev, NULL, slave->dev);
+		in6_dev_put(in6_dev);
+	}
+}
+
+/*
+ * Kick out a gratuitous Neighbor Solicitation for an IPv6 address on
+ * the bonding master.  This will help the switch learn our address
+ * if in active-back mode.
+ *
+ * Caller must hold curr_slave_lock for read or better
+ */
+void bond_send_gratuitous_ns(struct bonding *bond)
+{
+	struct in6_addr mcaddr;
+	struct slave *slave = bond->curr_active_slave;
+
+	dprintk("bond_send_grat_ns: bond %s slave %s\n", bond->dev->name,
+				slave ? slave->dev->name : "NULL");
+
+	if (!slave || !bond->send_grat_ns ||
+	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
+		return;
+
+	bond->send_grat_ns--;
+
+	if (ipv6_addr_any(&bond->master_ipv6))
+		return;
+
+	dprintk("ipv6 ns on slave %s: target %s\n" NIP6_FMT,
+	       slave->name, NIP6(&bond->master_ipv6));
+
+	addrconf_addr_solict_mult(&bond->master_ipv6, &mcaddr);
+	ndisc_send_ns(slave->dev, NULL, &bond->master_ipv6, &mcaddr, &bond->master_ipv6);
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
+	struct net_device *event_dev = ifa->idev->dev;
+	struct bonding *bond;
+
+	if (dev_net(event_dev) != &init_net)
+		return NOTIFY_DONE;
+
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+		if (bond->dev == event_dev) {
+			switch (event) {
+			case NETDEV_UP:
+				ipv6_addr_copy(&bond->master_ipv6, &ifa->addr);
+				return NOTIFY_OK;
+			case NETDEV_DOWN:
+				bond_glean_dev_ipv6(bond->dev,
+						    &bond->master_ipv6);
+				return NOTIFY_OK;
+			default:
+				return NOTIFY_DONE;
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
index babe461..5c62626 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -89,6 +89,7 @@
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int num_grat_arp = 1;
+static int num_grat_ns  = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
 static int updelay	= 0;
 static int downdelay	= 0;
@@ -107,6 +108,8 @@ module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
 module_param(num_grat_arp, int, 0644);
 MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packets to send on failover event");
+module_param(num_grat_ns, int, 0644);
+MODULE_PARM_DESC(num_grat_ns, "Number of gratuitous IPv6 Neighbor Solicitation packets to send on failover event");
 module_param(miimon, int, 0);
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 module_param(updelay, int, 0);
@@ -988,6 +991,7 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
 			dev_mc_add(new_active->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
 		bond_resend_igmp_join_requests(bond);
+		bond_resend_ipv6_mld_report(bond);
 	}
 }
 
@@ -1208,6 +1212,9 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			bond->send_grat_arp = bond->params.num_grat_arp;
 			bond_send_gratuitous_arp(bond);
 
+			bond->send_grat_ns = bond->params.num_grat_ns;
+			bond_send_gratuitous_ns(bond);
+
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
 
@@ -2441,6 +2448,12 @@ void bond_mii_monitor(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
+	if (bond->send_grat_ns) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_gratuitous_ns(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (bond_miimon_inspect(bond)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3138,6 +3151,12 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
+	if (bond->send_grat_ns) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_gratuitous_ns(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3813,6 +3832,7 @@ static int bond_close(struct net_device *bond_dev)
 	write_lock_bh(&bond->lock);
 
 	bond->send_grat_arp = 0;
+	bond->send_grat_ns = 0;
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
@@ -4522,6 +4542,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
 	bond->send_grat_arp = 0;
+	bond->send_grat_ns = 0;
 	bond->setup_by_slave = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
@@ -4770,6 +4791,13 @@ static int bond_check_params(struct bond_params *params)
 		num_grat_arp = 1;
 	}
 
+	if (num_grat_ns < 0 || num_grat_ns > 255) {
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: num_grat_ns (%d) not in range 0-255 so it "
+		       "was reset to 1 \n", num_grat_ns);
+		num_grat_ns = 1;
+	}
+
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
 		if (!miimon) {
@@ -4971,6 +4999,7 @@ static int bond_check_params(struct bond_params *params)
 	params->xmit_policy = xmit_hashtype;
 	params->miimon = miimon;
 	params->num_grat_arp = num_grat_arp;
+	params->num_grat_ns = num_grat_ns;
 	params->arp_interval = arp_interval;
 	params->arp_validate = arp_validate_value;
 	params->updelay = updelay;
@@ -5123,6 +5152,7 @@ static int __init bonding_init(void)
 
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
+	bond_register_ipv6_notifier();
 
 	goto out;
 err:
@@ -5145,6 +5175,7 @@ static void __exit bonding_exit(void)
 {
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
+	bond_unregister_ipv6_notifier();
 
 	bond_destroy_sysfs();
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 3bdb473..4079295 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -981,6 +981,46 @@ out:
 	return ret;
 }
 static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR, bonding_show_n_grat_arp, bonding_store_n_grat_arp);
+
+/*
+ * Show and set the number of grat NS to send after a failover event.
+ */
+static ssize_t bonding_show_n_grat_ns(struct device *d,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.num_grat_ns);
+}
+
+static ssize_t bonding_store_n_grat_ns(struct device *d,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: no num_grat_ns value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (new_value < 0 || new_value > 255) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Invalid num_grat_ns value %d not in range 0-255; rejected.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		bond->params.num_grat_ns = new_value;
+	}
+out:
+	return ret;
+}
+static DEVICE_ATTR(num_grat_ns, S_IRUGO | S_IWUSR, bonding_show_n_grat_ns, bonding_store_n_grat_ns);
 /*
  * Show and set the MII monitor interval.  There are two tricky bits
  * here.  First, if MII monitoring is activated, then we must disable
@@ -1419,6 +1459,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_lacp_rate.attr,
 	&dev_attr_xmit_hash_policy.attr,
 	&dev_attr_num_grat_arp.attr,
+	&dev_attr_num_grat_ns.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
 	&dev_attr_use_carrier.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index fb730ec..a113c06 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -19,6 +19,7 @@
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
 #include <linux/kobject.h>
+#include <linux/in6.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
@@ -29,6 +30,8 @@
 
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
+	int num_grat_ns;
 	int arp_interval;
 	int arp_validate;
 	int use_carrier;
@@ -195,6 +199,7 @@ struct bonding {
 	rwlock_t curr_slave_lock;
 	s8       kill_timers;
 	s8	 send_grat_arp;
+	s8	 send_grat_ns;
 	s8	 setup_by_slave;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
@@ -207,6 +212,7 @@ struct bonding {
 	__be32   master_ip;
 	u16      flags;
 	u16      rr_tx_counter;
+	struct   in6_addr master_ipv6;
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
 	struct   bond_params params;
@@ -333,5 +339,29 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
 
+#ifdef CONFIG_IPV6_BONDING
+void bond_resend_ipv6_mld_report(struct bonding *bond);
+void bond_send_gratuitous_ns(struct bonding *bond);
+void bond_register_ipv6_notifier(void);
+void bond_unregister_ipv6_notifier(void);
+#else
+static inline void bond_resend_ipv6_mld_report(struct bonding *bond)
+{
+	return;
+}
+static inline void bond_send_gratuitous_ns(struct bonding *bond)
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
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 113028f..6f04d60 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -577,6 +577,12 @@ extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 			 struct group_filter __user *optval,
 			 int __user *optlen);
 
+/*
+ * mcast.c
+ */
+extern void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc,
+			    struct net_device *dev);
+
 #ifdef CONFIG_PROC_FS
 extern int  ac6_proc_init(struct net *net);
 extern void ac6_proc_exit(struct net *net);
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ec99215..bcaf3d4 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -217,4 +217,11 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.
 
+config IPV6_BONDING
+	bool "IPv6: Bonding driver support (EXPERIMENTAL)"
+	depends on IPV6=y && BONDING && EXPERIMENTAL
+	---help---
+	  Support for IPv6 in the bonding driver.
+	  If unsure, say N.
+
 endif # IPV6
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index e7c03bc..59a8a8b 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1628,7 +1628,8 @@ empty_source:
 	return skb;
 }
 
-static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
+void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc,
+		     struct net_device *dev)
 {
 	struct sk_buff *skb = NULL;
 	int type;
@@ -1656,9 +1657,14 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
 		skb = add_grec(skb, pmc, type, 0, 0);
 		spin_unlock_bh(&pmc->mca_lock);
 	}
-	if (skb)
+	if (skb) {
+		/* caller can override device to xmit on */
+		if (dev)
+			skb->dev = dev;
 		mld_sendpack(skb);
+	}
 }
+EXPORT_SYMBOL_GPL(mld_send_report);
 
 /*
  * remove zero-count source records from a source filter list
@@ -2197,7 +2203,7 @@ static void mld_gq_timer_expire(unsigned long data)
 	struct inet6_dev *idev = (struct inet6_dev *)data;
 
 	idev->mc_gq_running = 0;
-	mld_send_report(idev, NULL);
+	mld_send_report(idev, NULL, NULL);
 	__in6_dev_put(idev);
 }
 
@@ -2230,7 +2236,7 @@ static void igmp6_timer_handler(unsigned long data)
 	if (MLD_V1_SEEN(ma->idev))
 		igmp6_send(&ma->mca_addr, ma->idev->dev, ICMPV6_MGM_REPORT);
 	else
-		mld_send_report(ma->idev, ma);
+		mld_send_report(ma->idev, ma, NULL);
 
 	spin_lock(&ma->mca_lock);
 	ma->mca_flags |=  MAF_LAST_REPORTER;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f1c62ba..2599484 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -586,6 +586,8 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		     !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
 
+EXPORT_SYMBOL_GPL(ndisc_send_ns);
+
 void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		   const struct in6_addr *daddr)
 {

--------------030108040707040305040006--
