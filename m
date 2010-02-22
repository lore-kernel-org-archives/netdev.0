From: jamal <hadi@cyberus.ca>
Subject: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark infrastructure
Date: Mon, 22 Feb 2010 16:32:54 -0500
Message-ID: <1266874380-29593-2-git-send-email-hadi@cyberus.ca>
References: <xfrm-mark-v3>
 <1266874380-29593-1-git-send-email-hadi@cyberus.ca>
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:45423 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab0BVVdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 16:33:17 -0500
Received: by mail-bw0-f209.google.com with SMTP id 1so465221bwz.21
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 13:33:16 -0800 (PST)
In-Reply-To: <1266874380-29593-1-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

Add basic structuring and accessors for xfrm mark

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 include/linux/xfrm.h |   12 +++++++++---
 include/net/xfrm.h   |   22 ++++++++++++++++++++++
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 29e04be..b971e38 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -267,8 +267,8 @@ enum xfrm_attr_type_t {
 	XFRMA_ALG_COMP,		/* struct xfrm_algo */
 	XFRMA_ENCAP,		/* struct xfrm_algo + struct xfrm_encap_tmpl */
 	XFRMA_TMPL,		/* 1 or more struct xfrm_user_tmpl */
-	XFRMA_SA,
-	XFRMA_POLICY,
+	XFRMA_SA,		/* struct xfrm_usersa_info  */
+	XFRMA_POLICY,		/*struct xfrm_userpolicy_info */
 	XFRMA_SEC_CTX,		/* struct xfrm_sec_ctx */
 	XFRMA_LTIME_VAL,
 	XFRMA_REPLAY_VAL,
@@ -276,17 +276,23 @@ enum xfrm_attr_type_t {
 	XFRMA_ETIMER_THRESH,
 	XFRMA_SRCADDR,		/* xfrm_address_t */
 	XFRMA_COADDR,		/* xfrm_address_t */
-	XFRMA_LASTUSED,
+	XFRMA_LASTUSED,		/* unsigned long  */
 	XFRMA_POLICY_TYPE,	/* struct xfrm_userpolicy_type */
 	XFRMA_MIGRATE,
 	XFRMA_ALG_AEAD,		/* struct xfrm_algo_aead */
 	XFRMA_KMADDRESS,        /* struct xfrm_user_kmaddress */
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
+	XFRMA_MARK,		/* struct xfrm_mark */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
 };
 
+struct xfrm_mark {
+	__u32           v; /* value */
+	__u32           m; /* mask */
+};
+
 enum xfrm_sadattr_type_t {
 	XFRMA_SAD_UNSPEC,
 	XFRMA_SAD_CNT,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 0beb413..39f151c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -140,6 +140,7 @@ struct xfrm_state {
 
 	struct xfrm_id		id;
 	struct xfrm_selector	sel;
+	struct xfrm_mark	mark;
 
 	u32			genid;
 
@@ -481,6 +482,7 @@ struct xfrm_policy {
 
 	u32			priority;
 	u32			index;
+	struct xfrm_mark	mark;
 	struct xfrm_selector	selector;
 	struct xfrm_lifetime_cfg lft;
 	struct xfrm_lifetime_cur curlft;
@@ -1570,4 +1572,24 @@ static inline struct xfrm_state *xfrm_input_state(struct sk_buff *skb)
 }
 #endif
 
+static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
+{
+	if (attrs[XFRMA_MARK])
+		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
+	else
+		m->v = m->m = 0;
+
+	return m->v & m->m;
+}
+
+static inline int xfrm_mark_put(struct sk_buff *skb, struct xfrm_mark *m)
+{
+	if (m->m | m->v)
+		NLA_PUT(skb, XFRMA_MARK, sizeof(struct xfrm_mark), m);
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
 #endif	/* _NET_XFRM_H */
-- 
1.6.0.4

