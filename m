From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] xfrm: do the garbage collection after flushing policy
Date: Mon, 24 Apr 2017 15:33:39 +0800
Message-ID: <b55e4ad516bc1be8fe70f68de028a4b32055e43f.1493019219.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Herbert Xu <herbert@gondor.apana.org.au>,
        fw@strlen.de
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34470 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1166190AbdDXHds (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 03:33:48 -0400
Received: by mail-it0-f68.google.com with SMTP id c26so6717884itd.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 00:33:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
2.1.0
