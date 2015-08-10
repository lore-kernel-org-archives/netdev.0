From: Damian Hobson-Garcia <dhobsong@igel.co.jp>
Subject: [PATCH] eventfd: implementation of EFD_MASK flag
Date: Mon, 10 Aug 2015 14:51:46 +0900
Message-ID: <1439185906-28180-2-git-send-email-dhobsong@igel.co.jp>
References: <1439185906-28180-1-git-send-email-dhobsong@igel.co.jp>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-api@vger.kernel.org
To: sustrik@250bpm.com, viro@zeniv.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439185906-28180-1-git-send-email-dhobsong@igel.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Sustrik <sustrik@250bpm.com>

When implementing network protocols in user space, one has to implement
fake file descriptors to represent the sockets for the protocol.

Polling on such fake file descriptors is a problem (poll/select/epoll accept
only true file descriptors) and forces protocol implementers to use various
workarounds resulting in complex, non-standard and convoluted APIs.

More generally, ability to create full-blown file descriptors for
userspace-to-userspace signalling is missing. While eventfd(2) goes half the way
towards this goal it has follwoing shorcomings:

I.  There's no way to signal POLLPRI, POLLHUP etc.
II. There's no way to signal arbitrary combination of POLL* flags. Most notably,
    simultaneous !POLLIN and !POLLOUT, which is a perfectly valid combination
    for a network protocol (rx buffer is empty and tx buffer is full), cannot be
    signaled using eventfd.

This patch implements new EFD_MASK flag which solves the above problems.

Additionally, to provide a way to associate user-space state with eventfd
object, it allows to attach user-space data to the file descriptor.

The semantics of EFD_MASK are as follows:

eventfd(2):

If eventfd is created with EFD_MASK flag set, it is initialised in such a way
as to signal no events on the file descriptor when it is polled on. 'initval'
argument is ignored.

write(2):

User is allowed to write only buffers containing the following structure:

struct efd_mask {
  __u32 events;
  __u64 data;
};

The value of 'events' should be any combination of event flags as defined by
poll(2) function (POLLIN, POLLOUT, POLLERR, POLLHUP etc.) Specified events will
be signaled when polling (select, poll, epoll) on the eventfd is done later on.
'data' is opaque data that are not interpreted by eventfd object.

read(2):

User is allowed to read an efd_mask structure from the eventfd marked by
EFD_MASK. Returned value shall be the last one written to the eventfd.

select(2), poll(2) and similar:

When polling on the eventfd marked by EFD_MASK flag, all the events specified
in last written 'events' field shall be signaled.

Signed-off-by: Martin Sustrik <sustrik@250bpm.com>
---
 fs/eventfd.c                 | 93 ++++++++++++++++++++++++++++++++++++++------
 include/linux/eventfd.h      | 16 +-------
 include/uapi/linux/eventfd.h | 40 +++++++++++++++++++
 3 files changed, 123 insertions(+), 26 deletions(-)
 create mode 100644 include/uapi/linux/eventfd.h

diff --git a/fs/eventfd.c b/fs/eventfd.c
index 8d0c0df..11fb92a 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -2,6 +2,7 @@
  *  fs/eventfd.c
  *
  *  Copyright (C) 2007  Davide Libenzi <davidel@xmailserver.org>
+ *  Copyright (C) 2013  Martin Sustrik <sustrik@250bpm.com>
  *
  */
 
@@ -22,18 +23,31 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
+#define EFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
+#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE | EFD_MASK)
+#define EFD_MASK_VALID_EVENTS (POLLIN | POLLPRI | POLLOUT | POLLERR | POLLHUP)
+
 struct eventfd_ctx {
 	struct kref kref;
 	wait_queue_head_t wqh;
-	/*
-	 * Every time that a write(2) is performed on an eventfd, the
-	 * value of the __u64 being written is added to "count" and a
-	 * wakeup is performed on "wqh". A read(2) will return the "count"
-	 * value to userspace, and will reset "count" to zero. The kernel
-	 * side eventfd_signal() also, adds to the "count" counter and
-	 * issue a wakeup.
-	 */
-	__u64 count;
+	union {
+		/*
+		 * Every time that a write(2) is performed on an eventfd, the
+		 * value of the __u64 being written is added to "count" and a
+		 * wakeup is performed on "wqh". A read(2) will return the
+		 * "count" value to userspace, and will reset "count" to zero.
+		 * The kernel side eventfd_signal() also, adds to the "count"
+		 * counter and issue a wakeup.
+		 */
+		__u64 count;
+
+		/*
+		 * When using eventfd in EFD_MASK mode this stracture stores the
+		 * current events to be signaled on the eventfd (events member)
+		 * along with opaque user-defined data (data member).
+		 */
+		struct efd_mask mask;
+	};
 	unsigned int flags;
 };
 
@@ -55,6 +69,9 @@ __u64 eventfd_signal(struct eventfd_ctx *ctx, __u64 n)
 {
 	unsigned long flags;
 
+	/* This function should never be used with eventfd in the mask mode. */
+	BUG_ON(ctx->flags & EFD_MASK);
+
 	spin_lock_irqsave(&ctx->wqh.lock, flags);
 	if (ULLONG_MAX - ctx->count < n)
 		n = ULLONG_MAX - ctx->count;
@@ -124,6 +141,11 @@ static unsigned int eventfd_poll(struct file *file, poll_table *wait)
 	smp_rmb();
 	count = ctx->count;
 
+	if (ctx->flags & EFD_MASK) {
+		events = ctx->mask.events;
+		return events;
+	}
+
 	if (count > 0)
 		events |= POLLIN;
 	if (count == ULLONG_MAX)
@@ -158,6 +180,9 @@ int eventfd_ctx_remove_wait_queue(struct eventfd_ctx *ctx, wait_queue_t *wait,
 {
 	unsigned long flags;
 
+	/* This function should never be used with eventfd in the mask mode. */
+	BUG_ON(ctx->flags & EFD_MASK);
+
 	spin_lock_irqsave(&ctx->wqh.lock, flags);
 	eventfd_ctx_do_read(ctx, cnt);
 	__remove_wait_queue(&ctx->wqh, wait);
@@ -188,6 +213,9 @@ ssize_t eventfd_ctx_read(struct eventfd_ctx *ctx, int no_wait, __u64 *cnt)
 	ssize_t res;
 	DECLARE_WAITQUEUE(wait, current);
 
+	/* This function should never be used with eventfd in the mask mode. */
+	BUG_ON(ctx->flags & EFD_MASK);
+
 	spin_lock_irq(&ctx->wqh.lock);
 	*cnt = 0;
 	res = -EAGAIN;
@@ -230,6 +258,19 @@ static ssize_t eventfd_read(struct file *file, char __user *buf, size_t count,
 	ssize_t res;
 	__u64 cnt;
 
+	if (ctx->flags & EFD_MASK) {
+		struct efd_mask mask;
+
+		if (count < sizeof(mask))
+			return -EINVAL;
+		spin_lock_irq(&ctx->wqh.lock);
+		mask = ctx->mask;
+		spin_unlock_irq(&ctx->wqh.lock);
+		if (copy_to_user(buf, &mask, sizeof(mask)))
+			return -EFAULT;
+		return sizeof(mask);
+	}
+
 	if (count < sizeof(cnt))
 		return -EINVAL;
 	res = eventfd_ctx_read(ctx, file->f_flags & O_NONBLOCK, &cnt);
@@ -247,6 +288,24 @@ static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t c
 	__u64 ucnt;
 	DECLARE_WAITQUEUE(wait, current);
 
+	if (ctx->flags & EFD_MASK) {
+		struct efd_mask mask;
+
+		if (count < sizeof(mask))
+			return -EINVAL;
+		if (copy_from_user(&mask, buf, sizeof(mask)))
+			return -EFAULT;
+		if (mask.events & ~EFD_MASK_VALID_EVENTS)
+			return -EINVAL;
+		spin_lock_irq(&ctx->wqh.lock);
+		memcpy(&ctx->mask, &mask, sizeof(ctx->mask));
+		if (waitqueue_active(&ctx->wqh))
+			wake_up_locked_poll(&ctx->wqh,
+				(unsigned long)ctx->mask.events);
+		spin_unlock_irq(&ctx->wqh.lock);
+		return sizeof(ctx->mask);
+	}
+
 	if (count < sizeof(ucnt))
 		return -EINVAL;
 	if (copy_from_user(&ucnt, buf, sizeof(ucnt)))
@@ -292,8 +351,13 @@ static void eventfd_show_fdinfo(struct seq_file *m, struct file *f)
 	struct eventfd_ctx *ctx = f->private_data;
 
 	spin_lock_irq(&ctx->wqh.lock);
-	seq_printf(m, "eventfd-count: %16llx\n",
-		   (unsigned long long)ctx->count);
+	if (ctx->flags & EFD_MASK) {
+		seq_printf(m, "eventfd-mask: %x\n",
+				 (unsigned)ctx->mask.events);
+	} else {
+		seq_printf(m, "eventfd-count: %16llx\n",
+				 (unsigned long long)ctx->count);
+	}
 	spin_unlock_irq(&ctx->wqh.lock);
 }
 #endif
@@ -406,7 +470,12 @@ struct file *eventfd_file_create(unsigned int count, int flags)
 
 	kref_init(&ctx->kref);
 	init_waitqueue_head(&ctx->wqh);
-	ctx->count = count;
+	if (flags & EFD_MASK) {
+		ctx->mask.events = 0;
+		ctx->mask.data = 0;
+	} else {
+		ctx->count = count;
+	}
 	ctx->flags = flags;
 
 	file = anon_inode_getfile("[eventfd]", &eventfd_fops, ctx,
diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
index ff0b981..87de343 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -8,23 +8,11 @@
 #ifndef _LINUX_EVENTFD_H
 #define _LINUX_EVENTFD_H
 
+#include <uapi/linux/eventfd.h>
+
 #include <linux/fcntl.h>
 #include <linux/wait.h>
 
-/*
- * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
- * new flags, since they might collide with O_* ones. We want
- * to re-use O_* flags that couldn't possibly have a meaning
- * from eventfd, in order to leave a free define-space for
- * shared O_* flags.
- */
-#define EFD_SEMAPHORE (1 << 0)
-#define EFD_CLOEXEC O_CLOEXEC
-#define EFD_NONBLOCK O_NONBLOCK
-
-#define EFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
-#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE)
-
 struct file;
 
 #ifdef CONFIG_EVENTFD
diff --git a/include/uapi/linux/eventfd.h b/include/uapi/linux/eventfd.h
new file mode 100644
index 0000000..03057a5
--- /dev/null
+++ b/include/uapi/linux/eventfd.h
@@ -0,0 +1,40 @@
+/*
+ *  Copyright (C) 2013 Martin Sustrik <sustrik@250bpm.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_EVENTFD_H
+#define _UAPI_LINUX_EVENTFD_H
+
+/* For O_CLOEXEC */
+#include <linux/fcntl.h>
+#include <linux/types.h>
+
+/*
+ * CAREFUL: Check include/asm-generic/fcntl.h when defining
+ * new flags, since they might collide with O_* ones. We want
+ * to re-use O_* flags that couldn't possibly have a meaning
+ * from eventfd, in order to leave a free define-space for
+ * shared O_* flags.
+ */
+
+/* Provide semaphore-like semantics for reads from the eventfd. */
+#define EFD_SEMAPHORE (1 << 0)
+/* Provide event mask semantics for the eventfd. */
+#define EFD_MASK (1 << 1)
+/*  Set the close-on-exec (FD_CLOEXEC) flag on the eventfd. */
+#define EFD_CLOEXEC O_CLOEXEC
+/*  Create the eventfd in non-blocking mode. */
+#define EFD_NONBLOCK O_NONBLOCK
+
+/* Structure to read/write to eventfd in EFD_MASK mode. */
+struct efd_mask {
+	__u32 events;
+	__u64 data;
+} __packed;
+
+#endif /* _UAPI_LINUX_EVENTFD_H */
-- 
1.9.1
