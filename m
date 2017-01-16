From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH ipsec-next v3 1/2] IPsec: do not ignore crypto err in ah4 input
Date: Mon, 16 Jan 2017 13:17:55 +0200
Message-ID: <1484565476-19371-2-git-send-email-gilad@benyossef.com>
References: <1484565476-19371-1-git-send-email-gilad@benyossef.com>
Cc: ofir.drang@arm.com, gilad.benyossef@arm.com
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:50220 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751074AbdAPLSM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 06:18:12 -0500
In-Reply-To: <1484565476-19371-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ah4 input processing uses the asynchronous hash crypto API which
supplies an error code as part of the operation completion but
the error code was being ignored.

Treat a crypto API error indication as a verification failure.

While a crypto API reported error would almost certainly result
in a memcpy of the digest failing anyway and thus the security
risk seems minor, performing a memory compare on what might be
uninitialized memory is wrong.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 net/ipv4/ah4.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index f2a7102..22377c8 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -270,6 +270,9 @@ static void ah_input_done(struct crypto_async_request *base, int err)
 	int ihl = ip_hdrlen(skb);
 	int ah_hlen = (ah->hdrlen + 2) << 2;
 
+	if (err)
+		goto out;
+
 	work_iph = AH_SKB_CB(skb)->tmp;
 	auth_data = ah_tmp_auth(work_iph, ihl);
 	icv = ah_tmp_icv(ahp->ahash, auth_data, ahp->icv_trunc_len);
-- 
2.1.4
