From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v6 2/3] ptr_ring: ring test
Date: Wed, 1 Jun 2016 15:54:41 +0300
Message-ID: <1464785601-3074-3-git-send-email-mst@redhat.com>
References: <1464785601-3074-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com, kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464785601-3074-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ringtest based unit test for ptr ring.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 tools/virtio/ringtest/ptr_ring.c | 192 +++++++++++++++++++++++++++++++++++++++
 tools/virtio/ringtest/Makefile   |   5 +-
 2 files changed, 196 insertions(+), 1 deletion(-)
 create mode 100644 tools/virtio/ringtest/ptr_ring.c

diff --git a/tools/virtio/ringtest/ptr_ring.c b/tools/virtio/ringtest/ptr_ring.c
new file mode 100644
index 0000000..74abd74
--- /dev/null
+++ b/tools/virtio/ringtest/ptr_ring.c
@@ -0,0 +1,192 @@
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
+static void spin_lock(spinlock_t *lock)
+{
+	int ret = pthread_spin_lock(lock);
+	assert(!ret);
+}
+
+static void spin_unlock(spinlock_t *lock)
+{
+	int ret = pthread_spin_unlock(lock);
+	assert(!ret);
+}
+
+static void spin_lock_bh(spinlock_t *lock)
+{
+	spin_lock(lock);
+}
+
+static void spin_unlock_bh(spinlock_t *lock)
+{
+	spin_unlock(lock);
+}
+
+static void spin_lock_irq(spinlock_t *lock)
+{
+	spin_lock(lock);
+}
+
+static void spin_unlock_irq(spinlock_t *lock)
+{
+	spin_unlock(lock);
+}
+
+static void spin_lock_irqsave(spinlock_t *lock, unsigned long f)
+{
+	spin_lock(lock);
+}
+
+static void spin_unlock_irqrestore(spinlock_t *lock, unsigned long f)
+{
+	spin_unlock(lock);
+}
+
+#include "../../../include/linux/ptr_ring.h"
+
+static unsigned long long headcnt, tailcnt;
+static struct ptr_ring array ____cacheline_aligned_in_smp;
+
+/* implemented by ring */
+void alloc_ring(void)
+{
+	int ret = ptr_ring_init(&array, ring_size, 0);
+	assert(!ret);
+}
+
+/* guest side */
+int add_inbuf(unsigned len, void *buf, void *datap)
+{
+	int ret;
+
+	ret = __ptr_ring_produce(&array, buf);
+	if (ret >= 0) {
+		ret = 0;
+		headcnt++;
+	}
+
+	return ret;
+}
+
+/*
+ * ptr_ring API provides no way for producer to find out whether a given
+ * buffer was consumed.  Our tests merely require that a successful get_buf
+ * implies that add_inbuf succeed in the past, and that add_inbuf will succeed,
+ * fake it accordingly.
+ */
+void *get_buf(unsigned *lenp, void **bufp)
+{
+	void *datap;
+
+	if (tailcnt == headcnt || __ptr_ring_full(&array))
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
+		if (tailcnt == headcnt || __ptr_ring_full(&array)) {
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
+		barrier();
+		b = __ptr_ring_peek(&array);
+	} while (!b);
+}
+
+bool use_buf(unsigned *lenp, void **bufp)
+{
+	void *ptr;
+
+	ptr = __ptr_ring_consume(&array);
+
+	return ptr;
+}
+
+void call_used(void)
+{
+	assert(0);
+}
diff --git a/tools/virtio/ringtest/Makefile b/tools/virtio/ringtest/Makefile
index 6173ada..877a8a4 100644
--- a/tools/virtio/ringtest/Makefile
+++ b/tools/virtio/ringtest/Makefile
@@ -1,6 +1,6 @@
 all:
 
-all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder noring
+all: ring virtio_ring_0_9 virtio_ring_poll virtio_ring_inorder ptr_ring noring
 
 CFLAGS += -Wall
 CFLAGS += -pthread -O2 -ggdb
@@ -8,6 +8,7 @@ LDFLAGS += -pthread -O2 -ggdb
 
 main.o: main.c main.h
 ring.o: ring.c main.h
+ptr_ring.o: ptr_ring.c main.h ../../../include/linux/ptr_ring.h
 virtio_ring_0_9.o: virtio_ring_0_9.c main.h
 virtio_ring_poll.o: virtio_ring_poll.c virtio_ring_0_9.c main.h
 virtio_ring_inorder.o: virtio_ring_inorder.c virtio_ring_0_9.c main.h
@@ -15,6 +16,7 @@ ring: ring.o main.o
 virtio_ring_0_9: virtio_ring_0_9.o main.o
 virtio_ring_poll: virtio_ring_poll.o main.o
 virtio_ring_inorder: virtio_ring_inorder.o main.o
+ptr_ring: ptr_ring.o main.o
 noring: noring.o main.o
 clean:
 	-rm main.o
@@ -22,6 +24,7 @@ clean:
 	-rm virtio_ring_0_9.o virtio_ring_0_9
 	-rm virtio_ring_poll.o virtio_ring_poll
 	-rm virtio_ring_inorder.o virtio_ring_inorder
+	-rm ptr_ring.o ptr_ring
 	-rm noring.o noring
 
 .PHONY: all clean
-- 
MST
