From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm_user: propagate sec ctx allocation errors
Date: Wed, 21 Sep 2016 13:05:43 +0200
Message-ID: <1474455946-674-2-git-send-email-steffen.klassert@secunet.com>
References: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38335 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754689AbcIULF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 07:05:56 -0400
In-Reply-To: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

When we fail to attach the security context in xfrm_state_construct()
we'll return 0 as error value which, in turn, will wrongly claim success
to userland when, in fact, we won't be adding / updating the XFRM state.

This is a regression introduced by commit fd21150a0fe1 ("[XFRM] netlink:
Inline attach_encap_tmpl(), attach_sec_ctx(), and attach_one_addr()").

Fix it by propagating the error returned by security_xfrm_state_alloc()
in this case.

Fixes: fd21150a0fe1 ("[XFRM] netlink: Inline attach_encap_tmpl()...")
Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index cb65d91..0889209 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -581,9 +581,12 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 	if (err)
 		goto error;
 
-	if (attrs[XFRMA_SEC_CTX] &&
-	    security_xfrm_state_alloc(x, nla_data(attrs[XFRMA_SEC_CTX])))
-		goto error;
+	if (attrs[XFRMA_SEC_CTX]) {
+		err = security_xfrm_state_alloc(x,
+						nla_data(attrs[XFRMA_SEC_CTX]));
+		if (err)
+			goto error;
+	}
 
 	if ((err = xfrm_alloc_replay_state_esn(&x->replay_esn, &x->preplay_esn,
 					       attrs[XFRMA_REPLAY_ESN_VAL])))
-- 
1.9.1
