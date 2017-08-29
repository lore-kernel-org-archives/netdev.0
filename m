From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/7] xfrm_user: fix info leak in build_expire()
Date: Tue, 29 Aug 2017 12:31:33 +0200
Message-ID: <1504002694-1931-7-git-send-email-steffen.klassert@secunet.com>
References: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50686 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752172AbdH2Kbo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 06:31:44 -0400
In-Reply-To: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

The memory reserved to dump the expired xfrm state includes padding
bytes in struct xfrm_user_expire added by the compiler for alignment. To
prevent the heap info leak, memset(0) the remainder of the struct.
Initializing the whole structure isn't needed as copy_to_user_state()
already takes care of clearing the padding bytes within the 'state'
member.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index c33516e..2cbdc81 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2578,6 +2578,8 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, const struct
 	ue = nlmsg_data(nlh);
 	copy_to_user_state(x, &ue->state);
 	ue->hard = (c->data.hard != 0) ? 1 : 0;
+	/* clear the padding bytes */
+	memset(&ue->hard + 1, 0, sizeof(*ue) - offsetofend(typeof(*ue), hard));
 
 	err = xfrm_mark_put(skb, &x->mark);
 	if (err)
-- 
2.7.4
