From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH v2] bonding: rejoin multicast groups on VLANs
Date: Thu, 30 Sep 2010 17:45:24 -0300
Message-ID: <1285879524-7046-1-git-send-email-fleitner@redhat.com>
References: <20100929131713.GB2857@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Flavio Leitner <fleitner@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754788Ab0I3Upu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 16:45:50 -0400
In-Reply-To: <20100929131713.GB2857@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It fixes bonding to rejoin multicast groups added
to VLAN devices on top of bonding when a failover
happens.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 drivers/net/bonding/bond_main.c |   61 +++++++++++++++++++++++++++++++++-----
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 54 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3b16f62..1016c09 100644
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
@@ -885,6 +881,45 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
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
+out:
+	read_unlock(&bond->lock);
+}
+
+void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    mcast_work.work);
+	bond_resend_igmp_join_requests(bond);
+}
+
 /*
  * flush all members of flush->mc_list from device dev->mc_list
  */
@@ -944,7 +979,9 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 
 		netdev_for_each_mc_addr(ha, bond->dev)
 			dev_mc_add(new_active->dev, ha->addr);
-		bond_resend_igmp_join_requests(bond);
+
+		/* rejoin multicast groups */
+		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
 	}
 }
 
@@ -3744,6 +3781,9 @@ static int bond_open(struct net_device *bond_dev)
 
 	bond->kill_timers = 0;
 
+	/* multicast retrans */
+	INIT_DELAYED_WORK(&bond->mcast_work, bond_resend_igmp_join_requests_delayed);
+
 	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -3828,6 +3868,8 @@ static int bond_close(struct net_device *bond_dev)
 		break;
 	}
 
+	if (delayed_work_pending(&bond->mcast_work))
+		cancel_delayed_work(&bond->mcast_work);
 
 	if (bond_is_lb(bond)) {
 		/* Must be called only after all
@@ -4699,6 +4741,9 @@ static void bond_work_cancel_all(struct bonding *bond)
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
1.7.3

