From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/6] xfrm: extend MIGRATE with UDP encapsulation port
Date: Fri, 23 Jun 2017 10:38:29 +0200
Message-ID: <1498207110-22520-6-git-send-email-steffen.klassert@secunet.com>
References: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51154 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751217AbdFWIin (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 04:38:43 -0400
In-Reply-To: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antony Antony <antony@phenome.org>

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
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |  6 ++++--
 net/key/af_key.c       |  2 +-
 net/xfrm/xfrm_policy.c | 11 ++++-------
 net/xfrm/xfrm_state.c  | 18 +++++++++++++-----
 net/xfrm/xfrm_user.c   | 14 ++++++++++++--
 5 files changed, 34 insertions(+), 17 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6793a30c..1cc7172 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1688,10 +1688,12 @@ int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
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
index c1950bb..3b130cb 100644
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
index b00a1d5..d47f055 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -3315,11 +3315,6 @@ static int xfrm_migrate_check(const struct xfrm_migrate *m, int num_migrate)
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
@@ -3343,7 +3338,8 @@ static int xfrm_migrate_check(const struct xfrm_migrate *m, int num_migrate)
 
 int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 		 struct xfrm_migrate *m, int num_migrate,
-		 struct xfrm_kmaddress *k, struct net *net)
+		 struct xfrm_kmaddress *k, struct net *net,
+		 struct xfrm_encap_tmpl *encap)
 {
 	int i, err, nx_cur = 0, nx_new = 0;
 	struct xfrm_policy *pol = NULL;
@@ -3366,7 +3362,8 @@ int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
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
index 5780cda..b76e673 100644
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
@@ -1440,11 +1447,12 @@ struct xfrm_state *xfrm_migrate_state_find(struct xfrm_migrate *m, struct net *n
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
2.7.4
