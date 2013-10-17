From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] net: refactor sk_page_frag_refill()
Date: Thu, 17 Oct 2013 16:27:07 -0700
Message-ID: <1382052427.3284.3.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380787003-20488-1-git-send-email-dborkman@redhat.com>
	 <1380805381.19002.206.camel@edumazet-glaptop.roam.corp.google.com>
	 <CANJ5vPJpVfDjaC8JauGYu=Qe4ZshqmBMkCbB1cru-xAfa7K1+g@mail.gmail.com>
	 <1381623952.3392.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1381639591.3392.31.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Francesco Fusco <ffusco@redhat.com>,
	ycheng@google.com, Neal Cardwell <ncardwell@google.com>,
	Eric Northup <digitaleric@google.com>
To: Michael Dalton <mwdalton@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:53547 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253Ab3JQX1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 19:27:10 -0400
Received: by mail-pd0-f182.google.com with SMTP id q10so2361388pdj.13
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 16:27:09 -0700 (PDT)
In-Reply-To: <1381639591.3392.31.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While working on virtio_net new allocation strategy to increase
payload/truesize ratio, we found that refactoring sk_page_frag_refill()
was needed.

This patch splits sk_page_frag_refill() into two parts, adding
skb_page_frag_refill() which can be used without a socket.

While we are at it, add a minimum frag size of 32 for
sk_page_frag_refill()

Michael will either use netdev_alloc_frag() from softirq context,
or skb_page_frag_refill() from process context in refill_work()
 (GFP_KERNEL allocations)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Michael Dalton <mwdalton@google.com>
---
v3: page_frag_refill() -> skb_page_frag_refill()
v2: fix a off-by one error

 include/linux/skbuff.h |    2 ++
 net/core/sock.c        |   27 +++++++++++++++++++++++----
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1cd32f9..ba74474 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2062,6 +2062,8 @@ static inline void skb_frag_set_page(struct sk_buff *skb, int f,
 	__skb_frag_set_page(&skb_shinfo(skb)->frags[f], page);
 }
 
+bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio);
+
 /**
  * skb_frag_dma_map - maps a paged fragment via the DMA API
  * @dev: the device to map the fragment to
diff --git a/net/core/sock.c b/net/core/sock.c
index fd6afa2..440afdc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1847,7 +1847,17 @@ EXPORT_SYMBOL(sock_alloc_send_skb);
 /* On 32bit arches, an skb frag is limited to 2^15 */
 #define SKB_FRAG_PAGE_ORDER	get_order(32768)
 
-bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
+/**
+ * skb_page_frag_refill - check that a page_frag contains enough room
+ * @sz: minimum size of the fragment we want to get
+ * @pfrag: pointer to page_frag
+ * @prio: priority for memory allocation
+ *
+ * Note: While this allocator tries to use high order pages, there is
+ * no guarantee that allocations succeed. Therefore, @sz MUST be
+ * less or equal than PAGE_SIZE.
+ */
+bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
 {
 	int order;
 
@@ -1856,16 +1866,16 @@ bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
 			pfrag->offset = 0;
 			return true;
 		}
-		if (pfrag->offset < pfrag->size)
+		if (pfrag->offset + sz <= pfrag->size)
 			return true;
 		put_page(pfrag->page);
 	}
 
 	/* We restrict high order allocations to users that can afford to wait */
-	order = (sk->sk_allocation & __GFP_WAIT) ? SKB_FRAG_PAGE_ORDER : 0;
+	order = (prio & __GFP_WAIT) ? SKB_FRAG_PAGE_ORDER : 0;
 
 	do {
-		gfp_t gfp = sk->sk_allocation;
+		gfp_t gfp = prio;
 
 		if (order)
 			gfp |= __GFP_COMP | __GFP_NOWARN;
@@ -1877,6 +1887,15 @@ bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
 		}
 	} while (--order >= 0);
 
+	return false;
+}
+EXPORT_SYMBOL(skb_page_frag_refill);
+
+bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
+{
+	if (likely(skb_page_frag_refill(32U, pfrag, sk->sk_allocation)))
+		return true;
+
 	sk_enter_memory_pressure(sk);
 	sk_stream_moderate_sndbuf(sk);
 	return false;
