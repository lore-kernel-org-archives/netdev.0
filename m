From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] net: Providing protocol type via system.sockprotoname xattr of /proc/PID/fd entries
Date: Thu, 30 Aug 2012 05:44:29 +0900
Message-ID: <1346273069-5390-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lsof reports some of socket descriptors as "can't identify protocol" like:

    [yamato@localhost]/tmp% sudo lsof | grep dbus | grep iden
    dbus-daem   652          dbus    6u     sock ... 17812 can't identify protocol
    dbus-daem   652          dbus   34u     sock ... 24689 can't identify protocol
    dbus-daem   652          dbus   42u     sock ... 24739 can't identify protocol
    dbus-daem   652          dbus   48u     sock ... 22329 can't identify protocol
    ...

lsof cannot resolve the protocol used in a socket because procfs
doesn't provide the map between inode number on sockfs and protocol
type of the socket.

For improving the situation this patch adds an extended attribute named
'system.sockprotoname' in which the protocol name for
/proc/PID/fd/SOCKET is stored. So lsof can know the protocol for a
given /proc/PID/fd/SOCKET with getxattr system call.

A few weeks ago I submitted a patch for the same purpose. The patch
was introduced /proc/net/sockfs which enumerates inodes and protocols
of all sockets alive on a system. However, it was rejected because (1)
a global lock was needed, and (2) the layout of struct socket was
changed with the patch.

This patch doesn't use any global lock; and doesn't change the layout
of any structs.

In this patch, a protocol name is stored to dentry->d_name of sockfs
when new socket is associated with a file descriptor. Before this
patch dentry->d_name was not used; it was just filled with empty
string. lsof may use an extended attribute named
'system.sockprotoname' to retrieve the value of dentry->d_name.

It is nice if we can see the protocol name with ls -l
/proc/PID/fd. However, "socket:[#INODE]", the name format returned
from sockfs_dname() was already defined. To keep the compatibility
between kernel and user land, the extended attribute is used to
prepare the value of dentry->d_name.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/socket.c | 83 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 78 insertions(+), 5 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index a5471f8..977c0f4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -88,6 +88,7 @@
 #include <linux/nsproxy.h>
 #include <linux/magic.h>
 #include <linux/slab.h>
+#include <linux/xattr.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -346,7 +347,8 @@ static struct file_system_type sock_fs_type = {
  *	but we take care of internal coherence yet.
  */
 
-static int sock_alloc_file(struct socket *sock, struct file **f, int flags)
+static int sock_alloc_file(struct socket *sock, struct file **f, int flags,
+			   const char *dname)
 {
 	struct qstr name = { .name = "" };
 	struct path path;
@@ -357,6 +359,13 @@ static int sock_alloc_file(struct socket *sock, struct file **f, int flags)
 	if (unlikely(fd < 0))
 		return fd;
 
+	if (dname) {
+		name.name = dname;
+		name.len = strlen(name.name);
+	} else if (sock->sk) {
+		name.name = sock->sk->sk_prot_creator->name;
+		name.len = strlen(name.name);
+	}
 	path.dentry = d_alloc_pseudo(sock_mnt->mnt_sb, &name);
 	if (unlikely(!path.dentry)) {
 		put_unused_fd(fd);
@@ -389,7 +398,7 @@ static int sock_alloc_file(struct socket *sock, struct file **f, int flags)
 int sock_map_fd(struct socket *sock, int flags)
 {
 	struct file *newfile;
-	int fd = sock_alloc_file(sock, &newfile, flags);
+	int fd = sock_alloc_file(sock, &newfile, flags, NULL);
 
 	if (likely(fd >= 0))
 		fd_install(fd, newfile);
@@ -455,6 +464,68 @@ static struct socket *sockfd_lookup_light(int fd, int *err, int *fput_needed)
 	return NULL;
 }
 
+#define XATTR_SOCKPROTONAME_SUFFIX "sockprotoname"
+#define XATTR_NAME_SOCKPROTONAME (XATTR_SYSTEM_PREFIX XATTR_SOCKPROTONAME_SUFFIX)
+#define XATTR_NAME_SOCKPROTONAME_LEN (sizeof(XATTR_NAME_SOCKPROTONAME)-1)
+static ssize_t sockfs_getxattr(struct dentry *dentry,
+			       const char *name, void *value, size_t size)
+{
+	const char *proto_name;
+	size_t proto_size;
+	int error;
+
+	error = -ENODATA;
+	if (!strncmp(name, XATTR_NAME_SOCKPROTONAME, XATTR_NAME_SOCKPROTONAME_LEN)) {
+		proto_name = dentry->d_name.name;
+		proto_size = strlen(proto_name);
+
+		if (value) {
+			error = -ERANGE;
+			if (proto_size + 1 > size)
+				goto out;
+
+			strncpy(value, proto_name, proto_size + 1);
+		}
+		error = proto_size + 1;
+	}
+
+out:
+	return error;
+}
+
+static ssize_t sockfs_listxattr(struct dentry *dentry, char *buffer,
+				size_t size)
+{
+	ssize_t len;
+	ssize_t used = 0;
+
+	len = security_inode_listsecurity(dentry->d_inode, buffer, size);
+	if (len < 0)
+		return len;
+	used += len;
+	if (buffer) {
+		if (size < used)
+			return -ERANGE;
+		buffer += len;
+	}
+
+	len = (XATTR_NAME_SOCKPROTONAME_LEN + 1);
+	used += len;
+	if (buffer) {
+		if (size < used)
+			return -ERANGE;
+		memcpy(buffer, XATTR_NAME_SOCKPROTONAME, len);
+		buffer += len;
+	}
+
+	return used;
+}
+
+static const struct inode_operations sockfs_inode_ops = {
+	.getxattr = sockfs_getxattr,
+	.listxattr = sockfs_listxattr,
+};
+
 /**
  *	sock_alloc	-	allocate a socket
  *
@@ -479,6 +550,7 @@ static struct socket *sock_alloc(void)
 	inode->i_mode = S_IFSOCK | S_IRWXUGO;
 	inode->i_uid = current_fsuid();
 	inode->i_gid = current_fsgid();
+	inode->i_op = &sockfs_inode_ops;
 
 	this_cpu_add(sockets_in_use, 1);
 	return sock;
@@ -1394,13 +1466,13 @@ SYSCALL_DEFINE4(socketpair, int, family, int, type, int, protocol,
 	if (err < 0)
 		goto out_release_both;
 
-	fd1 = sock_alloc_file(sock1, &newfile1, flags);
+	fd1 = sock_alloc_file(sock1, &newfile1, flags, NULL);
 	if (unlikely(fd1 < 0)) {
 		err = fd1;
 		goto out_release_both;
 	}
 
-	fd2 = sock_alloc_file(sock2, &newfile2, flags);
+	fd2 = sock_alloc_file(sock2, &newfile2, flags, NULL);
 	if (unlikely(fd2 < 0)) {
 		err = fd2;
 		fput(newfile1);
@@ -1536,7 +1608,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	 */
 	__module_get(newsock->ops->owner);
 
-	newfd = sock_alloc_file(newsock, &newfile, flags);
+	newfd = sock_alloc_file(newsock, &newfile, flags,
+				sock->sk->sk_prot_creator->name);
 	if (unlikely(newfd < 0)) {
 		err = newfd;
 		sock_release(newsock);
-- 
1.7.11.4
