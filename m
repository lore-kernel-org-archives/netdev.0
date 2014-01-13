From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 3/5] {IPv6,xfrm} Add ESN support for AH egress part
Date: Mon, 13 Jan 2014 15:48:42 +0800
Message-ID: <1389599324-5174-4-git-send-email-fan.du@windriver.com>
References: <1389599324-5174-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40799 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaAMHsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 02:48:45 -0500
In-Reply-To: <1389599324-5174-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add esn support for AH output stage by attaching upper 32bits
sequence number right after packet payload as specified by RFC 4302.

Then the ICV value will guard upper 32bits sequence number as well when
packet going out.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/ipv6/ah6.c |   24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 81e496a..87826a5 100644
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
+	seqhi = (char *)iph_ext + extlen;
+	icv = ah_tmp_icv(ahash, seqhi, seqhi_len);
 	req = ah_tmp_req(ahash, icv);
 	sg = ah_req_sg(ahash, req);
+	seqhisg = sg + nfrags;
 
 	ah = ip_auth_hdr(skb);
 	memset(ah->auth_data, 0, ahp->icv_trunc_len);
@@ -414,7 +425,14 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg, 0, skb->len);
 
-	ahash_request_set_crypt(req, sg, icv, skb->len);
+	if ((x->props.flags & XFRM_STATE_ESN)) {
+		sg_unmark_end(&sg[nfrags - 1]);
+		/* Attach seqhi sg right after packet payload */
+		*seqhi = htonl(XFRM_SKB_CB(skb)->seq.output.hi);
+		sg_init_table(seqhisg, sglists);
+		sg_set_buf(seqhisg, seqhi, seqhi_len);
+	}
+	ahash_request_set_crypt(req, sg, icv, skb->len + seqhi_len);
 	ahash_request_set_callback(req, 0, ah6_output_done, skb);
 
 	AH_SKB_CB(skb)->tmp = iph_base;
-- 
1.7.9.5
