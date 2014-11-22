From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 05/17] switch drivers/net/tun.c to ->read_iter()
Date: Sat, 22 Nov 2014 04:32:02 +0000
Message-ID: <20141122043202.GE30478@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
 <20141122042856.GZ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	nab@linux-iscsi.org, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/tun.c |   40 +++++++++++++++-------------------------
 1 file changed, 15 insertions(+), 25 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ac53a73..405dfdf 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1339,18 +1339,17 @@ done:
 }
 
 static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
-			   const struct iovec *iv, unsigned long segs,
-			   ssize_t len, int noblock)
+			   struct iov_iter *to,
+			   int noblock)
 {
 	struct sk_buff *skb;
-	ssize_t ret = 0;
+	ssize_t ret;
 	int peeked, err, off = 0;
-	struct iov_iter iter;
 
 	tun_debug(KERN_INFO, tun, "tun_do_read\n");
 
-	if (!len)
-		return ret;
+	if (!iov_iter_count(to))
+		return 0;
 
 	if (tun->dev->reg_state != NETREG_REGISTERED)
 		return -EIO;
@@ -1359,37 +1358,27 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
 				  &peeked, &off, &err);
 	if (!skb)
-		return ret;
+		return 0;
 
-	iov_iter_init(&iter, READ, iv, segs, len);
-	ret = tun_put_user(tun, tfile, skb, &iter);
+	ret = tun_put_user(tun, tfile, skb, to);
 	kfree_skb(skb);
 
 	return ret;
 }
 
-static ssize_t tun_chr_aio_read(struct kiocb *iocb, const struct iovec *iv,
-			    unsigned long count, loff_t pos)
+static ssize_t tun_chr_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct file *file = iocb->ki_filp;
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun = __tun_get(tfile);
-	ssize_t len, ret;
+	ssize_t len = iov_iter_count(to), ret;
 
 	if (!tun)
 		return -EBADFD;
-	len = iov_length(iv, count);
-	if (len < 0) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	ret = tun_do_read(tun, tfile, iv, count, len,
-			  file->f_flags & O_NONBLOCK);
+	ret = tun_do_read(tun, tfile, to, file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len);
 	if (ret > 0)
 		iocb->ki_pos = ret;
-out:
 	tun_put(tun);
 	return ret;
 }
@@ -1471,6 +1460,7 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
 	struct tun_struct *tun = __tun_get(tfile);
+	struct iov_iter to;
 	int ret;
 
 	if (!tun)
@@ -1485,8 +1475,8 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 					 SOL_PACKET, TUN_TX_TIMESTAMP);
 		goto out;
 	}
-	ret = tun_do_read(tun, tfile, m->msg_iov, m->msg_iovlen, total_len,
-			  flags & MSG_DONTWAIT);
+	iov_iter_init(&to, READ, m->msg_iov, m->msg_iovlen, total_len);
+	ret = tun_do_read(tun, tfile, &to, flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
@@ -2242,8 +2232,8 @@ static int tun_chr_show_fdinfo(struct seq_file *m, struct file *f)
 static const struct file_operations tun_fops = {
 	.owner	= THIS_MODULE,
 	.llseek = no_llseek,
-	.read  = do_sync_read,
-	.aio_read  = tun_chr_aio_read,
+	.read  = new_sync_read,
+	.read_iter  = tun_chr_read_iter,
 	.write = do_sync_write,
 	.aio_write = tun_chr_aio_write,
 	.poll	= tun_chr_poll,
-- 
1.7.10.4
