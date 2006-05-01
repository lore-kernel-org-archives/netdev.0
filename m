From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] AIO sendfile() implementation.
Date: Mon, 1 May 2006 20:09:07 +0400
Message-ID: <20060501160907.GA18304@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:21926 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932142AbWEAQJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 12:09:31 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kevent [1] based AIO sendfile() implementation.

Patch can be found in archive [2] and is attached. 
It is called /tmp/aio_sendfile.1 and depends on full kevent patchset
kevent_full.diff.2, which was recenly sent to netdev@ [3].

Patch is fairly trivial - just use file->f_op->sendpage() for page
sending, all asynchronous mechanism lives in page propagation into VFS
cache.

1. kevent system
http://tservice.net.ru/~s0mbre/old/?section=projects&item=kevent

2. kevent archive
http://tservice.net.ru/~s0mbre/archive/kevent/

3. full kevent patchset
http://marc.theaimsgroup.com/?l=linux-netdev&m=114631895701710&w=2

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/kernel/kevent/kevent_aio.c b/kernel/kevent/kevent_aio.c
index f72107a..249fbc2 100644
--- a/kernel/kevent/kevent_aio.c
+++ b/kernel/kevent/kevent_aio.c
@@ -31,6 +31,8 @@
 #include <linux/buffer_head.h>
 #include <linux/kevent.h>
 
+#include <net/sock.h>
+
 #define KEVENT_AIO_DEBUG
 
 #ifdef KEVENT_AIO_DEBUG
@@ -47,7 +49,7 @@ struct kevent_aio_private
 	loff_t			processed;
 	atomic_t		bio_page_num;
 	struct completion	bio_complete;
-	struct file		*file;
+	struct file		*file, *sock;
 	struct work_struct	work;
 };
 
@@ -320,15 +322,15 @@ static int kevent_mpage_readpages(struct
 
 static size_t kevent_aio_vfs_read_actor(struct kevent *k, struct page *kpage, size_t len)
 {
-#if 0
 	struct kevent_aio_private *priv = k->priv;
-	struct kevent *n;
+	size_t ret;
+	
+	ret = priv->sock->f_op->sendpage(priv->sock, kpage, 0, len, &priv->sock->f_pos, 1);
 
-	n = kevent_alloc(GFP_KERNEL);
-	if (!n)
-		return -ENOMEM;
-#endif	
-	return len;
+	dprintk("%s: k=%p, page=%p, len=%zu, ret=%zd.\n", 
+			__func__, k, kpage, len, ret);
+
+	return ret;
 }
 
 static int kevent_aio_vfs_read(struct kevent *k, 
@@ -444,21 +446,28 @@ static void kevent_aio_work(void *data)
 static int kevent_aio_enqueue(struct kevent *k)
 {
 	int err;
-	struct file *file;
+	struct file *file, *sock;
 	struct inode *inode;
 	struct kevent_aio_private *priv;
 	int fd = k->event.id.raw[0];
 	int num = k->event.id.raw[1];
+	int s = k->event.ret_data[0];
 	size_t size;
 
 	err = -ENODEV;
 	file = fget(fd);
 	if (!file)
 		goto err_out_exit;
+	
+	sock = fget(s);
+	if (!sock)
+		goto err_out_fput_file;
 
 	err = -EINVAL;
 	if (!file->f_dentry || !file->f_dentry->d_inode)
 		goto err_out_fput;
+	if (!sock->f_dentry || !sock->f_dentry->d_inode)
+		goto err_out_fput;
 
 	inode = igrab(file->f_dentry->d_inode);
 	if (!inode)
@@ -477,6 +486,7 @@ static int kevent_aio_enqueue(struct kev
 	priv->size = size;
 	priv->offset = 0;
 	priv->file = file;
+	priv->sock = sock;
 	INIT_WORK(&priv->work, kevent_aio_work, k);
 	k->priv = priv;
 
@@ -492,6 +502,8 @@ static int kevent_aio_enqueue(struct kev
 err_out_iput:
 	iput(inode);
 err_out_fput:
+	fput(sock);
+err_out_fput_file:
 	fput(file);
 err_out_exit:
 
@@ -503,6 +515,7 @@ static int kevent_aio_dequeue(struct kev
 	struct kevent_aio_private *priv = k->priv;
 	struct inode *inode = k->st->origin;
 	struct file *file = priv->file;
+	struct file *sock = priv->sock;
 
 	kevent_storage_dequeue(k->st, k);
 	flush_scheduled_work();
@@ -512,6 +525,7 @@ static int kevent_aio_dequeue(struct kev
 	k->priv = NULL;
 	iput(inode);
 	fput(file);
+	fput(sock);
 
 	return 0;
 }
@@ -533,6 +547,9 @@ asmlinkage long sys_aio_sendfile(int ctl
 
 	ukread.id.raw[0] = fd;
 	ukread.id.raw[1] = num;
+	ukread.ret_data[0] = s;
+
+	dprintk("%s: fd=%d, s=%d, num=%d.\n", __func__, fd, s, num);
 
 	file = fget_light(ctl_fd, &fput_needed);
 	if (!file)

-- 
	Evgeniy Polyakov
