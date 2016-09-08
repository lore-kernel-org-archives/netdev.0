From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] xfrm_user: propagate sec ctx allocation errors
Date: Thu,  8 Sep 2016 18:09:57 +0200
Message-ID: <1473350997-32733-1-git-send-email-minipli@googlemail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>,
        Thomas Graf <tgraf@suug.ch>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35819 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932882AbcIHQKs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 12:10:48 -0400
Received: by mail-wm0-f68.google.com with SMTP id a6so8556745wmc.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 09:10:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/xfrm/xfrm_user.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d516845e16e3..b08440a8f123 100644
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
1.7.10.4
