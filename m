From: Jean-Francois Remy <jeff@melix.org>
Subject: [PATCH] neighbour: fix base_reachable_time(_ms) not effective immediatly when changed
Date: Tue, 13 Jan 2015 08:51:19 +0100
Message-ID: <1421135479-15952-1-git-send-email-jeff@melix.org>
Cc: Jean-Francois Remy <jeff@melix.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp05.smtpout.orange.fr ([80.12.242.127]:35659 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbAMHv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 02:51:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When setting base_reachable_time or base_reachable_time_ms through
sysctl or netlink, the reachable_time value is not updated.
This means that neighbour entries will continue to be updated using the
old value until it is recomputed in neigh_period_work (which
    recomputes the value every 300*HZ).
On systems with HZ equal to 1000 for instance, it means 5mins before
the change is effective.

This patch changes this behavior by recomputing reachable_time after
each set on base_reachable_time or base_reachable_time_ms.
The new value will become effective the next time the neighbour's timer
is triggered.

Changes are made in two places: the netlink code for set and the sysctl
handling code. For sysctl, I use a proc_handler. The ipv6 network
code does provide its own handler but it already refreshes
reachable_time correctly so it's not an issue.
Any other user of neighbour which provide its own handlers must
refresh reachable_time.

Signed-off-by: Jean-Francois Remy <jeff@melix.org>
---
 net/core/neighbour.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8e38f17..b6d1d46 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2043,6 +2043,13 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 			case NDTPA_BASE_REACHABLE_TIME:
 				NEIGH_VAR_SET(p, BASE_REACHABLE_TIME,
 					      nla_get_msecs(tbp[i]));
+				/*
+				 * update reachable_time as well, otherwise, the change will
+				 * only be effective after the next time neigh_periodic_work
+				 * decides to recompute it (can be multiple minutes)
+				 */
+				p->reachable_time =
+					neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
 				break;
 			case NDTPA_GC_STALETIME:
 				NEIGH_VAR_SET(p, GC_STALETIME,
@@ -2921,6 +2928,32 @@ static int neigh_proc_dointvec_unres_qlen(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static int neigh_proc_base_reachable_time(struct ctl_table *ctl, int write,
+					  void __user *buffer,
+					  size_t *lenp, loff_t *ppos)
+{
+	struct neigh_parms *p = ctl->extra2;
+	int ret;
+
+	if (strcmp(ctl->procname, "base_reachable_time") == 0)
+		ret = neigh_proc_dointvec_jiffies(ctl, write, buffer, lenp, ppos);
+	else if (strcmp(ctl->procname, "base_reachable_time_ms") == 0)
+		ret = neigh_proc_dointvec_ms_jiffies(ctl, write, buffer, lenp, ppos);
+	else
+		ret = -1;
+
+	if (write && ret == 0 ) {
+		/*
+		 * update reachable_time as well, otherwise, the change will
+		 * only be effective after the next time neigh_periodic_work
+		 * decides to recompute it
+		 */
+		p->reachable_time =
+			neigh_rand_reach_time(NEIGH_VAR(p, BASE_REACHABLE_TIME));
+	}
+	return ret;
+}
+
 #define NEIGH_PARMS_DATA_OFFSET(index)	\
 	(&((struct neigh_parms *) 0)->data[index])
 
@@ -3047,6 +3080,20 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 		t->neigh_vars[NEIGH_VAR_RETRANS_TIME_MS].proc_handler = handler;
 		/* ReachableTime (in milliseconds) */
 		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].proc_handler = handler;
+	} else {
+		/*
+		 * Those handlers will update p->reachable_time after
+		 * base_reachable_time(_ms) is set to ensure the new timer starts being
+		 * applied after the next neighbour update instead of waiting for
+		 * neigh_periodic_work to update its value (can be multiple minutes)
+		 * So any handler that replaces them should do this as well
+		 */
+		/* ReachableTime */
+		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME].proc_handler =
+			neigh_proc_base_reachable_time;
+		/* ReachableTime (in milliseconds) */
+		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].proc_handler =
+			neigh_proc_base_reachable_time;
 	}
 
 	/* Don't export sysctls to unprivileged users */
-- 
2.1.0
