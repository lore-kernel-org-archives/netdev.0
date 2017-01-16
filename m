From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH ipsec-next v3 2/2] IPsec: do not ignore crypto err in ah6 input
Date: Mon, 16 Jan 2017 13:17:56 +0200
Message-ID: <1484565476-19371-3-git-send-email-gilad@benyossef.com>
References: <1484565476-19371-1-git-send-email-gilad@benyossef.com>
Cc: ofir.drang@arm.com, gilad.benyossef@arm.com
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:50234 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750994AbdAPLST (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 06:18:19 -0500
In-Reply-To: <1484565476-19371-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ah6 input processing uses the asynchronous hash crypto API which
supplies an error code as part of the operation completion but
the error code was being ignored.

Treat a crypto API error indication as a verification failure.

While a crypto API reported error would almost certainly result
in a memcpy of the digest failing anyway and thus the security
risk seems minor, performing a memory compare on what might be
uninitialized memory is wrong.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 net/ipv6/ah6.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 189eb10..dda6035 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -474,6 +474,9 @@ static void ah6_input_done(struct crypto_async_request *base, int err)
 	int hdr_len = skb_network_header_len(skb);
 	int ah_hlen = (ah->hdrlen + 2) << 2;
 
+	if (err)
+		goto out;
+
 	work_iph = AH_SKB_CB(skb)->tmp;
 	auth_data = ah_tmp_auth(work_iph, hdr_len);
 	icv = ah_tmp_icv(ahp->ahash, auth_data, ahp->icv_trunc_len);
-- 
2.1.4
