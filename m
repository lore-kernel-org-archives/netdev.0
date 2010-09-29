From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] bonding: rejoin multicast groups on VLANs
Date: Wed, 29 Sep 2010 04:12:24 -0300
Message-ID: <1285744344-1231-1-git-send-email-fleitner@redhat.com>
Cc: Flavio Leitner <fleitner@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45137 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442Ab0I2HM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 03:12:27 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8T7CRHK011722
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 03:12:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It fixes bonding to rejoin multicast groups added
to VLAN devices on top of bonding when a failover
happens.

The first packet may be discarded, so the timer
assure that at least 3 Reports are sent.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 drivers/net/bonding/bond_main.c |   59 +++++++++++++++++++++++++++++++++-----
 drivers/net/bonding/bonding.h   |    2 +
 2 files changed, 53 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3b16f62..a23a5fa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -865,18 +865,14 @@ static void bond_mc_del(struct bonding *bond, void *addr)
 }
 
 
-/*
- * Retrieve the list of registered multicast addresses for the bonding
- * device and retransmit an IGMP JOIN request to the current active
- * slave.
- */
-static void bond_resend_igmp_join_requests(struct bonding *bond)
+static void __bond_resend_igmp_join_requests(struct net_device *dev)
 {
 	struct in_device *in_dev;
 	struct ip_mc_list *im;
 
 	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(bond->dev);
+
+	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
 		for (im = in_dev->mc_list; im; im = im->next)
 			ip_mc_rejoin_group(im);
@@ -885,6 +881,42 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 	rcu_read_unlock();
 }
 
+
+/*
+ * Retrieve the list of registered multicast addresses for the bonding
+ * device and retransmit an IGMP JOIN request to the current active
+ * slave.
+ */
+static void bond_resend_igmp_join_requests(struct bonding *bond)
+{
+	struct net_device *vlan_dev;
+	struct vlan_entry *vlan;
+
+	read_lock(&bond->lock);
+	if (bond->kill_timers)
+		goto out;
+
+	/* rejoin all groups on bond device */
+	__bond_resend_igmp_join_requests(bond->dev);
+
+	if (!bond->vlgrp)
+		goto reschedule;
+
+	/* rejoin all groups on vlan devices */
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+		vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
+		if (vlan_dev)
+			__bond_resend_igmp_join_requests(vlan_dev);
+	}
+
+reschedule:
+	if (--bond->resend_igmp > 0)
+		mod_timer(&bond->mc_timer, jiffies + HZ/5);
+
+out:
+	read_unlock(&bond->lock);
+}
+
 /*
  * flush all members of flush->mc_list from device dev->mc_list
  */
@@ -944,7 +976,10 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 
 		netdev_for_each_mc_addr(ha, bond->dev)
 			dev_mc_add(new_active->dev, ha->addr);
-		bond_resend_igmp_join_requests(bond);
+
+		/* rejoin multicast groups */
+		bond->resend_igmp = 3;
+		mod_timer(&bond->mc_timer, jiffies + 1);
 	}
 }
 
@@ -3741,9 +3776,15 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
 static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct timer_list *mc_timer = &bond->mc_timer;
 
 	bond->kill_timers = 0;
 
+	/* multicast */
+	init_timer(mc_timer);
+	mc_timer->data = (unsigned long)bond;
+	mc_timer->function = (void *)&bond_resend_igmp_join_requests;
+
 	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -3808,6 +3849,8 @@ static int bond_close(struct net_device *bond_dev)
 
 	write_unlock_bh(&bond->lock);
 
+	del_timer_sync(&bond->mc_timer);
+
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
 		cancel_delayed_work(&bond->mii_work);
 	}
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c6fdd85..5fd4164 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -198,6 +198,8 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
+	struct   timer_list mc_timer;
+	s8       resend_igmp;
 	s8       kill_timers;
 	s8	 send_grat_arp;
 	s8	 send_unsol_na;
-- 
1.7.2.3

