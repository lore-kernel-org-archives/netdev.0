From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: ipv6: tunnel: hang when destroying ipv6 tunnel
Date: Thu, 5 Apr 2012 23:29:04 +0900
Message-ID: <201204052329.EBH52139.FFOLQMOJSVHOFt@I-love.SAKURA.ne.jp>
References: <20120331213423.GA21219@redhat.com>
	<CA+1xoqcAXyh306=2=QKWyM3BE44=MT+nsuRQn5YLOLgbtZqicA@mail.gmail.com>
	<CA+1xoqe1Wc_uifrKsko6hu+py9Ahz3Q0p1tRxup09jmh2NZ1rw@mail.gmail.com>
	<201204011221.GAG51016.JQFSFFOtLOMVHO@I-love.SAKURA.ne.jp>
	<CA+1xoqe+T=iUtUeFdeqmRvMZ7TMCgkLs_1QYv-4YNtn-jCoMCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oleg@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: levinsasha928@gmail.com, garlick@llnl.gov, ericvh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+1xoqe+T=iUtUeFdeqmRvMZ7TMCgkLs_1QYv-4YNtn-jCoMCQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Tetsuo Handa wrote:
> > Maybe you can get more useful information with below untested printk() patch.
> > 
> > diff --git a/net/9p/client.c b/net/9p/client.c
> > index b23a17c..2dd447a 100644
> > --- a/net/9p/client.c
> > +++ b/net/9p/client.c
> > @@ -734,7 +734,9 @@ p9_client_rpc(struct p9_client *c, int8_t type, const char *fmt, ...)
> >  	} else
> >  		sigpending = 0;
> >  
> > +	printk("%u:Calling %pS\n", current->pid, c->trans_mod->request);
> >  	err = c->trans_mod->request(c, req);
> > +	printk("%u:%pS = %d\n", current->pid, c->trans_mod->request, err);
> >  	if (err < 0) {
> >  		if (err != -ERESTARTSYS && err != -EFAULT)
> >  			c->status = Disconnected;
> > @@ -742,8 +744,10 @@ p9_client_rpc(struct p9_client *c, int8_t type, const char *fmt, ...)
> >  	}
> >  again:
> >  	/* Wait for the response */
> > +	printk("%u:req->status = %u\n", current->pid, req->status);
> >  	err = wait_event_interruptible(*req->wq,
> >  				       req->status >= REQ_STATUS_RCVD);
> > +	printk("%u:wait = %d\n", current->pid, err);
> >  
> >  	if ((err == -ERESTARTSYS) && (c->status == Connected)
> >  				  && (type == P9_TFLUSH)) {
> > 

Sasha Levin wrote:
> Heya,
> 
> The output from the printk confirmed that there are several threads
> waiting for RPC to complete, with the last two having and odd 'wait'
> result. This is just before the hang:
> 
> [  809.165663] 19964:Calling p9_virtio_request+0x0/0x200
> [  809.166951] 19964:p9_virtio_request+0x0/0x200 = 0
> [  809.167878] 19964:req->status = 3
> [  809.803535] 19957:Calling p9_virtio_request+0x0/0x200
> [  809.804506] 19957:p9_virtio_request+0x0/0x200 = 0
> [  809.805332] 19957:req->status = 3
> [  809.868591] 19955:Calling p9_virtio_request+0x0/0x200
> [  809.869493] 19955:p9_virtio_request+0x0/0x200 = 0
> [  809.870331] 19955:req->status = 3
> [  811.364554] 19985:Calling p9_virtio_request+0x0/0x200
> [  811.365498] 19985:p9_virtio_request+0x0/0x200 = 0
> [  811.366386] 19985:req->status = 3
> [  811.458600] 19999:wait = -512
> [  811.459171] 19999:Calling p9_virtio_request+0x0/0x200
> [  811.459992] 19999:p9_virtio_request+0x0/0x200 = 0
> [  811.460822] 19999:req->status = 3
> [  811.472175] 19994:wait = -512
> [  811.472943] 19994:Calling p9_virtio_request+0x0/0x200
> [  811.474195] 19994:p9_virtio_request+0x0/0x200 = 0
> [  811.474955] 19994:req->status = 3
> [... Hang 120 sec later here]
> 

Good. -512 is -ERESTARTSYS, and this hang occurs after -ERESTARTSYS is
returned. It indicates that c->trans_mod->request() is interrupted by signal.
Since c->trans_mod->request is pointing at p9_virtio_request, the location
returning that error would be

254 static int
255 p9_virtio_request(struct p9_client *client, struct p9_req_t *req)
256 {
257         int err;
258         int in, out;
259         unsigned long flags;
260         struct virtio_chan *chan = client->trans;
261 
262         p9_debug(P9_DEBUG_TRANS, "9p debug: virtio request\n");
263 
264         req->status = REQ_STATUS_SENT;
265 req_retry:
266         spin_lock_irqsave(&chan->lock, flags);
267 
268         /* Handle out VirtIO ring buffers */
269         out = pack_sg_list(chan->sg, 0,
270                            VIRTQUEUE_NUM, req->tc->sdata, req->tc->size);
271 
272         in = pack_sg_list(chan->sg, out,
273                           VIRTQUEUE_NUM, req->rc->sdata, req->rc->capacity);
274 
275         err = virtqueue_add_buf(chan->vq, chan->sg, out, in, req->tc,
276                                 GFP_ATOMIC);
277         if (err < 0) {
278                 if (err == -ENOSPC) {
279                         chan->ring_bufs_avail = 0;
280                         spin_unlock_irqrestore(&chan->lock, flags);
281                         err = wait_event_interruptible(*chan->vc_wq,
282                                                         chan->ring_bufs_avail);

   here.

283                         if (err  == -ERESTARTSYS)
284                                 return err;
285 
286                         p9_debug(P9_DEBUG_TRANS, "Retry virtio request\n");
287                         goto req_retry;
288                 } else {
289                         spin_unlock_irqrestore(&chan->lock, flags);
290                         p9_debug(P9_DEBUG_TRANS,
291                                  "virtio rpc add_buf returned failure\n");
292                         return -EIO;
293                 }
294         }
295         virtqueue_kick(chan->vq);
296         spin_unlock_irqrestore(&chan->lock, flags);
297 
298         p9_debug(P9_DEBUG_TRANS, "virtio request kicked\n");
299         return 0;
300 }

Comparing 3.3.1 and linux-next in my environment, there are several changes.

# diff -ur linux-3.3.1/drivers/virtio/ linux-next/drivers/virtio/ | diffstat
 config.c         |    1
 virtio_balloon.c |   14 ----------
 virtio_pci.c     |   74 +++++--------------------------------------------------
 3 files changed, 8 insertions(+), 81 deletions(-)
# diff -urp linux-3.3.1/fs/9p/ linux-next/fs/9p/ | diffstat
 v9fs.c      |   16 ++++++++--------
 vfs_super.c |    5 ++---
 2 files changed, 10 insertions(+), 11 deletions(-)
# diff -ur linux-3.3.1/net/9p/ linux-next/net/9p/ | diffstat
 client.c |   26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

Most suspicious change is net/9p/client.c because it is changing handling of
ERESTARTSYS case.

--- linux-3.3.1/net/9p/client.c
+++ linux-next/net/9p/client.c
@@ -740,10 +740,18 @@
                        c->status = Disconnected;
                goto reterr;
        }
+again:
        /* Wait for the response */
        err = wait_event_interruptible(*req->wq,
                                       req->status >= REQ_STATUS_RCVD);

+       if ((err == -ERESTARTSYS) && (c->status == Connected)
+                                 && (type == P9_TFLUSH)) {
+               sigpending = 1;
+               clear_thread_flag(TIF_SIGPENDING);
+               goto again;
+       }
+
        if (req->status == REQ_STATUS_ERROR) {
                p9_debug(P9_DEBUG_ERROR, "req_status error %d\n", req->t_err);
                err = req->t_err;
@@ -1420,6 +1428,7 @@
        int err;
        struct p9_client *clnt;
        struct p9_req_t *req;
+       int retries = 0;

        if (!fid) {
                pr_warn("%s (%d): Trying to clunk with NULL fid\n",
@@ -1428,7 +1437,9 @@
                return 0;
        }

-       p9_debug(P9_DEBUG_9P, ">>> TCLUNK fid %d\n", fid->fid);
+again:
+       p9_debug(P9_DEBUG_9P, ">>> TCLUNK fid %d (try %d)\n", fid->fid,
+                                                               retries);
        err = 0;
        clnt = fid->clnt;

@@ -1444,8 +1455,14 @@
 error:
        /*
         * Fid is not valid even after a failed clunk
+        * If interrupted, retry once then give up and
+        * leak fid until umount.
         */
-       p9_fid_destroy(fid);
+       if (err == -ERESTARTSYS) {
+               if (retries++ == 0)
+                       goto again;
+       } else
+               p9_fid_destroy(fid);
        return err;
 }
 EXPORT_SYMBOL(p9_client_clunk);
@@ -1470,7 +1487,10 @@

        p9_free_req(clnt, req);
 error:
-       p9_fid_destroy(fid);
+       if (err == -ERESTARTSYS)
+               p9_client_clunk(fid);
+       else
+               p9_fid_destroy(fid);
        return err;
 }
 EXPORT_SYMBOL(p9_client_remove);

Maybe commit a314f274 "net/9p: don't allow Tflush to be interrupted" or nearby.



By the way, have you already tried 3.4-rc1?
In my environment, there is no difference between linux-next and 3.4-rc1.

# diff -ur linux-3.4.0-rc1/net/9p/ linux-next/net/9p/
# diff -ur linux-3.4.0-rc1/drivers/virtio/ linux-next/drivers/virtio/
# diff -ur linux-3.4.0-rc1/fs/9p/ linux-next/fs/9p/
