From: Martin Sustrik <sustrik@250bpm.com>
Subject: [PATCH 1/1] eventfd: implementation of EFD_MASK flag
Date: Fri,  8 Feb 2013 00:29:23 +0100
Message-ID: <1360279763-4768-1-git-send-email-sustrik@250bpm.com>
Cc: netdev@vger.kernel.org, Martin Sustrik <sustrik@250bpm.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sha Zhengju <handai.szj@taobao.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When implementing network protocols in user space, one has to implement
fake user-space file descriptors to represent the sockets for the protocol.

While all the BSD socket API functionality for such descriptors may be faked as
well (myproto_send(), myproto_recv() etc.) this approach doesn't work for
polling  (select, poll, epoll). And unfortunately, sockets that can't be polled
on allow only for building the simplest possible applications. Basically, you
can build a simple client, but once you want to implement a server handling
many sockets in parallel, you are stuck.

However, to do polling, real system-level file descriptor is needed,
not a fake one.

In theory, eventfd may be used for this purpose, except that it is well suited
only for signaling POLLIN. With some hacking it can be also used to signal
POLLOUT and POLLERR, but:

I.  There's no way to signal POLLPRI, POLLHUP etc.
II. There's no way to signal arbitraty combination of POLL* flags. Most notably,
    !POLLIN & !POLLOUT, which is a perfectly valid combination for a network
    protocol (rx buffer is empty and tx buffer is full), cannot be signaled
    using current implementation of eventfd.

This patch implements new EFD_MASK flag which attempts to solve this problem.

Additionally, when implementing network protocols in user space, there's a
need to associate user-space state with the each "socket". If eventfd object is
used as a reference to the socket, it should be possible to associate an opaque
pointer to user-space data with it.

The semantics of EFD_MASK are as follows:

eventfd(2):

If eventfd is created with EFD_MASK flag set, it is initialised in such a way
as to signal no events on the file descriptor when it is polled on. 'initval'
argument is ignored.

write(2):

User is allowed to write only buffers containing the following structure:

struct efd_mask {
  short events;
  void *ptr;
};

The value of 'events' should be any combination of event flags as defined by
poll(2) function (POLLIN, POLLOUT, POLLERR, POLLHUP etc.) Specified events will
be signaled when polling (select, poll, epoll) on the eventfd is done later on.
'ptr' is an opaque pointer that is not interpreted by eventfd object.

read(2):

User is allowed to read an efd_mask structure from the eventfd marked by
EFD_MASK. Returned value shall be the last one written to the eventfd.

select(2), poll(2) and similar:

When polling on the eventfd marked by EFD_MASK flag, all the events specified
in last written 'events' field shall be signaled.

Signed-off-by: Martin Sustrik <sustrik@250bpm.com>
---
 fs/eventfd.c            |  105 ++++++++++++++++++++++++++++++++++++-----------
 include/linux/eventfd.h |    3 +-
 2 files changed, 83 insertions(+), 25 deletions(-)

diff --git a/fs/eventfd.c b/fs/eventfd.c
index 35470d9..9fec49f 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -2,6 +2,7 @@
  *  fs/eventfd.c
  *
  *  Copyright (C) 2007  Davide Libenzi <davidel@xmailserver.org>
+ *  Copyright (C) 2013  Martin Sustrik <sustrik@250bpm.com>
  *
  */
 
@@ -22,18 +23,26 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
+struct eventfd_mask {
+	short events;
+	void *ptr;
+};
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
+		struct eventfd_mask mask;
+	};
 	unsigned int flags;
 };
 
@@ -55,6 +64,9 @@ __u64 eventfd_signal(struct eventfd_ctx *ctx, __u64 n)
 {
 	unsigned long flags;
 
+	/* This function should never be used with eventfd in the mask mode. */
+	BUG_ON(ctx->flags & EFD_MASK);
+
 	spin_lock_irqsave(&ctx->wqh.lock, flags);
 	if (ULLONG_MAX - ctx->count < n)
 		n = ULLONG_MAX - ctx->count;
@@ -123,12 +135,16 @@ static unsigned int eventfd_poll(struct file *file, poll_table *wait)
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
@@ -158,6 +174,9 @@ int eventfd_ctx_remove_wait_queue(struct eventfd_ctx *ctx, wait_queue_t *wait,
 {
 	unsigned long flags;
 
+	/* This function should never be used with eventfd in the mask mode. */
+	BUG_ON(ctx->flags & EFD_MASK);
+
 	spin_lock_irqsave(&ctx->wqh.lock, flags);
 	eventfd_ctx_do_read(ctx, cnt);
 	__remove_wait_queue(&ctx->wqh, wait);
@@ -188,6 +207,9 @@ ssize_t eventfd_ctx_read(struct eventfd_ctx *ctx, int no_wait, __u64 *cnt)
 	ssize_t res;
 	DECLARE_WAITQUEUE(wait, current);
 
+	/* This function should never be used with eventfd in the mask mode. */
+	BUG_ON(ctx->flags & EFD_MASK);
+
 	spin_lock_irq(&ctx->wqh.lock);
 	*cnt = 0;
 	res = -EAGAIN;
@@ -230,13 +252,23 @@ static ssize_t eventfd_read(struct file *file, char __user *buf, size_t count,
 	ssize_t res;
 	__u64 cnt;
 
-	if (count < sizeof(cnt))
-		return -EINVAL;
-	res = eventfd_ctx_read(ctx, file->f_flags & O_NONBLOCK, &cnt);
-	if (res < 0)
+	if (ctx->flags & EFD_MASK) {
+		spin_lock_irq(&ctx->wqh.lock);
+		if (count < sizeof(ctx->mask))
+			return -EINVAL;
+		res = copy_to_user(buf, &ctx->mask, sizeof(ctx->mask)) ?
+			-EFAULT : sizeof(ctx->mask);
+		spin_unlock_irq(&ctx->wqh.lock);
 		return res;
-
-	return put_user(cnt, (__u64 __user *) buf) ? -EFAULT : sizeof(cnt);
+	} else {
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
@@ -247,6 +279,21 @@ static ssize_t eventfd_write(struct file *file, const char __user *buf, size_t c
 	__u64 ucnt;
 	DECLARE_WAITQUEUE(wait, current);
 
+	if (ctx->flags & EFD_MASK) {
+		if (count < sizeof(ctx->mask))
+			return -EINVAL;
+		spin_lock_irq(&ctx->wqh.lock);
+		if (copy_from_user(&ctx->mask, buf, sizeof(ctx->mask))) {
+			spin_unlock_irq(&ctx->wqh.lock);
+			return -EFAULT;
+		}
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
@@ -293,8 +340,13 @@ static int eventfd_show_fdinfo(struct seq_file *m, struct file *f)
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
@@ -412,7 +464,12 @@ struct file *eventfd_file_create(unsigned int count, int flags)
 
 	kref_init(&ctx->kref);
 	init_waitqueue_head(&ctx->wqh);
-	ctx->count = count;
+	if (flags & EFD_MASK) {
+		ctx->mask.events = 0;
+		ctx->mask.ptr = NULL;
+	} else {
+		ctx->count = count;
+	}
 	ctx->flags = flags;
 
 	file = anon_inode_getfile("[eventfd]", &eventfd_fops, ctx,
diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
index 3c3ef19..b806d2b 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -20,11 +20,12 @@
  * shared O_* flags.
  */
 #define EFD_SEMAPHORE (1 << 0)
+#define EFD_MASK (1 << 1)
 #define EFD_CLOEXEC O_CLOEXEC
 #define EFD_NONBLOCK O_NONBLOCK
 
 #define EFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
-#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE)
+#define EFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS | EFD_SEMAPHORE | EFD_MASK)
 
 #ifdef CONFIG_EVENTFD
 
-- 
1.7.4.1
