From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 5/7] xfrm: SP lookups with mark
Date: Sun, 14 Feb 2010 10:18:50 -0500
Message-ID: <1266160732-946-6-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-net-next>
 <1266160732-946-1-git-send-email-hadi@cyberus.ca>
 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
 <1266160732-946-3-git-send-email-hadi@cyberus.ca>
 <1266160732-946-4-git-send-email-hadi@cyberus.ca>
 <1266160732-946-5-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:64587 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab0BNPTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 10:19:10 -0500
Received: by qw-out-2122.google.com with SMTP id 5so313015qwi.37
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2010 07:19:10 -0800 (PST)
In-Reply-To: <1266160732-946-5-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Allow mark to be used when doing SP lookup

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/xfrm/xfrm_policy.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e804aa5..38f40c4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -556,6 +556,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	struct hlist_head *chain;
 	struct hlist_node *entry, *newpos;
 	struct dst_entry *gc_list;
+	u32 mark = policy->mark.v & policy->mark.m;
 
 	write_lock_bh(&xfrm_policy_lock);
 	chain = policy_hash_bysel(net, &policy->selector, policy->family, dir);
@@ -564,6 +565,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type == policy->type &&
 		    !selector_cmp(&pol->selector, &policy->selector) &&
+		    (mark & pol->mark.m) == pol->mark.v &&
 		    xfrm_sec_ctx_match(pol->security, policy->security) &&
 		    !WARN_ON(delpol)) {
 			if (excl) {
@@ -650,6 +652,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark, u8 type,
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type == type &&
+		    (mark & pol->mark.m) == pol->mark.v &&
 		    !selector_cmp(sel, &pol->selector) &&
 		    xfrm_sec_ctx_match(ctx, pol->security)) {
 			xfrm_pol_hold(pol);
@@ -692,7 +695,8 @@ struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8 type,
 	chain = net->xfrm.policy_byidx + idx_hash(net, id);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, byidx) {
-		if (pol->type == type && pol->index == id) {
+		if (pol->type == type && pol->index == id &&
+		    (mark & pol->mark.m) == pol->mark.v) {
 			xfrm_pol_hold(pol);
 			if (delete) {
 				*err = security_xfrm_policy_delete(
@@ -909,6 +913,7 @@ static int xfrm_policy_match(struct xfrm_policy *pol, struct flowi *fl,
 	int match, ret = -ESRCH;
 
 	if (pol->family != family ||
+	    (fl->mark & pol->mark.m) != pol->mark.v ||
 	    pol->type != type)
 		return ret;
 
@@ -1033,6 +1038,10 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struc
 		int err = 0;
 
 		if (match) {
+			if ((sk->sk_mark & pol->mark.m) != pol->mark.v) {
+				pol = NULL;
+				goto out;
+			}
 			err = security_xfrm_policy_lookup(pol->security,
 						      fl->secid,
 						      policy_to_flow_dir(dir));
@@ -1045,6 +1054,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struc
 		} else
 			pol = NULL;
 	}
+out:
 	read_unlock_bh(&xfrm_policy_lock);
 	return pol;
 }
-- 
1.6.0.4

