From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next V2] tun: introduce tx skb ring
Date: Wed, 22 Jun 2016 21:18:19 +0300
Message-ID: <20160622211620-mutt-send-email-mst@redhat.com>
References: <1465979897-4445-1-git-send-email-jasowang@redhat.com>
	<20160617033218-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, brouer@redhat.com,
	davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160617033218-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2016 at 03:41:20AM +0300, Michael S. Tsirkin wrote:
> Would it help to have ptr_ring_resize that gets an array of
> rings and resizes them both to same length?

OK, here it is. Untested so far, and no skb wrapper.
Pls let me know whether this is what you had in mind.

-->

ptr_ring: support resizing multiple queues

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index a29b023..e576801 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -354,20 +354,14 @@ static inline int ptr_ring_init(struct ptr_ring *r, int size, int pad, gfp_t gfp
 	return 0;
 }
 
-static inline int ptr_ring_resize(struct ptr_ring *r, int size, gfp_t gfp,
-				  void (*destroy)(void *))
+static inline void **__ptr_ring_swap_queue(struct ptr_ring *r, void **queue,
+					   int size, gfp_t gfp,
+					   void (*destroy)(void *))
 {
-	unsigned long flags;
 	int producer = 0;
-	void **queue = __ptr_ring_init_queue_alloc(size, gfp);
 	void **old;
 	void *ptr;
 
-	if (!queue)
-		return -ENOMEM;
-
-	spin_lock_irqsave(&(r)->producer_lock, flags);
-
 	while ((ptr = ptr_ring_consume(r)))
 		if (producer < size)
 			queue[producer++] = ptr;
@@ -380,6 +374,23 @@ static inline int ptr_ring_resize(struct ptr_ring *r, int size, gfp_t gfp,
 	old = r->queue;
 	r->queue = queue;
 
+	return old;
+}
+
+static inline int ptr_ring_resize(struct ptr_ring *r, int size, gfp_t gfp,
+				  void (*destroy)(void *))
+{
+	unsigned long flags;
+	void **queue = __ptr_ring_init_queue_alloc(size, gfp);
+	void **old;
+
+	if (!queue)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&(r)->producer_lock, flags);
+
+	old = __ptr_ring_swap_queue(r, queue, size, gfp, destroy);
+
 	spin_unlock_irqrestore(&(r)->producer_lock, flags);
 
 	kfree(old);
@@ -387,6 +398,49 @@ static inline int ptr_ring_resize(struct ptr_ring *r, int size, gfp_t gfp,
 	return 0;
 }
 
+static inline int ptr_ring_resize_multiple(struct ptr_ring **rings, int nrings,
+					   int size,
+					   gfp_t gfp, void (*destroy)(void *))
+{
+	unsigned long flags;
+	void ***queues;
+	int i;
+
+	queues = kmalloc(nrings * sizeof *queues, gfp);
+	if (!queues)
+		goto noqueues;
+
+	for (i = 0; i < nrings; ++i) {
+		queues[i] = __ptr_ring_init_queue_alloc(size, gfp);
+		if (!queues[i])
+			goto nomem;
+	}
+
+	spin_lock_irqsave(&(rings[i])->producer_lock, flags);
+
+	for (i = 0; i < nrings; ++i)
+		queues[i] = __ptr_ring_swap_queue(rings[i], queues[i],
+						  size, gfp, destroy);
+
+	spin_unlock_irqrestore(&(rings[i])->producer_lock, flags);
+
+	for (i = 0; i < nrings; ++i)
+		kfree(queues[i]);
+
+	kfree(queues);
+
+	return 0;
+
+nomem:
+	while (--i >= 0)
+		kfree(queues[i]);
+
+	kfree(queues);
+
+noqueues:
+	return -ENOMEM;
+}
+
 static inline void ptr_ring_cleanup(struct ptr_ring *r, void (*destroy)(void *))
 {
 	void *ptr;
diff --git a/tools/virtio/ringtest/ptr_ring.c b/tools/virtio/ringtest/ptr_ring.c
index 26dc1d2..deb36af 100644
--- a/tools/virtio/ringtest/ptr_ring.c
+++ b/tools/virtio/ringtest/ptr_ring.c
@@ -17,6 +17,11 @@
 typedef pthread_spinlock_t  spinlock_t;
 
 typedef int gfp_t;
+static void *kmalloc(unsigned size, gfp_t gfp)
+{
+	return memalign(64, size);
+}
+
 static void *kzalloc(unsigned size, gfp_t gfp)
 {
 	void *p = memalign(64, size);
