From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 1/3] xfrm: Try to honor policy index if it's supplied by user
Date: Thu, 7 Nov 2013 17:47:48 +0800
Message-ID: <1383817670-5783-2-git-send-email-fan.du@windriver.com>
References: <1383817670-5783-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.hengli.com.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60627 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763Ab3KGJrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:47:48 -0500
In-Reply-To: <1383817670-5783-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm code always searches for unused policy index for
newly created policy regardless whether or not user
space policy index hint supplied.

This patch enables such feature so that using
"ip xfrm ... index=xxx" can be used by user to set
specific policy index.

Currently this beahvior is broken, so this patch make
it happen as expected.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
v2:
 -Unchanged
---
 net/xfrm/xfrm_policy.c |   16 +++++++++++-----
 net/xfrm/xfrm_user.c   |   10 +++++++++-
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 9a91f74..a5bbdfb 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -538,7 +538,7 @@ static void xfrm_hash_resize(struct work_struct *work)
 
 /* Generate new index... KAME seems to generate them ordered by cost
  * of an absolute inpredictability of ordering of rules. This will not pass. */
-static u32 xfrm_gen_index(struct net *net, int dir)
+static u32 xfrm_gen_index(struct net *net, int dir, u32 index)
 {
 	static u32 idx_generator;
 
@@ -548,8 +548,14 @@ static u32 xfrm_gen_index(struct net *net, int dir)
 		u32 idx;
 		int found;
 
-		idx = (idx_generator | dir);
-		idx_generator += 8;
+		if (!index) {
+			idx = (idx_generator | dir);
+			idx_generator += 8;
+		} else {
+			idx = index;
+			index = 0;
+		}
+
 		if (idx == 0)
 			idx = 8;
 		list = net->xfrm.policy_byidx + idx_hash(net, idx);
@@ -672,7 +678,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		xfrm_policy_requeue(delpol, policy);
 		__xfrm_policy_unlink(delpol, dir);
 	}
-	policy->index = delpol ? delpol->index : xfrm_gen_index(net, dir);
+	policy->index = delpol ? delpol->index : xfrm_gen_index(net, dir, policy->index);
 	hlist_add_head(&policy->byidx, net->xfrm.policy_byidx+idx_hash(net, policy->index));
 	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
@@ -1192,7 +1198,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 	sk->sk_policy[dir] = pol;
 	if (pol) {
 		pol->curlft.add_time = get_seconds();
-		pol->index = xfrm_gen_index(net, XFRM_POLICY_MAX+dir);
+		pol->index = xfrm_gen_index(net, XFRM_POLICY_MAX+dir, 0);
 		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
 	}
 	if (old_pol) {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index f964d4c..4e0546e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1189,6 +1189,8 @@ static int verify_policy_type(u8 type)
 
 static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
 {
+	int ret;
+
 	switch (p->share) {
 	case XFRM_SHARE_ANY:
 	case XFRM_SHARE_SESSION:
@@ -1224,7 +1226,13 @@ static int verify_newpolicy_info(struct xfrm_userpolicy_info *p)
 		return -EINVAL;
 	}
 
-	return verify_policy_dir(p->dir);
+	ret = verify_policy_dir(p->dir);
+	if (ret)
+		return ret;
+	if (p->index && ((p->index & XFRM_POLICY_MAX) != p->dir))
+		return -EINVAL;
+
+	return 0;
 }
 
 static int copy_from_user_sec_ctx(struct xfrm_policy *pol, struct nlattr **attrs)
-- 
1.7.9.5
