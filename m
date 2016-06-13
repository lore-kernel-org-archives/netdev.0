From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v8 5/5] skb_array: resize support
Date: Mon, 13 Jun 2016 23:54:50 +0300
Message-ID: <20160613235450-mutt-send-email-mst@redhat.com>
References: <1465851234-13558-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com, kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465851234-13558-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update skb_array after ptr_ring API changes.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/skb_array.h | 33 +++++++++++++++++++++++++++++----
 1 file changed, 29 insertions(+), 4 deletions(-)

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index c4c0902..678bfbf 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -63,9 +63,9 @@ static inline int skb_array_produce_any(struct skb_array *a, struct sk_buff *skb
 	return ptr_ring_produce_any(&a->ring, skb);
 }
 
-/* Might be slightly faster than skb_array_empty below, but callers invoking
- * this in a loop must take care to use a compiler barrier, for example
- * cpu_relax().
+/* Might be slightly faster than skb_array_empty below, but only safe if the
+ * array is never resized. Also, callers invoking this in a loop must take care
+ * to use a compiler barrier, for example cpu_relax().
  */
 static inline bool __skb_array_empty(struct skb_array *a)
 {
@@ -77,6 +77,21 @@ static inline bool skb_array_empty(struct skb_array *a)
 	return ptr_ring_empty(&a->ring);
 }
 
+static inline bool skb_array_empty_bh(struct skb_array *a)
+{
+	return ptr_ring_empty_bh(&a->ring);
+}
+
+static inline bool skb_array_empty_irq(struct skb_array *a)
+{
+	return ptr_ring_empty_irq(&a->ring);
+}
+
+static inline bool skb_array_empty_any(struct skb_array *a)
+{
+	return ptr_ring_empty_any(&a->ring);
+}
+
 static inline struct sk_buff *skb_array_consume(struct skb_array *a)
 {
 	return ptr_ring_consume(&a->ring);
@@ -136,9 +151,19 @@ static inline int skb_array_init(struct skb_array *a, int size, gfp_t gfp)
 	return ptr_ring_init(&a->ring, size, gfp);
 }
 
+void __skb_array_destroy_skb(void *ptr)
+{
+	kfree_skb(ptr);
+}
+
+int skb_array_resize(struct skb_array *a, int size, gfp_t gfp)
+{
+	return ptr_ring_resize(&a->ring, size, gfp, __skb_array_destroy_skb);
+}
+
 static inline void skb_array_cleanup(struct skb_array *a)
 {
-	ptr_ring_cleanup(&a->ring);
+	ptr_ring_cleanup(&a->ring, __skb_array_destroy_skb);
 }
 
 #endif /* _LINUX_SKB_ARRAY_H  */
-- 
MST
