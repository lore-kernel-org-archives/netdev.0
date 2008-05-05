From: jamal <hadi@cyberus.ca>
Subject: [NET_CLS_ACT] act_simple dont ignore realloc code
Date: Mon, 05 May 2008 08:48:06 -0400
Message-ID: <1209991686.6972.185.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zOUnawMxLZan78wUweLf"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.249]:51283 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756949AbYEEMsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 08:48:12 -0400
Received: by hs-out-0708.google.com with SMTP id 4so541045hsl.5
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 05:48:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zOUnawMxLZan78wUweLf
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


A buglet i noticed after previous patch.

cheers,
jamal

--=-zOUnawMxLZan78wUweLf
Content-Disposition: attachment; filename=act_simp2
Content-Type: text/plain; name=act_simp2; charset=us-ascii
Content-Transfer-Encoding: 7bit

[NET_CLS_ACT] act_simple dont ignore realloc code

reallocation of the policy data was being ignored. It could fail.
Simplify so that there is no need for reallocating.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 8ff83dfef72af6acb76fa2925c0be7b60da524f0
tree a68c20dfaeb4b30d2f633b9711a9dc253687c709
parent a189f0b99f377aeadd1d56046c4c0d2694cd9734
author Jamal Hadi Salim <hadi@cyberus.ca> Mon, 05 May 2008 08:43:45 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Mon, 05 May 2008 08:43:45 -0400

 net/sched/act_simple.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 269ab51..1d421d0 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -79,10 +79,14 @@ static int alloc_defdata(struct tcf_defact *d, char *defdata)
 	return 0;
 }
 
-static int realloc_defdata(struct tcf_defact *d, char *defdata)
+static void reset_policy(struct tcf_defact *d, char *defdata,
+			 struct tc_defact *p)
 {
-	kfree(d->tcfd_defdata);
-	return alloc_defdata(d, defdata);
+	spin_lock_bh(&d->tcf_lock);
+	d->tcf_action = p->action;
+	memset(d->tcfd_defdata, 0, SIMP_MAX_DATA);
+	strlcpy(d->tcfd_defdata, defdata, SIMP_MAX_DATA);
+	spin_unlock_bh(&d->tcf_lock);
 }
 
 static const struct nla_policy simple_policy[TCA_DEF_MAX + 1] = {
@@ -129,6 +133,7 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 			kfree(pc);
 			return ret;
 		}
+		d->tcf_action = parm->action;
 		ret = ACT_P_CREATED;
 	} else {
 		d = to_defact(pc);
@@ -136,13 +141,9 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 			tcf_simp_release(d, bind);
 			return -EEXIST;
 		}
-		realloc_defdata(d, defdata);
+		reset_policy(d, defdata, parm);
 	}
 
-	spin_lock_bh(&d->tcf_lock);
-	d->tcf_action = parm->action;
-	spin_unlock_bh(&d->tcf_lock);
-
 	if (ret == ACT_P_CREATED)
 		tcf_hash_insert(pc, &simp_hash_info);
 	return ret;

--=-zOUnawMxLZan78wUweLf--

