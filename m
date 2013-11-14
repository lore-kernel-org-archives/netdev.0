From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/9] taskstats: use genl_register_family_with_ops()
Date: Thu, 14 Nov 2013 17:14:39 +0100
Message-ID: <1384445687-30948-2-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
 <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Cc: linux-wimax@intel.com, Balbir Singh <bsingharora@gmail.com>,
	netfilter-devel@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg@intel.com>

This simplifies the code since there's no longer a
need to have error handling in the registration.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 kernel/taskstats.c | 39 ++++++++++++++-------------------------
 1 file changed, 14 insertions(+), 25 deletions(-)

diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 9f4618e..609e77f 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -673,17 +673,18 @@ err:
 	nlmsg_free(rep_skb);
 }
 
-static struct genl_ops taskstats_ops = {
-	.cmd		= TASKSTATS_CMD_GET,
-	.doit		= taskstats_user_cmd,
-	.policy		= taskstats_cmd_get_policy,
-	.flags		= GENL_ADMIN_PERM,
-};
-
-static struct genl_ops cgroupstats_ops = {
-	.cmd		= CGROUPSTATS_CMD_GET,
-	.doit		= cgroupstats_user_cmd,
-	.policy		= cgroupstats_cmd_get_policy,
+static struct genl_ops taskstats_ops[] = {
+	{
+		.cmd		= TASKSTATS_CMD_GET,
+		.doit		= taskstats_user_cmd,
+		.policy		= taskstats_cmd_get_policy,
+		.flags		= GENL_ADMIN_PERM,
+	},
+	{
+		.cmd		= CGROUPSTATS_CMD_GET,
+		.doit		= cgroupstats_user_cmd,
+		.policy		= cgroupstats_cmd_get_policy,
+	},
 };
 
 /* Needed early in initialization */
@@ -702,26 +703,14 @@ static int __init taskstats_init(void)
 {
 	int rc;
 
-	rc = genl_register_family(&family);
+	rc = genl_register_family_with_ops(&family, taskstats_ops,
+					   ARRAY_SIZE(taskstats_ops));
 	if (rc)
 		return rc;
 
-	rc = genl_register_ops(&family, &taskstats_ops);
-	if (rc < 0)
-		goto err;
-
-	rc = genl_register_ops(&family, &cgroupstats_ops);
-	if (rc < 0)
-		goto err_cgroup_ops;
-
 	family_registered = 1;
 	pr_info("registered taskstats version %d\n", TASKSTATS_GENL_VERSION);
 	return 0;
-err_cgroup_ops:
-	genl_unregister_ops(&family, &taskstats_ops);
-err:
-	genl_unregister_family(&family);
-	return rc;
 }
 
 /*
-- 
1.8.4.rc3

