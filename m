From: Antony Antony <antony@phenome.org>
Subject: [PATCH v2 1/2] xfrm: extend MIGRATE with UDP encapsulation port
Date: Tue,  6 Jun 2017 12:12:13 +0200
Message-ID: <1496743934-12697-1-git-send-email-antony@phenome.org>
References: <20170605215625.11043-1-antony@phenome.org>
Cc: Antony Antony <antony@phenome.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Richard Guy Briggs <rgb@tricolour.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb3-smtp-cloud3.xs4all.net ([194.109.24.30]:48203 "EHLO
        lb3-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751443AbdFFKMY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 06:12:24 -0400
In-Reply-To: <20170605215625.11043-1-antony@phenome.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add UDP encapsulation port to XFRM_MSG_MIGRATE using an optional
netlink attribute XFRMA_ENCAP.

The devices that support IKE MOBIKE extension (RFC-4555 Section 3.8)
could go to sleep for a few minutes and wake up. When it wake up the
NAT mapping could have expired, the device send a MOBIKE UPDATE_SA
message to migrate the IPsec SA. The change could be a change UDP
encapsulation port, IP address, or both.

Reported-by: Paul Wouters <pwouters@redhat.com>
Signed-off-by: Antony Antony <antony@phenome.org>
Reviewed-by: Richard Guy Briggs <rgb@tricolour.ca>
---
 include/net/xfrm.h     |  6 ++++--
 net/key/af_key.c       |  2 +-
 net/xfrm/xfrm_policy.c | 11 ++++-------
 net/xfrm/xfrm_state.c  | 18 +++++++++++++-----
 net/xfrm/xfrm_user.c   | 14 ++++++++++++--
 5 files changed, 34 insertions(+), 17 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 7e7e2b0..df98463 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1678,10 +1678,12 @@ int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	       const struct xfrm_kmaddress *k);
 struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *net);
 struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
-				      struct xfrm_migrate *m);
+				      struct xfrm_migrate *m,
+				      struct xfrm_encap_tmpl *encap);
 int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		 struct xfrm_migrate *m, int num_bundles,
-		 struct xfrm_kmaddress *k, struct net *net);
+		 struct xfrm_kmaddress *k, struct net *net,
+		 struct xfrm_encap_tmpl *encap);
 #endif
 
 int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 512dc43..56df9fb 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2602,7 +2602,7 @@ static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
 	}
 
 	return xfrm_migrate(&sel, dir, XFRM_POLICY_TYPE_MAIN, m, i,
-			    kma ? &k : NULL, net);
+			    kma ? &k : NULL, net, NULL);
 
  out:
 	return err;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ed4e52d..eaecfa4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3268,11 +3268,6 @@ static int xfrm_migrate_check(const struct xfrm_migrate *m, int num_migrate)
 		return -EINVAL;
 
 	for (i = 0; i < num_migrate; i++) {
-		if (xfrm_addr_equal(&m[i].old_daddr, &m[i].new_daddr,
-				    m[i].old_family) &&
-		    xfrm_addr_equal(&m[i].old_saddr, &m[i].new_saddr,
-				    m[i].old_family))
-			return -EINVAL;
 		if (xfrm_addr_any(&m[i].new_daddr, m[i].new_family) ||
 		    xfrm_addr_any(&m[i].new_saddr, m[i].new_family))
 			return -EINVAL;
@@ -3296,7 +3291,8 @@ static int xfrm_migrate_check(const struct xfrm_migrate *m, int num_migrate)
 
 int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		 struct xfrm_migrate *m, int num_migrate,
-		 struct xfrm_kmaddress *k, struct net *net)
+		 struct xfrm_kmaddress *k, struct net *net,
+		 struct xfrm_encap_tmpl *encap)
 {
 	int i, err, nx_cur = 0, nx_new = 0;
 	struct xfrm_policy *pol = NULL;
@@ -3319,7 +3315,8 @@ int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		if ((x = xfrm_migrate_state_find(mp, net))) {
 			x_cur[nx_cur] = x;
 			nx_cur++;
-			if ((xc = xfrm_state_migrate(x, mp))) {
+			xc = xfrm_state_migrate(x, mp, encap);
+			if (xc) {
 				x_new[nx_new] = xc;
 				nx_new++;
 			} else {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 2e291bc..ae6206b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1309,7 +1309,8 @@ int xfrm_state_add(struct xfrm_state *x)
 EXPORT_SYMBOL(xfrm_state_add);
 
 #ifdef CONFIG_XFRM_MIGRATE
-static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig)
+static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig,
+					   struct xfrm_encap_tmpl *encap)
 {
 	struct net *net = xs_net(orig);
 	struct xfrm_state *x = xfrm_state_alloc(net);
@@ -1351,8 +1352,14 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig)
 	}
 	x->props.calgo = orig->props.calgo;
 
-	if (orig->encap) {
-		x->encap = kmemdup(orig->encap, sizeof(*x->encap), GFP_KERNEL);
+	if (encap || orig->encap) {
+		if (encap)
+			x->encap = kmemdup(encap, sizeof(*x->encap),
+					GFP_KERNEL);
+		else
+			x->encap = kmemdup(orig->encap, sizeof(*x->encap),
+					GFP_KERNEL);
+
 		if (!x->encap)
 			goto error;
 	}
@@ -1442,11 +1449,12 @@ struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *n
 EXPORT_SYMBOL(xfrm_migrate_state_find);
 
 struct xfrm_state *xfrm_state_migrate(struct xfrm_state *x,
-				      struct xfrm_migrate *m)
+				      struct xfrm_migrate *m,
+				      struct xfrm_encap_tmpl *encap)
 {
 	struct xfrm_state *xc;
 
-	xc = xfrm_state_clone(x);
+	xc = xfrm_state_clone(x, encap);
 	if (!xc)
 		return NULL;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 38614df..fb98892 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2243,6 +2243,7 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err;
 	int n = 0;
 	struct net *net = sock_net(skb->sk);
+	struct xfrm_encap_tmpl  *encap = NULL;
 
 	if (attrs[XFRMA_MIGRATE] == NULL)
 		return -EINVAL;
@@ -2260,9 +2261,18 @@ static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (!n)
 		return 0;
 
-	xfrm_migrate(&pi->sel, pi->dir, type, m, n, kmp, net);
+	if (attrs[XFRMA_ENCAP]) {
+		encap = kmemdup(nla_data(attrs[XFRMA_ENCAP]),
+				sizeof(*encap), GFP_KERNEL);
+		if (!encap)
+			return 0;
+	}
 
-	return 0;
+	err = xfrm_migrate(&pi->sel, pi->dir, type, m, n, kmp, net, encap);
+
+	kfree(encap);
+
+	return err;
 }
 #else
 static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
-- 
2.9.3
