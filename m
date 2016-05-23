From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v5 2/2] skb_array: ring test
Date: Mon, 23 May 2016 13:43:46 +0300
Message-ID: <1464000201-15560-3-git-send-email-mst@redhat.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464000201-15560-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ringtest based unit test for skb array.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 tools/virtio/ringtest/skb_array.c | 167 ++++++++++++++++++++++++++++++++++++++
 tools/virtio/ringtest/Makefile    |   4 +-
 2 files changed, 170 insertions(+), 1 deletion(-)
 create mode 100644 tools/virtio/ringtest/skb_array.c

diff --git a/tools/virtio/ringtest/skb_array.c b/tools/virtio/ringtest/skb_array.c
new file mode 100644
index 0000000..4ab7e31
--- /dev/null
+++ b/tools/virtio/ringtest/skb_array.c
@@ -0,0 +1,167 @@
+#define _GNU_SOURCE
+#include "main.h"
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <pthread.h>
+#include <malloc.h>
+#include <assert.h>
+#include <errno.h>
+#include <limits.h>
+
+struct sk_buff;
+#define SMP_CACHE_BYTES 64
+#define cache_line_size() SMP_CACHE_BYTES
+#define ____cacheline_aligned_in_smp __attribute__ ((aligned (SMP_CACHE_BYTES)))
+#define unlikely(x)    (__builtin_expect(!!(x), 0))
+#define ALIGN(x, a) (((x) + (a) - 1) / (a) * (a))
+typedef pthread_spinlock_t  spinlock_t;
+
+typedef int gfp_t;
+static void *kzalloc(unsigned size, gfp_t gfp)
+{
+	void *p = memalign(64, size);
+	if (!p)
+		return p;
+	memset(p, 0, size);
+
+	return p;
+}
+
+static void kfree(void *p)
+{
+	if (p)
+		free(p);
+}
+
+static void spin_lock_init(spinlock_t *lock)
+{
+	int r = pthread_spin_init(lock, 0);
+	assert(!r);
+}
+
+static void spin_lock_bh(spinlock_t *lock)
+{
+	int ret = pthread_spin_lock(lock);
+	assert(!ret);
+}
+
+static void spin_unlock_bh(spinlock_t *lock)
+{
+	int ret = pthread_spin_unlock(lock);
+	assert(!ret);
+}
+
+#include "../../../include/linux/skb_array.h"
+
+static unsigned long long headcnt, tailcnt;
+static struct skb_array array ____cacheline_aligned_in_smp;
+
+/* implemented by ring */
+void alloc_ring(void)
+{
+	int ret = skb_array_init(&array, ring_size, 0);
+	assert(!ret);
+}
+
+/* guest side */
+int add_inbuf(unsigned len, void *buf, void *datap)
+{
+	int ret;
+	
+	assert(headcnt - tailcnt <= ring_size);
+	ret = __skb_array_produce(&array, buf);
+	if (ret >= 0) {
+		ret = 0;
+		headcnt++;
+	}
+
+	return ret;
+}
+
+/*
+ * skb_array API provides no way for producer to find out whether a given
+ * buffer was consumed.  Our tests merely require that a successful get_buf
+ * implies that add_inbuf succeed in the past, and that add_inbuf will succeed,
+ * fake it accordingly.
+ */
+void *get_buf(unsigned *lenp, void **bufp)
+{
+	void *datap;
+
+	if (tailcnt == headcnt || __skb_array_full(&array))
+		datap = NULL;
+	else {
+		datap = "Buffer\n";
+		++tailcnt;
+	}
+
+	return datap;
+}
+
+void poll_used(void)
+{
+	void *b;
+
+	do {
+		if (tailcnt == headcnt || __skb_array_full(&array)) {
+			b = NULL;
+			barrier();
+		} else {
+			b = "Buffer\n";
+		}
+	} while (!b);
+}
+
+void disable_call()
+{
+	assert(0);
+}
+
+bool enable_call()
+{
+	assert(0);
+}
+
+void kick_available(void)
+{
+	assert(0);
+}
+
+/* host side */
+void disable_kick()
+{
+	assert(0);
+}
+
+bool enable_kick()
+{
+	assert(0);
+}
+
+void poll_avail(void)
+{
+	void *b;
+
+	do {
+		b = __skb_array_peek(&array);
+		barrier();
+	} while (!b);
+}
+
+bool use_buf(unsigned *lenp, void **bufp)
+{
+	struct sk_buff *skb;
+
+	skb = __skb_array_peek(&array);
+	if (skb) {
+		__skb_array_consume(&array);
+	}
+
+	return skb;
+}
+
+void call_used(void)
+{
+	assert(0);
+}
diff --git a/tools/virtio/ringtest/Makefile b/tools/virtio/ringtest/Makefile
index 6ba7455..87e58cf 100644
--- a/tools/virtio/ringtest/Makefile
+++ b/tools/virtio/ringtest/Makefile
@@ -1,6 +1,6 @@
 all:
 
-all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder
+all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder skb_array
 
 CFLAGS += -Wall
 CFLAGS += -pthread -O2 -ggdb
@@ -8,6 +8,7 @@ LDFLAGS += -pthread -O2 -ggdb
 
 main.o: main.c main.h
 ring.o: ring.c main.h
+skb_array.o: skb_array.c main.h ../../../include/linux/skb_array.h
 virtio_ring_0_9.o: virtio_ring_0_9.c main.h
 virtio_ring_poll.o: virtio_ring_poll.c virtio_ring_0_9.c main.h
 virtio_ring_inorder.o: virtio_ring_inorder.c virtio_ring_0_9.c main.h
@@ -15,6 +16,7 @@ ring: ring.o main.o
 virtio_ring_0_9: virtio_ring_0_9.o main.o
 virtio_ring_poll: virtio_ring_poll.o main.o
 virtio_ring_inorder: virtio_ring_inorder.o main.o
+skb_array: skb_array.o main.o
 clean:
 	-rm main.o
 	-rm ring.o ring
-- 
MST
