From: Martin Sustrik <sustrik@250bpm.com>
Subject: [PATCH v3 1/1] eventfd: implementation of EFD_MASK flag
Date: Mon, 18 Feb 2013 12:34:50 +0100
Message-ID: <1361187290-11759-1-git-send-email-sustrik@250bpm.com>
Cc: mtk.manpages@gmail.com, Martin Sustrik <sustrik@250bpm.com>
To: viro@zeniv.linux.org.uk, handai.szj@taobao.com,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	normalperson@yhbt.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
  short events;
  union {
    void    *ptr;
    uint32_t u32;
    uint64_t u64;
  };
};

The value of 'events' should be any combination of event flags as defined by
poll(2) function (POLLIN, POLLOUT, POLLERR, POLLHUP etc.) Specified events will
be signaled when polling (select, poll, epoll) on the eventfd is done later on.
'ptr', 'u32' or 'u64' are opaque data that are not interpreted by eventfd
object.

read(2):

User is allowed to read an efd_mask structure from the eventfd marked by
EFD_MASK. Returned value shall be the last one written to the eventfd.

select(2), poll(2) and similar:

When polling on the eventfd marked by EFD_MASK flag, all the events specified
in last written 'events' field shall be signaled.

Signed-off-by: Martin Sustrik <sustrik@250bpm.com>
---
Following changes were made to the patch since v2:

- eventfd_mask structure renamed to efd_mask to keep user-space prefixes
  consistent
- efd_mask is __packed for all architectures
- eventfd.h header file added to uapi; given there wasn't one so far, in
  addition to moving efd_mask there, I've moved also all the eventfd flags that
  are meant to be visible from the user space
- comment for 'mask' member eventfd_ctx added 
- synchronisation bugs in eventfd_read fixed
- several variable declarations moved from the beginning of the function to
  the blocks where they are used
- changelog text made simpler and more up to the point

There was also a request to explain why this functionality is needed. I've
written an article explaining the problems user-space network protocol
implementers face here: http://www.250bpm.com/blog:16
---
 fs/eventfd.c                 |  194 ++++++++++++++++++++++++++++--------------
 include/linux/eventfd.h      |   17 +---
 include/uapi/linux/eventfd.h |   40 +++++++++
 3 files changed, 172 insertions(+), 79 deletions(-)
 create mode 100644 include/uapi/linux/eventfd.h

diff --git a/fs/eventfd.c b/fs/eventfd.c
index 35470d9..8f821b1 100644
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
@@ -123,12 +140,16 @@ static unsigned int eventfd_poll(struct file *file, poll_table *wait)
 	poll_wait(file, &ctx->wqh, wait);
 
 	spin_lock_irqsave(&ctx->wqh.lock, flags);
-	if (ctx->count > 0)
-		events |= POLLIN;
-	if (ctx->count == ULLONG_MAX)
-		events |= POLLERR;
-	if (ULLONG_MAX - 1 > ctx->count)
-		events |= POLLOUT;
+	if (ctx->flags & EFD_MASK) {
+		events = ctx->mask.events;
+	} else {
+		if (ctx->count > 0)
+			events |= POLLIN;
+		if (ctx->count == ULLONG_MAX)
+			events |= POLLERR;
+		if (ULLONG_MAX - 1 > ctx->count)
+			events |= POLLOUT;
+	}
 	spin_unlock_irqrestore(&ctx->wqh.lock, flags);
 
 	return events;
@@ -158,6 +179,9 @@ int eventfd_ctx_remove_wait_queue(struct eventfd_ctx *ctx, wait_queue_t *wait,
 {
 	unsigned long flags;
 
+	/* This function should never be used with eventfd in the mask mode. */
+	BUG_ON(ctx->flags & EFD_MASK);
+
 	spin_lock_irqsave(&ctx->wqh.lock, flags);
 	eventfd_ctx_do_read(ctx, cnt);
 	__remove_wait_queue(&ctx->wqh, wait);
@@ -188,6 +212,9 @@ ssize_t eventfd_ctx_read(struct eventfd_ctx *ctx, int no_wait, __u64 *cnt)
 	ssize_t res;
 	DECLARE_WAITQUEUE(wait, current);
 
+	/* This function should never be used with eventfd in the mask mode. */
+	BUG_ON(ctx->flags & EFD_MASK);
+
 	spin_lock_irq(&ctx->wqh.lock);
 	*cnt = 0;
 	res = -EAGAIN;
@@ -227,63 +254,92 @@ static ssize_t eventfd_read(struct file *file, char __user *buf, size_t count,
 			    loff_t *ppos)
 {
 	struct eventfd_ctx *ctx = file->private_data;
-	ssize_t res;
-	__u64 cnt;
 
-	if (count < sizeof(cnt))
-		return -EINVAL;
-	res = eventfd_ctx_read(ctx, file->f_flags & O_NONBLOCK, &cnt);
-	if (res < 0)
-		return res;
-
-	return put_user(cnt, (__u64 __user *) buf) ? -EFAULT : sizeof(cnt);
+	if (ctx->flags & EFD_MASK) {
+		struct efd_mask mask;
+		if (count < sizeof(mask))
+			return -EINVAL;
+		spin_lock_irq(&ctx->wqh.lock);
+		mask = ctx->mask;
+		spin_unlock_irq(&ctx->wqh.lock);
+		if (copy_to_user(buf, &mask, sizeof(mask)))
+			return -EFAULT;
+		return sizeof(mask);
+	} else {
+		ssize_t res;
+		__u64 cnt;
+		if (count < sizeof(cnt))
+			return -EINVAL;
+		res = eventfd_ctx_read(ctx, file->f_flags & O_NONBLOCK, &cnt);
+		if (res < 0)
+			return res;
+		return put_user(cnt, (__u64 __user *) buf) ?
+			-EFAULT : sizeof(cnt);
+	}
 }
 
 static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t count,
 			     loff_t *ppos)
 {
 	struct eventfd_ctx *ctx = file->private_data;
-	ssize_t res;
-	__u64 ucnt;
-	DECLARE_WAITQUEUE(wait, current);
 
-	if (count < sizeof(ucnt))
-		return -EINVAL;
-	if (copy_from_user(&ucnt, buf, sizeof(ucnt)))
-		return -EFAULT;
-	if (ucnt == ULLONG_MAX)
-		return -EINVAL;
-	spin_lock_irq(&ctx->wqh.lock);
-	res = -EAGAIN;
-	if (ULLONG_MAX - ctx->count > ucnt)
-		res = sizeof(ucnt);
-	else if (!(file->f_flags & O_NONBLOCK)) {
-		__add_wait_queue(&ctx->wqh, &wait);
-		for (res = 0;;) {
-			set_current_state(TASK_INTERRUPTIBLE);
-			if (ULLONG_MAX - ctx->count > ucnt) {
-				res = sizeof(ucnt);
-				break;
-			}
-			if (signal_pending(current)) {
-				res = -ERESTARTSYS;
-				break;
+	if (ctx->flags & EFD_MASK) {
+		struct efd_mask mask;
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
+	} else {
+		ssize_t res;
+		__u64 ucnt;
+		DECLARE_WAITQUEUE(wait, current);
+		if (count < sizeof(ucnt))
+			return -EINVAL;
+		if (copy_from_user(&ucnt, buf, sizeof(ucnt)))
+			return -EFAULT;
+		if (ucnt == ULLONG_MAX)
+			return -EINVAL;
+		spin_lock_irq(&ctx->wqh.lock);
+		res = -EAGAIN;
+		if (ULLONG_MAX - ctx->count > ucnt)
+			res = sizeof(ucnt);
+		else if (!(file->f_flags & O_NONBLOCK)) {
+			__add_wait_queue(&ctx->wqh, &wait);
+			for (res = 0;;) {
+				set_current_state(TASK_INTERRUPTIBLE);
+				if (ULLONG_MAX - ctx->count > ucnt) {
+					res = sizeof(ucnt);
+					break;
+				}
+				if (signal_pending(current)) {
+					res = -ERESTARTSYS;
+					break;
+				}
+				spin_unlock_irq(&ctx->wqh.lock);
+				schedule();
+				spin_lock_irq(&ctx->wqh.lock);
 			}
-			spin_unlock_irq(&ctx->wqh.lock);
-			schedule();
-			spin_lock_irq(&ctx->wqh.lock);
+			__remove_wait_queue(&ctx->wqh, &wait);
+			__set_current_state(TASK_RUNNING);
 		}
-		__remove_wait_queue(&ctx->wqh, &wait);
-		__set_current_state(TASK_RUNNING);
-	}
-	if (likely(res > 0)) {
-		ctx->count += ucnt;
-		if (waitqueue_active(&ctx->wqh))
-			wake_up_locked_poll(&ctx->wqh, POLLIN);
-	}
-	spin_unlock_irq(&ctx->wqh.lock);
+		if (likely(res > 0)) {
+			ctx->count += ucnt;
+			if (waitqueue_active(&ctx->wqh))
+				wake_up_locked_poll(&ctx->wqh, POLLIN);
+		}
+		spin_unlock_irq(&ctx->wqh.lock);
 
-	return res;
+		return res;
+	}
 }
 
 #ifdef CONFIG_PROC_FS
@@ -293,8 +349,13 @@ static int eventfd_show_fdinfo(struct seq_file *m, struct file *f)
 	int ret;
 
 	spin_lock_irq(&ctx->wqh.lock);
-	ret = seq_printf(m, "eventfd-count: %16llx\n",
-			 (unsigned long long)ctx->count);
+	if (ctx->flags & EFD_MASK) {
+		ret = seq_printf(m, "eventfd-mask: %x\n",
+				 (unsigned)ctx->mask.events);
+	} else {
+		ret = seq_printf(m, "eventfd-count: %16llx\n",
+				 (unsigned long long)ctx->count);
+	}
 	spin_unlock_irq(&ctx->wqh.lock);
 
 	return ret;
@@ -412,7 +473,12 @@ struct file *eventfd_file_create(unsigned int count, int flags)
 
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
index 3c3ef19..218aba6 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -8,24 +8,11 @@
 #ifndef _LINUX_EVENTFD_H
 #define _LINUX_EVENTFD_H
 
-#include <linux/fcntl.h>
+#include <uapi/linux/eventfd.h>
+
 #include <linux/file.h>
 #include <linux/wait.h>
 
-/*
- * CAREFUL: Check include/asm-generic/fcntl.h when defining
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
 #ifdef CONFIG_EVENTFD
 
 struct file *eventfd_file_create(unsigned int count, int flags);
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
1.7.4.1
