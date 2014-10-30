From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH ipsec-next] xfrm: add XFRMA_REPLAY_VAL attribute to SA messages
Date: Thu, 30 Oct 2014 09:39:36 +0100
Message-ID: <1414658376-4207-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dingzhi <zhi.ding@6wind.com>,
	Adrien Mazarguil <adrien.mazarguil@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53442 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbaJ3Ijt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 04:39:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dingzhi <zhi.ding@6wind.com>

After this commit, the attribute XFRMA_REPLAY_VAL is added when no ESN replay
value is defined. Thus sequence number values are always notified to userspace.

Signed-off-by: dingzhi <zhi.ding@6wind.com>
Signed-off-by: Adrien Mazarguil <adrien.mazarguil@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/xfrm/xfrm_user.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e812e988c111..8128594ab379 100644
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
2.1.0
