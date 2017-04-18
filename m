From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: [PATCH v2 net 2/2] net sched actions: decrement module refcount earlier
Date: Tue, 18 Apr 2017 12:13:22 +0200
Message-ID: <20170418101322.27666-2-w.bumiller@proxmox.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxmox.maurer-it.com ([212.186.127.180]:4296 "EHLO
        proxmox.maurer-it.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755547AbdDRKN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 06:13:26 -0400
In-Reply-To: <20170418101322.27666-1-w.bumiller@proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whether the reference count has to be decremented depends
on whether the policy was created. If TCA_ACT_COOKIE is
passed and an error occurs there, the same condition still
has to be honored.

Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---

I did not include the Acked-bys here because I've noticed that this
is still wrong. After reading a bit more and doing more tests with
different filters I realized that the `name != NULL` case is specific
to the police filter only. For the other filters this patch here breaks
refcounting in the error case (I included it for reference only).
I'm thinking the first patch should be enough. (I've tested forcing the
other filters into the error path *without* this patch and couldn't
produce crashes or reference count problems (while with this patch
applied it was leaking reference counts on creation (which makes sense
considering tcf_hash_release is used and the ACT_P_CREATED case will
keep repeating)). (Whereas without both patches simply looking through
creating and deleting a policing filter pretty much always resulted in
crashes with various different backtraces.)

(I'd still like to clarify the comment in the code btw.)

 net/sched/act_api.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8cc883c063f0..4493f1b9d22b 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -604,28 +604,30 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (err < 0)
 		goto err_mod;
 
+	/* The module count should only go up when a brand new policy was
+	 * created, if it exists and is only bound to in a_o->init() then
+	 * ACT_P_CREATED is not returned (a zero is), and we need to roll back
+	 * the bump caused by tc_lookup_action_n().
+	 */
+	if (err != ACT_P_CREATED)
+		module_put(a_o->owner);
+
 	if (name == NULL && tb[TCA_ACT_COOKIE]) {
 		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
 
 		if (cklen > TC_COOKIE_MAX_SIZE) {
 			err = -EINVAL;
 			tcf_hash_release(a, bind);
-			goto err_mod;
+			goto err_out;
 		}
 
 		if (nla_memdup_cookie(a, tb) < 0) {
 			err = -ENOMEM;
 			tcf_hash_release(a, bind);
-			goto err_mod;
+			goto err_out;
 		}
 	}
 
-	/* module count goes up only when brand new policy is created
-	 * if it exists and is only bound to in a_o->init() then
-	 * ACT_P_CREATED is not returned (a zero is).
-	 */
-	if (err != ACT_P_CREATED)
-		module_put(a_o->owner);
 
 	return a;
 
-- 
2.11.0
