From: Antony Antony <antony@phenome.org>
Subject: [PATCH 2/2] xfrm: add UDP encapsulation port in migrate message
Date: Mon,  5 Jun 2017 23:56:25 +0200
Message-ID: <20170605215625.11043-3-antony@phenome.org>
References: <20170605215625.11043-1-antony@phenome.org>
Cc: Antony Antony <antony@phenome.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Richard Guy Briggs <rgb@tricolour.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud3.xs4all.net ([194.109.24.26]:58948 "EHLO
        lb2-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751277AbdFEV5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 17:57:30 -0400
In-Reply-To: <20170605215625.11043-1-antony@phenome.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add XFRMA_ENCAP, UDP encapsulation port, to km_migrate announcement
to userland. Only add if XFRMA_ENCAP was in user migrate request.

Signed-off-by: Antony Antony <antony@phenome.org>
---
 include/net/xfrm.h     |  5 +++--
 net/key/af_key.c       |  3 ++-
 net/xfrm/xfrm_policy.c |  2 +-
 net/xfrm/xfrm_state.c  |  5 +++--
 net/xfrm/xfrm_user.c   | 23 +++++++++++++++++------
 5 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index df98463..9fb75fb 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -631,7 +631,8 @@ struct xfrm_mgr {
 					   u8 dir, u8 type,
 					   const struct xfrm_migrate *m,
 					   int num_bundles,
-					   const struct xfrm_kmaddress *k);
+					   const struct xfrm_kmaddress *k,
+					   struct xfrm_encap_tmpl *encap);
 	bool			(*is_alive)(const struct km_event *c);
 };
 
@@ -1675,7 +1676,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 #ifdef CONFIG_XFRM_MIGRATE
 int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	       const struct xfrm_migrate *m, int num_bundles,
-	       const struct xfrm_kmaddress *k);
+	       const struct xfrm_kmaddress *k, struct xfrm_encap_tmpl *encap);
 struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *net);
 struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
 				      struct xfrm_migrate *m,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 56df9fb..2ad2286 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3508,7 +3508,8 @@ static int set_ipsecrequest(struct sk_buff *skb,
 #ifdef CONFIG_NET_KEY_MIGRATE
 static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 			      const struct xfrm_migrate *m, int num_bundles,
-			      const struct xfrm_kmaddress *k)
+			      const struct xfrm_kmaddress *k,
+			      struct xfrm_encap_tmpl *encap)
 {
 	int i;
 	int sasize_sel;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index eaecfa4..7152147 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3337,7 +3337,7 @@ int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	}
 
 	/* Stage 5 - announce */
-	km_migrate(sel, dir, type, m, num_migrate, k);
+	km_migrate(sel, dir, type, m, num_migrate, k, encap);
 
 	xfrm_pol_put(pol);
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index ae6206b..d6220f7 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1966,7 +1966,7 @@ EXPORT_SYMBOL(km_policy_expired);
 #ifdef CONFIG_XFRM_MIGRATE
 int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	       const struct xfrm_migrate *m, int num_migrate,
-	       const struct xfrm_kmaddress *k)
+	       const struct xfrm_kmaddress *k, struct xfrm_encap_tmpl *encap)
 {
 	int err = -EINVAL;
 	int ret;
@@ -1975,7 +1975,8 @@ int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	rcu_read_lock();
 	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
 		if (km->migrate) {
-			ret = km->migrate(sel, dir, type, m, num_migrate, k);
+			ret = km->migrate(sel, dir, type, m, num_migrate, k,
+					  encap);
 			if (!ret)
 				err = ret;
 		}
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index fb98892..8c54484 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2314,17 +2314,20 @@ static int copy_to_user_kmaddress(const struct xfrm_kmaddress *k, struct sk_buff
 	return nla_put(skb, XFRMA_KMADDRESS, sizeof(uk), &uk);
 }
 
-static inline size_t xfrm_migrate_msgsize(int num_migrate, int with_kma)
+static inline size_t xfrm_migrate_msgsize(int num_migrate, int with_kma,
+					  int with_encp)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_userpolicy_id))
 	      + (with_kma ? nla_total_size(sizeof(struct xfrm_kmaddress)) : 0)
+	      + (with_encp ? nla_total_size(sizeof(struct xfrm_encap_tmpl)) : 0)
 	      + nla_total_size(sizeof(struct xfrm_user_migrate) * num_migrate)
 	      + userpolicy_type_attrsize();
 }
 
 static int build_migrate(struct sk_buff *skb, const struct xfrm_migrate *m,
 			 int num_migrate, const struct xfrm_kmaddress *k,
-			 const struct xfrm_selector *sel, u8 dir, u8 type)
+			 const struct xfrm_selector *sel,
+			 struct xfrm_encap_tmpl *encap, u8 dir, u8 type)
 {
 	const struct xfrm_migrate *mp;
 	struct xfrm_userpolicy_id *pol_id;
@@ -2346,6 +2349,11 @@ static int build_migrate(struct sk_buff *skb, const struct xfrm_migrate *m,
 		if (err)
 			goto out_cancel;
 	}
+	if (encap) {
+		err = nla_put(skb, XFRMA_ENCAP, sizeof(*encap), encap);
+		if (err)
+			goto out_cancel;
+	}
 	err = copy_to_user_policy_type(type, skb);
 	if (err)
 		goto out_cancel;
@@ -2365,17 +2373,19 @@ static int build_migrate(struct sk_buff *skb, const struct xfrm_migrate *m,
 
 static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 			     const struct xfrm_migrate *m, int num_migrate,
-			     const struct xfrm_kmaddress *k)
+			     const struct xfrm_kmaddress *k,
+			     struct xfrm_encap_tmpl *encap)
 {
 	struct net *net = &init_net;
 	struct sk_buff *skb;
 
-	skb = nlmsg_new(xfrm_migrate_msgsize(num_migrate, !!k), GFP_ATOMIC);
+	skb = nlmsg_new(xfrm_migrate_msgsize(num_migrate, !!k, !!encap),
+			GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
 	/* build migrate */
-	if (build_migrate(skb, m, num_migrate, k, sel, dir, type) < 0)
+	if (build_migrate(skb, m, num_migrate, k, sel, encap, dir, type) < 0)
 		BUG();
 
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_MIGRATE);
@@ -2383,7 +2393,8 @@ static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 #else
 static int xfrm_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 			     const struct xfrm_migrate *m, int num_migrate,
-			     const struct xfrm_kmaddress *k)
+			     const struct xfrm_kmaddress *k,
+			     struct xfrm_encap_tmpl *encap)
 {
 	return -ENOPROTOOPT;
 }
-- 
2.9.3
