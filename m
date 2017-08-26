From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net 3/4] xfrm_user: fix info leak in build_expire()
Date: Sat, 26 Aug 2017 17:08:59 +0200
Message-ID: <1503760140-9095-4-git-send-email-minipli@googlemail.com>
References: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33774 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdHZPJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 11:09:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id e67so2617741wmd.0
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 08:09:30 -0700 (PDT)
In-Reply-To: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory reserved to dump the expired xfrm state includes padding
bytes in struct xfrm_user_expire added by the compiler for alignment. To
prevent the heap info leak, memset(0) the remainder of the struct.
Initializing the whole structure isn't needed as copy_to_user_state()
already takes care of clearing the padding bytes within the 'state'
member.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index c33516ef52f2..2cbdc81610c6 100644
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
1.7.10.4
