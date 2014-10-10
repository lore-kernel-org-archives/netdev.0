From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net] skbuff: fix ftrace handling in skb_unshare
Date: Fri, 10 Oct 2014 23:10:47 +0200
Message-ID: <1412975447-29958-1-git-send-email-alex.aring@gmail.com>
Cc: kernel@pengutronix.de, Alexander Aring <alex.aring@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:39831 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028AbaJJVLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 17:11:53 -0400
Received: by mail-wi0-f173.google.com with SMTP id fb4so3230195wid.6
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 14:11:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the skb is not dropped afterwards we should run consume_skb instead
kfree_skb. Inside of function skb_unshare we do always a kfree_skb,
doesn't depend if skb_copy failed or was successful.

This patch switch this behaviour like skb_share_check, if allocation of
sk_buff failed we use kfree_skb otherwise consume_skb.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/linux/skbuff.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index abde271..d150734 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1116,7 +1116,12 @@ static inline struct sk_buff *skb_unshare(struct sk_buff *skb,
 	might_sleep_if(pri & __GFP_WAIT);
 	if (skb_cloned(skb)) {
 		struct sk_buff *nskb = skb_copy(skb, pri);
-		kfree_skb(skb);	/* Free our shared copy */
+
+		/* Free our shared copy */
+		if (likely(nskb))
+			consume_skb(skb);
+		else
+			kfree_skb(skb);
 		skb = nskb;
 	}
 	return skb;
-- 
2.1.2
