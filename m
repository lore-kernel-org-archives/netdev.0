From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 2/6] {IPv4,xfrm} Add ESN support for AH egress part
Date: Wed, 15 Jan 2014 15:13:11 +0800
Message-ID: <1389769995-350-3-git-send-email-fan.du@windriver.com>
References: <1389769995-350-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63755 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaAOHNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:13:10 -0500
In-Reply-To: <1389769995-350-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add esn support for AH output stage by attaching upper 32bits
sequence number right after packet payload as specified by RFC 4302.

Then the ICV value will guard upper 32bits sequence number as well when
packet going out.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv4/ah4.c |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 7179026..c6accac 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -155,6 +155,10 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct iphdr *iph, *top_iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
+	int seqhi_len = 0;
+	__be32 *seqhi;
+	int sglists = 0;
+	struct scatterlist *seqhisg;
 
 	ahp = x->data;
 	ahash = ahp->ahash;
@@ -167,14 +171,19 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	ah = ip_auth_hdr(skb);
 	ihl = ip_hdrlen(skb);
 
+	if (x->props.flags & XFRM_STATE_ESN) {
+		sglists = 1;
+		seqhi_len = sizeof(*seqhi);
+	}
 	err = -ENOMEM;
-	iph = ah_alloc_tmp(ahash, nfrags, ihl);
+	iph = ah_alloc_tmp(ahash, nfrags + sglists, ihl + seqhi_len);
 	if (!iph)
 		goto out;
-
-	icv = ah_tmp_icv(ahash, iph, ihl);
+	seqhi = (__be32 *)((char *)iph + ihl);
+	icv = ah_tmp_icv(ahash, seqhi, seqhi_len);
 	req = ah_tmp_req(ahash, icv);
 	sg = ah_req_sg(ahash, req);
+	seqhisg = sg + nfrags;
 
 	memset(ah->auth_data, 0, ahp->icv_trunc_len);
 
@@ -210,10 +219,15 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 
-	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	sg_init_table(sg, nfrags + sglists);
+	skb_to_sgvec_nomark(skb, sg, 0, skb->len);
 
-	ahash_request_set_crypt(req, sg, icv, skb->len);
+	if (x->props.flags & XFRM_STATE_ESN) {
+		/* Attach seqhi sg right after packet payload */
+		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
+		sg_set_buf(seqhisg, seqhi, seqhi_len);
+	}
+	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah_output_done, skb);
 
 	AH_SKB_CB(skb)->tmp = iph;
-- 
1.7.9.5
