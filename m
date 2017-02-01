From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 09/15] IPsec: do not ignore crypto err in ah4 input
Date: Wed, 1 Feb 2017 09:17:51 +0100
Message-ID: <1485937077-612-10-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37078 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751687AbdBAISP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:15 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gilad Ben-Yossef <gilad@benyossef.com>

ah4 input processing uses the asynchronous hash crypto API which
supplies an error code as part of the operation completion but
the error code was being ignored.

Treat a crypto API error indication as a verification failure.

While a crypto API reported error would almost certainly result
in a memcpy of the digest failing anyway and thus the security
risk seems minor, performing a memory compare on what might be
uninitialized memory is wrong.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
1.9.1
