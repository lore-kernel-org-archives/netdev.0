From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] netpoll: shut up a kernel warning on refcount
Date: Wed, 12 Jul 2017 15:56:41 -0700
Message-ID: <1499900201-8676-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davej@codemonkey.org.uk, Cong Wang <xiyou.wangcong@gmail.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33923 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752434AbdGLW4w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 18:56:52 -0400
Received: by mail-pg0-f67.google.com with SMTP id j186so4598212pge.1
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 15:56:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we convert atomic_t to refcount_t, a new kernel warning
on "increment on 0" is introduced in the netpoll code,
zap_completion_queue(). In fact for this special case, we know
the refcount is 0 and we just have to set it to 1 to satisfy
the following dev_kfree_skb_any(), so we can just use
refcount_set(..., 1) instead.

Fixes: 633547973ffc ("net: convert sk_buff.users from atomic_t to refcount_t")
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Cc: Reshetova, Elena <elena.reshetova@intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/netpoll.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index d3408a6..8357f16 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -277,7 +277,7 @@ static void zap_completion_queue(void)
 			struct sk_buff *skb = clist;
 			clist = clist->next;
 			if (!skb_irq_freeable(skb)) {
-				refcount_inc(&skb->users);
+				refcount_set(&skb->users, 1);
 				dev_kfree_skb_any(skb); /* put this one back */
 			} else {
 				__kfree_skb(skb);
-- 
2.5.5
