From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 1/8] ptr_ring: introduce batch dequeuing
Date: Tue, 21 Mar 2017 12:04:40 +0800
Message-ID: <1490069087-4783-2-git-send-email-jasowang@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
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

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/ptr_ring.h | 65 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 65 insertions(+)

diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
index 6c70444..4771ded 100644
--- a/include/linux/ptr_ring.h
+++ b/include/linux/ptr_ring.h
@@ -247,6 +247,22 @@ static inline void *__ptr_ring_consume(struct ptr_ring *r)
 	return ptr;
 }
 
+static inline int __ptr_ring_consume_batched(struct ptr_ring *r,
+					     void **array, int n)
+{
+	void *ptr;
+	int i = 0;
+
+	while (i < n) {
+		ptr = __ptr_ring_consume(r);
+		if (!ptr)
+			break;
+		array[i++] = ptr;
+	}
+
+	return i;
+}
+
 /*
  * Note: resize (below) nests producer lock within consumer lock, so if you
  * call this in interrupt or BH context, you must disable interrupts/BH when
@@ -297,6 +313,55 @@ static inline void *ptr_ring_consume_bh(struct ptr_ring *r)
 	return ptr;
 }
 
+static inline int ptr_ring_consume_batched(struct ptr_ring *r,
+					   void **array, int n)
+{
+	int ret;
+
+	spin_lock(&r->consumer_lock);
+	ret = __ptr_ring_consume_batched(r, array, n);
+	spin_unlock(&r->consumer_lock);
+
+	return ret;
+}
+
+static inline int ptr_ring_consume_batched_irq(struct ptr_ring *r,
+					       void **array, int n)
+{
+	int ret;
+
+	spin_lock_irq(&r->consumer_lock);
+	ret = __ptr_ring_consume_batched(r, array, n);
+	spin_unlock_irq(&r->consumer_lock);
+
+	return ret;
+}
+
+static inline int ptr_ring_consume_batched_any(struct ptr_ring *r,
+					       void **array, int n)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&r->consumer_lock, flags);
+	ret = __ptr_ring_consume_batched(r, array, n);
+	spin_unlock_irqrestore(&r->consumer_lock, flags);
+
+	return ret;
+}
+
+static inline int ptr_ring_consume_batched_bh(struct ptr_ring *r,
+					      void **array, int n)
+{
+	int ret;
+
+	spin_lock_bh(&r->consumer_lock);
+	ret = __ptr_ring_consume_batched(r, array, n);
+	spin_unlock_bh(&r->consumer_lock);
+
+	return ret;
+}
+
 /* Cast to structure type and call a function without discarding from FIFO.
  * Function must return a value.
  * Callers must take consumer_lock.
-- 
2.7.4
