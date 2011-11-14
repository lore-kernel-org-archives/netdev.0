From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] net: introduce build_skb()
Date: Mon, 14 Nov 2011 17:03:34 +0100
Message-ID: <1321286614.2272.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, pstaszewski@itcare.pl, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39548 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336Ab1KNQDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 11:03:39 -0500
Received: by bke11 with SMTP id 11so6038902bke.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 08:03:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the thing we discussed during netdev 2011 conference was the idea
to change some network drivers to allocate/populate their skb at RX
completion time, right before feeding the skb to network stack.

In old days, we allocated skbs when populating the RX ring.

This means bringing into cpu cache sk_buff and skb_shared_info cache
lines (since we clear/initialize them), then 'queue' skb->data to NIC.

By the time NIC fills a frame in skb->data buffer and host can process
it, cpu probably threw away the cache lines from its caches, because lot
of things happened between the allocation and final use.

So the deal would be to allocate only the data buffer for the NIC to
populate its RX ring buffer. And use build_skb() at RX completion to
attach a data buffer (now filled with an ethernet frame) to a new skb,
initialize the skb_shared_info portion, and give the hot skb to network
stack.

build_skb() is the function to allocate an skb, caller providing the
data buffer that should be attached to it. Drivers are expected to call 
skb_reserve() right after build_skb() to adjust skb->data to the
Ethernet frame (usually skipping NET_SKB_PAD and NET_IP_ALIGN, but some
drivers might add a hardware provided alignment)

Data provided to build_skb() MUST have been allocated by a prior
kmalloc() call, with enough room to add SKB_DATA_ALIGN(sizeof(struct
skb_shared_info)) bytes at the end of the data without corrupting
incoming frame.

data = kmalloc(NET_SKB_PAD + NET_IP_ALIGN + 1536 +
               SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
	       GFP_ATOMIC);
...
skb = build_skb(data);
if (!skb) {
	recycle_data(data);
} else {
	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
	...
}

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Eilon Greenstein <eilong@broadcom.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
CC: Tom Herbert <therbert@google.com>
CC: Jamal Hadi Salim <hadi@mojatatu.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Thomas Graf <tgraf@infradead.org>
CC: Herbert Xu <herbert@gondor.apana.org.au>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/skbuff.h |    1 
 net/core/skbuff.c      |   49 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index fe86488..abad8a0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -540,6 +540,7 @@ extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
 				   gfp_t priority, int fclone, int node);
+extern struct sk_buff *build_skb(void *data);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 18a3ceb..8d2c5b3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -245,6 +245,55 @@ nodata:
 EXPORT_SYMBOL(__alloc_skb);
 
 /**
+ * build_skb - build a network buffer
+ * @data: data buffer provided by caller
+ *
+ * Allocate a new &sk_buff. Caller provides space holding head and
+ * skb_shared_info. @data must have been allocated by kmalloc()
+ * The return is the new skb buffer.
+ * On a failure the return is %NULL, and @data is not freed.
+ * Notes :
+ *  Before IO, driver allocates only data buffer where NIC put incoming frame
+ *  Driver should add room at head (NET_SKB_PAD) and
+ *  MUST add room at tail (SKB_DATA_ALIGN(skb_shared_info))
+ *  After IO, driver calls build_skb(), to allocate sk_buff and populate it
+ *  before giving packet to stack.
+ *  RX rings only contains data buffers, not full skbs.
+ */
+struct sk_buff *build_skb(void *data)
+{
+	struct skb_shared_info *shinfo;
+	struct sk_buff *skb;
+	unsigned int size;
+
+	skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
+	if (!skb)
+		return NULL;
+
+	size = ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->truesize = SKB_TRUESIZE(size);
+	atomic_set(&skb->users, 1);
+	skb->head = data;
+	skb->data = data;
+	skb_reset_tail_pointer(skb);
+	skb->end = skb->tail + size;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->mac_header = ~0U;
+#endif
+
+	/* make sure we initialize shinfo sequentially */
+	shinfo = skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+	atomic_set(&shinfo->dataref, 1);
+	kmemcheck_annotate_variable(shinfo->destructor_arg);
+
+	return skb;
+}
+EXPORT_SYMBOL(build_skb);
+
+/**
  *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
  *	@length: length to allocate
