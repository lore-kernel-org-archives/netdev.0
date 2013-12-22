From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [Patch net-next] net_sched: act: Dont increment refcnt on replace
Date: Sun, 22 Dec 2013 07:35:39 -0500
Message-ID: <52B6DC9B.9060309@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060907090805000601030101"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38204 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab3LVMfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 07:35:44 -0500
Received: by mail-ig0-f170.google.com with SMTP id k19so18961333igc.1
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 04:35:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060907090805000601030101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Dave,

This bug seems to have been around for some time, nothing to do with
recent changes; i am just doing tests i havent run in a while and
saw it. It is against net-next. If you think it is important enough,
I could also create one against linus tree..

cheers,
jamal

--------------060907090805000601030101
Content-Type: text/plain; charset=us-ascii;
 name="act-refcnt-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="act-refcnt-fix"

commit c845c05bed4834616deec4b3c504946326ecfc44
Author: Jamal Hadi Salim <hadi@mojatatu.com>
Date:   Sun Dec 22 07:15:57 2013 -0500

    This is a bug fix. The existing code tries to kill many birds with one
    stone: Handling binding of actions to filters, new actions and
    replacing of action attributes. A simple test case to illustrate:
    ----
    moja@fe1:~$ sudo tc actions add action drop index 12
    moja@fe1:~$ actions get action gact index 12
            action order 1: gact action drop
             random type none pass val 0
             index 12 ref 1 bind 0
    moja@fe1:~$ sudo tc actions replace action ok index 12
    moja@fe1:~$ actions get action gact index 12
            action order 1: gact action pass
             random type none pass val 0
             index 12 ref 2 bind 0
    ----
    
    The above shows the refcounf being wrongly incremented on replace.
    There are more complex scenarios with binding of actions to filters
    that i am leaving out that didnt work as well...
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 9cc6717..8b1d657 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -70,16 +70,16 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 				     &csum_idx_gen, &csum_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
-		p = to_tcf_csum(pc);
 		ret = ACT_P_CREATED;
 	} else {
-		p = to_tcf_csum(pc);
-		if (!ovr) {
-			tcf_hash_release(pc, bind, &csum_hash_info);
+		if (bind)/* dont override defaults */
+			return 0;
+		tcf_hash_release(pc, bind, &csum_hash_info);
+		if (!ovr)
 			return -EEXIST;
-		}
 	}
 
+	p = to_tcf_csum(pc);
 	spin_lock_bh(&p->tcf_lock);
 	p->tcf_action = parm->action;
 	p->update_flags = parm->update_flags;
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index dea9273..af5641c 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -95,10 +95,11 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
-		if (!ovr) {
-			tcf_hash_release(pc, bind, &gact_hash_info);
+		if (bind)/* dont override defaults */
+			return 0;
+		tcf_hash_release(pc, bind, &gact_hash_info);
+		if (!ovr)
 			return -EEXIST;
-		}
 	}
 
 	gact = to_gact(pc);
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index e13ecbb..2426369 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -134,10 +134,12 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 			return PTR_ERR(pc);
 		ret = ACT_P_CREATED;
 	} else {
-		if (!ovr) {
-			tcf_ipt_release(to_ipt(pc), bind);
+		if (bind)/* dont override defaults */
+			return 0;
+		tcf_ipt_release(to_ipt(pc), bind);
+
+		if (!ovr)
 			return -EEXIST;
-		}
 	}
 	ipt = to_ipt(pc);
 
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 921fea4..584e655 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -64,15 +64,15 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 				     &nat_idx_gen, &nat_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
-		p = to_tcf_nat(pc);
 		ret = ACT_P_CREATED;
 	} else {
-		p = to_tcf_nat(pc);
-		if (!ovr) {
-			tcf_hash_release(pc, bind, &nat_hash_info);
+		if (bind)
+			return 0;
+		tcf_hash_release(pc, bind, &nat_hash_info);
+		if (!ovr)
 			return -EEXIST;
-		}
 	}
+	p = to_tcf_nat(pc);
 
 	spin_lock_bh(&p->tcf_lock);
 	p->old_addr = parm->old_addr;
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index e2520e9..7291893 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -78,10 +78,12 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 		ret = ACT_P_CREATED;
 	} else {
 		p = to_pedit(pc);
-		if (!ovr) {
-			tcf_hash_release(pc, bind, &pedit_hash_info);
+		tcf_hash_release(pc, bind, &pedit_hash_info);
+		if (bind)
+			return 0;
+		if (!ovr)
 			return -EEXIST;
-		}
+
 		if (p->tcfp_nkeys && p->tcfp_nkeys != parm->nkeys) {
 			keys = kmalloc(ksize, GFP_KERNEL);
 			if (keys == NULL)
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 819a9a4..9295b86 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -162,10 +162,12 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 			if (bind) {
 				police->tcf_bindcnt += 1;
 				police->tcf_refcnt += 1;
+				return 0;
 			}
 			if (ovr)
 				goto override;
-			return ret;
+			/* not replacing */
+			return -EEXIST;
 		}
 	}
 
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 81aebc1..b44491e 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -135,10 +135,13 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 		ret = ACT_P_CREATED;
 	} else {
 		d = to_defact(pc);
-		if (!ovr) {
-			tcf_simp_release(d, bind);
+
+		if (bind)
+			return 0;
+		tcf_simp_release(d, bind);
+		if (!ovr)
 			return -EEXIST;
-		}
+
 		reset_policy(d, defdata, parm);
 	}
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index aa0a4c0..0fa1aad 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -112,10 +112,11 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 		ret = ACT_P_CREATED;
 	} else {
 		d = to_skbedit(pc);
-		if (!ovr) {
-			tcf_hash_release(pc, bind, &skbedit_hash_info);
+		if (bind)
+			return 0;
+		tcf_hash_release(pc, bind, &skbedit_hash_info);
+		if (!ovr)
 			return -EEXIST;
-		}
 	}
 
 	spin_lock_bh(&d->tcf_lock);

--------------060907090805000601030101--
