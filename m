From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] af_key: Fix sadb_x_ipsecrequest parsing
Date: Wed, 19 Apr 2017 07:10:36 +0200
Message-ID: <1492578636-621-3-git-send-email-steffen.klassert@secunet.com>
References: <1492578636-621-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:40724 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759459AbdDSFKz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 01:10:55 -0400
In-Reply-To: <1492578636-621-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

The parsing of sadb_x_ipsecrequest is broken in a number of ways.
First of all we're not verifying sadb_x_ipsecrequest_len.  This
is needed when the structure carries addresses at the end.  Worse
we don't even look at the length when we parse those optional
addresses.

The migration code had similar parsing code that's better but
it also has some deficiencies.  The length is overcounted first
of all as it includes the header itself.  It also fails to check
the length before dereferencing the sa_family field.

This patch fixes those problems in parse_sockaddr_pair and then
uses it in parse_ipsecrequest.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c | 47 ++++++++++++++++++++++++++---------------------
 1 file changed, 26 insertions(+), 21 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1b0ea80..be8cecc 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -66,6 +66,10 @@ struct pfkey_sock {
 	struct mutex dump_lock;
 };
 
+static int parse_sockaddr_pair(struct sockaddr *sa, int ext_len,
+			       xfrm_address_t *saddr, xfrm_address_t *daddr,
+			       u16 *family);
+
 static inline struct pfkey_sock *pfkey_sk(struct sock *sk)
 {
 	return (struct pfkey_sock *)sk;
@@ -1939,19 +1943,14 @@ parse_ipsecrequest(struct xfrm_policy *xp, struct sadb_x_ipsecrequest *rq)
 
 	/* addresses present only in tunnel mode */
 	if (t->mode == XFRM_MODE_TUNNEL) {
-		u8 *sa = (u8 *) (rq + 1);
-		int family, socklen;
+		int err;
 
-		family = pfkey_sockaddr_extract((struct sockaddr *)sa,
-						&t->saddr);
-		if (!family)
-			return -EINVAL;
-
-		socklen = pfkey_sockaddr_len(family);
-		if (pfkey_sockaddr_extract((struct sockaddr *)(sa + socklen),
-					   &t->id.daddr) != family)
-			return -EINVAL;
-		t->encap_family = family;
+		err = parse_sockaddr_pair(
+			(struct sockaddr *)(rq + 1),
+			rq->sadb_x_ipsecrequest_len - sizeof(*rq),
+			&t->saddr, &t->id.daddr, &t->encap_family);
+		if (err)
+			return err;
 	} else
 		t->encap_family = xp->family;
 
@@ -1971,7 +1970,11 @@ parse_ipsecrequests(struct xfrm_policy *xp, struct sadb_x_policy *pol)
 	if (pol->sadb_x_policy_len * 8 < sizeof(struct sadb_x_policy))
 		return -EINVAL;
 
-	while (len >= sizeof(struct sadb_x_ipsecrequest)) {
+	while (len >= sizeof(*rq)) {
+		if (len < rq->sadb_x_ipsecrequest_len ||
+		    rq->sadb_x_ipsecrequest_len < sizeof(*rq))
+			return -EINVAL;
+
 		if ((err = parse_ipsecrequest(xp, rq)) < 0)
 			return err;
 		len -= rq->sadb_x_ipsecrequest_len;
@@ -2434,7 +2437,6 @@ static int key_pol_get_resp(struct sock *sk, struct xfrm_policy *xp, const struc
 	return err;
 }
 
-#ifdef CONFIG_NET_KEY_MIGRATE
 static int pfkey_sockaddr_pair_size(sa_family_t family)
 {
 	return PFKEY_ALIGN8(pfkey_sockaddr_len(family) * 2);
@@ -2446,7 +2448,7 @@ static int parse_sockaddr_pair(struct sockaddr *sa, int ext_len,
 {
 	int af, socklen;
 
-	if (ext_len < pfkey_sockaddr_pair_size(sa->sa_family))
+	if (ext_len < 2 || ext_len < pfkey_sockaddr_pair_size(sa->sa_family))
 		return -EINVAL;
 
 	af = pfkey_sockaddr_extract(sa, saddr);
@@ -2462,6 +2464,7 @@ static int parse_sockaddr_pair(struct sockaddr *sa, int ext_len,
 	return 0;
 }
 
+#ifdef CONFIG_NET_KEY_MIGRATE
 static int ipsecrequests_to_migrate(struct sadb_x_ipsecrequest *rq1, int len,
 				    struct xfrm_migrate *m)
 {
@@ -2469,13 +2472,14 @@ static int ipsecrequests_to_migrate(struct sadb_x_ipsecrequest *rq1, int len,
 	struct sadb_x_ipsecrequest *rq2;
 	int mode;
 
-	if (len <= sizeof(struct sadb_x_ipsecrequest) ||
-	    len < rq1->sadb_x_ipsecrequest_len)
+	if (len < sizeof(*rq1) ||
+	    len < rq1->sadb_x_ipsecrequest_len ||
+	    rq1->sadb_x_ipsecrequest_len < sizeof(*rq1))
 		return -EINVAL;
 
 	/* old endoints */
 	err = parse_sockaddr_pair((struct sockaddr *)(rq1 + 1),
-				  rq1->sadb_x_ipsecrequest_len,
+				  rq1->sadb_x_ipsecrequest_len - sizeof(*rq1),
 				  &m->old_saddr, &m->old_daddr,
 				  &m->old_family);
 	if (err)
@@ -2484,13 +2488,14 @@ static int ipsecrequests_to_migrate(struct sadb_x_ipsecrequest *rq1, int len,
 	rq2 = (struct sadb_x_ipsecrequest *)((u8 *)rq1 + rq1->sadb_x_ipsecrequest_len);
 	len -= rq1->sadb_x_ipsecrequest_len;
 
-	if (len <= sizeof(struct sadb_x_ipsecrequest) ||
-	    len < rq2->sadb_x_ipsecrequest_len)
+	if (len <= sizeof(*rq2) ||
+	    len < rq2->sadb_x_ipsecrequest_len ||
+	    rq2->sadb_x_ipsecrequest_len < sizeof(*rq2))
 		return -EINVAL;
 
 	/* new endpoints */
 	err = parse_sockaddr_pair((struct sockaddr *)(rq2 + 1),
-				  rq2->sadb_x_ipsecrequest_len,
+				  rq2->sadb_x_ipsecrequest_len - sizeof(*rq2),
 				  &m->new_saddr, &m->new_daddr,
 				  &m->new_family);
 	if (err)
-- 
2.7.4
