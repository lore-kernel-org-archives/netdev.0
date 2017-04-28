From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: do the garbage collection after flushing policy
Date: Fri, 28 Apr 2017 11:14:32 +0200
Message-ID: <1493370873-30836-2-git-send-email-steffen.klassert@secunet.com>
References: <1493370873-30836-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58090 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163924AbdD1Js5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 05:48:57 -0400
In-Reply-To: <1493370873-30836-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>

Now xfrm garbage collection can be triggered by 'ip xfrm policy del'.
These is no reason not to do it after flushing policies, especially
considering that 'garbage collection deferred' is only triggered
when it reaches gc_thresh.

It's no good that the policy is gone but the xdst still hold there.
The worse thing is that xdst->route/orig_dst is also hold and can
not be released even if the orig_dst is already expired.

This patch is to do the garbage collection if there is any policy
removed in xfrm_policy_flush.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 236cbbc..dfc77b9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1006,6 +1006,10 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 		err = -ESRCH;
 out:
 	spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
+
+	if (cnt)
+		xfrm_garbage_collect(net);
+
 	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_flush);
-- 
2.7.4
