From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 07/10] MLSXFRM: Add security context to acquire messages using
 PF_KEY
Date: Wed, 12 Jul 2006 16:14:36 -0500
Message-ID: <44B5663C.3050307@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:38777 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932438AbWGLVOn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 17:14:43 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This includes the security context of a security association created for use by IKE
in the acquire messages sent to IKE daemons using PF_KEY. This would allow
the daemons to include the security context in the negotiation, so that the resultant
association is unique to that security context.

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---

 net/key/af_key.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

--- linux-2.6.17.xfrm_user/net/key/af_key.c	2006-07-11 16:04:20.000000000 -0500
+++ linux-2.6.17/net/key/af_key.c	2006-07-11 20:59:42.000000000 -0500
@@ -2708,6 +2708,9 @@ static int pfkey_send_acquire(struct xfr
 #endif
 	int sockaddr_size;
 	int size;
+	struct sadb_x_sec_ctx *sec_ctx;
+	struct xfrm_sec_ctx *xfrm_ctx;
+	int ctx_size = 0;
 	
 	sockaddr_size = pfkey_sockaddr_size(x->props.family);
 	if (!sockaddr_size)
@@ -2723,6 +2726,11 @@ static int pfkey_send_acquire(struct xfr
 	else if (x->id.proto == IPPROTO_ESP)
 		size += count_esp_combs(t);
 
+	if ((xfrm_ctx = x->security)) {
+		ctx_size = PFKEY_ALIGN8(xfrm_ctx->ctx_len);
+		size +=  sizeof(struct sadb_x_sec_ctx) + ctx_size;
+	}
+
 	skb =  alloc_skb(size + 16, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -2818,6 +2826,20 @@ static int pfkey_send_acquire(struct xfr
 	else if (x->id.proto == IPPROTO_ESP)
 		dump_esp_combs(skb, t);
 
+	/* security context */
+	if (xfrm_ctx) {
+		sec_ctx = (struct sadb_x_sec_ctx *) skb_put(skb,
+				sizeof(struct sadb_x_sec_ctx) + ctx_size);
+		sec_ctx->sadb_x_sec_len =
+		  (sizeof(struct sadb_x_sec_ctx) + ctx_size) / sizeof(uint64_t);
+		sec_ctx->sadb_x_sec_exttype = SADB_X_EXT_SEC_CTX;
+		sec_ctx->sadb_x_ctx_doi = xfrm_ctx->ctx_doi;
+		sec_ctx->sadb_x_ctx_alg = xfrm_ctx->ctx_alg;
+		sec_ctx->sadb_x_ctx_len = xfrm_ctx->ctx_len;
+		memcpy(sec_ctx + 1, xfrm_ctx->ctx_str,
+		       xfrm_ctx->ctx_len);
+	}
+
 	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL);
 }
 
