From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] KEY: Fix conversion between IPSEC_MODE_xxx and
 XFRM_MODE_xxx.
Date: Tue, 17 Apr 2007 17:15:17 +0900 (JST)
Message-ID: <20070417.171517.53528528.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:42774 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbXDQION (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 04:14:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
Subject: [PATCH] KEY: Fix conversion between IPSEC_MODE_xxx and XFRM_MODE_xxx.

We should not blindly convert between IPSEC_MODE_xxx and XFRM_MODE_xxx just
by incrementing / decrementing because the assumption is not true any longer.

Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
Singed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 90deefe..a61e6f6 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -630,6 +630,35 @@ #endif
 	/* NOTREACHED */
 }
 
+static inline int pfkey_mode_from_xfrm(int mode)
+{
+	switch(mode) {
+	case XFRM_MODE_TRANSPORT:
+		return IPSEC_MODE_TRANSPORT;
+	case XFRM_MODE_TUNNEL:
+		return IPSEC_MODE_TUNNEL;
+	case XFRM_MODE_BEET:
+		return IPSEC_MODE_BEET;
+	default:
+		return -1;
+	}
+}
+
+static inline int pfkey_mode_to_xfrm(int mode)
+{
+	switch(mode) {
+	case IPSEC_MODE_ANY:	/*XXX*/
+	case IPSEC_MODE_TRANSPORT:
+		return XFRM_MODE_TRANSPORT;
+	case IPSEC_MODE_TUNNEL:
+		return XFRM_MODE_TUNNEL;
+	case IPSEC_MODE_BEET:
+		return XFRM_MODE_BEET;
+	default:
+		return -1;
+	}
+}
+
 static struct sk_buff * pfkey_xfrm_state2msg(struct xfrm_state *x, int add_keys, int hsc)
 {
 	struct sk_buff *skb;
@@ -651,6 +680,7 @@ #endif
 	int encrypt_key_size = 0;
 	int sockaddr_size;
 	struct xfrm_encap_tmpl *natt = NULL;
+	int mode;
 
 	/* address family check */
 	sockaddr_size = pfkey_sockaddr_size(x->props.family);
@@ -928,7 +958,11 @@ #endif
 	sa2 = (struct sadb_x_sa2 *)  skb_put(skb, sizeof(struct sadb_x_sa2));
 	sa2->sadb_x_sa2_len = sizeof(struct sadb_x_sa2)/sizeof(uint64_t);
 	sa2->sadb_x_sa2_exttype = SADB_X_EXT_SA2;
-	sa2->sadb_x_sa2_mode = x->props.mode + 1;
+	if ((mode = pfkey_mode_from_xfrm(x->props.mode)) < 0) {
+		kfree_skb(skb);
+		return ERR_PTR(-EINVAL);
+	}
+	sa2->sadb_x_sa2_mode = mode;
 	sa2->sadb_x_sa2_reserved1 = 0;
 	sa2->sadb_x_sa2_reserved2 = 0;
 	sa2->sadb_x_sa2_sequence = 0;
@@ -1155,9 +1189,12 @@ static struct xfrm_state * pfkey_msg2xfr
 
 	if (ext_hdrs[SADB_X_EXT_SA2-1]) {
 		struct sadb_x_sa2 *sa2 = (void*)ext_hdrs[SADB_X_EXT_SA2-1];
-		x->props.mode = sa2->sadb_x_sa2_mode;
-		if (x->props.mode)
-			x->props.mode--;
+		int mode = pfkey_mode_to_xfrm(sa2->sadb_x_sa2_mode);
+		if (mode < 0) {
+			err = -EINVAL;
+			goto out;
+		}
+		x->props.mode = mode;
 		x->props.reqid = sa2->sadb_x_sa2_reqid;
 	}
 
@@ -1218,7 +1255,7 @@ static int pfkey_getspi(struct sock *sk,
 	struct sadb_address *saddr, *daddr;
 	struct sadb_msg *out_hdr;
 	struct xfrm_state *x = NULL;
-	u8 mode;
+	int mode;
 	u32 reqid;
 	u8 proto;
 	unsigned short family;
@@ -1233,7 +1270,9 @@ static int pfkey_getspi(struct sock *sk,
 		return -EINVAL;
 
 	if ((sa2 = ext_hdrs[SADB_X_EXT_SA2-1]) != NULL) {
-		mode = sa2->sadb_x_sa2_mode - 1;
+		mode = pfkey_mode_to_xfrm(sa2->sadb_x_sa2_mode);
+		if (mode < 0)
+			return -EINVAL;
 		reqid = sa2->sadb_x_sa2_reqid;
 	} else {
 		mode = 0;
@@ -1756,6 +1795,7 @@ parse_ipsecrequest(struct xfrm_policy *x
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct sockaddr_in6 *sin6;
 #endif
+	int mode;
 
 	if (xp->xfrm_nr >= XFRM_MAX_DEPTH)
 		return -ELOOP;
@@ -1764,7 +1804,9 @@ #endif
 		return -EINVAL;
 
 	t->id.proto = rq->sadb_x_ipsecrequest_proto; /* XXX check proto */
-	t->mode = rq->sadb_x_ipsecrequest_mode-1;
+	if ((mode = pfkey_mode_to_xfrm(rq->sadb_x_ipsecrequest_mode)) < 0)
+		return -EINVAL;
+	t->mode = mode;
 	if (rq->sadb_x_ipsecrequest_level == IPSEC_LEVEL_USE)
 		t->optional = 1;
 	else if (rq->sadb_x_ipsecrequest_level == IPSEC_LEVEL_UNIQUE) {
@@ -1877,7 +1919,7 @@ static struct sk_buff * pfkey_xfrm_polic
 	return skb;
 }
 
-static void pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, int dir)
+static int pfkey_xfrm_policy2msg(struct sk_buff *skb, struct xfrm_policy *xp, int dir)
 {
 	struct sadb_msg *hdr;
 	struct sadb_address *addr;
@@ -2014,6 +2056,7 @@ #endif
 		struct sadb_x_ipsecrequest *rq;
 		struct xfrm_tmpl *t = xp->xfrm_vec + i;
 		int req_size;
+		int mode;
 
 		req_size = sizeof(struct sadb_x_ipsecrequest);
 		if (t->mode == XFRM_MODE_TUNNEL)
@@ -2027,7 +2070,9 @@ #endif
 		memset(rq, 0, sizeof(*rq));
 		rq->sadb_x_ipsecrequest_len = req_size;
 		rq->sadb_x_ipsecrequest_proto = t->id.proto;
-		rq->sadb_x_ipsecrequest_mode = t->mode+1;
+		if ((mode = pfkey_mode_from_xfrm(t->mode)) < 0)
+			return -EINVAL;
+		mode = pfkey_mode_from_xfrm(t->mode);
 		rq->sadb_x_ipsecrequest_level = IPSEC_LEVEL_REQUIRE;
 		if (t->reqid)
 			rq->sadb_x_ipsecrequest_level = IPSEC_LEVEL_UNIQUE;
@@ -2089,6 +2134,8 @@ #endif
 
 	hdr->sadb_msg_len = size / sizeof(uint64_t);
 	hdr->sadb_msg_reserved = atomic_read(&xp->refcnt);
+
+	return 0;
 }
 
 static int key_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *c)
@@ -2102,7 +2149,9 @@ static int key_notify_policy(struct xfrm
 		err = PTR_ERR(out_skb);
 		goto out;
 	}
-	pfkey_xfrm_policy2msg(out_skb, xp, dir);
+	err = pfkey_xfrm_policy2msg(out_skb, xp, dir);
+	if (err < 0)
+		return err;
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version = PF_KEY_V2;
@@ -2327,7 +2376,9 @@ static int key_pol_get_resp(struct sock 
 		err =  PTR_ERR(out_skb);
 		goto out;
 	}
-	pfkey_xfrm_policy2msg(out_skb, xp, dir);
+	err = pfkey_xfrm_policy2msg(out_skb, xp, dir);
+	if (err < 0)
+		goto out;
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
@@ -2409,6 +2460,7 @@ static int ipsecrequests_to_migrate(stru
 {
 	int err;
 	struct sadb_x_ipsecrequest *rq2;
+	int mode;
 
 	if (len <= sizeof(struct sadb_x_ipsecrequest) ||
 	    len < rq1->sadb_x_ipsecrequest_len)
@@ -2439,7 +2491,9 @@ static int ipsecrequests_to_migrate(stru
 		return -EINVAL;
 
 	m->proto = rq1->sadb_x_ipsecrequest_proto;
-	m->mode = rq1->sadb_x_ipsecrequest_mode - 1;
+	if ((mode = pfkey_mode_to_xfrm(rq1->sadb_x_ipsecrequest_mode)) < 0)
+		return -EINVAL;
+	m->mode = mode;
 	m->reqid = rq1->sadb_x_ipsecrequest_reqid;
 
 	return ((int)(rq1->sadb_x_ipsecrequest_len +
@@ -2579,12 +2633,15 @@ static int dump_sp(struct xfrm_policy *x
 	struct pfkey_dump_data *data = ptr;
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
+	int err;
 
 	out_skb = pfkey_xfrm_policy2msg_prep(xp);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);
 
-	pfkey_xfrm_policy2msg(out_skb, xp, dir);
+	err = pfkey_xfrm_policy2msg(out_skb, xp, dir);
+	if (err < 0)
+		return err;
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version = data->hdr->sadb_msg_version;
@@ -3513,7 +3570,10 @@ static int pfkey_send_migrate(struct xfr
 
 	for (i = 0, mp = m; i < num_bundles; i++, mp++) {
 		/* old ipsecrequest */
-		if (set_ipsecrequest(skb, mp->proto, mp->mode + 1,
+		int mode = pfkey_mode_from_xfrm(mp->mode);
+		if (mode < 0)
+			return -EINVAL;
+		if (set_ipsecrequest(skb, mp->proto, mode,
 				     (mp->reqid ?  IPSEC_LEVEL_UNIQUE : IPSEC_LEVEL_REQUIRE),
 				     mp->reqid, mp->old_family,
 				     &mp->old_saddr, &mp->old_daddr) < 0) {
@@ -3521,7 +3581,7 @@ static int pfkey_send_migrate(struct xfr
 		}
 
 		/* new ipsecrequest */
-		if (set_ipsecrequest(skb, mp->proto, mp->mode + 1,
+		if (set_ipsecrequest(skb, mp->proto, mode,
 				     (mp->reqid ? IPSEC_LEVEL_UNIQUE : IPSEC_LEVEL_REQUIRE),
 				     mp->reqid, mp->new_family,
 				     &mp->new_saddr, &mp->new_daddr) < 0) {

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
