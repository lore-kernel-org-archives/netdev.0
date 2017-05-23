From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/5] af_key: Fix slab-out-of-bounds in pfkey_compile_policy.
Date: Tue, 23 May 2017 07:33:42 +0200
Message-ID: <1495517624-27096-4-git-send-email-steffen.klassert@secunet.com>
References: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45122 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934692AbdEWFdx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 01:33:53 -0400
In-Reply-To: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sadb_x_sec_len is stored in the unit 'byte divided by eight'.
So we have to multiply this value by eight before we can do
size checks. Otherwise we may get a slab-out-of-bounds when
we memcpy the user sec_ctx.

Fixes: df71837d502 ("[LSM-IPSec]: Security association restriction.")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index c1950bb..512dc43 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3285,7 +3285,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 		p += pol->sadb_x_policy_len*8;
 		sec_ctx = (struct sadb_x_sec_ctx *)p;
 		if (len < pol->sadb_x_policy_len*8 +
-		    sec_ctx->sadb_x_sec_len) {
+		    sec_ctx->sadb_x_sec_len*8) {
 			*dir = -EINVAL;
 			goto out;
 		}
-- 
2.7.4
