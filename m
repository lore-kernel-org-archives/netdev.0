From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] Remove i_sock
Date: Sat, 26 Mar 2005 01:37:42 +0000
Message-ID: <20050326013742.GP21986@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Remove i_sock from struct inode.  Also remove some checks for SOCKET_I()
returning NULL -- it can never return NULL for a valid inode.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Index: ./fs/inode.c
===================================================================
RCS file: /var/lib/cvs/linux-2.6/fs/inode.c,v
retrieving revision 1.17
diff -u -p -r1.17 inode.c
--- ./fs/inode.c	18 Mar 2005 13:17:29 -0000	1.17
+++ ./fs/inode.c	24 Mar 2005 20:56:43 -0000
@@ -118,7 +118,6 @@ static struct inode *alloc_inode(struct 
 		inode->i_blkbits = sb->s_blocksize_bits;
 		inode->i_flags = 0;
 		atomic_set(&inode->i_count, 1);
-		inode->i_sock = 0;
 		inode->i_op = &empty_iops;
 		inode->i_fop = &empty_fops;
 		inode->i_nlink = 1;
Index: ./include/linux/fs.h
===================================================================
RCS file: /var/lib/cvs/linux-2.6/include/linux/fs.h,v
retrieving revision 1.29
diff -u -p -r1.29 fs.h
--- ./include/linux/fs.h	18 Mar 2005 13:17:48 -0000	1.29
+++ ./include/linux/fs.h	24 Mar 2005 20:56:43 -0000
@@ -445,7 +445,6 @@ struct inode {
 	unsigned long		i_version;
 	unsigned long		i_blocks;
 	unsigned short          i_bytes;
-	unsigned char		i_sock;
 	spinlock_t		i_lock;	/* i_blocks, i_bytes, maybe i_size */
 	struct semaphore	i_sem;
 	struct rw_semaphore	i_alloc_sem;
Index: ./net/socket.c
===================================================================
RCS file: /var/lib/cvs/linux-2.6/net/socket.c,v
retrieving revision 1.16
diff -u -p -r1.16 socket.c
--- ./net/socket.c	18 Mar 2005 13:17:56 -0000	1.16
+++ ./net/socket.c	24 Mar 2005 20:56:43 -0000
@@ -437,13 +437,13 @@ struct socket *sockfd_lookup(int fd, int
 	}
 
 	inode = file->f_dentry->d_inode;
-	if (!inode->i_sock || !(sock = SOCKET_I(inode)))
-	{
+	if (!S_ISSOCK(inode->i_mode)) {
 		*err = -ENOTSOCK;
 		fput(file);
 		return NULL;
 	}
 
+	sock = SOCKET_I(inode);
 	if (sock->file != file) {
 		printk(KERN_ERR "socki_lookup: socket file changed!\n");
 		sock->file = file;
@@ -471,7 +471,6 @@ static struct socket *sock_alloc(void)
 	sock = SOCKET_I(inode);
 
 	inode->i_mode = S_IFSOCK|S_IRWXUGO;
-	inode->i_sock = 1;
 	inode->i_uid = current->fsuid;
 	inode->i_gid = current->fsgid;
 
Index: ./net/netlink/af_netlink.c
===================================================================
RCS file: /var/lib/cvs/linux-2.6/net/netlink/af_netlink.c,v
retrieving revision 1.20
diff -u -p -r1.20 af_netlink.c
--- ./net/netlink/af_netlink.c	18 Mar 2005 13:18:02 -0000	1.20
+++ ./net/netlink/af_netlink.c	24 Mar 2005 20:56:43 -0000
@@ -563,13 +563,12 @@ static struct sock *netlink_getsockbypid
 struct sock *netlink_getsockbyfilp(struct file *filp)
 {
 	struct inode *inode = filp->f_dentry->d_inode;
-	struct socket *socket;
 	struct sock *sock;
 
-	if (!inode->i_sock || !(socket = SOCKET_I(inode)))
+	if (!S_ISSOCK(inode->i_mode))
 		return ERR_PTR(-ENOTSOCK);
 
-	sock = socket->sk;
+	sock = SOCKET_I(inode)->sk;
 	if (sock->sk_family != AF_NETLINK)
 		return ERR_PTR(-EINVAL);
 
Index: ./net/unix/garbage.c
===================================================================
RCS file: /var/lib/cvs/linux-2.6/net/unix/garbage.c,v
retrieving revision 1.1
diff -u -p -r1.1 garbage.c
--- ./net/unix/garbage.c	29 Jul 2003 17:02:26 -0000	1.1
+++ ./net/unix/garbage.c	24 Mar 2005 20:56:43 -0000
@@ -100,7 +100,7 @@ static struct sock *unix_get_socket(stru
 	/*
 	 *	Socket ?
 	 */
-	if (inode->i_sock) {
+	if (S_ISSOCK(inode->i_mode)) {
 		struct socket * sock = SOCKET_I(inode);
 		struct sock * s = sock->sk;
 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
