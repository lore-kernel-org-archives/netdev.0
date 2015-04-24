From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] xfrm: slightly optimise xfrm_input
Date: Fri, 24 Apr 2015 16:49:31 +0800
Message-ID: <1429865371-14722-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58040 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965840AbbDXItl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 04:49:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Check x->km.state with XFRM_STATE_ACQ only when state is not
XFRM_STAT_VALID, not everytime

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_input.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 459796a..1858a45f 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -239,13 +239,13 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb->sp->xvec[skb->sp->len++] = x;
 
 		spin_lock(&x->lock);
-		if (unlikely(x->km.state == XFRM_STATE_ACQ)) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMACQUIREERROR);
-			goto drop_unlock;
-		}
 
 		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEINVALID);
+			if (x->km.state == XFRM_STATE_ACQ)
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMACQUIREERROR);
+			else
+				XFRM_INC_STATS(net,
+					       LINUX_MIB_XFRMINSTATEINVALID);
 			goto drop_unlock;
 		}
 
-- 
2.1.0
