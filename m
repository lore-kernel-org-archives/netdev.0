From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: /async open+send/ Re: [take35 10/10] kevent: Kevent based AIO (aio_sendfile()/aio_sendfile_path()).
Date: Fri, 2 Feb 2007 14:58:35 +0300
Message-ID: <20070202115835.GA4833@2ka.mipt.ru>
References: <11703247541476@2ka.mipt.ru> <11703247543653@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11703247543653@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 01, 2007 at 01:12:34PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> 
> Kevent based AIO (aio_sendfile()/aio_sendfile_path()).
> 
> aio_sendfile()/aio_sendfile_path() contains of two major parts: AIO 
> state machine and page processing code. 
> The former is just a small subsystem, which allows to queue callback 
> for theirs invocation in process' context on behalf of pool of kernel 
> threads. It allows to queue caches of callbacks to the local thread 
> or to any other specified. Each cache of callbacks is processed until 
> there are callbacks in it, callbacks can requeue themselfs into the 
> same cache.

Below patch, casted by discussion in lkml@ about micro-thread AIO.
Async sending and file closing are implemented already, I added 
kaio_open() into state machine as example of what it can do, it was sync
before. It is an example only - kevent was asked to have feature-freeze
time.

Btw, could you please Cc: linux-fsdevel@ on AIO patchsets too.
Thanks.

diff --git a/kernel/kevent/kevent_aio.c b/kernel/kevent/kevent_aio.c
index 9bb5e99..803e9ff 100644
--- a/kernel/kevent/kevent_aio.c
+++ b/kernel/kevent/kevent_aio.c
@@ -759,16 +759,15 @@ err_out_exit:
 	return err;
 }
 
-asmlinkage long sys_aio_sendfile_path(int kevent_fd, int sock_fd, 
-		void __user *header, size_t header_size, 
-		char __user *filename, off_t offset, size_t count)
+static int kaio_open(struct kaio_req *req, int direct)
 {
+	struct kaio_private *priv = req->priv;
+	char *filename = priv->sptr;
 	char *tmp = getname(filename);
 	int fd = PTR_ERR(tmp);
 	int flags = O_RDONLY, err;
 	struct nameidata nd;
 	struct file *file;
-	struct kaio_req *req;
 
 	if (force_o_largefile())
 		flags = O_LARGEFILE;
@@ -795,25 +794,12 @@ asmlinkage long sys_aio_sendfile_path(int kevent_fd, int sock_fd,
 	if (!file)
 		goto err_out_fdput;
 
-	/* One reference will be released in sys_close(), 
-	 * second one through req->destructor() 
-	 */
-	atomic_inc(&file->f_count);
-
-	req = kaio_sendfile(kevent_fd, sock_fd, header, header_size, 
-			file, offset, count);
-	if (!req) {
-		err = -EINVAL;
-		goto err_out_fput;
-	}
-
 	fd_install(fd, file);
 
-	return fd;
+	priv->sptr = file;
+
+	return 0;
 
-err_out_fput:
-	fput(file);
-	fput(file);
 err_out_fdput:
 	put_unused_fd(fd);
 err_out_put_name:
@@ -822,6 +808,67 @@ err_out_exit:
 	return err;
 }
 
+asmlinkage long sys_aio_sendfile_path(int kevent_fd, int sock_fd, 
+		void __user *header, size_t header_size, 
+		char __user *filename, off_t offset, size_t count)
+{
+	struct kaio_req *req;
+	struct socket *sock;
+	struct kaio_private *priv;
+	int err;
+
+	sock = sockfd_lookup(sock_fd, &err);
+	if (!sock)
+		goto err_out_exit;
+
+	priv = kmem_cache_alloc(kaio_priv_cache, GFP_KERNEL);
+	if (!priv)
+		goto err_out_sput;
+
+	priv->sptr = filename;
+	priv->dptr = sock;
+	priv->offset = offset;
+	priv->count = count;
+	priv->processed = offset;
+	priv->limit = 128;
+	priv->header = header;
+	priv->header_size = header_size;
+
+	req = kaio_add_call(NULL, &kaio_open, -1, GFP_KERNEL);
+	if (!req)
+		goto err_out_free;
+	
+	kaio_append_call(req, &kaio_read_send_pages);
+
+	req->destructor = kaio_destructor;
+	req->priv = priv;
+
+	err = kaio_add_kevent(kevent_fd, req);
+
+	dprintk("%s: req: %p, priv: %p, call: %p [%p], offset: %Lu, processed: %Lu, count: %Lu, err: %d.\n",
+			__func__, req, priv, &kaio_read_send_pages, 
+			kaio_read_send_pages, priv->offset, priv->processed, priv->count, err);
+
+	if (err)
+		goto err_out_remove;
+
+	kaio_schedule_req(req);
+
+	return (long)req;
+
+err_out_remove:
+	/* It is safe to just free the object since it is guaranteed that it was not
+	 * queued for processing.
+	 */
+	kmem_cache_free(kaio_req_cache, req);
+err_out_free:
+	kmem_cache_free(kaio_priv_cache, priv);
+err_out_sput:
+	sockfd_put(sock);
+err_out_exit:
+	return -1;
+}
+
 static int kevent_aio_callback(struct kevent *k)
 {
 	struct kaio_req *req = k->event.ptr;


-- 
	Evgeniy Polyakov
