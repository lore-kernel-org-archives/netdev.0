From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 net] tuntap: properly align skb->head before building skb
Date: Fri, 27 Oct 2017 11:05:44 +0800
Message-ID: <1509073544-4474-1-git-send-email-jasowang@redhat.com>
Cc: dotweiba@gmail.com, Jason Wang <jasowang@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Mark Rutland <mark.rutland@arm.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47386 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751685AbdJ0DFx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 23:05:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An unaligned alloc_frag->offset caused by previous allocation will
result an unaligned skb->head. This will lead unaligned
skb_shared_info and then unaligned dataref which requires to be
aligned for accessing on some architecture. Fix this by aligning
alloc_frag->offset before the frag refilling.

Fixes: 0bbd7dad34f8 ("tun: make tun_build_skb() thread safe")
Cc: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Cc: Wei Wei <dotweiba@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Reported-by: Wei Wei <dotweiba@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
- The patch is needed for -stable.
- Wei, can you try this patch to see if it solves your issue?
---
 drivers/net/tun.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b9973fb..5550f56 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1286,6 +1286,7 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 	buflen += SKB_DATA_ALIGN(len + pad);
 	rcu_read_unlock();
 
+	alloc_frag->offset = ALIGN((u64)alloc_frag->offset, SMP_CACHE_BYTES);
 	if (unlikely(!skb_page_frag_refill(buflen, alloc_frag, GFP_KERNEL)))
 		return ERR_PTR(-ENOMEM);
 
-- 
2.7.4
