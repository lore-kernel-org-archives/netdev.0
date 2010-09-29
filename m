From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: rejoin multicast groups on VLANs
Date: Wed, 29 Sep 2010 14:44:13 -0400
Message-ID: <20100929184413.GY7497@gospo.rdu.redhat.com>
References: <1285744344-1231-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755274Ab0I2SoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 14:44:15 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o8TIiE9Z024888
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 14:44:14 -0400
Content-Disposition: inline
In-Reply-To: <1285744344-1231-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 29, 2010 at 04:12:24AM -0300, Flavio Leitner wrote:
> It fixes bonding to rejoin multicast groups added
> to VLAN devices on top of bonding when a failover
> happens.
> 
> The first packet may be discarded, so the timer
> assure that at least 3 Reports are sent.
> 

Good find, Flavio.  Clearly the fact that multicast membership is broken
needs to be fixed, but I would rather not see timers used at all.  We
worked hard in the past to eliminate timers for several reasons, so I
would rather see a workqueue used.

I also don't like retransmitting the membership report 3 times when it
may not be needed.  Though many switches can handle it, the cost of
receiving and processing what might be a large list of multicast
addresses every 200ms for 600ms doesn't seem ideal.  It also feels like
a hack. :)

If retransmission of the membership reports is a requirement for some
users, I would rather see it as a configuration option.

Maybe something like this?

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3b16f62..b7b4a74 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -109,6 +109,7 @@ static char *arp_validate;
 static char *fail_over_mac;
 static int all_slaves_active = 0;
 static struct bond_params bonding_defaults;
+static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -163,6 +164,8 @@ module_param(all_slaves_active, int, 0);
 MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface"
 				     "by setting active flag for all slaves.  "
 				     "0 for never (default), 1 for always.");
+module_param(resend_igmp, int, 0);
+MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link failure");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -865,18 +868,14 @@ static void bond_mc_del(struct bonding *bond, void *addr)
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
@@ -885,6 +884,48 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
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
+	if (--bond->igmp_retrans > 0)
+		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
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
@@ -944,7 +985,10 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 
 		netdev_for_each_mc_addr(ha, bond->dev)
 			dev_mc_add(new_active->dev, ha->addr);
-		bond_resend_igmp_join_requests(bond);
+
+		/* rejoin multicast groups */
+		bond->igmp_retrans = bond->params.resend_igmp;
+		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
 	}
 }
 
@@ -3744,6 +3788,9 @@ static int bond_open(struct net_device *bond_dev)
 
 	bond->kill_timers = 0;
 
+	/* multicast retrans */
+	INIT_DELAYED_WORK(&bond->mcast_work, bond_resend_igmp_join_requests_delayed);
+
 	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -3828,6 +3875,8 @@ static int bond_close(struct net_device *bond_dev)
 		break;
 	}
 
+	if (delayed_work_pending(&bond->mcast_work))
+		cancel_delayed_work(&bond->ad_work);
 
 	if (bond_is_lb(bond)) {
 		/* Must be called only after all
@@ -4699,6 +4748,9 @@ static void bond_work_cancel_all(struct bonding *bond)
 	if (bond->params.mode == BOND_MODE_8023AD &&
 	    delayed_work_pending(&bond->ad_work))
 		cancel_delayed_work(&bond->ad_work);
+
+	if (delayed_work_pending(&bond->mcast_work))
+		cancel_delayed_work(&bond->ad_work);
 }
 
 /*
@@ -4891,6 +4943,12 @@ static int bond_check_params(struct bond_params *params)
 		all_slaves_active = 0;
 	}
 
+	if (resend_igmp < 0 || resend_igmp > 255) {
+		pr_warning("Warning: resend_igmp (%d) should be between "
+			   "0 and 255, resetting to %d\n",
+			   resend_igmp, BOND_DEFAULT_RESEND_IGMP);
+		resend_igmp = BOND_DEFAULT_RESEND_IGMP;
+	}
 	/* reset values for TLB/ALB */
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
@@ -5063,6 +5121,7 @@ static int bond_check_params(struct bond_params *params)
 	params->fail_over_mac = fail_over_mac_value;
 	params->tx_queues = tx_queues;
 	params->all_slaves_active = all_slaves_active;
+	params->resend_igmp = resend_igmp;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c6fdd85..c49bdb0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -136,6 +136,7 @@ struct bond_params {
 	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
 	int tx_queues;
 	int all_slaves_active;
+	int resend_igmp;
 };
 
 struct bond_parm_tbl {
@@ -198,6 +199,7 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
+	s8       igmp_retrans;
 	s8       kill_timers;
 	s8	 send_grat_arp;
 	s8	 send_unsol_na;
@@ -223,6 +225,7 @@ struct bonding {
 	struct   delayed_work arp_work;
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
+	struct   delayed_work mcast_work;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct   in6_addr master_ipv6;
 #endif
diff --git a/include/linux/if_bonding.h b/include/linux/if_bonding.h
index 2c79943..d2f78b7 100644
--- a/include/linux/if_bonding.h
+++ b/include/linux/if_bonding.h
@@ -84,6 +84,9 @@
 #define BOND_DEFAULT_MAX_BONDS  1   /* Default maximum number of devices to support */
 
 #define BOND_DEFAULT_TX_QUEUES 16   /* Default number of tx queues per device */
+
+#define BOND_DEFAULT_RESEND_IGMP	1 /* Default number of IGMP membership reports
+					     to resend on link failure. */
 /* hashing types */
 #define BOND_XMIT_POLICY_LAYER2		0 /* layer 2 (MAC only), default */
 #define BOND_XMIT_POLICY_LAYER34	1 /* layer 3+4 (IP ^ (TCP || UDP)) */
