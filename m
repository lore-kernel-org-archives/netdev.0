From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: avoid one atomic op per cloned skb
Date: Tue, 18 May 2010 15:40:47 +0200
Message-ID: <1274190047.8274.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:9371 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513Ab0ERNkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 09:40:51 -0400
Received: by fg-out-1718.google.com with SMTP id d23so3251765fga.1
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 06:40:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

I know you said 'only patches', but I found following patch small
enough ?

I have a followup patch to avoid two atomic ops per cloned skb on
dataref (helps TCP tx path) but will submit it for 2.6.36, since its
diffstat is a bit more than 3++- :)

Thanks

[PATCH] net: avoid one atomic op per cloned skb

skb_clone() can use atomic_set(clone_ref, 2) safely, because only
current thread can possibly touch clone_ref at this point.
   
Add a WARN_ON_ONCE() for a while, to catch wrong assumptions.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c543dd2..4444f15 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -628,7 +628,8 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
 		atomic_t *fclone_ref = (atomic_t *) (n + 1);
 		n->fclone = SKB_FCLONE_CLONE;
-		atomic_inc(fclone_ref);
+		WARN_ON_ONCE(atomic_read(fclone_ref) != 1);
+		atomic_set(fclone_ref, 2);
 	} else {
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)



