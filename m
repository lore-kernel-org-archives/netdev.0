From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH net-next] IPsec: do not ignore crypto err in ah input
Date: Thu, 12 Jan 2017 15:33:22 +0200
Message-ID: <1484228002-25078-1-git-send-email-gilad@benyossef.com>
Cc: ofir.drang@arm.com, gilad.benyossef@arm.com,
        Gilad Ben-Yossef <gilad@benyossef.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34029 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750755AbdALNdn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:33:43 -0500
Received: by mail-lf0-f68.google.com with SMTP id q89so1828680lfi.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 05:33:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ah input processing uses the asynchrnous hash crypto API which
supplies an error code as part of the operation completion but 
the error code was being ignored.

Treat a crypto API error indication as a verification failure.

While a crypto API reported error would almost certainly result
in a memcpy of the digest failing anyway and thus the security
risk seems minor, performing a memory compare on what might be
uninitialized memory is wrong.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---

The change was boot tested on Arm64 but I did not exercise
the specific error code path in question.

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
