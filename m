From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/5] xfrm: add XFRMA_REPLAY_VAL attribute to SA messages
Date: Wed, 3 Dec 2014 11:04:58 +0100
Message-ID: <1417601101-18625-3-git-send-email-steffen.klassert@secunet.com>
References: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33435 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbaLCKFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 05:05:19 -0500
In-Reply-To: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dingzhi <zhi.ding@6wind.com>

After this commit, the attribute XFRMA_REPLAY_VAL is added when no ESN replay
value is defined. Thus sequence number values are always notified to userspace.

Signed-off-by: dingzhi <zhi.ding@6wind.com>
Signed-off-by: Adrien Mazarguil <adrien.mazarguil@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e812e98..8128594 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -824,13 +824,15 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 	ret = xfrm_mark_put(skb, &x->mark);
 	if (ret)
 		goto out;
-	if (x->replay_esn) {
+	if (x->replay_esn)
 		ret = nla_put(skb, XFRMA_REPLAY_ESN_VAL,
 			      xfrm_replay_state_esn_len(x->replay_esn),
 			      x->replay_esn);
-		if (ret)
-			goto out;
-	}
+	else
+		ret = nla_put(skb, XFRMA_REPLAY_VAL, sizeof(x->replay),
+			      &x->replay);
+	if (ret)
+		goto out;
 	if (x->security)
 		ret = copy_sec_ctx(x->security, skb);
 out:
@@ -2569,6 +2571,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(x->tfcpad));
 	if (x->replay_esn)
 		l += nla_total_size(xfrm_replay_state_esn_len(x->replay_esn));
+	else
+		l += nla_total_size(sizeof(struct xfrm_replay_state));
 	if (x->security)
 		l += nla_total_size(sizeof(struct xfrm_user_sec_ctx) +
 				    x->security->ctx_len);
-- 
1.9.1
