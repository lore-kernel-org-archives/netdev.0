From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 3/6] {IPv4,xfrm} Add ESN support for AH ingress part
Date: Wed, 15 Jan 2014 15:13:12 +0800
Message-ID: <1389769995-350-4-git-send-email-fan.du@windriver.com>
References: <1389769995-350-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:50672 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbaAOHNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:13:13 -0500
In-Reply-To: <1389769995-350-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add esn support for AH input stage by attaching upper 32bits
sequence number right after packet payload as specified by RFC 4302.

Then the ICV value will guard upper 32bits sequence number as well when
packet getting in.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv4/ah4.c |   27 ++++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index c6accac..c94ef19 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -309,6 +309,10 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
 	int err = -ENOMEM;
+	int seqhi_len = 0;
+	__be32 *seqhi;
+	int sglists = 0;
+	struct scatterlist *seqhisg;
 
 	if (!pskb_may_pull(skb, sizeof(*ah)))
 		goto out;
@@ -349,14 +353,22 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 	iph = ip_hdr(skb);
 	ihl = ip_hdrlen(skb);
 
-	work_iph = ah_alloc_tmp(ahash, nfrags, ihl + ahp->icv_trunc_len);
+	if (x->props.flags & XFRM_STATE_ESN) {
+		sglists = 1;
+		seqhi_len = sizeof(*seqhi);
+	}
+
+	work_iph = ah_alloc_tmp(ahash, nfrags + sglists, ihl +
+				ahp->icv_trunc_len + seqhi_len);
 	if (!work_iph)
 		goto out;
 
-	auth_data = ah_tmp_auth(work_iph, ihl);
+	seqhi = (__be32 *)((char *)work_iph + ihl);
+	auth_data = ah_tmp_auth(seqhi, seqhi_len);
 	icv = ah_tmp_icv(ahash, auth_data, ahp->icv_trunc_len);
 	req = ah_tmp_req(ahash, icv);
 	sg = ah_req_sg(ahash, req);
+	seqhisg = sg + nfrags;
 
 	memcpy(work_iph, iph, ihl);
 	memcpy(auth_data, ah->auth_data, ahp->icv_trunc_len);
@@ -375,10 +387,15 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_push(skb, ihl);
 
-	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	sg_init_table(sg, nfrags + sglists);
+	skb_to_sgvec_nomark(skb, sg, 0, skb->len);
 
-	ahash_request_set_crypt(req, sg, icv, skb->len);
+	if (x->props.flags & XFRM_STATE_ESN) {
+		/* Attach seqhi sg right after packet payload */
+		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.input.hi);
+		sg_set_buf(seqhisg, seqhi, seqhi_len);
+	}
+	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah_input_done, skb);
 
 	AH_SKB_CB(skb)->tmp = work_iph;
-- 
1.7.9.5
