From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-2.6] net: copy userspace buffers on device forwarding
Date: Wed, 31 Aug 2011 21:03:29 +0300
Message-ID: <20110831180328.GA22016@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, Jesse Gross <jesse@nicira.com>,
	Shirley Ma <xma@us.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209Ab1HaSDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 14:03:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_forward_skb loops an skb back into host networking
stack which might hang on the memory indefinitely.
In particular, this can happen in macvtap in bridged mode.
Copy the userspace fragments to avoid blocking the
sender in that case.

As this patch makes skb_copy_ubufs extern now,
I also added some documentation and made it clear
the SKBTX_DEV_ZEROCOPY flag automatically instead
of doing it in all callers. This can be made into a separate
patch if people feel it's worth it.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Shirley, any thoughts on this?
Another alternative is to disable zero copy for
bridged mode devices.

 include/linux/skbuff.h |    1 +
 net/core/dev.c         |    8 ++++++++
 net/core/skbuff.c      |   22 +++++++++++++++++-----
 3 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7b996ed..8bd383c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -524,6 +524,7 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
 
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
+extern int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
 				 gfp_t priority);
 extern struct sk_buff *skb_copy(const struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index 17d67b5..b10ff0a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1515,6 +1515,14 @@ static inline bool is_skb_forwardable(struct net_device *dev,
  */
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 {
+	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
+		if (skb_copy_ubufs(skb, GFP_ATOMIC)) {
+			atomic_long_inc(&dev->rx_dropped);
+			kfree_skb(skb);
+			return NET_RX_DROP;
+		}
+	}
+
 	skb_orphan(skb);
 	nf_reset(skb);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 27002df..387703f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -611,8 +611,21 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 }
 EXPORT_SYMBOL_GPL(skb_morph);
 
-/* skb frags copy userspace buffers to kernel */
-static int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
+/*	skb_copy_ubufs	-	copy userspace skb frags buffers to kernel
+ *	@skb: the skb to modify
+ *	@gfp_mask: allocation priority
+ *
+ *	This must be called on SKBTX_DEV_ZEROCOPY skb.
+ *	It will copy all frags into kernel and drop the reference
+ *	to userspace pages.
+ *
+ *	If this function is called from an interrupt gfp_mask() must be
+ *	%GFP_ATOMIC.
+ *
+ *	Returns 0 on success or a negative error code on failure
+ *	to allocate kernel memory to copy to.
+ */
+int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 {
 	int i;
 	int num_frags = skb_shinfo(skb)->nr_frags;
@@ -652,6 +665,8 @@ static int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 		skb_shinfo(skb)->frags[i - 1].page = head;
 		head = (struct page *)head->private;
 	}
+
+	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 	return 0;
 }
 
@@ -677,7 +692,6 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 		if (skb_copy_ubufs(skb, gfp_mask))
 			return NULL;
-		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 	}
 
 	n = skb + 1;
@@ -803,7 +817,6 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 				n = NULL;
 				goto out;
 			}
-			skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 		}
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
@@ -896,7 +909,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 			if (skb_copy_ubufs(skb, gfp_mask))
 				goto nofrags;
-			skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 		}
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
 			get_page(skb_shinfo(skb)->frags[i].page);
-- 
1.7.5.53.gc233e
