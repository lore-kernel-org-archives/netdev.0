From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v2 ipsec-next 5/6] xfrm: Extend the sec_path for IPsec offloading
Date: Mon, 13 Feb 2017 10:58:00 +0100
Message-ID: <1486979881-24635-6-git-send-email-steffen.klassert@secunet.com>
References: <1486979881-24635-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35410 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751507AbdBMKAT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 05:00:19 -0500
In-Reply-To: <1486979881-24635-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to keep per packet offloading informations across
the layers. So we extend the sec_path to carry these for
the input and output offload codepath.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    | 41 +++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_input.c |  2 ++
 2 files changed, 43 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index fe8db3d..11f63f2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -498,6 +498,7 @@ struct xfrm_tmpl {
 };
 
 #define XFRM_MAX_DEPTH		6
+#define XFRM_MAX_OFFLOAD_DEPTH	1
 
 struct xfrm_policy_walk_entry {
 	struct list_head	all;
@@ -973,10 +974,41 @@ static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 
 void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev);
 
+struct xfrm_offload {
+        /* Output sequence number for replay protection on offloading. */
+	struct {
+		__u32 low;
+		__u32 hi;
+	} seq;
+
+	__u32			flags;
+#define	SA_DELETE_REQ		1
+#define	CRYPTO_DONE		2
+#define	CRYPTO_NEXT_DONE	4
+#define	CRYPTO_FALLBACK		8
+#define	XFRM_GSO_SEGMENT	16
+#define	XFRM_GRO		32
+
+	__u32			status;
+#define CRYPTO_SUCCESS				1
+#define CRYPTO_GENERIC_ERROR			2
+#define CRYPTO_TRANSPORT_AH_AUTH_FAILED		4
+#define CRYPTO_TRANSPORT_ESP_AUTH_FAILED	8
+#define CRYPTO_TUNNEL_AH_AUTH_FAILED		16
+#define CRYPTO_TUNNEL_ESP_AUTH_FAILED		32
+#define CRYPTO_INVALID_PACKET_SYNTAX		64
+#define CRYPTO_INVALID_PROTOCOL			128
+
+	__u8			proto;
+};
+
 struct sec_path {
 	atomic_t		refcnt;
 	int			len;
+	int			olen;
+
 	struct xfrm_state	*xvec[XFRM_MAX_DEPTH];
+	struct xfrm_offload	ovec[XFRM_MAX_OFFLOAD_DEPTH];
 };
 
 static inline int secpath_exists(struct sk_buff *skb)
@@ -1776,6 +1808,15 @@ static inline struct xfrm_state *xfrm_input_state(struct sk_buff *skb)
 {
 	return skb->sp->xvec[skb->sp->len - 1];
 }
+static inline struct xfrm_offload *xfrm_offload(struct sk_buff *skb)
+{
+	struct sec_path *sp = skb->sp;
+
+	if (!sp || !sp->olen || sp->len != sp->olen)
+		return NULL;
+
+	return &sp->ovec[sp->olen - 1];
+}
 #endif
 
 static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 86f8a8d..d2ff712 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -105,6 +105,8 @@ struct sec_path *secpath_dup(struct sec_path *src)
 		return NULL;
 
 	sp->len = 0;
+	sp->olen = 0;
+
 	if (src) {
 		int i;
 
-- 
1.9.1
