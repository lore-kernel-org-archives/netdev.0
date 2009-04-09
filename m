From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 01/19] shm-signal: shared-memory signals
Date: Thu, 09 Apr 2009 12:30:46 -0400
Message-ID: <20090409163046.32740.31982.stgit@dev.haskins.net>
References: <20090409155200.32740.19358.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This interface provides a bidirectional shared-memory based signaling
mechanism.  It can be used by any entities which desire efficient
communication via shared memory.  The implementation details of the
signaling are abstracted so that they may transcend a wide variety
of locale boundaries (e.g. userspace/kernel, guest/host, etc).

The shm_signal mechanism supports event masking as well as spurious
event delivery mitigation.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 include/linux/shm_signal.h |  188 ++++++++++++++++++++++++++++++++++++++++++++
 lib/Kconfig                |   10 ++
 lib/Makefile               |    1 
 lib/shm_signal.c           |  186 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 385 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/shm_signal.h
 create mode 100644 lib/shm_signal.c

diff --git a/include/linux/shm_signal.h b/include/linux/shm_signal.h
new file mode 100644
index 0000000..a65e54e
--- /dev/null
+++ b/include/linux/shm_signal.h
@@ -0,0 +1,188 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * Author:
+ *      Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#ifndef _LINUX_SHM_SIGNAL_H
+#define _LINUX_SHM_SIGNAL_H
+
+#include <asm/types.h>
+
+/*
+ *---------
+ * The following structures represent data that is shared across boundaries
+ * which may be quite disparate from one another (e.g. Windows vs Linux,
+ * 32 vs 64 bit, etc).  Therefore, care has been taken to make sure they
+ * present data in a manner that is independent of the environment.
+ *-----------
+ */
+
+#define SHM_SIGNAL_MAGIC 0x58fa39df
+#define SHM_SIGNAL_VER   1
+
+struct shm_signal_irq {
+	__u8                  enabled;
+	__u8                  pending;
+	__u8                  dirty;
+};
+
+enum shm_signal_locality {
+	shm_locality_north,
+	shm_locality_south,
+};
+
+struct shm_signal_desc {
+	__u32                 magic;
+	__u32                 ver;
+	struct shm_signal_irq irq[2];
+};
+
+/* --- END SHARED STRUCTURES --- */
+
+#ifdef __KERNEL__
+
+#include <linux/interrupt.h>
+
+struct shm_signal_notifier {
+	void (*signal)(struct shm_signal_notifier *);
+};
+
+struct shm_signal;
+
+struct shm_signal_ops {
+	int      (*inject)(struct shm_signal *s);
+	void     (*fault)(struct shm_signal *s, const char *fmt, ...);
+	void     (*release)(struct shm_signal *s);
+};
+
+enum {
+	shm_signal_in_wakeup,
+};
+
+struct shm_signal {
+	atomic_t                    refs;
+	spinlock_t                  lock;
+	enum shm_signal_locality    locale;
+	unsigned long               flags;
+	struct shm_signal_ops      *ops;
+	struct shm_signal_desc     *desc;
+	struct shm_signal_notifier *notifier;
+	struct tasklet_struct       deferred_notify;
+};
+
+#define SHM_SIGNAL_FAULT(s, fmt, args...)  \
+  ((s)->ops->fault ? (s)->ops->fault((s), fmt, ## args) : panic(fmt, ## args))
+
+ /*
+  * These functions should only be used internally
+  */
+void _shm_signal_release(struct shm_signal *s);
+void _shm_signal_wakeup(struct shm_signal *s);
+
+/**
+ * shm_signal_init() - initialize an SHM_SIGNAL
+ * @s:        SHM_SIGNAL context
+ *
+ * Initializes SHM_SIGNAL context before first use
+ *
+ **/
+void shm_signal_init(struct shm_signal *s);
+
+/**
+ * shm_signal_get() - acquire an SHM_SIGNAL context reference
+ * @s:        SHM_SIGNAL context
+ *
+ **/
+static inline struct shm_signal *shm_signal_get(struct shm_signal *s)
+{
+	atomic_inc(&s->refs);
+
+	return s;
+}
+
+/**
+ * shm_signal_put() - release an SHM_SIGNAL context reference
+ * @s:        SHM_SIGNAL context
+ *
+ **/
+static inline void shm_signal_put(struct shm_signal *s)
+{
+	if (atomic_dec_and_test(&s->refs))
+		_shm_signal_release(s);
+}
+
+/**
+ * shm_signal_enable() - enables local notifications on an SHM_SIGNAL
+ * @s:        SHM_SIGNAL context
+ * @flags:      Reserved for future use, must be 0
+ *
+ * Enables/unmasks the registered notifier (if applicable) to receive wakeups
+ * whenever the remote side performs an shm_signal() operation. A notification
+ * will be dispatched immediately if any pending signals have already been
+ * issued prior to invoking this call.
+ *
+ * This is synonymous with unmasking an interrupt.
+ *
+ * Returns: success = 0, <0 = ERRNO
+ *
+ **/
+int shm_signal_enable(struct shm_signal *s, int flags);
+
+/**
+ * shm_signal_disable() - disable local notifications on an SHM_SIGNAL
+ * @s:        SHM_SIGNAL context
+ * @flags:      Reserved for future use, must be 0
+ *
+ * Disables/masks the registered shm_signal_notifier (if applicable) from
+ * receiving any further notifications.  Any subsequent calls to shm_signal()
+ * by the remote side will update the shm as dirty, but will not traverse the
+ * locale boundary and will not invoke the notifier callback.  Signals
+ * delivered while masked will be deferred until shm_signal_enable() is
+ * invoked.
+ *
+ * This is synonymous with masking an interrupt
+ *
+ * Returns: success = 0, <0 = ERRNO
+ *
+ **/
+int shm_signal_disable(struct shm_signal *s, int flags);
+
+/**
+ * shm_signal_inject() - notify the remote side about shm changes
+ * @s:        SHM_SIGNAL context
+ * @flags:      Reserved for future use, must be 0
+ *
+ * Marks the shm state as "dirty" and, if enabled, will traverse
+ * a locale boundary to inject a remote notification.  The remote
+ * side controls whether the notification should be delivered via
+ * the shm_signal_enable/disable() interface.
+ *
+ * The specifics of how to traverse a locale boundary are abstracted
+ * by the shm_signal_ops->signal() interface and provided by a particular
+ * implementation.  However, typically going north to south would be
+ * something like a syscall/hypercall, and going south to north would be
+ * something like a posix-signal/guest-interrupt.
+ *
+ * Returns: success = 0, <0 = ERRNO
+ *
+ **/
+int shm_signal_inject(struct shm_signal *s, int flags);
+
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_SHM_SIGNAL_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 03c2c24..32d82fe 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -174,4 +174,14 @@ config DISABLE_OBSOLETE_CPUMASK_FUNCTIONS
        bool "Disable obsolete cpumask functions" if DEBUG_PER_CPU_MAPS
        depends on EXPERIMENTAL && BROKEN
 
+config SHM_SIGNAL
+	boolean "SHM Signal - Generic shared-memory signaling mechanism"
+	default n
+	help
+	 Provides a shared-memory based signaling mechansim to indicate
+         memory-dirty notifications between two end-points.
+
+	 If unsure, say N
+
+
 endmenu
diff --git a/lib/Makefile b/lib/Makefile
index 32b0e64..bc36327 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -71,6 +71,7 @@ obj-$(CONFIG_TEXTSEARCH_BM) += ts_bm.o
 obj-$(CONFIG_TEXTSEARCH_FSM) += ts_fsm.o
 obj-$(CONFIG_SMP) += percpu_counter.o
 obj-$(CONFIG_AUDIT_GENERIC) += audit.o
+obj-$(CONFIG_SHM_SIGNAL) += shm_signal.o
 
 obj-$(CONFIG_SWIOTLB) += swiotlb.o
 obj-$(CONFIG_IOMMU_HELPER) += iommu-helper.o
diff --git a/lib/shm_signal.c b/lib/shm_signal.c
new file mode 100644
index 0000000..fa1770c
--- /dev/null
+++ b/lib/shm_signal.c
@@ -0,0 +1,186 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * See include/linux/shm_signal.h for documentation
+ *
+ * Author:
+ *      Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/shm_signal.h>
+
+int shm_signal_enable(struct shm_signal *s, int flags)
+{
+	struct shm_signal_irq *irq = &s->desc->irq[s->locale];
+	unsigned long iflags;
+
+	spin_lock_irqsave(&s->lock, iflags);
+
+	irq->enabled = 1;
+	wmb();
+
+	if ((irq->dirty || irq->pending)
+	    && !test_bit(shm_signal_in_wakeup, &s->flags)) {
+		rmb();
+		tasklet_schedule(&s->deferred_notify);
+	}
+
+	spin_unlock_irqrestore(&s->lock, iflags);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(shm_signal_enable);
+
+int shm_signal_disable(struct shm_signal *s, int flags)
+{
+	struct shm_signal_irq *irq = &s->desc->irq[s->locale];
+
+	irq->enabled = 0;
+	wmb();
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(shm_signal_disable);
+
+/*
+ * signaling protocol:
+ *
+ * each side of the shm_signal has an "irq" structure with the following
+ * fields:
+ *
+ *    - enabled: controlled by shm_signal_enable/disable() to mask/unmask
+ *               the notification locally
+ *    - dirty:   indicates if the shared-memory is dirty or clean.  This
+ *               is updated regardless of the enabled/pending state so that
+ *               the state is always accurately tracked.
+ *    - pending: indicates if a signal is pending to the remote locale.
+ *               This allows us to determine if a remote-notification is
+ *               already in flight to optimize spurious notifications away.
+ */
+int shm_signal_inject(struct shm_signal *s, int flags)
+{
+	/* Load the irq structure from the other locale */
+	struct shm_signal_irq *irq = &s->desc->irq[!s->locale];
+
+	/*
+	 * We always mark the remote side as dirty regardless of whether
+	 * they need to be notified.
+	 */
+	irq->dirty = 1;
+	wmb();   /* dirty must be visible before we test the pending state */
+
+	if (irq->enabled && !irq->pending) {
+		rmb();
+
+		/*
+		 * If the remote side has enabled notifications, and we do
+		 * not see a notification pending, we must inject a new one.
+		 */
+		irq->pending = 1;
+		wmb(); /* make it visible before we do the injection */
+
+		s->ops->inject(s);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(shm_signal_inject);
+
+void _shm_signal_wakeup(struct shm_signal *s)
+{
+	struct shm_signal_irq *irq = &s->desc->irq[s->locale];
+	int dirty;
+	unsigned long flags;
+
+	spin_lock_irqsave(&s->lock, flags);
+
+	__set_bit(shm_signal_in_wakeup, &s->flags);
+
+	/*
+	 * The outer loop protects against race conditions between
+	 * irq->dirty and irq->pending updates
+	 */
+	while (irq->enabled && (irq->dirty || irq->pending)) {
+
+		/*
+		 * Run until we completely exhaust irq->dirty (it may
+		 * be re-dirtied by the remote side while we are in the
+		 * callback).  We let "pending" remain untouched until we have
+		 * processed them all so that the remote side knows we do not
+		 * need a new notification (yet).
+		 */
+		do {
+			irq->dirty = 0;
+			/* the unlock is an implicit wmb() for dirty = 0 */
+			spin_unlock_irqrestore(&s->lock, flags);
+
+			if (s->notifier)
+				s->notifier->signal(s->notifier);
+
+			spin_lock_irqsave(&s->lock, flags);
+			dirty = irq->dirty;
+			rmb();
+
+		} while (irq->enabled && dirty);
+
+		barrier();
+
+		/*
+		 * We can finally acknowledge the notification by clearing
+		 * "pending" after all of the dirty memory has been processed
+		 * Races against this clearing are handled by the outer loop.
+		 * Subsequent iterations of this loop will execute with
+		 * pending=0 potentially leading to future spurious
+		 * notifications, but this is an acceptable tradeoff as this
+		 * will be rare and harmless.
+		 */
+		irq->pending = 0;
+		wmb();
+
+	}
+
+	__clear_bit(shm_signal_in_wakeup, &s->flags);
+	spin_unlock_irqrestore(&s->lock, flags);
+
+}
+EXPORT_SYMBOL_GPL(_shm_signal_wakeup);
+
+void _shm_signal_release(struct shm_signal *s)
+{
+	s->ops->release(s);
+}
+EXPORT_SYMBOL_GPL(_shm_signal_release);
+
+static void
+deferred_notify(unsigned long data)
+{
+	struct shm_signal *s = (struct shm_signal *)data;
+
+	_shm_signal_wakeup(s);
+}
+
+void shm_signal_init(struct shm_signal *s)
+{
+	memset(s, 0, sizeof(*s));
+	atomic_set(&s->refs, 1);
+	spin_lock_init(&s->lock);
+	tasklet_init(&s->deferred_notify,
+		     deferred_notify,
+		     (unsigned long)s);
+}
+EXPORT_SYMBOL_GPL(shm_signal_init);

