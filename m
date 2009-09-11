From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 7/8] fanotify: userspace can add and remove fsnotify inode
	marks
Date: Fri, 11 Sep 2009 01:26:42 -0400
Message-ID: <20090911052642.32359.22259.stgit@paris.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, alan@linux.intel.com,
	hch@infradead.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using setsockopt a user can add or remove fsnotify marks on inodes.  These
marks are used to determine which events for which inode are to be sent to
userspace.  They are very similar in nature to inotify_add_watch and
inotify_rm_watch.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 fs/notify/fanotify/af_fanotify.c |  169 ++++++++++++++++++++++++++++++++++++++
 include/linux/fanotify.h         |   10 ++
 2 files changed, 178 insertions(+), 1 deletions(-)

diff --git a/fs/notify/fanotify/af_fanotify.c b/fs/notify/fanotify/af_fanotify.c
index d7bf658..ac6aee1 100644
--- a/fs/notify/fanotify/af_fanotify.c
+++ b/fs/notify/fanotify/af_fanotify.c
@@ -17,6 +17,7 @@
 #include "af_fanotify.h"
 
 static const struct proto_ops fanotify_proto_ops;
+static struct kmem_cache *fanotify_mark_cache __read_mostly;
 
 static struct proto fanotify_proto = {
 	.name     = "FANOTIFY",
@@ -113,6 +114,170 @@ static int fan_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 	return 0;
 }
 
+static void fanotify_free_mark(struct fsnotify_mark_entry *entry)
+{
+	kmem_cache_free(fanotify_mark_cache, entry);
+}
+
+static int fanotify_remove_inode_mark(struct fsnotify_group *group,
+				      struct fanotify_so_inode_mark *so_inode_mark)
+{
+	struct fsnotify_mark_entry *entry;
+	struct file *file;
+	struct inode *inode;
+	int fput_needed, ret = 0;
+
+	ret = -EBADF;
+	file = fget_light(so_inode_mark->fd, &fput_needed);
+	if (!file)
+		goto out;
+
+	inode = file->f_path.dentry->d_inode;
+
+	spin_lock(&inode->i_lock);
+	entry = fsnotify_find_mark_entry(group, inode);
+	spin_unlock(&inode->i_lock);
+
+	ret = -ENOENT;
+	if (!entry)
+		goto out_fput;
+
+	ret = 0;
+
+	fsnotify_destroy_mark_by_entry(entry);
+
+	/* matches the fsnotify_find_mark_entry() */
+	fsnotify_put_mark(entry);
+
+	fsnotify_recalc_group_mask(group);
+out_fput:
+	fput_light(file, fput_needed);
+out:
+	return ret;
+}
+
+static int fanotify_add_inode_mark(struct fsnotify_group *group,
+				   struct fanotify_so_inode_mark *so_inode_mark)
+{
+	struct fsnotify_mark_entry *entry;
+	struct file *file;
+	struct inode *inode;
+	__u32 old_mask, new_mask;
+	int fput_needed, ret;
+
+	ret = -EINVAL;
+	if (!fanotify_is_mask_valid(so_inode_mark->mask))
+		goto out;
+
+	ret = -EBADF;
+	file = fget_light(so_inode_mark->fd, &fput_needed);
+	if (!file)
+		goto out;
+
+	inode = file->f_path.dentry->d_inode;
+
+	spin_lock(&inode->i_lock);
+	entry = fsnotify_find_mark_entry(group, inode);
+	spin_unlock(&inode->i_lock);
+
+	if (!entry) {
+		struct fsnotify_mark_entry *new_entry;
+
+		ret = -ENOMEM;
+		new_entry = kmem_cache_alloc(fanotify_mark_cache, GFP_KERNEL);
+		if (!new_entry)
+			goto out_fput;
+
+		fsnotify_init_mark(new_entry, fanotify_free_mark);
+		ret = fsnotify_add_mark(new_entry, group, inode, 0);
+		if (ret) {
+			fanotify_free_mark(new_entry);
+			goto out_fput;
+		}
+
+		entry = new_entry;
+	}
+
+	ret = 0;
+
+	spin_lock(&entry->lock);
+	old_mask = entry->mask;
+	entry->mask |= so_inode_mark->mask;
+	new_mask = entry->mask;
+	spin_unlock(&entry->lock);
+
+	/* we made changes to a mask, update the group mask and the inode mask
+	 * so things happen quickly. */
+	if (old_mask != new_mask) {
+		/* more bits in old than in new? */
+		int dropped = (old_mask & ~new_mask);
+		/* more bits in this entry than the inode's mask? */
+		int do_inode = (new_mask & ~inode->i_fsnotify_mask);
+		/* more bits in this entry than the group? */
+		int do_group = (new_mask & ~group->mask);
+
+		/* update the inode with this new entry */
+		if (dropped || do_inode)
+			fsnotify_recalc_inode_mask(inode);
+
+		/* update the group mask with the new mask */
+		if (dropped || do_group)
+			fsnotify_recalc_group_mask(group);
+	}
+
+	/* match the init or the find.... */
+	fsnotify_put_mark(entry);
+
+out_fput:
+	fput_light(file, fput_needed);
+out:
+	return ret;
+}
+
+static int fan_setsockopt(struct socket *sock, int level, int optname,
+			  char __user *optval, int optlen)
+{
+	struct fanotify_sock *fan_sock;
+	struct fsnotify_group *group;
+	size_t copy_len;
+
+	union {
+		struct fanotify_so_inode_mark inode_mark;
+	} data;
+	int ret = 0;
+
+	if (sock->state != SS_CONNECTED)
+		return -EBADF;
+
+	if (level != SOL_FANOTIFY)
+		return -ENOPROTOOPT;
+
+	fan_sock = fan_sk(sock->sk);
+	group = fan_sock->group;
+
+	copy_len = min(optlen, (int)sizeof(data));
+	ret = copy_from_user(&data, optval, copy_len);
+	if (ret)
+		return ret;
+
+	switch (optname) {
+	case FANOTIFY_SET_MARK:
+	case FANOTIFY_REMOVE_MARK:
+		if (optlen < sizeof(struct fanotify_so_inode_mark))
+			return -ENOMEM;
+
+		if (optname == FANOTIFY_SET_MARK)
+			ret = fanotify_add_inode_mark(group, &data.inode_mark);
+		else if (optname == FANOTIFY_REMOVE_MARK)
+			ret = fanotify_remove_inode_mark(group, &data.inode_mark);
+		break;
+	default:
+		return -ENOPROTOOPT;
+	}
+
+	return ret;
+}
+
 static const struct net_proto_family fanotify_family_ops = {
 	.family		=	PF_FANOTIFY,
 	.create		=	fan_sock_create,
@@ -132,7 +297,7 @@ static const struct proto_ops fanotify_proto_ops = {
 	.ioctl =	sock_no_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	sock_no_shutdown,
-	.setsockopt =	sock_no_setsockopt,
+	.setsockopt =	fan_setsockopt,
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	sock_no_sendmsg,
 	.recvmsg =	sock_no_recvmsg,
@@ -142,6 +307,8 @@ static const struct proto_ops fanotify_proto_ops = {
 
 static int __init fanotify_init(void)
 {
+	fanotify_mark_cache = KMEM_CACHE(fsnotify_mark_entry, SLAB_PANIC);
+
 	if (proto_register(&fanotify_proto, 0))
 		panic("unable to register fanotify protocol with network stack\n");
 
diff --git a/include/linux/fanotify.h b/include/linux/fanotify.h
index 4c1c6cd..6ecbcea 100644
--- a/include/linux/fanotify.h
+++ b/include/linux/fanotify.h
@@ -53,6 +53,16 @@ struct fanotify_addr {
 	__u32 unused[16];
 }  __attribute__((packed));
 
+/* struct used for FANOTIFY_SET_MARK */
+struct fanotify_so_inode_mark {
+	__s32 fd;
+	__u32 mask;
+}  __attribute__((packed));
+
+/* fanotify setsockopt optvals */
+#define FANOTIFY_SET_MARK	1
+#define FANOTIFY_REMOVE_MARK	2
+
 #ifdef __KERNEL__
 
 #endif /* __KERNEL__ */

