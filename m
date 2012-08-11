From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 01/15] net: proc entry showing inodes on sockfs and their types
Date: Sun, 12 Aug 2012 05:07:04 +0900
Message-ID: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've worked on improving lsof output on linux both lsof and linux
sides.  Sometimes lsof cannot resolve socket descriptors and as the
result it prints them like:

    [yamato@localhost]/tmp% sudo lsof | grep dbus | grep iden
    dbus-daem   652          dbus    6u     sock ... 17812 can't identify protocol
    dbus-daem   652          dbus   34u     sock ... 24689 can't identify protocol
    dbus-daem   652          dbus   42u     sock ... 24739 can't identify protocol
    dbus-daem   652          dbus   48u     sock ... 22329 can't identify protocol
    ...

lsof refers /proc/net/PROTOCOL files to solve the type of socket for
given socket descriptor. lsof looks up inode column of the files.

lsof cannot resolve the type if there is no PROTOCOL file for PROTOCOL
for the given socket descriptor nor there is PROTOCOL file with no
inode column.

About kernel side, bluetooth protocol families didn't have their own
PROTOCOL files. So I added them. netlink protocol had its own PROTOCOL
file but no inode column. So I added the column to it.

About lsof side, I added code to refer /proc/net/netlink to lsof.  I
added code to refer /proc/net/icmp to lsof. I have to added code to
refer /proc/net/PROTOCOL files for bluetooth protocol families.

However, it is far from complete.

    $ grep -r '^\(static \)*struct proto ' | wc -l
    60

It is difficult for me to deal such many protocols.  During working on
improving, newer protocol may be implemented. Further more subsystem
mariners don't want to add inode column to /proc/net/PROTOCOL file for
avoiding file format incompatibility.

This patch introduces /proc/net/sockfs, which shows most of all inodes
on sockfs and their socket type. A socket newly associated with socket
descriptor in kernel is stored to a list named
`proc_sockfs_list'. /proc/net/sockfs shows the element of the list.

If a protocol has its own lsof friendly proc entry, a socket of the
protocol should not be stored to `proc_sockfs_list'; lsof can solve
the socket type via protocol the proc entry. A protocol can declare it
has own proc entry with `has_own_proc_entry' field in struct proto.
If the field is non-zero, the socket of the protocol is never added to
`proc_sockfs_list'.

In v2 patch, unnecessary CONFIG_PROC_FS ifdefs are removed as suggested
by Alan Cox. The patches are rebased to net-next.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 include/linux/net.h |   8 +++
 include/net/sock.h  |   3 +
 net/socket.c        | 169 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 178 insertions(+), 2 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 99276c3..c87acff 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -61,6 +61,9 @@ typedef enum {
 #include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/kmemcheck.h>
 #include <linux/rcupdate.h>
+#ifdef CONFIG_PROC_FS
+#include <linux/list.h>
+#endif
 
 struct poll_table_struct;
 struct pipe_inode_info;
@@ -135,6 +138,7 @@ struct socket_wq {
  *  @file: File back pointer for gc
  *  @sk: internal networking protocol agnostic socket representation
  *  @wq: wait queue for several uses
+ *  @proc_sockfs_list: list head to link this socket to /proc/net/sockfs
  */
 struct socket {
 	socket_state		state;
@@ -150,6 +154,10 @@ struct socket {
 	struct file		*file;
 	struct sock		*sk;
 	const struct proto_ops	*ops;
+
+#ifdef CONFIG_PROC_FS
+	struct list_head        proc_sockfs_list;
+#endif
 };
 
 struct vm_area_struct;
diff --git a/include/net/sock.h b/include/net/sock.h
index 72132ae..af37a1e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -955,6 +955,9 @@ struct proto {
 	void			(*destroy_cgroup)(struct mem_cgroup *memcg);
 	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
 #endif
+	/* Set non-zero value if this protocol manages its
+	   own /proc/net/PROTOCOL entry and the entry has inode column. */
+        int has_own_proc_entry;
 };
 
 /*
diff --git a/net/socket.c b/net/socket.c
index dfe5b66..5f4f228 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -104,6 +104,7 @@
 #include <linux/route.h>
 #include <linux/sockios.h>
 #include <linux/atalk.h>
+#include <linux/rwlock_types.h>
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -127,6 +128,10 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 				struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags);
 
+static int proc_sockfs_init(void);
+static void proc_sockfs_add(struct socket *sock);
+static void proc_sockfs_remove(struct socket *sock);
+
 /*
  *	Socket files have a set of 'special' operations as well as the generic file ones. These don't appear
  *	in the operation structures but are done directly via the socketcall() multiplexor.
@@ -259,6 +264,7 @@ static struct inode *sock_alloc_inode(struct super_block *sb)
 	ei->socket.ops = NULL;
 	ei->socket.sk = NULL;
 	ei->socket.file = NULL;
+	INIT_LIST_HEAD(&ei->socket.proc_sockfs_list);
 
 	return &ei->vfs_inode;
 }
@@ -391,8 +397,10 @@ int sock_map_fd(struct socket *sock, int flags)
 	struct file *newfile;
 	int fd = sock_alloc_file(sock, &newfile, flags);
 
-	if (likely(fd >= 0))
+	if (likely(fd >= 0)) {
 		fd_install(fd, newfile);
+		proc_sockfs_add(sock);
+	}
 
 	return fd;
 }
@@ -512,9 +520,15 @@ const struct file_operations bad_sock_fops = {
 
 void sock_release(struct socket *sock)
 {
+	int externally_allocated = test_bit(SOCK_EXTERNALLY_ALLOCATED,
+					    &sock->flags);
+
 	if (sock->ops) {
 		struct module *owner = sock->ops->owner;
 
+		if (!externally_allocated)
+			proc_sockfs_remove(sock);
+
 		sock->ops->release(sock);
 		sock->ops = NULL;
 		module_put(owner);
@@ -523,7 +537,7 @@ void sock_release(struct socket *sock)
 	if (rcu_dereference_protected(sock->wq, 1)->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
 
-	if (test_bit(SOCK_EXTERNALLY_ALLOCATED, &sock->flags))
+	if (externally_allocated)
 		return;
 
 	this_cpu_sub(sockets_in_use, 1);
@@ -1411,7 +1425,9 @@ SYSCALL_DEFINE4(socketpair, int, family, int, type, int, protocol,
 
 	audit_fd_pair(fd1, fd2);
 	fd_install(fd1, newfile1);
+	proc_sockfs_add(sock1);
 	fd_install(fd2, newfile2);
+	proc_sockfs_add(sock2);
 	/* fd1 and fd2 may be already another descriptors.
 	 * Not kernel problem.
 	 */
@@ -1566,6 +1582,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	/* File flags are not inherited via accept() unlike another OSes. */
 
 	fd_install(newfd, newfile);
+	proc_sockfs_add(newsock);
 	err = newfd;
 
 out_put:
@@ -2552,6 +2569,9 @@ static int __init sock_init(void)
 		err = PTR_ERR(sock_mnt);
 		goto out_mount;
 	}
+	err = proc_sockfs_init();
+	if (err)
+		goto out_proc_socfs;
 
 	/* The real protocol initialization is performed in later initcalls.
 	 */
@@ -2567,6 +2587,8 @@ static int __init sock_init(void)
 out:
 	return err;
 
+out_proc_socfs:
+	kern_unmount(sock_mnt);
 out_mount:
 	unregister_filesystem(&sock_fs_type);
 out_fs:
@@ -3380,3 +3402,146 @@ int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
 	return sock->ops->shutdown(sock, how);
 }
 EXPORT_SYMBOL(kernel_sock_shutdown);
+
+#ifdef CONFIG_PROC_FS
+static LIST_HEAD(proc_sockfs_list);
+static DEFINE_RWLOCK(proc_sockfs_lock);
+
+static void proc_sockfs_add(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	if (!sk->sk_prot_creator->has_own_proc_entry) {
+		write_lock(&proc_sockfs_lock);
+		list_add_tail(&sock->proc_sockfs_list, &proc_sockfs_list);
+		write_unlock(&proc_sockfs_lock);
+	}
+}
+
+static void proc_sockfs_remove(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	if (!sk)
+		return;
+
+	if (!sk->sk_prot_creator->has_own_proc_entry) {
+		if (!list_empty(&sock->proc_sockfs_list)) {
+			write_lock(&proc_sockfs_lock);
+			list_del_init(&sock->proc_sockfs_list);
+			write_unlock(&proc_sockfs_lock);
+		}
+	}
+}
+
+static void *proc_sockfs_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(&proc_sockfs_lock)
+{
+	read_lock(&proc_sockfs_lock);
+	return seq_list_start_head(&proc_sockfs_list, *pos);
+}
+
+static void *proc_sockfs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	return seq_list_next(v, &proc_sockfs_list, pos);
+}
+
+static void proc_sockfs_seq_stop(struct seq_file *seq, void *v)
+       __releases(&proc_sockfs_lock)
+{
+	read_unlock(&proc_sockfs_lock);
+}
+
+static int proc_sockfs_seq_show_header(struct seq_file *seq)
+{
+	return seq_printf(seq, "Inode                name     state family type protocol socket           net\n");
+}
+
+static int proc_sockfs_seq_show_socket(struct seq_file *seq, struct socket *sock)
+{
+	struct sock *sk;
+	const char *name;
+
+	sk = sock->sk;
+	BUG_ON(sk == NULL);
+
+	name = sk->sk_prot_creator->name;
+	if (name == NULL || name[0] == '\0')
+		name = "UNKNOWN";
+
+	return seq_printf(seq, "%20lu %-8s %5d %6d %4d %8d %p %p\n",
+			  sock_i_ino(sk),
+			  name,
+			  sock->state,
+			  sk->sk_family,
+			  sock->type,
+			  sk->sk_protocol,
+			  sock,
+		          sock_net(sk));
+}
+
+static int proc_sockfs_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == &proc_sockfs_list)
+		proc_sockfs_seq_show_header(seq);
+	else {
+		struct socket *sock = list_entry(v, struct socket, proc_sockfs_list);
+		proc_sockfs_seq_show_socket(seq, sock);
+	}
+
+	return 0;
+}
+
+static const struct seq_operations proc_sockfs_seq_ops = {
+	.start  = proc_sockfs_seq_start,
+	.next   = proc_sockfs_seq_next,
+	.stop   = proc_sockfs_seq_stop,
+	.show   = proc_sockfs_seq_show,
+};
+
+static int proc_sockfs_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &proc_sockfs_seq_ops);
+}
+
+static const struct file_operations proc_sockfs_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= proc_sockfs_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static __net_init int proc_sockfs_init_net(struct net *net)
+{
+	if (!proc_net_fops_create(net, "sockfs", S_IRUGO, &proc_sockfs_seq_fops))
+		return -ENOMEM;
+	return 0;
+}
+
+static __net_exit void proc_sockfs_exit_net(struct net *net)
+{
+	proc_net_remove(net, "sockfs");
+}
+
+static __net_initdata struct pernet_operations proc_sockfs_ops = {
+	.init = proc_sockfs_init_net,
+	.exit = proc_sockfs_exit_net,
+};
+
+static int proc_sockfs_init(void)
+{
+	return register_pernet_subsys(&proc_sockfs_ops);
+}
+#else
+static int proc_sockfs_init(void)
+{
+	return 0;
+}
+static void proc_sockfs_add(struct socket *sock)
+{
+}
+static void proc_sockfs_remove(struct socket *sock)
+{
+}
+#endif	/* CONFIG_PROC_FS */
-- 
1.7.11.2
