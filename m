From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/2] sock: fix zerocopy panic in mem accounting
Date: Wed,  9 Aug 2017 19:09:43 -0400
Message-ID: <20170809230944.59289-2-willemdebruijn.kernel@gmail.com>
References: <20170809230944.59289-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, dsahern@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34284 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752218AbdHIXJw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 19:09:52 -0400
Received: by mail-qk0-f194.google.com with SMTP id q66so7093921qki.1
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 16:09:52 -0700 (PDT)
In-Reply-To: <20170809230944.59289-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Only call mm_unaccount_pinned_pages when releasing a struct ubuf_info
that has initialized its field uarg->mmp.

Before this patch, a vhost-net with experimental_zcopytx can crash in

  mm_unaccount_pinned_pages
  sock_zerocopy_put
  skb_zcopy_clear
  skb_release_data

Only sock_zerocopy_alloc initializes this field. Move the unaccount
call from generic sock_zerocopy_put to its specific callback
sock_zerocopy_callback.

Fixes: a91dbff551a6 ("sock: ulimit on MSG_ZEROCOPY pages")
Reported-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 42b62c716a33..cb123590c674 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1044,6 +1044,8 @@ void sock_zerocopy_callback(struct ubuf_info *uarg, bool success)
 	u32 lo, hi;
 	u16 len;
 
+	mm_unaccount_pinned_pages(&uarg->mmp);
+
 	/* if !len, there was only 1 call, and it was aborted
 	 * so do not queue a completion notification
 	 */
@@ -1084,8 +1086,6 @@ EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
 void sock_zerocopy_put(struct ubuf_info *uarg)
 {
 	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
-		mm_unaccount_pinned_pages(&uarg->mmp);
-
 		if (uarg->callback)
 			uarg->callback(uarg, uarg->zerocopy);
 		else
-- 
2.14.0.434.g98096fd7a8-goog
