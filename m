From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv5 net-next 4/6] {IPv6,xfrm} Add ESN support for AH egress part
Date: Sat, 18 Jan 2014 09:54:26 +0800
Message-ID: <1390010068-15715-5-git-send-email-fan.du@windriver.com>
References: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63083 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbaARByk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 20:54:40 -0500
In-Reply-To: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add esn support for AH output stage by attaching upper 32bits
sequence number right after packet payload as specified by RFC 4302.

Then the ICV value will guard upper 32bits sequence number as well when
packet going out.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv6/ah6.c |   26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 81e496a..8929812 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -346,6 +346,10 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
 	struct tmp_ext *iph_ext;
+	int seqhi_len = 0;
+	__be32 *seqhi;
+	int sglists = 0;
+	struct scatterlist *seqhisg;
 
 	ahp = x->data;
 	ahash = ahp->ahash;
@@ -359,15 +363,22 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (extlen)
 		extlen += sizeof(*iph_ext);
 
+	if (x->props.flags & XFRM_STATE_ESN) {
+		sglists = 1;
+		seqhi_len = sizeof(*seqhi);
+	}
 	err = -ENOMEM;
-	iph_base = ah_alloc_tmp(ahash, nfrags, IPV6HDR_BASELEN + extlen);
+	iph_base = ah_alloc_tmp(ahash, nfrags + sglists, IPV6HDR_BASELEN +
+				extlen + seqhi_len);
 	if (!iph_base)
 		goto out;
 
 	iph_ext = ah_tmp_ext(iph_base);
-	icv = ah_tmp_icv(ahash, iph_ext, extlen);
+	seqhi = (__be32 *)((char *)iph_ext + extlen);
+	icv = ah_tmp_icv(ahash, seqhi, seqhi_len);
 	req = ah_tmp_req(ahash, icv);
 	sg = ah_req_sg(ahash, req);
+	seqhisg = sg + nfrags;
 
 	ah = ip_auth_hdr(skb);
 	memset(ah->auth_data, 0, ahp->icv_trunc_len);
@@ -411,10 +422,15 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
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
 	ahash_request_set_callback(req, 0, ah6_output_done, skb);
 
 	AH_SKB_CB(skb)->tmp = iph_base;
-- 
1.7.9.5
