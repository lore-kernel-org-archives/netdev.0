From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net] bonding: properly stop queuing work when requested
Date: Fri, 23 Sep 2011 16:53:34 -0400
Message-ID: <1316811214-15002-1-git-send-email-andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4339 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105Ab1IWUwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 16:52:39 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8NKqdn6029449
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 16:52:39 -0400
Received: from quad.redhat.com (vpn-9-209.rdu.redhat.com [10.11.9.209])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8NKqcZi011179
	for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 16:52:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During a test where a pair of bonding interfaces using ARP monitoring
were both brought up and torn down (with an rmmod) repeatedly, a panic
in the timer code was noticed.  I tracked this down and determined that
any of the bonding functions that ran as workqueue handlers and requeued
more work might not properly exit when the module was removed.

There was a flag protected by the bond lock called kill_timers that is
set when the interface goes down or the module is removed, but many of
the functions that monitor link status now unlock the bond lock to take
rtnl first.  There is a chance that another CPU running the rmmod could
get the lock and set kill_timers after the first check has passed.

This patch does not allow any function to queue work that will make
itself run unless kill_timers is not set.  I also noticed while doing
this work that bond_resend_igmp_join_requests did not have a check for
kill_timers, so I added the needed call there as well.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Reported-by: Liang Zheng <lzheng@redhat.com>

---
 drivers/net/bonding/bond_3ad.c  |    3 ++-
 drivers/net/bonding/bond_alb.c  |    3 ++-
 drivers/net/bonding/bond_main.c |   13 ++++++++-----
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index a047eb9..47b928e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2168,7 +2168,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	}
 
 re_arm:
-	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
+	if (!bond->kill_timers)
+		queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 7f8b20a..c172028 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1440,7 +1440,8 @@ void bond_alb_monitor(struct work_struct *work)
 	}
 
 re_arm:
-	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
+	if (!bond->kill_timers)
+		queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 43f2ea5..6d79b78 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -777,6 +777,9 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 
 	read_lock(&bond->lock);
 
+	if (bond->kill_timers)
+		goto out;
+
 	/* rejoin all groups on bond device */
 	__bond_resend_igmp_join_requests(bond->dev);
 
@@ -790,9 +793,9 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 			__bond_resend_igmp_join_requests(vlan_dev);
 	}
 
-	if (--bond->igmp_retrans > 0)
+	if ((--bond->igmp_retrans > 0) && !bond->kill_timers)
 		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
-
+out:
 	read_unlock(&bond->lock);
 }
 
@@ -2538,7 +2541,7 @@ void bond_mii_monitor(struct work_struct *work)
 	}
 
 re_arm:
-	if (bond->params.miimon)
+	if (bond->params.miimon && !bond->kill_timers)
 		queue_delayed_work(bond->wq, &bond->mii_work,
 				   msecs_to_jiffies(bond->params.miimon));
 out:
@@ -2886,7 +2889,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	}
 
 re_arm:
-	if (bond->params.arp_interval)
+	if (bond->params.arp_interval && !bond->kill_timers)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
@@ -3154,7 +3157,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	bond_ab_arp_probe(bond);
 
 re_arm:
-	if (bond->params.arp_interval)
+	if (bond->params.arp_interval && !bond->kill_timers)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
