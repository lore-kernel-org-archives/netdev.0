From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 1/8] genetlink: only pass array to genl_register_family_with_ops()
Date: Sat, 16 Nov 2013 18:03:42 +0100
Message-ID: <1384621429-24543-2-git-send-email-johannes@sipsolutions.net>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:57902 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab3KPREA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 12:04:00 -0500
In-Reply-To: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

As suggested by David Miller, make genl_register_family_with_ops()
a macro and pass only the array, evaluating ARRAY_SIZE() in the
macro, this is a little safer.

The openvswitch has some indirection, assing ops/n_ops directly in
that code. This might ultimately just assign the pointers in the
family initializations, saving the struct genl_family_and_ops and
code (once mcast groups are handled differently.)

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/net/team/team.c               |  3 +--
 drivers/net/wireless/mac80211_hwsim.c |  3 +--
 fs/dlm/netlink.c                      | 10 ++++++----
 include/linux/genl_magic_func.h       |  3 +--
 include/net/genetlink.h               |  8 ++++++--
 kernel/taskstats.c                    |  3 +--
 net/core/drop_monitor.c               |  3 +--
 net/hsr/hsr_netlink.c                 |  3 +--
 net/ieee802154/netlink.c              |  3 +--
 net/ipv4/tcp_metrics.c                |  3 +--
 net/irda/irnetlink.c                  |  3 +--
 net/l2tp/l2tp_netlink.c               |  7 +------
 net/netfilter/ipvs/ip_vs_ctl.c        |  2 +-
 net/netlabel/netlabel_cipso_v4.c      |  2 +-
 net/netlabel/netlabel_mgmt.c          |  2 +-
 net/netlabel/netlabel_unlabeled.c     |  2 +-
 net/netlink/genetlink.c               | 14 ++++++++------
 net/nfc/netlink.c                     |  3 +--
 net/openvswitch/datapath.c            |  5 +++--
 net/tipc/netlink.c                    | 11 ++++++-----
 net/wimax/stack.c                     |  4 ++--
 net/wireless/nl80211.c                |  3 +--
 22 files changed, 47 insertions(+), 53 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6390254..f55758b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2699,8 +2699,7 @@ static int team_nl_init(void)
 {
 	int err;
 
-	err = genl_register_family_with_ops(&team_nl_family, team_nl_ops,
-					    ARRAY_SIZE(team_nl_ops));
+	err = genl_register_family_with_ops(&team_nl_family, team_nl_ops);
 	if (err)
 		return err;
 
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index cfc3fda..9df7bc9 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2148,8 +2148,7 @@ static int hwsim_init_netlink(void)
 
 	printk(KERN_INFO "mac80211_hwsim: initializing netlink\n");
 
-	rc = genl_register_family_with_ops(&hwsim_genl_family,
-		hwsim_ops, ARRAY_SIZE(hwsim_ops));
+	rc = genl_register_family_with_ops(&hwsim_genl_family, hwsim_ops);
 	if (rc)
 		goto failure;
 
diff --git a/fs/dlm/netlink.c b/fs/dlm/netlink.c
index 60a3278..e7cfbaf 100644
--- a/fs/dlm/netlink.c
+++ b/fs/dlm/netlink.c
@@ -74,14 +74,16 @@ static int user_cmd(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 }
 
-static struct genl_ops dlm_nl_ops = {
-	.cmd		= DLM_CMD_HELLO,
-	.doit		= user_cmd,
+static struct genl_ops dlm_nl_ops[] = {
+	{
+		.cmd	= DLM_CMD_HELLO,
+		.doit	= user_cmd,
+	},
 };
 
 int __init dlm_netlink_init(void)
 {
-	return genl_register_family_with_ops(&family, &dlm_nl_ops, 1);
+	return genl_register_family_with_ops(&family, dlm_nl_ops);
 }
 
 void dlm_netlink_exit(void)
diff --git a/include/linux/genl_magic_func.h b/include/linux/genl_magic_func.h
index 023bc34..4708603 100644
--- a/include/linux/genl_magic_func.h
+++ b/include/linux/genl_magic_func.h
@@ -293,8 +293,7 @@ static int CONCAT_(GENL_MAGIC_FAMILY, _genl_multicast_ ## group)(	\
 
 int CONCAT_(GENL_MAGIC_FAMILY, _genl_register)(void)
 {
-	int err = genl_register_family_with_ops(&ZZZ_genl_family,
-		ZZZ_genl_ops, ARRAY_SIZE(ZZZ_genl_ops));
+	int err = genl_register_family_with_ops(&ZZZ_genl_family, ZZZ_genl_ops);
 	if (err)
 		return err;
 #undef GENL_mc_group
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index e96385d..9bd52a4c 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -152,8 +152,9 @@ static inline int genl_register_family(struct genl_family *family)
  *
  * Return 0 on success or a negative error code.
  */
-static inline int genl_register_family_with_ops(struct genl_family *family,
-	const struct genl_ops *ops, size_t n_ops)
+static inline int _genl_register_family_with_ops(struct genl_family *family,
+						 const struct genl_ops *ops,
+						 size_t n_ops)
 {
 	family->module = THIS_MODULE;
 	family->ops = ops;
@@ -161,6 +162,9 @@ static inline int genl_register_family_with_ops(struct genl_family *family,
 	return __genl_register_family(family);
 }
 
+#define genl_register_family_with_ops(family, ops)	\
+	_genl_register_family_with_ops((family), (ops), ARRAY_SIZE(ops))
+
 int genl_unregister_family(struct genl_family *family);
 int genl_register_mc_group(struct genl_family *family,
 			   struct genl_multicast_group *grp);
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 76595cd..13d2f7c 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -703,8 +703,7 @@ static int __init taskstats_init(void)
 {
 	int rc;
 
-	rc = genl_register_family_with_ops(&family, taskstats_ops,
-					   ARRAY_SIZE(taskstats_ops));
+	rc = genl_register_family_with_ops(&family, taskstats_ops);
 	if (rc)
 		return rc;
 
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index f9fe2f2..0efc502 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -365,8 +365,7 @@ static int __init init_net_drop_monitor(void)
 	}
 
 	rc = genl_register_family_with_ops(&net_drop_monitor_family,
-					   dropmon_ops,
-					   ARRAY_SIZE(dropmon_ops));
+					   dropmon_ops);
 	if (rc) {
 		pr_err("Could not create drop monitor netlink family\n");
 		return rc;
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 3b9205d..f182260 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -414,8 +414,7 @@ int __init hsr_netlink_init(void)
 	if (rc)
 		goto fail_rtnl_link_register;
 
-	rc = genl_register_family_with_ops(&hsr_genl_family, hsr_ops,
-					   ARRAY_SIZE(hsr_ops));
+	rc = genl_register_family_with_ops(&hsr_genl_family, hsr_ops);
 	if (rc)
 		goto fail_genl_register_family;
 
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 3ffcdbb..1a81709 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -129,8 +129,7 @@ int __init ieee802154_nl_init(void)
 {
 	int rc;
 
-	rc = genl_register_family_with_ops(&nl802154_family, ieee8021154_ops,
-					   ARRAY_SIZE(ieee8021154_ops));
+	rc = genl_register_family_with_ops(&nl802154_family, ieee8021154_ops);
 	if (rc)
 		return rc;
 
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 8c121b5..0649373 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1082,8 +1082,7 @@ void __init tcp_metrics_init(void)
 	if (ret < 0)
 		goto cleanup;
 	ret = genl_register_family_with_ops(&tcp_metrics_nl_family,
-					    tcp_metrics_nl_ops,
-					    ARRAY_SIZE(tcp_metrics_nl_ops));
+					    tcp_metrics_nl_ops);
 	if (ret < 0)
 		goto cleanup_subsys;
 	return;
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index bf5d7d4..a37b81f 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -149,8 +149,7 @@ static const struct genl_ops irda_nl_ops[] = {
 
 int irda_nl_register(void)
 {
-	return genl_register_family_with_ops(&irda_nl_family,
-		irda_nl_ops, ARRAY_SIZE(irda_nl_ops));
+	return genl_register_family_with_ops(&irda_nl_family, irda_nl_ops);
 }
 
 void irda_nl_unregister(void)
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 57db66e..4cfd722 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -887,13 +887,8 @@ EXPORT_SYMBOL_GPL(l2tp_nl_unregister_ops);
 
 static int l2tp_nl_init(void)
 {
-	int err;
-
 	pr_info("L2TP netlink interface\n");
-	err = genl_register_family_with_ops(&l2tp_nl_family, l2tp_nl_ops,
-					    ARRAY_SIZE(l2tp_nl_ops));
-
-	return err;
+	return genl_register_family_with_ops(&l2tp_nl_family, l2tp_nl_ops);
 }
 
 static void l2tp_nl_cleanup(void)
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index fc8a04e..3934987 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3666,7 +3666,7 @@ static const struct genl_ops ip_vs_genl_ops[] __read_mostly = {
 static int __init ip_vs_genl_register(void)
 {
 	return genl_register_family_with_ops(&ip_vs_genl_family,
-		ip_vs_genl_ops, ARRAY_SIZE(ip_vs_genl_ops));
+					     ip_vs_genl_ops);
 }
 
 static void ip_vs_genl_unregister(void)
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 7066917..69345ce 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -783,5 +783,5 @@ static const struct genl_ops netlbl_cipsov4_ops[] = {
 int __init netlbl_cipsov4_genl_init(void)
 {
 	return genl_register_family_with_ops(&netlbl_cipsov4_gnl_family,
-		netlbl_cipsov4_ops, ARRAY_SIZE(netlbl_cipsov4_ops));
+					     netlbl_cipsov4_ops);
 }
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 7de6f66..8ef83ee 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -779,5 +779,5 @@ static const struct genl_ops netlbl_mgmt_genl_ops[] = {
 int __init netlbl_mgmt_genl_init(void)
 {
 	return genl_register_family_with_ops(&netlbl_mgmt_gnl_family,
-		netlbl_mgmt_genl_ops, ARRAY_SIZE(netlbl_mgmt_genl_ops));
+					     netlbl_mgmt_genl_ops);
 }
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 76ee925..43817d7 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1397,7 +1397,7 @@ static const struct genl_ops netlbl_unlabel_genl_ops[] = {
 int __init netlbl_unlabel_genl_init(void)
 {
 	return genl_register_family_with_ops(&netlbl_unlabel_gnl_family,
-		netlbl_unlabel_genl_ops, ARRAY_SIZE(netlbl_unlabel_genl_ops));
+					     netlbl_unlabel_genl_ops);
 }
 
 /*
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index f07eb56..2b57aee 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -906,11 +906,13 @@ static int genl_ctrl_event(int event, void *data)
 	return 0;
 }
 
-static struct genl_ops genl_ctrl_ops = {
-	.cmd		= CTRL_CMD_GETFAMILY,
-	.doit		= ctrl_getfamily,
-	.dumpit		= ctrl_dumpfamily,
-	.policy		= ctrl_policy,
+static struct genl_ops genl_ctrl_ops[] = {
+	{
+		.cmd		= CTRL_CMD_GETFAMILY,
+		.doit		= ctrl_getfamily,
+		.dumpit		= ctrl_dumpfamily,
+		.policy		= ctrl_policy,
+	},
 };
 
 static struct genl_multicast_group notify_grp = {
@@ -954,7 +956,7 @@ static int __init genl_init(void)
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++)
 		INIT_LIST_HEAD(&family_ht[i]);
 
-	err = genl_register_family_with_ops(&genl_ctrl, &genl_ctrl_ops, 1);
+	err = genl_register_family_with_ops(&genl_ctrl, genl_ctrl_ops);
 	if (err < 0)
 		goto problem;
 
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index f558561..fe6760d 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1536,8 +1536,7 @@ int __init nfc_genl_init(void)
 {
 	int rc;
 
-	rc = genl_register_family_with_ops(&nfc_genl_family, nfc_genl_ops,
-					   ARRAY_SIZE(nfc_genl_ops));
+	rc = genl_register_family_with_ops(&nfc_genl_family, nfc_genl_ops);
 	if (rc)
 		return rc;
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 91e1c92..8ec8b73 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1817,8 +1817,9 @@ static int dp_register_genl(void)
 	for (i = 0; i < ARRAY_SIZE(dp_genl_families); i++) {
 		const struct genl_family_and_ops *f = &dp_genl_families[i];
 
-		err = genl_register_family_with_ops(f->family, f->ops,
-						    f->n_ops);
+		f->family->ops = f->ops;
+		f->family->n_ops = f->n_ops;
+		err = genl_register_family(f->family);
 		if (err)
 			goto error;
 		n_registered++;
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 8bcd498..9f72a63 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -76,9 +76,11 @@ static struct genl_family tipc_genl_family = {
 	.maxattr	= 0,
 };
 
-static struct genl_ops tipc_genl_ops = {
-	.cmd		= TIPC_GENL_CMD,
-	.doit		= handle_cmd,
+static struct genl_ops tipc_genl_ops[] = {
+	{
+		.cmd		= TIPC_GENL_CMD,
+		.doit		= handle_cmd,
+	},
 };
 
 static int tipc_genl_family_registered;
@@ -87,8 +89,7 @@ int tipc_netlink_start(void)
 {
 	int res;
 
-	res = genl_register_family_with_ops(&tipc_genl_family,
-		&tipc_genl_ops, 1);
+	res = genl_register_family_with_ops(&tipc_genl_family, tipc_genl_ops);
 	if (res) {
 		pr_err("Failed to register netlink interface\n");
 		return res;
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 47170c9..6328afe 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -597,8 +597,8 @@ int __init wimax_subsys_init(void)
 
 	snprintf(wimax_gnl_family.name, sizeof(wimax_gnl_family.name),
 		 "WiMAX");
-	result = genl_register_family_with_ops(&wimax_gnl_family, wimax_gnl_ops,
-					       ARRAY_SIZE(wimax_gnl_ops));
+	result = genl_register_family_with_ops(&wimax_gnl_family,
+					       wimax_gnl_ops);
 	if (unlikely(result < 0)) {
 		printk(KERN_ERR "cannot register generic netlink family: %d\n",
 		       result);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 58c43c8..1b6c5dd 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -11329,8 +11329,7 @@ int nl80211_init(void)
 {
 	int err;
 
-	err = genl_register_family_with_ops(&nl80211_fam,
-		nl80211_ops, ARRAY_SIZE(nl80211_ops));
+	err = genl_register_family_with_ops(&nl80211_fam, nl80211_ops);
 	if (err)
 		return err;
 
-- 
1.8.4.rc3
