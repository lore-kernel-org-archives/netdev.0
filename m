From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] tuntap: properly align skb->head before building skb
Date: Thu, 26 Oct 2017 20:15:55 +0800
Message-ID: <1509020155-3830-1-git-send-email-jasowang@redhat.com>
Cc: dotweiba@gmail.com, Jason Wang <jasowang@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Mark Rutland <mark.rutland@arm.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index b9973fb..60e44f2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1286,6 +1286,7 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 	buflen += SKB_DATA_ALIGN(len + pad);
 	rcu_read_unlock();
 
+	alloc_frag->offset = ALIGN((u64)alloc_frag->offset, TUN_RX_PAD);
 	if (unlikely(!skb_page_frag_refill(buflen, alloc_frag, GFP_KERNEL)))
 		return ERR_PTR(-ENOMEM);
 
-- 
2.7.4
