From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 2/3] xfrm: Using the right namespace to migrate key info
Date: Thu, 7 Nov 2013 17:47:49 +0800
Message-ID: <1383817670-5783-3-git-send-email-fan.du@windriver.com>
References: <1383817670-5783-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.hengli.com.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:57471 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab3KGJru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 04:47:50 -0500
In-Reply-To: <1383817670-5783-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

because the home agent could surely be run on a different
net namespace other than init_net. The original behavior
could lead into inconsistent of key info.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
v2:
 -Unchanged
---
 include/net/xfrm.h     |    2 +-
 net/key/af_key.c       |    3 ++-
 net/xfrm/xfrm_policy.c |   10 +++++-----
 net/xfrm/xfrm_user.c   |    3 ++-
 4 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6b82fdf..5b522c5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1581,7 +1581,7 @@ struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
 				      struct xfrm_migrate *m);
 int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		 struct xfrm_migrate *m, int num_bundles,
-		 struct xfrm_kmaddress *k);
+		 struct xfrm_kmaddress *k, struct net *net);
 #endif
 
 int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 911ef03..33480b3 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2485,6 +2485,7 @@ static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
 	struct xfrm_selector sel;
 	struct xfrm_migrate m[XFRM_MAX_DEPTH];
 	struct xfrm_kmaddress k;
+	struct net *net = sock_net(sk);
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC - 1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST - 1]) ||
@@ -2558,7 +2559,7 @@ static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
 	}
 
 	return xfrm_migrate(&sel, dir, XFRM_POLICY_TYPE_MAIN, m, i,
-			    kma ? &k : NULL);
+			    kma ? &k : NULL, net);
 
  out:
 	return err;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a5bbdfb..907fd2f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3076,14 +3076,14 @@ static bool xfrm_migrate_selector_match(const struct xfrm_selector *sel_cmp,
 }
 
 static struct xfrm_policy * xfrm_migrate_policy_find(const struct xfrm_selector *sel,
-						     u8 dir, u8 type)
+						     u8 dir, u8 type, struct net *net)
 {
 	struct xfrm_policy *pol, *ret = NULL;
 	struct hlist_head *chain;
 	u32 priority = ~0U;
 
 	read_lock_bh(&xfrm_policy_lock);
-	chain = policy_hash_direct(&init_net, &sel->daddr, &sel->saddr, sel->family, dir);
+	chain = policy_hash_direct(net, &sel->daddr, &sel->saddr, sel->family, dir);
 	hlist_for_each_entry(pol, chain, bydst) {
 		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
 		    pol->type == type) {
@@ -3092,7 +3092,7 @@ static struct xfrm_policy * xfrm_migrate_policy_find(const struct xfrm_selector
 			break;
 		}
 	}
-	chain = &init_net.xfrm.policy_inexact[dir];
+	chain = &net->xfrm.policy_inexact[dir];
 	hlist_for_each_entry(pol, chain, bydst) {
 		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
 		    pol->type == type &&
@@ -3216,7 +3216,7 @@ static int xfrm_migrate_check(const struct xfrm_migrate *m, int num_migrate)
 
 int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		 struct xfrm_migrate *m, int num_migrate,
-		 struct xfrm_kmaddress *k)
+		 struct xfrm_kmaddress *k, struct net *net)
 {
 	int i, err, nx_cur = 0, nx_new = 0;
 	struct xfrm_policy *pol = NULL;
@@ -3229,7 +3229,7 @@ int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		goto out;
 
 	/* Stage 1 - find policy */
-	if ((pol = xfrm_migrate_policy_find(sel, dir, type)) == NULL) {
+	if ((pol = xfrm_migrate_policy_find(sel, dir, type, net)) == NULL) {
 		err = -ENOENT;
 		goto out;
 	}
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4e0546e..840cc8d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2137,6 +2137,7 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u8 type;
 	int err;
 	int n = 0;
+	struct net *net = sock_net(skb->sk);
 
 	if (attrs[XFRMA_MIGRATE] == NULL)
 		return -EINVAL;
@@ -2154,7 +2155,7 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!n)
 		return 0;
 
-	xfrm_migrate(&pi->sel, pi->dir, type, m, n, kmp);
+	xfrm_migrate(&pi->sel, pi->dir, type, m, n, kmp, net);
 
 	return 0;
 }
-- 
1.7.9.5
