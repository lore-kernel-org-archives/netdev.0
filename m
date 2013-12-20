From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: fix a regression in tc actions
Date: Fri, 20 Dec 2013 00:08:51 -0800
Message-ID: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:46899 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab3LTIJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 03:09:00 -0500
Received: by mail-pa0-f49.google.com with SMTP id kx10so2310306pab.22
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 00:09:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes:
1) pass mask rather than size to tcf_hashinfo_init()
2) the cleanup should be in reversed order in mirred_cleanup_module()

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Fixes: 369ba56787d7469c0afd ("net_sched: init struct tcf_hashinfo at register time")
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 5d350c5..9cc6717 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -586,7 +586,7 @@ MODULE_LICENSE("GPL");
 
 static int __init csum_init_module(void)
 {
-	int err = tcf_hashinfo_init(&csum_hash_info, CSUM_TAB_MASK+1);
+	int err = tcf_hashinfo_init(&csum_hash_info, CSUM_TAB_MASK);
 	if (err)
 		return err;
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 1e6e0e7..dea9273 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -208,7 +208,7 @@ MODULE_LICENSE("GPL");
 
 static int __init gact_init_module(void)
 {
-	int err = tcf_hashinfo_init(&gact_hash_info, GACT_TAB_MASK+1);
+	int err = tcf_hashinfo_init(&gact_hash_info, GACT_TAB_MASK);
 	if (err)
 		return err;
 #ifdef CONFIG_GACT_PROB
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 8344380..e13ecbb 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -314,7 +314,7 @@ MODULE_ALIAS("act_xt");
 static int __init ipt_init_module(void)
 {
 	int ret1, ret2, err;
-	err = tcf_hashinfo_init(&ipt_hash_info, IPT_TAB_MASK+1);
+	err = tcf_hashinfo_init(&ipt_hash_info, IPT_TAB_MASK);
 	if (err)
 		return err;
 
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 199fc98..9dbb8cd 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -276,7 +276,7 @@ static int __init mirred_init_module(void)
 	if (err)
 		return err;
 
-	err = tcf_hashinfo_init(&mirred_hash_info, MIRRED_TAB_MASK+1);
+	err = tcf_hashinfo_init(&mirred_hash_info, MIRRED_TAB_MASK);
 	if (err) {
 		unregister_netdevice_notifier(&mirred_device_notifier);
 		return err;
@@ -287,9 +287,9 @@ static int __init mirred_init_module(void)
 
 static void __exit mirred_cleanup_module(void)
 {
-	unregister_netdevice_notifier(&mirred_device_notifier);
-	tcf_hashinfo_destroy(&mirred_hash_info);
 	tcf_unregister_action(&act_mirred_ops);
+	tcf_hashinfo_destroy(&mirred_hash_info);
+	unregister_netdevice_notifier(&mirred_device_notifier);
 }
 
 module_init(mirred_init_module);
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 409fe71..921fea4 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -310,7 +310,7 @@ MODULE_LICENSE("GPL");
 
 static int __init nat_init_module(void)
 {
-	int err = tcf_hashinfo_init(&nat_hash_info, NAT_TAB_MASK+1);
+	int err = tcf_hashinfo_init(&nat_hash_info, NAT_TAB_MASK);
 	if (err)
 		return err;
 	return tcf_register_action(&act_nat_ops);
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index aa5347c..e2520e9 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -246,7 +246,7 @@ MODULE_LICENSE("GPL");
 
 static int __init pedit_init_module(void)
 {
-	int err = tcf_hashinfo_init(&pedit_hash_info, PEDIT_TAB_MASK+1);
+	int err = tcf_hashinfo_init(&pedit_hash_info, PEDIT_TAB_MASK);
 	if (err)
 		return err;
 	return tcf_register_action(&act_pedit_ops);
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 7b23ab0..819a9a4 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -396,7 +396,7 @@ static struct tc_action_ops act_police_ops = {
 static int __init
 police_init_module(void)
 {
-	int err = tcf_hashinfo_init(&police_hash_info, POL_TAB_MASK+1);
+	int err = tcf_hashinfo_init(&police_hash_info, POL_TAB_MASK);
 	if (err)
 		return err;
 	err = tcf_register_action(&act_police_ops);
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 2d7a0eb..81aebc1 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -203,7 +203,7 @@ MODULE_LICENSE("GPL");
 static int __init simp_init_module(void)
 {
 	int err, ret;
-	err = tcf_hashinfo_init(&simp_hash_info, SIMP_TAB_MASK+1);
+	err = tcf_hashinfo_init(&simp_hash_info, SIMP_TAB_MASK);
 	if (err)
 		return err;
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 90ed04a..aa0a4c0 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -203,7 +203,7 @@ MODULE_LICENSE("GPL");
 
 static int __init skbedit_init_module(void)
 {
-	int err = tcf_hashinfo_init(&skbedit_hash_info, SKBEDIT_TAB_MASK+1);
+	int err = tcf_hashinfo_init(&skbedit_hash_info, SKBEDIT_TAB_MASK);
 	if (err)
 		return err;
 	return tcf_register_action(&act_skbedit_ops);
