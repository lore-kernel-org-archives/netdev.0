From: roy.qing.li@gmail.com
Subject: [PATCH net-next] core: adjust checks for calling skb_copy_bits in skb_try_coalesce
Date: Thu, 20 Sep 2012 11:19:42 +0800
Message-ID: <1348111182-6827-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60314 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119Ab2ITDT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 23:19:56 -0400
Received: by pbbrr13 with SMTP id rr13so4025537pbb.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 20:19:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Ensure that frags and frags_list of dst skb are empty if need to call
skb_copy_bits, or else it will break the data sequence.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/skbuff.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fe00d12..f0b9446 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3455,15 +3455,15 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 	if (skb_cloned(to))
 		return false;
 
-	if (len <= skb_tailroom(to)) {
+	if (skb_has_frag_list(to) || skb_has_frag_list(from))
+		return false;
+
+	if (len <= skb_tailroom(to) && !skb_shinfo(to)->nr_frags) {
 		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
 		*delta_truesize = 0;
 		return true;
 	}
 
-	if (skb_has_frag_list(to) || skb_has_frag_list(from))
-		return false;
-
 	if (skb_headlen(from) != 0) {
 		struct page *page;
 		unsigned int offset;
-- 
1.7.4.1
