From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 05/13] {IPv6,xfrm} Add ESN support for AH ingress part
Date: Mon, 24 Feb 2014 10:59:53 +0100
Message-ID: <1393236001-2445-6-git-send-email-steffen.klassert@secunet.com>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39103 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915AbaBXKAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:12 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

This patch add esn support for AH input stage by attaching upper 32bits
sequence number right after packet payload as specified by RFC 4302.

Then the ICV value will guard upper 32bits sequence number as well when
packet going in.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ah6.c |   30 ++++++++++++++++++++++++------
 1 file changed, 24 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 8929812..6c5f094 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -530,6 +530,10 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	int nexthdr;
 	int nfrags;
 	int err = -ENOMEM;
+	int seqhi_len = 0;
+	__be32 *seqhi;
+	int sglists = 0;
+	struct scatterlist *seqhisg;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
 		goto out;
@@ -566,14 +570,22 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_push(skb, hdr_len);
 
-	work_iph = ah_alloc_tmp(ahash, nfrags, hdr_len + ahp->icv_trunc_len);
+	if (x->props.flags & XFRM_STATE_ESN) {
+		sglists = 1;
+		seqhi_len = sizeof(*seqhi);
+	}
+
+	work_iph = ah_alloc_tmp(ahash, nfrags + sglists, hdr_len +
+				ahp->icv_trunc_len + seqhi_len);
 	if (!work_iph)
 		goto out;
 
-	auth_data = ah_tmp_auth(work_iph, hdr_len);
-	icv = ah_tmp_icv(ahash, auth_data, ahp->icv_trunc_len);
+	auth_data = ah_tmp_auth((u8 *)work_iph, hdr_len);
+	seqhi = (__be32 *)(auth_data + ahp->icv_trunc_len);
+	icv = ah_tmp_icv(ahash, seqhi, seqhi_len);
 	req = ah_tmp_req(ahash, icv);
 	sg = ah_req_sg(ahash, req);
+	seqhisg = sg + nfrags;
 
 	memcpy(work_iph, ip6h, hdr_len);
 	memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
@@ -588,10 +600,16 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	ip6h->flow_lbl[2] = 0;
 	ip6h->hop_limit   = 0;
 
-	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	sg_init_table(sg, nfrags + sglists);
+	skb_to_sgvec_nomark(skb, sg, 0, skb->len);
+
+	if (x->props.flags & XFRM_STATE_ESN) {
+		/* Attach seqhi sg right after packet payload */
+		*seqhi = XFRM_SKB_CB(skb)->seq.input.hi;
+		sg_set_buf(seqhisg, seqhi, seqhi_len);
+	}
 
-	ahash_request_set_crypt(req, sg, icv, skb->len);
+	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah6_input_done, skb);
 
 	AH_SKB_CB(skb)->tmp = work_iph;
-- 
1.7.9.5
