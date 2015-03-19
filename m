From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH v3 net-next 1/3] net: socket: add support for async operations
Date: Thu, 19 Mar 2015 12:31:25 -0700
Message-ID: <20150319193124.11500.16756.stgit@tstruk-mobl1>
References: <20150319193118.11500.10463.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ying.xue@windriver.com, bcrl@kvack.org,
	viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150319193118.11500.10463.stgit@tstruk-mobl1>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for async operations.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 include/linux/socket.h |    1 +
 net/compat.c           |    2 ++
 net/socket.c           |    8 ++++++--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index fab4d0d..c9852ef 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -51,6 +51,7 @@ struct msghdr {
 	void		*msg_control;	/* ancillary data */
 	__kernel_size_t	msg_controllen;	/* ancillary data buffer length */
 	unsigned int	msg_flags;	/* flags on received message */
+	struct kiocb	*msg_iocb;	/* ptr to iocb for async requests */
 };
  
 struct user_msghdr {
diff --git a/net/compat.c b/net/compat.c
index 4784431..7fb7ad1 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -72,6 +72,8 @@ ssize_t get_compat_msghdr(struct msghdr *kmsg,
 	if (nr_segs > UIO_MAXIOV)
 		return -EMSGSIZE;
 
+	kmsg->msg_iocb = NULL;
+
 	err = compat_rw_copy_check_uvector(save_addr ? READ : WRITE,
 					   compat_ptr(uiov), nr_segs,
 					   UIO_FASTIOV, *iov, iov);
diff --git a/net/socket.c b/net/socket.c
index 95d3085..fafc50a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -798,7 +798,8 @@ static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct file *file = iocb->ki_filp;
 	struct socket *sock = file->private_data;
-	struct msghdr msg = {.msg_iter = *to};
+	struct msghdr msg = {.msg_iter = *to,
+			     .msg_iocb = iocb};
 	ssize_t res;
 
 	if (file->f_flags & O_NONBLOCK)
@@ -819,7 +820,8 @@ static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct file *file = iocb->ki_filp;
 	struct socket *sock = file->private_data;
-	struct msghdr msg = {.msg_iter = *from};
+	struct msghdr msg = {.msg_iter = *from,
+			     .msg_iocb = iocb};
 	ssize_t res;
 
 	if (iocb->ki_pos != 0)
@@ -1890,6 +1892,8 @@ static ssize_t copy_msghdr_from_user(struct msghdr *kmsg,
 	if (nr_segs > UIO_MAXIOV)
 		return -EMSGSIZE;
 
+	kmsg->msg_iocb = NULL;
+
 	err = rw_copy_check_uvector(save_addr ? READ : WRITE,
 				    uiov, nr_segs,
 				    UIO_FASTIOV, *iov, iov);
