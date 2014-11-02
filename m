From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: fs: Use non-const iov in aio_read/aio_write
Date: Mon, 3 Nov 2014 07:05:52 +0800
Message-ID: <20141102230552.GA26095@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin LaHaise <bcrl@kvack.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the functions aio_read/aio_write use a const iov as
input.  This is unnecessary as all their callers supply a
stack-based or kmalloced iov which is never reused.  Conceptually
this is fine because iovs supplied to aio_read/aio_write ultimately
come from user-space so we always have to make a copy of them for
the kernel.

This is also a joke because for as long (since 2.1.15) as we've
had the const iov, the network stack (currently through do_sock_read
and do_sock_write) has been casting the const away.  IOW if anybody
did supply a const iov they would crash and burn if they ever
entered the network stack.

The network stack needs a non-const iov because it iterates through
the iov as it reads/writes data.

So we have two alternatives, either change the network stack to
not touch the iovs or make the iovs non-const.

As there is no reason for the iovs to be const in the first place,
I have taken the second choice and changed all aio_read/aio_write
functions to use non-const iovs.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index b30753c..dfefc79 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -434,8 +434,8 @@ prototypes:
 	loff_t (*llseek) (struct file *, loff_t, int);
 	ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
 	ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
-	ssize_t (*aio_read) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
-	ssize_t (*aio_write) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
+	ssize_t (*aio_read) (struct kiocb *, struct iovec *, unsigned long, loff_t);
+	ssize_t (*aio_write) (struct kiocb *, struct iovec *, unsigned long, loff_t);
 	ssize_t (*read_iter) (struct kiocb *, struct iov_iter *);
 	ssize_t (*write_iter) (struct kiocb *, struct iov_iter *);
 	int (*iterate) (struct file *, struct dir_context *);
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 20bf204..a2ba142 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -811,8 +811,8 @@ struct file_operations {
 	loff_t (*llseek) (struct file *, loff_t, int);
 	ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
 	ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
-	ssize_t (*aio_read) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
-	ssize_t (*aio_write) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
+	ssize_t (*aio_read) (struct kiocb *, struct iovec *, unsigned long, loff_t);
+	ssize_t (*aio_write) (struct kiocb *, struct iovec *, unsigned long, loff_t);
 	ssize_t (*read_iter) (struct kiocb *, struct iov_iter *);
 	ssize_t (*write_iter) (struct kiocb *, struct iov_iter *);
 	int (*iterate) (struct file *, struct dir_context *);
diff --git a/arch/s390/hypfs/inode.c b/arch/s390/hypfs/inode.c
index c952b98..c7490bd 100644
--- a/arch/s390/hypfs/inode.c
+++ b/arch/s390/hypfs/inode.c
@@ -144,7 +144,7 @@ static int hypfs_open(struct inode *inode, struct file *filp)
 	return nonseekable_open(inode, filp);
 }
 
-static ssize_t hypfs_aio_read(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t hypfs_aio_read(struct kiocb *iocb, struct iovec *iov,
 			      unsigned long nr_segs, loff_t offset)
 {
 	char *data;
@@ -167,7 +167,7 @@ static ssize_t hypfs_aio_read(struct kiocb *iocb, const struct iovec *iov,
 
 	return ret;
 }
-static ssize_t hypfs_aio_write(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t hypfs_aio_write(struct kiocb *iocb, struct iovec *iov,
 			      unsigned long nr_segs, loff_t offset)
 {
 	int rc;
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 524b707..d94e5b0 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -598,13 +598,13 @@ static ssize_t write_null(struct file *file, const char __user *buf,
 	return count;
 }
 
-static ssize_t aio_read_null(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t aio_read_null(struct kiocb *iocb, struct iovec *iov,
 			     unsigned long nr_segs, loff_t pos)
 {
 	return 0;
 }
 
-static ssize_t aio_write_null(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t aio_write_null(struct kiocb *iocb, struct iovec *iov,
 			      unsigned long nr_segs, loff_t pos)
 {
 	return iov_length(iov, nr_segs);
diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
index 6d7f453..8b75de4f 100644
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -53,7 +53,7 @@ static int ipath_open(struct inode *, struct file *);
 static int ipath_close(struct inode *, struct file *);
 static ssize_t ipath_write(struct file *, const char __user *, size_t,
 			   loff_t *);
-static ssize_t ipath_writev(struct kiocb *, const struct iovec *,
+static ssize_t ipath_writev(struct kiocb *, struct iovec *,
 			    unsigned long , loff_t);
 static unsigned int ipath_poll(struct file *, struct poll_table_struct *);
 static int ipath_mmap(struct file *, struct vm_area_struct *);
@@ -2414,7 +2414,7 @@ bail:
 	return ret;
 }
 
-static ssize_t ipath_writev(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t ipath_writev(struct kiocb *iocb, struct iovec *iov,
 			    unsigned long dim, loff_t off)
 {
 	struct file *filp = iocb->ki_filp;
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/hw/qib/qib_file_ops.c
index b15e34e..8872924 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -55,7 +55,7 @@
 static int qib_open(struct inode *, struct file *);
 static int qib_close(struct inode *, struct file *);
 static ssize_t qib_write(struct file *, const char __user *, size_t, loff_t *);
-static ssize_t qib_aio_write(struct kiocb *, const struct iovec *,
+static ssize_t qib_aio_write(struct kiocb *, struct iovec *,
 			     unsigned long, loff_t);
 static unsigned int qib_poll(struct file *, struct poll_table_struct *);
 static int qib_mmapf(struct file *, struct vm_area_struct *);
@@ -2245,7 +2245,7 @@ bail:
 	return ret;
 }
 
-static ssize_t qib_aio_write(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t qib_aio_write(struct kiocb *iocb, struct iovec *iov,
 			     unsigned long dim, loff_t off)
 {
 	struct qib_filedata *fp = iocb->ki_filp->private_data;
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 6f226de..823522e 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -761,7 +761,7 @@ err:
 	return err;
 }
 
-static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
+static ssize_t macvtap_aio_write(struct kiocb *iocb, struct iovec *iv,
 				 unsigned long count, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
@@ -871,7 +871,7 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
 	return ret;
 }
 
-static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
+static ssize_t macvtap_aio_read(struct kiocb *iocb, struct iovec *iv,
 				unsigned long count, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9dd3746..8d06816 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1206,7 +1206,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	return total_len;
 }
 
-static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
+static ssize_t tun_chr_aio_write(struct kiocb *iocb, struct iovec *iv,
 			      unsigned long count, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
@@ -1371,7 +1371,7 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	return ret;
 }
 
-static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
+static ssize_t tun_chr_aio_read(struct kiocb *iocb, struct iovec *iv,
 			    unsigned long count, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
diff --git a/drivers/usb/gadget/function/f_fs.c b/drivers/usb/gadget/function/f_fs.c
index 63314ed..47fec3fd 100644
--- a/drivers/usb/gadget/function/f_fs.c
+++ b/drivers/usb/gadget/function/f_fs.c
@@ -958,7 +958,7 @@ static int ffs_aio_cancel(struct kiocb *kiocb)
 }
 
 static ssize_t ffs_epfile_aio_write(struct kiocb *kiocb,
-				    const struct iovec *iovec,
+				    struct iovec *iovec,
 				    unsigned long nr_segs, loff_t loff)
 {
 	struct ffs_io_data *io_data;
@@ -985,7 +985,7 @@ static ssize_t ffs_epfile_aio_write(struct kiocb *kiocb,
 }
 
 static ssize_t ffs_epfile_aio_read(struct kiocb *kiocb,
-				   const struct iovec *iovec,
+				   struct iovec *iovec,
 				   unsigned long nr_segs, loff_t loff)
 {
 	struct ffs_io_data *io_data;
diff --git a/drivers/usb/gadget/legacy/inode.c b/drivers/usb/gadget/legacy/inode.c
index c744e49..211ab83 100644
--- a/drivers/usb/gadget/legacy/inode.c
+++ b/drivers/usb/gadget/legacy/inode.c
@@ -695,7 +695,7 @@ fail:
 }
 
 static ssize_t
-ep_aio_read(struct kiocb *iocb, const struct iovec *iov,
+ep_aio_read(struct kiocb *iocb, struct iovec *iov,
 		unsigned long nr_segs, loff_t o)
 {
 	struct ep_data		*epdata = iocb->ki_filp->private_data;
@@ -712,7 +712,7 @@ ep_aio_read(struct kiocb *iocb, const struct iovec *iov,
 }
 
 static ssize_t
-ep_aio_write(struct kiocb *iocb, const struct iovec *iov,
+ep_aio_write(struct kiocb *iocb, struct iovec *iov,
 		unsigned long nr_segs, loff_t o)
 {
 	struct ep_data		*epdata = iocb->ki_filp->private_data;
diff --git a/fs/bad_inode.c b/fs/bad_inode.c
index afd2b44..ca3db8d 100644
--- a/fs/bad_inode.c
+++ b/fs/bad_inode.c
@@ -33,13 +33,13 @@ static ssize_t bad_file_write(struct file *filp, const char __user *buf,
         return -EIO;
 }
 
-static ssize_t bad_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t bad_file_aio_read(struct kiocb *iocb, struct iovec *iov,
 			unsigned long nr_segs, loff_t pos)
 {
 	return -EIO;
 }
 
-static ssize_t bad_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t bad_file_aio_write(struct kiocb *iocb, struct iovec *iov,
 			unsigned long nr_segs, loff_t pos)
 {
 	return -EIO;
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index ca88731..88ce708 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1277,7 +1277,7 @@ static ssize_t fuse_dev_do_read(struct fuse_conn *fc, struct file *file,
 	return err;
 }
 
-static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t fuse_dev_read(struct kiocb *iocb, struct iovec *iov,
 			      unsigned long nr_segs, loff_t pos)
 {
 	struct fuse_copy_state cs;
@@ -1881,7 +1881,7 @@ static ssize_t fuse_dev_do_write(struct fuse_conn *fc,
 	return err;
 }
 
-static ssize_t fuse_dev_write(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t fuse_dev_write(struct kiocb *iocb, struct iovec *iov,
 			      unsigned long nr_segs, loff_t pos)
 {
 	struct fuse_copy_state cs;
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 643faa4..2617860 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -2114,7 +2114,7 @@ out:
 /**
  * ntfs_file_aio_write -
  */
-static ssize_t ntfs_file_aio_write(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t ntfs_file_aio_write(struct kiocb *iocb, struct iovec *iov,
 		unsigned long nr_segs, loff_t pos)
 {
 	struct file *file = iocb->ki_filp;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 4e41a4a..2585428 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1485,8 +1485,8 @@ struct file_operations {
 	loff_t (*llseek) (struct file *, loff_t, int);
 	ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
 	ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
-	ssize_t (*aio_read) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
-	ssize_t (*aio_write) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
+	ssize_t (*aio_read) (struct kiocb *, struct iovec *, unsigned long, loff_t);
+	ssize_t (*aio_write) (struct kiocb *, struct iovec *, unsigned long, loff_t);
 	ssize_t (*read_iter) (struct kiocb *, struct iov_iter *);
 	ssize_t (*write_iter) (struct kiocb *, struct iov_iter *);
 	int (*iterate) (struct file *, struct dir_context *);
diff --git a/net/socket.c b/net/socket.c
index fe20c31..3c6fbab 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -114,9 +114,9 @@ unsigned int sysctl_net_busy_poll __read_mostly;
 #endif
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
-static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t sock_aio_read(struct kiocb *iocb, struct iovec *iov,
 			 unsigned long nr_segs, loff_t pos);
-static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t sock_aio_write(struct kiocb *iocb, struct iovec *iov,
 			  unsigned long nr_segs, loff_t pos);
 static int sock_mmap(struct file *file, struct vm_area_struct *vma);
 
@@ -901,7 +901,7 @@ static struct sock_iocb *alloc_sock_iocb(struct kiocb *iocb,
 }
 
 static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
-		struct file *file, const struct iovec *iov,
+		struct file *file, struct iovec *iov,
 		unsigned long nr_segs)
 {
 	struct socket *sock = file->private_data;
@@ -915,14 +915,14 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 	msg->msg_namelen = 0;
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
-	msg->msg_iov = (struct iovec *)iov;
+	msg->msg_iov = iov;
 	msg->msg_iovlen = nr_segs;
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 
 	return __sock_recvmsg(iocb, sock, msg, size, msg->msg_flags);
 }
 
-static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t sock_aio_read(struct kiocb *iocb, struct iovec *iov,
 				unsigned long nr_segs, loff_t pos)
 {
 	struct sock_iocb siocb, *x;
@@ -941,7 +941,7 @@ static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 }
 
 static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
-			struct file *file, const struct iovec *iov,
+			struct file *file, struct iovec *iov,
 			unsigned long nr_segs)
 {
 	struct socket *sock = file->private_data;
@@ -955,7 +955,7 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 	msg->msg_namelen = 0;
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
-	msg->msg_iov = (struct iovec *)iov;
+	msg->msg_iov = iov;
 	msg->msg_iovlen = nr_segs;
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 	if (sock->type == SOCK_SEQPACKET)
@@ -964,7 +964,7 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 	return __sock_sendmsg(iocb, sock, msg, size);
 }
 
-static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t sock_aio_write(struct kiocb *iocb, struct iovec *iov,
 			  unsigned long nr_segs, loff_t pos)
 {
 	struct sock_iocb siocb, *x;
diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
index 166d59c..229b5a9 100644
--- a/sound/core/pcm_native.c
+++ b/sound/core/pcm_native.c
@@ -2995,7 +2995,7 @@ static ssize_t snd_pcm_write(struct file *file, const char __user *buf,
 	return result;
 }
 
-static ssize_t snd_pcm_aio_read(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t snd_pcm_aio_read(struct kiocb *iocb, struct iovec *iov,
 			     unsigned long nr_segs, loff_t pos)
 
 {
@@ -3031,7 +3031,7 @@ static ssize_t snd_pcm_aio_read(struct kiocb *iocb, const struct iovec *iov,
 	return result;
 }
 
-static ssize_t snd_pcm_aio_write(struct kiocb *iocb, const struct iovec *iov,
+static ssize_t snd_pcm_aio_write(struct kiocb *iocb, struct iovec *iov,
 			      unsigned long nr_segs, loff_t pos)
 {
 	struct snd_pcm_file *pcm_file;

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
