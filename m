From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 2/2] net_sched: hold netns refcnt for each action
Date: Wed,  1 Nov 2017 10:23:50 -0700
Message-ID: <20171101172350.12842-3-xiyou.wangcong@gmail.com>
References: <20171101172350.12842-1-xiyou.wangcong@gmail.com>
Cc: lucasb@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:55434 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754632AbdKARYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:24:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id 17so2444992pfn.12
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:24:03 -0700 (PDT)
In-Reply-To: <20171101172350.12842-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC actions have been destroyed asynchronously for a long time,
previously in a RCU callback and now in a workqueue. If we
don't hold a refcnt for its netns, we could use the per netns
data structure, struct tcf_idrinfo, after it has been freed by
netns workqueue.

Hold refcnt to ensure netns destroy happens after all actions
are gone.

Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
Reported-by: Lucas Bates <lucasb@mojatatu.com>
Tested-by: Lucas Bates <lucasb@mojatatu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h      | 4 +++-
 net/sched/act_api.c        | 2 ++
 net/sched/act_bpf.c        | 2 +-
 net/sched/act_connmark.c   | 2 +-
 net/sched/act_csum.c       | 2 +-
 net/sched/act_gact.c       | 2 +-
 net/sched/act_ife.c        | 2 +-
 net/sched/act_ipt.c        | 4 ++--
 net/sched/act_mirred.c     | 2 +-
 net/sched/act_nat.c        | 2 +-
 net/sched/act_pedit.c      | 2 +-
 net/sched/act_police.c     | 2 +-
 net/sched/act_sample.c     | 2 +-
 net/sched/act_simple.c     | 2 +-
 net/sched/act_skbedit.c    | 2 +-
 net/sched/act_skbmod.c     | 2 +-
 net/sched/act_tunnel_key.c | 2 +-
 net/sched/act_vlan.c       | 2 +-
 18 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 5072446d5f06..c68551255032 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -13,6 +13,7 @@
 struct tcf_idrinfo {
 	spinlock_t	lock;
 	struct idr	action_idr;
+	struct net	*net;
 };
 
 struct tc_action_ops;
@@ -104,7 +105,7 @@ struct tc_action_net {
 
 static inline
 int tc_action_net_init(struct tc_action_net *tn,
-		       const struct tc_action_ops *ops)
+		       const struct tc_action_ops *ops, struct net *net)
 {
 	int err = 0;
 
@@ -112,6 +113,7 @@ int tc_action_net_init(struct tc_action_net *tn,
 	if (!tn->idrinfo)
 		return -ENOMEM;
 	tn->ops = ops;
+	tn->idrinfo->net = net;
 	spin_lock_init(&tn->idrinfo->lock);
 	idr_init(&tn->idrinfo->action_idr);
 	return err;
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8f2c63514956..ca2ff0b3123f 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -78,6 +78,7 @@ static void tcf_idr_remove(struct tcf_idrinfo *idrinfo, struct tc_action *p)
 	spin_lock_bh(&idrinfo->lock);
 	idr_remove_ext(&idrinfo->action_idr, p->tcfa_index);
 	spin_unlock_bh(&idrinfo->lock);
+	put_net(idrinfo->net);
 	gen_kill_estimator(&p->tcfa_rate_est);
 	free_tcf(p);
 }
@@ -336,6 +337,7 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 	p->idrinfo = idrinfo;
 	p->ops = ops;
 	INIT_LIST_HEAD(&p->list);
+	get_net(idrinfo->net);
 	*a = p;
 	return 0;
 }
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index c0c707eb2c96..9bce8cc84cbb 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -398,7 +398,7 @@ static __net_init int bpf_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, bpf_net_id);
 
-	return tc_action_net_init(tn, &act_bpf_ops);
+	return tc_action_net_init(tn, &act_bpf_ops, net);
 }
 
 static void __net_exit bpf_exit_net(struct net *net)
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 10b7a8855a6c..34e52d01a5dd 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -206,7 +206,7 @@ static __net_init int connmark_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, connmark_net_id);
 
-	return tc_action_net_init(tn, &act_connmark_ops);
+	return tc_action_net_init(tn, &act_connmark_ops, net);
 }
 
 static void __net_exit connmark_exit_net(struct net *net)
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 1c40caadcff9..35171df2ebef 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -626,7 +626,7 @@ static __net_init int csum_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, csum_net_id);
 
-	return tc_action_net_init(tn, &act_csum_ops);
+	return tc_action_net_init(tn, &act_csum_ops, net);
 }
 
 static void __net_exit csum_exit_net(struct net *net)
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index e29a48ef7fc3..ef7f7f39d26d 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -232,7 +232,7 @@ static __net_init int gact_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, gact_net_id);
 
-	return tc_action_net_init(tn, &act_gact_ops);
+	return tc_action_net_init(tn, &act_gact_ops, net);
 }
 
 static void __net_exit gact_exit_net(struct net *net)
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 8ccd35825b6b..f65e4b5058e0 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -818,7 +818,7 @@ static __net_init int ife_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, ife_net_id);
 
-	return tc_action_net_init(tn, &act_ife_ops);
+	return tc_action_net_init(tn, &act_ife_ops, net);
 }
 
 static void __net_exit ife_exit_net(struct net *net)
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index d9e399a7e3d5..dbdf3b2470d5 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -334,7 +334,7 @@ static __net_init int ipt_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, ipt_net_id);
 
-	return tc_action_net_init(tn, &act_ipt_ops);
+	return tc_action_net_init(tn, &act_ipt_ops, net);
 }
 
 static void __net_exit ipt_exit_net(struct net *net)
@@ -384,7 +384,7 @@ static __net_init int xt_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, xt_net_id);
 
-	return tc_action_net_init(tn, &act_xt_ops);
+	return tc_action_net_init(tn, &act_xt_ops, net);
 }
 
 static void __net_exit xt_exit_net(struct net *net)
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 416627c66f08..84759cfd5a33 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -343,7 +343,7 @@ static __net_init int mirred_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, mirred_net_id);
 
-	return tc_action_net_init(tn, &act_mirred_ops);
+	return tc_action_net_init(tn, &act_mirred_ops, net);
 }
 
 static void __net_exit mirred_exit_net(struct net *net)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index c365d01b99c8..7eeaaf9217b6 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -307,7 +307,7 @@ static __net_init int nat_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, nat_net_id);
 
-	return tc_action_net_init(tn, &act_nat_ops);
+	return tc_action_net_init(tn, &act_nat_ops, net);
 }
 
 static void __net_exit nat_exit_net(struct net *net)
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 491fe5deb09e..b3d82c334a5f 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -450,7 +450,7 @@ static __net_init int pedit_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, pedit_net_id);
 
-	return tc_action_net_init(tn, &act_pedit_ops);
+	return tc_action_net_init(tn, &act_pedit_ops, net);
 }
 
 static void __net_exit pedit_exit_net(struct net *net)
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 3bb2ebf9e9ae..9ec42b26e4b9 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -331,7 +331,7 @@ static __net_init int police_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, police_net_id);
 
-	return tc_action_net_init(tn, &act_police_ops);
+	return tc_action_net_init(tn, &act_police_ops, net);
 }
 
 static void __net_exit police_exit_net(struct net *net)
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index 8b5abcd2f32f..e69a1e3a39bf 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -240,7 +240,7 @@ static __net_init int sample_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, sample_net_id);
 
-	return tc_action_net_init(tn, &act_sample_ops);
+	return tc_action_net_init(tn, &act_sample_ops, net);
 }
 
 static void __net_exit sample_exit_net(struct net *net)
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index e7b57e5071a3..a8d0ea95f894 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -201,7 +201,7 @@ static __net_init int simp_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, simp_net_id);
 
-	return tc_action_net_init(tn, &act_simp_ops);
+	return tc_action_net_init(tn, &act_simp_ops, net);
 }
 
 static void __net_exit simp_exit_net(struct net *net)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 59949d61f20d..fbac62472e09 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -238,7 +238,7 @@ static __net_init int skbedit_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, skbedit_net_id);
 
-	return tc_action_net_init(tn, &act_skbedit_ops);
+	return tc_action_net_init(tn, &act_skbedit_ops, net);
 }
 
 static void __net_exit skbedit_exit_net(struct net *net)
diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
index b642ad3d39dd..8e12d8897d2f 100644
--- a/net/sched/act_skbmod.c
+++ b/net/sched/act_skbmod.c
@@ -263,7 +263,7 @@ static __net_init int skbmod_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, skbmod_net_id);
 
-	return tc_action_net_init(tn, &act_skbmod_ops);
+	return tc_action_net_init(tn, &act_skbmod_ops, net);
 }
 
 static void __net_exit skbmod_exit_net(struct net *net)
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index 30c96274c638..c33faa373cf2 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -322,7 +322,7 @@ static __net_init int tunnel_key_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
 
-	return tc_action_net_init(tn, &act_tunnel_key_ops);
+	return tc_action_net_init(tn, &act_tunnel_key_ops, net);
 }
 
 static void __net_exit tunnel_key_exit_net(struct net *net)
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 16eb067a8d8f..115fc33cc6d8 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -269,7 +269,7 @@ static __net_init int vlan_init_net(struct net *net)
 {
 	struct tc_action_net *tn = net_generic(net, vlan_net_id);
 
-	return tc_action_net_init(tn, &act_vlan_ops);
+	return tc_action_net_init(tn, &act_vlan_ops, net);
 }
 
 static void __net_exit vlan_exit_net(struct net *net)
-- 
2.13.0
