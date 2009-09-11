From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 8/8] fanotify: send events to userspace over socket reads
Date: Fri, 11 Sep 2009 01:26:50 -0400
Message-ID: <20090911052649.32359.18553.stgit@paris.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752940AbZIKF1X@vger.kernel.org>
In-Reply-To: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fanotify sends event notification to userspace when userspace reads from the
fanotify socket. This patch implements the operations that happen at read
time.  These include opening the file descriptor to the original object and
then filling the userspace buffer.  The fd should be pollable to indicate when
it has data present and it should return how much data it has to send when the
FIONREAD ioctl is checked.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/notify/fanotify/af_fanotify.c |  228 ++++++++++++++++++++++++++++++++++++++
 fs/notify/fanotify/fanotify.h    |    5 +
 include/linux/fanotify.h         |   25 ++++
 3 files changed, 256 insertions(+), 2 deletions(-)

diff --git a/fs/notify/fanotify/af_fanotify.c b/fs/notify/fanotify/af_fanotify.c
index ac6aee1..2ae871b 100644
--- a/fs/notify/fanotify/af_fanotify.c
+++ b/fs/notify/fanotify/af_fanotify.c
@@ -2,6 +2,7 @@
 #include <linux/fdtable.h>
 #include <linux/file.h>
 #include <linux/fsnotify_backend.h>
+#include <linux/ima.h> /* ima_path_check */
 #include <linux/init.h>
 #include <linux/kernel.h> /* UINT_MAX */
 #include <linux/mount.h> /* mntget() */
@@ -16,6 +17,8 @@
 #include "fanotify.h"
 #include "af_fanotify.h"
 
+#include <asm/ioctls.h>
+
 static const struct proto_ops fanotify_proto_ops;
 static struct kmem_cache *fanotify_mark_cache __read_mostly;
 
@@ -114,6 +117,36 @@ static int fan_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 	return 0;
 }
 
+static int fan_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	struct fanotify_sock *fan_sock;
+	struct fsnotify_group *group;
+	struct fsnotify_event_holder *holder;
+	void __user *p;
+	int ret = -ENOTTY;
+	size_t send_len = 0;
+
+	if (sock->state != SS_CONNECTED)
+		return -EBADF;
+
+	fan_sock = fan_sk(sock->sk);
+	group = fan_sock->group;
+
+	p = (void __user *) arg;
+
+	switch (cmd) {
+	case FIONREAD:
+		mutex_lock(&group->notification_mutex);
+		list_for_each_entry(holder, &group->notification_list, event_list)
+			send_len += FAN_EVENT_METADATA_LEN;
+		mutex_unlock(&group->notification_mutex);
+		ret = put_user(send_len, (int __user *) p);
+		break;
+	}
+
+	return ret;
+}
+
 static void fanotify_free_mark(struct fsnotify_mark_entry *entry)
 {
 	kmem_cache_free(fanotify_mark_cache, entry);
@@ -278,6 +311,197 @@ static int fan_setsockopt(struct socket *sock, int level, int optname,
 	return ret;
 }
 
+/*
+ * Get an fsnotify notification event if one exists and is small
+ * enough to fit in "count". Return an error pointer if the count
+ * is not large enough.
+ *
+ * Called with the group->notification_mutex held.
+ */
+static struct fsnotify_event *get_one_event(struct fsnotify_group *group,
+					    size_t count)
+{
+	BUG_ON(!mutex_is_locked(&group->notification_mutex));
+
+	if (fsnotify_notify_queue_is_empty(group))
+		return NULL;
+
+	if (FAN_EVENT_METADATA_LEN > count)
+		return ERR_PTR(-EINVAL);
+
+	/* held the notification_mutex the whole time, so this is the
+	 * same event we peeked above */
+	return fsnotify_remove_notify_event(group);
+}
+
+static int create_and_fill_fd(struct fsnotify_group *group,
+			      struct fanotify_event_metadata *metadata,
+			      struct fsnotify_event *event)
+{
+	int client_fd, err;
+	struct dentry *dentry;
+	struct vfsmount *mnt;
+	struct file *new_file;
+
+	client_fd = get_unused_fd();
+	if (client_fd < 0)
+		return client_fd;
+
+	if (event->data_type != FSNOTIFY_EVENT_PATH) {
+		WARN_ON(1);
+		put_unused_fd(client_fd);
+		return -EINVAL;
+	}
+
+	/*
+	 * we need a new file handle for the userspace program so it can read even if it was
+	 * originally opened O_WRONLY.
+	 */
+	dentry = dget(event->path.dentry);
+	mnt = mntget(event->path.mnt);
+	/* it's possible this event was an overflow event.  in that case dentry and mnt
+	 * are NULL;  That's fine, just don't call dentry open */
+	if (dentry && mnt) {
+		err = ima_path_check(&event->path, MAY_READ, IMA_COUNT_UPDATE);
+		if (err)
+			new_file = ERR_PTR(err);
+		else
+			new_file = dentry_open(dentry, mnt, O_RDONLY | O_LARGEFILE,
+					       current_cred());
+	} else
+		new_file = ERR_PTR(-EOVERFLOW);
+	if (IS_ERR(new_file)) {
+		/*
+		 * we still send an event even if we can't open the file.  this
+		 * can happen when say tasks are gone and we try to open their
+		 * /proc entries or we try to open a WRONLY file like in sysfs
+		 * we just send the errno to userspace since there isn't much
+		 * else we can do.
+		 */
+		put_unused_fd(client_fd);
+		client_fd = PTR_ERR(new_file);
+	} else {
+		new_file->f_mode |= FMODE_NONOTIFY;
+		fd_install(client_fd, new_file);
+	}
+
+	metadata->fd = client_fd;
+
+	return 0;
+}
+
+static ssize_t fill_event_metadata(struct fsnotify_group *group,
+				   struct fanotify_event_metadata *metadata,
+				   struct fsnotify_event *event)
+{
+	pr_debug("%s: \n", __func__);
+
+	metadata->event_len = FAN_EVENT_METADATA_LEN;
+	metadata->vers = FANOTIFY_METADATA_VERSION;
+	metadata->mask = fanotify_outgoing_mask(event->mask);
+
+	return create_and_fill_fd(group, metadata, event);
+
+}
+
+static ssize_t copy_event_to_iov(struct fsnotify_group *group,
+				 struct fsnotify_event *event,
+				 struct iovec *iov)
+{
+	struct fanotify_event_metadata fanotify_event_metadata;
+	int ret;
+
+	pr_debug("%s: \n", __func__);
+
+	ret = fill_event_metadata(group, &fanotify_event_metadata, event);
+	if (ret)
+		return ret;
+
+	/* send the main event */
+	ret = memcpy_toiovec(iov, (unsigned char *)&fanotify_event_metadata,
+			     FAN_EVENT_METADATA_LEN);
+	if (ret < 0)
+		return ret;
+
+	return FAN_EVENT_METADATA_LEN;
+}
+
+static ssize_t fan_recv_events(struct fsnotify_group *group, struct msghdr *msg,
+				int count, int nonblock)
+{
+	struct fsnotify_event *event;
+	int ret, len_sent = 0;
+	DEFINE_WAIT(wait);
+
+	pr_debug("%s: \n", __func__);
+
+	while (1) {
+		prepare_to_wait(&group->notification_waitq, &wait, TASK_INTERRUPTIBLE);
+
+		mutex_lock(&group->notification_mutex);
+		event = get_one_event(group, count);
+		mutex_unlock(&group->notification_mutex);
+
+		if (event) {
+			ret = PTR_ERR(event);
+			if (IS_ERR(event))
+				break;
+
+			ret = copy_event_to_iov(group, event, msg->msg_iov);
+			fsnotify_put_event(event);
+			if (ret < 0)
+				break;
+			len_sent += ret;
+			count -= ret;
+			continue;
+		}
+
+		ret = -EAGAIN;
+		if (nonblock)
+			break;
+		ret = -EINTR;
+		if (signal_pending(current))
+			break;
+
+		if (len_sent)
+			break;
+
+		schedule();
+	}
+
+	finish_wait(&group->notification_waitq, &wait);
+	if (len_sent && ret != -EFAULT)
+		ret = len_sent;
+	return ret;
+}
+
+static int fan_recvmsg(struct kiocb *iocb, struct socket *sock,
+		       struct msghdr *msg, size_t size, int flags)
+{
+	struct fanotify_sock *fan_sock;
+	struct fsnotify_group *group;
+	int nonblock;
+
+	pr_debug("%s: \n", __func__);
+
+	if (sock->state != SS_CONNECTED)
+		return -EBADF;
+
+	if (size < FAN_EVENT_METADATA_LEN)
+		return -ENOMEM;
+
+	fan_sock = fan_sk(sock->sk);
+	group = fan_sock->group;
+
+	/* hey, nonblock no matter how they ask */
+	nonblock = !!(sock->file->f_flags & O_NONBLOCK);
+	nonblock |= !!(flags & MSG_DONTWAIT);
+
+	size = fan_recv_events(group, msg, size, nonblock);
+
+	return size;
+}
+
 static const struct net_proto_family fanotify_family_ops = {
 	.family		=	PF_FANOTIFY,
 	.create		=	fan_sock_create,
@@ -294,13 +518,13 @@ static const struct proto_ops fanotify_proto_ops = {
 	.accept =	sock_no_accept,
 	.getname =	sock_no_getname,
 	.poll =		sock_no_poll,
-	.ioctl =	sock_no_ioctl,
+	.ioctl =	fan_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	sock_no_shutdown,
 	.setsockopt =	fan_setsockopt,
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	sock_no_sendmsg,
-	.recvmsg =	sock_no_recvmsg,
+	.recvmsg =	fan_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/fs/notify/fanotify/fanotify.h b/fs/notify/fanotify/fanotify.h
index 6c7bf06..4a5c785 100644
--- a/fs/notify/fanotify/fanotify.h
+++ b/fs/notify/fanotify/fanotify.h
@@ -12,3 +12,8 @@ static inline bool fanotify_is_mask_valid(__u32 mask)
 		return false;
 	return true;
 }
+
+static inline __u32 fanotify_outgoing_mask(__u32 mask)
+{
+	return mask & FAN_ALL_OUTGOING_EVENTS;
+}
diff --git a/include/linux/fanotify.h b/include/linux/fanotify.h
index 6ecbcea..17f9550 100644
--- a/include/linux/fanotify.h
+++ b/include/linux/fanotify.h
@@ -35,6 +35,10 @@
  */
 #define FAN_ALL_INCOMING_EVENTS	(FAN_ALL_EVENTS |\
 				 FAN_EVENT_ON_CHILD)
+
+#define FAN_ALL_OUTGOING_EVENTS	(FAN_ALL_EVENTS |\
+				 FAN_Q_OVERFLOW)
+
 #ifndef SOL_FANOTIFY
 #define SOL_FANOTIFY	278
 #endif
@@ -63,6 +67,27 @@ struct fanotify_so_inode_mark {
 #define FANOTIFY_SET_MARK	1
 #define FANOTIFY_REMOVE_MARK	2
 
+#define FANOTIFY_METADATA_VERSION	1
+
+struct fanotify_event_metadata {
+	__u32 event_len;
+	__u32 vers;
+	__s32 fd;
+	__u32 mask;
+}  __attribute__((packed));
+
+
+/* Helper functions to deal with fanotify_event_metadata buffers */
+#define FAN_EVENT_METADATA_LEN	(sizeof(struct fanotify_event_metadata))
+
+#define FAN_EVENT_NEXT(meta, len) ((len) -= (meta)->event_len, \
+				   (struct fanotify_event_metadata*)(((char *)(meta)) + \
+				   (meta)->event_len))
+
+#define FAN_EVENT_OK(meta, len)	((long)(len) >= (long)FAN_EVENT_METADATA_LEN && \
+				 (long)(meta)->event_len >= (long)FAN_EVENT_METADATA_LEN && \
+				 (long)(meta)->event_len <= (long)(len))
+
 #ifdef __KERNEL__
 
 #endif /* __KERNEL__ */
