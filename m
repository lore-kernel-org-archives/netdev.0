From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: remove entries for master_ip and vlan_ip and query devices instead
Date: Thu, 15 Mar 2012 18:03:20 -0700
Message-ID: <29983.1331859800@death.nxdomain>
References: <1331742069-16602-1-git-send-email-andy@greyhouse.net>
Cc: netdev@vger.kernel.org, Ralf Zeidler <ralf.zeidler@nsn.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41385 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032520Ab2CPBD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 21:03:26 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 15 Mar 2012 21:03:25 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 865F138C805F
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 21:03:22 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2G13M0F034046
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 21:03:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2G13Meb002922
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 21:03:22 -0400
In-reply-to: <1331742069-16602-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>The following patch aimed to resolve an issue where secondary, tertiary,
>etc. addresses added to bond interfaces could overwrite the
>bond->master_ip and vlan_ip values.
>
>	commit 917fbdb32f37e9a93b00bb12ee83532982982df3
>	Author: Henrik Saavedra Persson <henrik.e.persson@ericsson.com>
>	Date:   Wed Nov 23 23:37:15 2011 +0000
>
>	    bonding: only use primary address for ARP
>
>That patch was good because it prevented bonds using ARP monitoring from
>sending frames with an invalid source IP address.  Unfortunately, it
>didn't always work as expected.
>
>When using an ioctl (like ifconfig does) to set the IP address and
>netmask, 2 separate ioctls are actually called to set the IP and netmask
>if the mask chosen doesn't match the standard mask for that class of
>address.  The first ioctl did not have a mask that matched the one in
>the primary address and would still cause the device address to be
>overwritten.  The second ioctl that was called to set the mask would
>then detect as secondary and ignored, but the damage was already done.
>
>This was not an issue when using an application that used netlink
>sockets as the setting of IP and netmask came down at once.  The
>inconsistent behavior between those two interfaces was something that
>needed to be resolved.
>
>While I was thinking about how I wanted to resolve this, Ralf Zeidler
>came with a patch that resolved this on a RHEL kernel by keeping a full
>shadow of the entries in dev->ifa_list for the bonding device and vlan
>devices in the bonding driver.  I didn't like the duplication of the
>list as I want to see the 'bonding' struct and code shrink rather than
>grow, but liked the general idea.
>
>As the Subject indicates this patch drops the master_ip and vlan_ip
>elements from the 'bonding' and 'vlan_entry' structs, respectively.
>This can be done because a device's address-list is now traversed to
>determine the optimal source IP address for ARP requests and for checks
>to see if the bonding device has a particular IP address.  This code
>could have all be contained inside the bonding driver, but it made more
>sense to me to EXPORT and call inet_confirm_addr since it did exactly
>what was needed.
>
>I tested this and a backported patch and everything works as expected.
>Ralf also helped with verification of the backported patch.
>
>Thanks to Ralf for all his help on this.

	I did not test this, but it looks good to me from inspection.
I've got a couple of minor style questions, though, below.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>CC: Ralf Zeidler <ralf.zeidler@nsn.com>
>
>---
> drivers/net/bonding/bond_main.c |   86 +++++++++------------------------------
> drivers/net/bonding/bonding.h   |   17 +++++++-
> net/ipv4/devinet.c              |    1 +
> 3 files changed, 35 insertions(+), 69 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 435984a..67d58cd 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2561,12 +2561,18 @@ re_arm:
> static int bond_has_this_ip(struct bonding *bond, __be32 ip)
> {
> 	struct vlan_entry *vlan;
>+	struct net_device *vlan_dev;
>
>-	if (ip == bond->master_ip)
>+	if (ip == bond_confirm_addr(bond->dev, 0, ip))
> 		return 1;
>
> 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
>-		if (ip == vlan->vlan_ip)
>+		rcu_read_lock();
>+		vlan_dev = __vlan_find_dev_deep(bond->dev,
>+						vlan->vlan_id);

	Can the function call arguments fit on one line?

>+		rcu_read_unlock();
>+		if (vlan_dev &&
>+		    ip == bond_confirm_addr(vlan_dev, 0, ip))

	Similarly, can these be combined on to one line?

> 			return 1;
> 	}
>
>@@ -2608,7 +2614,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 	int i, vlan_id;
> 	__be32 *targets = bond->params.arp_targets;
> 	struct vlan_entry *vlan;
>-	struct net_device *vlan_dev;
>+	struct net_device *vlan_dev = NULL;
> 	struct rtable *rt;
>
> 	for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
>@@ -2618,7 +2624,9 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 		if (!bond_vlan_used(bond)) {
> 			pr_debug("basa: empty vlan: arp_send\n");
> 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
>-				      bond->master_ip, 0);
>+				      bond_confirm_addr(bond->dev,
>+							targets[i],
>+							0), 0);

	Same comment here and for the later calls to bond_confirm_addr,
here putting "targets[i]" and perhaps the 0 on the previous line,
although I'm less sure that it won't look funky.

	-J

> 			continue;
> 		}
>
>@@ -2644,7 +2652,9 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 			ip_rt_put(rt);
> 			pr_debug("basa: rtdev == bond->dev: arp_send\n");
> 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
>-				      bond->master_ip, 0);
>+				      bond_confirm_addr(bond->dev,
>+							targets[i],
>+							0), 0);
> 			continue;
> 		}
>
>@@ -2662,10 +2672,12 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
> 			}
> 		}
>
>-		if (vlan_id) {
>+		if (vlan_id && vlan_dev) {
> 			ip_rt_put(rt);
> 			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
>-				      vlan->vlan_ip, vlan_id);
>+				      bond_confirm_addr(vlan_dev,
>+							targets[i],
>+							0), vlan_id);
> 			continue;
> 		}
>
>@@ -3287,68 +3299,10 @@ static int bond_netdev_event(struct notifier_block *this,
> 	return NOTIFY_DONE;
> }
>
>-/*
>- * bond_inetaddr_event: handle inetaddr notifier chain events.
>- *
>- * We keep track of device IPs primarily to use as source addresses in
>- * ARP monitor probes (rather than spewing out broadcasts all the time).
>- *
>- * We track one IP for the main device (if it has one), plus one per VLAN.
>- */
>-static int bond_inetaddr_event(struct notifier_block *this, unsigned long event, void *ptr)
>-{
>-	struct in_ifaddr *ifa = ptr;
>-	struct net_device *vlan_dev, *event_dev = ifa->ifa_dev->dev;
>-	struct bond_net *bn = net_generic(dev_net(event_dev), bond_net_id);
>-	struct bonding *bond;
>-	struct vlan_entry *vlan;
>-
>-	/* we only care about primary address */
>-	if(ifa->ifa_flags & IFA_F_SECONDARY)
>-		return NOTIFY_DONE;
>-
>-	list_for_each_entry(bond, &bn->dev_list, bond_list) {
>-		if (bond->dev == event_dev) {
>-			switch (event) {
>-			case NETDEV_UP:
>-				bond->master_ip = ifa->ifa_local;
>-				return NOTIFY_OK;
>-			case NETDEV_DOWN:
>-				bond->master_ip = 0;
>-				return NOTIFY_OK;
>-			default:
>-				return NOTIFY_DONE;
>-			}
>-		}
>-
>-		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
>-			vlan_dev = __vlan_find_dev_deep(bond->dev,
>-							vlan->vlan_id);
>-			if (vlan_dev == event_dev) {
>-				switch (event) {
>-				case NETDEV_UP:
>-					vlan->vlan_ip = ifa->ifa_local;
>-					return NOTIFY_OK;
>-				case NETDEV_DOWN:
>-					vlan->vlan_ip = 0;
>-					return NOTIFY_OK;
>-				default:
>-					return NOTIFY_DONE;
>-				}
>-			}
>-		}
>-	}
>-	return NOTIFY_DONE;
>-}
>-
> static struct notifier_block bond_netdev_notifier = {
> 	.notifier_call = bond_netdev_event,
> };
>
>-static struct notifier_block bond_inetaddr_notifier = {
>-	.notifier_call = bond_inetaddr_event,
>-};
>-
> /*---------------------------- Hashing Policies -----------------------------*/
>
> /*
>@@ -4917,7 +4871,6 @@ static int __init bonding_init(void)
> 	}
>
> 	register_netdevice_notifier(&bond_netdev_notifier);
>-	register_inetaddr_notifier(&bond_inetaddr_notifier);
> out:
> 	return res;
> err:
>@@ -4931,7 +4884,6 @@ err_link:
> static void __exit bonding_exit(void)
> {
> 	unregister_netdevice_notifier(&bond_netdev_notifier);
>-	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
>
> 	bond_destroy_debugfs();
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 1aecc37..4fc9659 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -21,6 +21,7 @@
> #include <linux/cpumask.h>
> #include <linux/in6.h>
> #include <linux/netpoll.h>
>+#include <linux/inetdevice.h>
> #include "bond_3ad.h"
> #include "bond_alb.h"
>
>@@ -166,7 +167,6 @@ struct bond_parm_tbl {
>
> struct vlan_entry {
> 	struct list_head vlan_list;
>-	__be32 vlan_ip;
> 	unsigned short vlan_id;
> };
>
>@@ -232,7 +232,6 @@ struct bonding {
> 	struct   list_head bond_list;
> 	struct   netdev_hw_addr_list mc_list;
> 	int      (*xmit_hash_policy)(struct sk_buff *, int);
>-	__be32   master_ip;
> 	u16      rr_tx_counter;
> 	struct   ad_bond_info ad_info;
> 	struct   alb_bond_info alb_info;
>@@ -378,6 +377,20 @@ static inline bool bond_is_slave_inactive(struct slave *slave)
> 	return slave->inactive;
> }
>
>+static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
>+{
>+	struct in_device *in_dev;
>+	__be32 addr = 0;
>+
>+	rcu_read_lock();
>+	in_dev = __in_dev_get_rcu(dev);
>+	rcu_read_unlock();
>+
>+	if (in_dev)
>+		addr = inet_confirm_addr(in_dev, dst, local, RT_SCOPE_HOST);
>+	return addr;
>+}
>+
> struct bond_net;
>
> struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
>diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>index e41c40f..d4fad5c 100644
>--- a/net/ipv4/devinet.c
>+++ b/net/ipv4/devinet.c
>@@ -1079,6 +1079,7 @@ __be32 inet_confirm_addr(struct in_device *in_dev,
>
> 	return addr;
> }
>+EXPORT_SYMBOL(inet_confirm_addr);
>
> /*
>  *	Device notifier
>-- 
>1.7.4.4

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
