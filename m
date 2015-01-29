From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH 1/3] net: socket: enable async read and write
Date: Thu, 29 Jan 2015 15:13:45 -0800
Message-ID: <20150129231345.25156.51764.stgit@tstruk-mobl1>
References: <20150129231338.25156.65450.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, qat-linux@intel.com,
	linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150129231338.25156.65450.stgit@tstruk-mobl1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AIO read or write are not currently supported on sockets.
This patch enables real socket async read/write.

Please note - this patch is generated against cryptodev.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 include/net/sock.h |    2 ++
 net/socket.c       |   48 ++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 40 insertions(+), 10 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2210fec..2c7d160 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1397,6 +1397,8 @@ static inline struct kiocb *siocb_to_kiocb(struct sock_iocb *si)
 	return si->kiocb;
 }
 
+void sock_aio_complete(struct kiocb *iocb, long res, long res2);
+
 struct socket_alloc {
 	struct socket socket;
 	struct inode vfs_inode;
diff --git a/net/socket.c b/net/socket.c
index a2c33a4..368fa9f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -866,14 +866,25 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
+void sock_aio_complete(struct kiocb *iocb, long res, long res2)
+{
+	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
+
+	kfree(siocb);
+	aio_complete(iocb, res, res2);
+}
+EXPORT_SYMBOL(sock_aio_complete);
+
 static struct sock_iocb *alloc_sock_iocb(struct kiocb *iocb,
 					 struct sock_iocb *siocb)
 {
-	if (!is_sync_kiocb(iocb))
-		BUG();
+	if (!siocb)
+		siocb = kmalloc(sizeof(*siocb), GFP_KERNEL);
 
-	siocb->kiocb = iocb;
-	iocb->private = siocb;
+	if (siocb) {
+		siocb->kiocb = iocb;
+		iocb->private = siocb;
+	}
 	return siocb;
 }
 
@@ -901,7 +912,8 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos)
 {
-	struct sock_iocb siocb, *x;
+	struct sock_iocb siocb, *x = NULL;
+	int ret;
 
 	if (pos != 0)
 		return -ESPIPE;
@@ -909,11 +921,18 @@ static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 	if (iocb->ki_nbytes == 0)	/* Match SYS5 behaviour */
 		return 0;
 
+	if (is_sync_kiocb(iocb))
+		x = &siocb;
 
-	x = alloc_sock_iocb(iocb, &siocb);
+	x = alloc_sock_iocb(iocb, x);
 	if (!x)
 		return -ENOMEM;
-	return do_sock_read(&x->async_msg, iocb, iocb->ki_filp, iov, nr_segs);
+	ret = do_sock_read(&x->async_msg, iocb, iocb->ki_filp, iov, nr_segs);
+
+	if (!is_sync_kiocb(iocb) && ret != -EIOCBQUEUED)
+		kfree(x);
+
+	return ret;
 }
 
 static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
@@ -942,16 +961,25 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
 			  unsigned long nr_segs, loff_t pos)
 {
-	struct sock_iocb siocb, *x;
+	struct sock_iocb siocb, *x = NULL;
+	int ret;
 
 	if (pos != 0)
 		return -ESPIPE;
 
-	x = alloc_sock_iocb(iocb, &siocb);
+	if (is_sync_kiocb(iocb))
+		x = &siocb;
+
+	x = alloc_sock_iocb(iocb, x);
 	if (!x)
 		return -ENOMEM;
 
-	return do_sock_write(&x->async_msg, iocb, iocb->ki_filp, iov, nr_segs);
+	ret = do_sock_write(&x->async_msg, iocb, iocb->ki_filp, iov, nr_segs);
+
+	if (!is_sync_kiocb(iocb) && ret != -EIOCBQUEUED)
+		kfree(x);
+
+	return ret;
 }
 
 /*
