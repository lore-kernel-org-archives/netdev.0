From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 2/8] drop_monitor/genetlink: use proper genetlink multicast APIs
Date: Sat, 16 Nov 2013 18:03:43 +0100
Message-ID: <1384621429-24543-3-git-send-email-johannes@sipsolutions.net>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:57913 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953Ab3KPREB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 12:04:01 -0500
In-Reply-To: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The drop monitor code is abusing the genetlink API and is
statically using the generic netlink multicast group 1, even
if that group belongs to somebody else (which it invariably
will, since it's not reserved.)

Make the drop monitor code use the proper APIs to reserve a
group ID, but also reserve the group id 1 in generic netlink
code to preserve the userspace API. Since drop monitor can
be a module, don't clear the bit for it on unregistration.

Cc: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/core/drop_monitor.c | 13 ++++++++++++-
 net/netlink/genetlink.c | 13 ++++++++++---
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 0efc502..46ee488 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -106,6 +106,10 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 	return skb;
 }
 
+static struct genl_multicast_group dm_mcgrp = {
+	.name = "events",
+};
+
 static void send_dm_alert(struct work_struct *work)
 {
 	struct sk_buff *skb;
@@ -116,7 +120,7 @@ static void send_dm_alert(struct work_struct *work)
 	skb = reset_per_cpu_data(data);
 
 	if (skb)
-		genlmsg_multicast(skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
+		genlmsg_multicast(skb, 0, dm_mcgrp.id, GFP_KERNEL);
 }
 
 /*
@@ -371,6 +375,13 @@ static int __init init_net_drop_monitor(void)
 		return rc;
 	}
 
+	rc = genl_register_mc_group(&net_drop_monitor_family, &dm_mcgrp);
+	if (rc) {
+		pr_err("Failed to register drop monitor mcast group\n");
+		goto out_unreg;
+	}
+	WARN_ON(dm_mcgrp.id != NET_DM_GRP_ALERT);
+
 	rc = register_netdevice_notifier(&dropmon_net_notifier);
 	if (rc < 0) {
 		pr_crit("Failed to register netdevice notifier\n");
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2b57aee..8a2ed2c 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -65,8 +65,12 @@ static struct list_head family_ht[GENL_FAM_TAB_SIZE];
  * To avoid an allocation at boot of just one unsigned long,
  * declare it global instead.
  * Bit 0 is marked as already used since group 0 is invalid.
+ * Bit 1 is marked as already used since the drop-monitor code
+ * abuses the API and thinks it can statically use group 1.
+ * That group will typically conflict with other groups that
+ * any proper users use.
  */
-static unsigned long mc_group_start = 0x1;
+static unsigned long mc_group_start = 0x3;
 static unsigned long *mc_groups = &mc_group_start;
 static unsigned long mc_groups_longs = 1;
 
@@ -160,9 +164,11 @@ int genl_register_mc_group(struct genl_family *family,
 
 	genl_lock_all();
 
-	/* special-case our own group */
+	/* special-case our own group and hacks */
 	if (grp == &notify_grp)
 		id = GENL_ID_CTRL;
+	else if (strcmp(family->name, "NET_DM") == 0)
+		id = 1;
 	else
 		id = find_first_zero_bit(mc_groups,
 					 mc_groups_longs * BITS_PER_LONG);
@@ -245,7 +251,8 @@ static void __genl_unregister_mc_group(struct genl_family *family,
 	rcu_read_unlock();
 	netlink_table_ungrab();
 
-	clear_bit(grp->id, mc_groups);
+	if (grp->id != 1)
+		clear_bit(grp->id, mc_groups);
 	list_del(&grp->list);
 	genl_ctrl_event(CTRL_CMD_DELMCAST_GRP, grp);
 	grp->id = 0;
-- 
1.8.4.rc3
