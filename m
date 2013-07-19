From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] net: convert resend IGMP to notifier event
Date: Fri, 19 Jul 2013 15:40:21 +0200
Message-ID: <1374241222-9683-3-git-send-email-jiri@resnulli.us>
References: <1374241222-9683-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:34036 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760297Ab3GSNke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:40:34 -0400
Received: by mail-ea0-f181.google.com with SMTP id a15so2432873eae.12
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 06:40:33 -0700 (PDT)
In-Reply-To: <1374241222-9683-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, bond_resend_igmp_join_requests() looks for vlans attached to
bonding device, bridge where bonding act as port manually. It does not
care of other scenarios, like stacked bonds or team device above. Make
this more generic and use netdev notifier to propagate the event to
upper devices and to actually call ip_mc_rejoin_groups().

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c | 44 ++++++++-------------------------------
 drivers/net/team/team.c         |  4 ++++
 include/linux/igmp.h            |  1 -
 include/linux/netdevice.h       |  1 +
 net/8021q/vlan.c                |  1 +
 net/bridge/br_notify.c          |  5 +++++
 net/ipv4/igmp.c                 | 46 +++++++++++++++++++++++++++++++++++------
 7 files changed, 60 insertions(+), 42 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07f257d4..ae9864c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -715,15 +715,6 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 	return err;
 }
 
-static void __bond_resend_igmp_join_requests(struct net_device *dev)
-{
-	struct in_device *in_dev;
-
-	in_dev = __in_dev_get_rcu(dev);
-	if (in_dev)
-		ip_mc_rejoin_groups(in_dev);
-}
-
 /*
  * Retrieve the list of registered multicast addresses for the bonding
  * device and retransmit an IGMP JOIN request to the current active
@@ -731,33 +722,12 @@ static void __bond_resend_igmp_join_requests(struct net_device *dev)
  */
 static void bond_resend_igmp_join_requests(struct bonding *bond)
 {
-	struct net_device *bond_dev, *vlan_dev, *upper_dev;
-	struct vlan_entry *vlan;
-
-	read_lock(&bond->lock);
-	rcu_read_lock();
-
-	bond_dev = bond->dev;
-
-	/* rejoin all groups on bond device */
-	__bond_resend_igmp_join_requests(bond_dev);
-
-	/*
-	 * if bond is enslaved to a bridge,
-	 * then rejoin all groups on its master
-	 */
-	upper_dev = netdev_master_upper_dev_get_rcu(bond_dev);
-	if (upper_dev && upper_dev->priv_flags & IFF_EBRIDGE)
-		__bond_resend_igmp_join_requests(upper_dev);
-
-	/* rejoin all groups on vlan devices */
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		vlan_dev = __vlan_find_dev_deep(bond_dev, htons(ETH_P_8021Q),
-						vlan->vlan_id);
-		if (vlan_dev)
-			__bond_resend_igmp_join_requests(vlan_dev);
+	if (!rtnl_trylock()) {
+		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
+		return;
 	}
-	rcu_read_unlock();
+	call_netdevice_notifiers(NETDEV_RESEND_IGMP, bond->dev);
+	rtnl_unlock();
 
 	/* We use curr_slave_lock to protect against concurrent access to
 	 * igmp_retrans from multiple running instances of this function and
@@ -3234,6 +3204,10 @@ static int bond_slave_netdev_event(unsigned long event,
 	case NETDEV_FEAT_CHANGE:
 		bond_compute_features(bond);
 		break;
+	case NETDEV_RESEND_IGMP:
+		/* Propagate to master device */
+		call_netdevice_notifiers(event, slave->bond->dev);
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9b185f7..68938ad 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2785,6 +2785,10 @@ static int team_device_event(struct notifier_block *unused,
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid to change type of underlaying device */
 		return NOTIFY_BAD;
+	case NETDEV_RESEND_IGMP:
+		/* Propagate to master device */
+		call_netdevice_notifiers(event, port->team->dev);
+		break;
 	}
 	return NOTIFY_DONE;
 }
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index e3362b5..f47550d 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -129,6 +129,5 @@ extern void ip_mc_unmap(struct in_device *);
 extern void ip_mc_remap(struct in_device *);
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
-extern void ip_mc_rejoin_groups(struct in_device *in_dev);
 
 #endif
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0741a1e..2bb2357 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1633,6 +1633,7 @@ struct packet_offload {
 #define NETDEV_NOTIFY_PEERS	0x0013
 #define NETDEV_JOIN		0x0014
 #define NETDEV_CHANGEUPPER	0x0015
+#define NETDEV_RESEND_IGMP	0x0016
 
 extern int register_netdevice_notifier(struct notifier_block *nb);
 extern int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 2fb2d88..03a92e1 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -459,6 +459,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_BONDING_FAILOVER:
+	case NETDEV_RESEND_IGMP:
 		/* Propagate to vlan devices */
 		vlan_group_for_each_dev(grp, i, vlandev)
 			call_netdevice_notifiers(event, vlandev);
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 3a3f371..2998dd1 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -102,6 +102,11 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
 		return NOTIFY_BAD;
+
+	case NETDEV_RESEND_IGMP:
+		/* Propagate to master device */
+		call_netdevice_notifiers(event, br->dev);
+		break;
 	}
 
 	/* Events that may cause spanning tree to refresh */
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index cd71190..375aca3 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1323,16 +1323,17 @@ out:
 EXPORT_SYMBOL(ip_mc_inc_group);
 
 /*
- *	Resend IGMP JOIN report; used for bonding.
- *	Called with rcu_read_lock()
+ *	Resend IGMP JOIN report; used by netdev notifier.
  */
-void ip_mc_rejoin_groups(struct in_device *in_dev)
+static void ip_mc_rejoin_groups(struct in_device *in_dev)
 {
 #ifdef CONFIG_IP_MULTICAST
 	struct ip_mc_list *im;
 	int type;
 
-	for_each_pmc_rcu(in_dev, im) {
+	ASSERT_RTNL();
+
+	for_each_pmc_rtnl(in_dev, im) {
 		if (im->multiaddr == IGMP_ALL_HOSTS)
 			continue;
 
@@ -1349,7 +1350,6 @@ void ip_mc_rejoin_groups(struct in_device *in_dev)
 	}
 #endif
 }
-EXPORT_SYMBOL(ip_mc_rejoin_groups);
 
 /*
  *	A socket has left a multicast group on device dev
@@ -2735,8 +2735,42 @@ static struct pernet_operations igmp_net_ops = {
 	.exit = igmp_net_exit,
 };
 
+static int igmp_netdev_event(struct notifier_block *this,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct in_device *in_dev;
+
+	switch (event) {
+	case NETDEV_RESEND_IGMP:
+		in_dev = __in_dev_get_rtnl(dev);
+		if (in_dev)
+			ip_mc_rejoin_groups(in_dev);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block igmp_notifier = {
+	.notifier_call = igmp_netdev_event,
+};
+
 int __init igmp_mc_proc_init(void)
 {
-	return register_pernet_subsys(&igmp_net_ops);
+	int err;
+
+	err = register_pernet_subsys(&igmp_net_ops);
+	if (err)
+		return err;
+	err = register_netdevice_notifier(&igmp_notifier);
+	if (err)
+		goto reg_notif_fail;
+	return 0;
+
+reg_notif_fail:
+	unregister_pernet_subsys(&igmp_net_ops);
+	return err;
 }
 #endif
-- 
1.8.1.4
