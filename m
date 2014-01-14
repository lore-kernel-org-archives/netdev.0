From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next 4/5] {IPv6,xfrm} Add ESN support for AH ingress part
Date: Tue, 14 Jan 2014 09:39:11 +0800
Message-ID: <1389663552-29638-5-git-send-email-fan.du@windriver.com>
References: <1389663552-29638-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44126 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641AbaANBjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 20:39:13 -0500
In-Reply-To: <1389663552-29638-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add esn support for AH input stage by attaching upper 32bits
sequence number right after packet payload as specified by RFC 4302.

Then the ICV value will guard upper 32bits sequence number as well when
packet going in.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv6/ah6.c |   28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 3053a01..8119256 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -532,6 +532,10 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	int nexthdr;
 	int nfrags;
 	int err = -ENOMEM;
+	int seqhi_len = 0;
+	__be32 *seqhi;
+	int sglists = 0;
+	struct scatterlist *seqhisg;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
 		goto out;
@@ -568,14 +572,22 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 
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
@@ -593,7 +605,15 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg, 0, skb->len);
 
-	ahash_request_set_crypt(req, sg, icv, skb->len);
+	if (x->props.flags & XFRM_STATE_ESN) {
+		sg_unmark_end(&sg[nfrags - 1]);
+		/* Attach seqhi sg right after packet payload */
+		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
+		sg_init_table(seqhisg, sglists);
+		sg_set_buf(seqhisg, seqhi, seqhi_len);
+	}
+
+	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah6_input_done, skb);
 
 	AH_SKB_CB(skb)->tmp = work_iph;
-- 
1.7.9.5
