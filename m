From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH 1/3] bonding: rejoin multicast groups on VLANs
Date: Tue,  5 Oct 2010 21:23:57 -0300
Message-ID: <1286324639-22314-1-git-send-email-fleitner@redhat.com>
References: <20101005220757.GB19931@redhat.com>
Cc: bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Flavio Leitner <fleitner@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756230Ab0JFAYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 20:24:14 -0400
In-Reply-To: <20101005220757.GB19931@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During a failover, the IGMP membership is sent to update
the switch restoring the traffic, but it misses groups added
to VLAN devices running on top of bonding devices.

This patch changes it to iterate over all VLAN devices
on top of it sending IGMP memberships too.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 drivers/net/bonding/bond_main.c |   60 +++++++++++++++++++++++++++++++-------
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 50 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3b16f62..6554b47 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -865,18 +865,13 @@ static void bond_mc_del(struct bonding *bond, void *addr)
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
+	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
 		for (im = in_dev->mc_list; im; im = im->next)
 			ip_mc_rejoin_group(im);
@@ -886,6 +881,41 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 }
 
 /*
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
+
+	/* rejoin all groups on bond device */
+	__bond_resend_igmp_join_requests(bond->dev);
+
+	/* rejoin all groups on vlan devices */
+	if (bond->vlgrp) {
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+			vlan_dev = vlan_group_get_device(bond->vlgrp,
+							 vlan->vlan_id);
+			if (vlan_dev)
+				__bond_resend_igmp_join_requests(vlan_dev);
+		}
+	}
+
+	read_unlock(&bond->lock);
+}
+
+void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+							mcast_work.work);
+	bond_resend_igmp_join_requests(bond);
+}
+
+/*
  * flush all members of flush->mc_list from device dev->mc_list
  */
 static void bond_mc_list_flush(struct net_device *bond_dev,
@@ -944,7 +974,6 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 
 		netdev_for_each_mc_addr(ha, bond->dev)
 			dev_mc_add(new_active->dev, ha->addr);
-		bond_resend_igmp_join_requests(bond);
 	}
 }
 
@@ -1180,9 +1209,11 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		}
 	}
 
-	/* resend IGMP joins since all were sent on curr_active_slave */
-	if (bond->params.mode == BOND_MODE_ROUNDROBIN) {
-		bond_resend_igmp_join_requests(bond);
+	/* resend IGMP joins since active slave has changed or
+	 * all were sent on curr_active_slave */
+	if ((USES_PRIMARY(bond->params.mode) && new_active) ||
+	    bond->params.mode == BOND_MODE_ROUNDROBIN) {
+		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
 	}
 }
 
@@ -3744,6 +3775,8 @@ static int bond_open(struct net_device *bond_dev)
 
 	bond->kill_timers = 0;
 
+	INIT_DELAYED_WORK(&bond->mcast_work, bond_resend_igmp_join_requests_delayed);
+
 	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -3828,6 +3861,8 @@ static int bond_close(struct net_device *bond_dev)
 		break;
 	}
 
+	if (delayed_work_pending(&bond->mcast_work))
+		cancel_delayed_work(&bond->mcast_work);
 
 	if (bond_is_lb(bond)) {
 		/* Must be called only after all
@@ -4699,6 +4734,9 @@ static void bond_work_cancel_all(struct bonding *bond)
 	if (bond->params.mode == BOND_MODE_8023AD &&
 	    delayed_work_pending(&bond->ad_work))
 		cancel_delayed_work(&bond->ad_work);
+
+	if (delayed_work_pending(&bond->mcast_work))
+		cancel_delayed_work(&bond->mcast_work);
 }
 
 /*
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c6fdd85..308ed10 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -223,6 +223,7 @@ struct bonding {
 	struct   delayed_work arp_work;
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
+	struct   delayed_work mcast_work;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct   in6_addr master_ipv6;
 #endif
-- 
1.7.0.1

