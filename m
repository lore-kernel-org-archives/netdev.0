From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V4 4/8]vhost: vhost TX zero-copy support
Date: Wed, 04 May 2011 08:18:04 -0700
Message-ID: <1304522284.7076.12.camel@localhost.localdomain>
References: <1304496684.20660.84.camel@localhost.localdomain>
	 <20110504095650.GA11592@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:51427 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265Ab1EDPTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 11:19:37 -0400
In-Reply-To: <20110504095650.GA11592@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 12:56 +0300, Michael S. Tsirkin wrote:
> On Wed, May 04, 2011 at 01:11:24AM -0700, Shirley Ma wrote:
> > This patch maintains the outstanding userspace buffers in the 
> > sequence it is delivered to vhost. The outstanding userspace
> buffers 
> > will be marked as done once the lower device buffers DMA has
> finished. 
> > This is monitored through last reference of kfree_skb callback. Two
> > buffer index are used for this purpose.
> > 
> > The vhost passes the userspace buffers info to lower device skb 
> > through message control. Since there will be some done DMAs when
> > entering vhost handle_tx. The worse case is all buffers in the vq
> are
> > in pending/done status, so we need to notify guest to release DMA
> done 
> > buffers first before get any new buffers from the vq.
> > 
> > Signed-off-by: Shirley <xma@us.ibm.com>
> 
> Looks good overall. Some nits to iron out below.
> 
> > ---
> > 
> >  drivers/vhost/net.c   |   30 +++++++++++++++++++++++++++-
> >  drivers/vhost/vhost.c |   50
> > ++++++++++++++++++++++++++++++++++++++++++++++++-
> >  drivers/vhost/vhost.h |   10 +++++++++
> >  3 files changed, 87 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 2f7c76a..c403afb 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -32,6 +32,8 @@
> >   * Using this limit prevents one virtqueue from starving others. */
> >  #define VHOST_NET_WEIGHT 0x80000
> >  
> > +#define MAX_ZEROCOPY_PEND 64
> > +
> 
> Pls document what the above is. Also scope with VHOST_

Will do.

> >  enum {
> >       VHOST_NET_VQ_RX = 0,
> >       VHOST_NET_VQ_TX = 1,
> > @@ -129,6 +131,7 @@ static void handle_tx(struct vhost_net *net)
> >       int err, wmem;
> >       size_t hdr_size;
> >       struct socket *sock;
> > +     struct skb_ubuf_info pend;
> >  
> >       /* TODO: check that we are running from vhost_worker? */
> >       sock = rcu_dereference_check(vq->private_data, 1);
> > @@ -151,6 +154,10 @@ static void handle_tx(struct vhost_net *net)
> >       hdr_size = vq->vhost_hlen;
> >  
> >       for (;;) {
> > +             /* Release DMAs done buffers first */
> > +             if (sock_flag(sock->sk, SOCK_ZEROCOPY))
> > +                     vhost_zerocopy_signal_used(vq);
> > +
> >               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> >                                        ARRAY_SIZE(vq->iov),
> >                                        &out, &in,
> > @@ -166,6 +173,12 @@ static void handle_tx(struct vhost_net *net)
> >                               set_bit(SOCK_ASYNC_NOSPACE,
> &sock->flags);
> >                               break;
> >                       }
> > +                     /* If more outstanding DMAs, queue the work */
> > +                     if (sock_flag(sock->sk, SOCK_ZEROCOPY) &&
> > +                         (atomic_read(&vq->refcnt) >
> MAX_ZEROCOPY_PEND)) {
> > +                             vhost_poll_queue(&vq->poll);
> 
> Well, this just keeps polling, doesn't it?
> If you want to wait until # of DMAs is below MAX_ZEROCOPY_PEND,
> you'll need to do the queueing from some callback.
> 
> Something like this: when refcnt is above 2 * MAX_ZEROCOPY_PEND,
> stop submitting and wait until some are freed.
Will try this today

> BTW, can the socket poll wakeup do the job?
Not sure, will try this today.

> > +                             break;
> > +                     }
> >                       if (unlikely(vhost_enable_notify(vq))) {
> >                               vhost_disable_notify(vq);
> >                               continue;
> > @@ -188,17 +201,30 @@ static void handle_tx(struct vhost_net *net)
> >                              iov_length(vq->hdr, s), hdr_size);
> >                       break;
> >               }
> > +             /* use msg_control to pass vhost zerocopy ubuf info to
> skb */
> > +             if (sock_flag(sock->sk, SOCK_ZEROCOPY)) {
> > +                     pend.callback = vhost_zerocopy_callback;
> > +                     pend.arg = vq;
> > +                     pend.desc = vq->upend_idx;
> > +                     msg.msg_control = &pend;
> > +                     msg.msg_controllen = sizeof(pend);
> > +                     vq->heads[vq->upend_idx].id = head;
> > +                     vq->upend_idx = (vq->upend_idx + 1) %
> UIO_MAXIOV;
> > +                     atomic_inc(&vq->refcnt);
> > +             }
> >               /* TODO: Check specific error and bomb out unless
> ENOBUFS? */
> >               err = sock->ops->sendmsg(NULL, sock, &msg, len);
> >               if (unlikely(err < 0)) {
> > -                     vhost_discard_vq_desc(vq, 1);
> > +                     if (!sock_flag(sock->sk, SOCK_ZEROCOPY))
> > +                             vhost_discard_vq_desc(vq, 1);
> >                       tx_poll_start(net, sock);
> >                       break;
> >               }
> >               if (err != len)
> >                       pr_debug("Truncated TX packet: "
> >                                " len %d != %zd\n", err, len);
> > -             vhost_add_used_and_signal(&net->dev, vq, head, 0);
> > +             if (!sock_flag(sock->sk, SOCK_ZEROCOPY))
> > +                     vhost_add_used_and_signal(&net->dev, vq, head,
> 0);
> >               total_len += len;
> >               if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> >                       vhost_poll_queue(&vq->poll);
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index 2ab2912..3048953 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -174,6 +174,9 @@ static void vhost_vq_reset(struct vhost_dev
> *dev,
> >       vq->call_ctx = NULL;
> >       vq->call = NULL;
> >       vq->log_ctx = NULL;
> > +     vq->upend_idx = 0;
> > +     vq->done_idx = 0;
> > +     atomic_set(&vq->refcnt, 0);
> >  }
> >  
> >  static int vhost_worker(void *data)
> > @@ -230,7 +233,7 @@ static long vhost_dev_alloc_iovecs(struct
> vhost_dev
> > *dev)
> >                                              UIO_MAXIOV,
> GFP_KERNEL);
> >               dev->vqs[i].log = kmalloc(sizeof *dev->vqs[i].log *
> UIO_MAXIOV,
> >                                         GFP_KERNEL);
> > -             dev->vqs[i].heads = kmalloc(sizeof *dev->vqs[i].heads
> *
> > +             dev->vqs[i].heads = kzalloc(sizeof *dev->vqs[i].heads
> *
> >                                           UIO_MAXIOV, GFP_KERNEL);
> 
> Do we really need to zero it all out? We generally tried to only
> init what is necessary ...

Don't need to.

> >               if (!dev->vqs[i].indirect || !dev->vqs[i].log ||
> > @@ -385,10 +388,41 @@ long vhost_dev_reset_owner(struct vhost_dev
> *dev)
> >       return 0;
> >  }
> >  
> 
> Pls document what the below does.

Ok.

> > +void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
> > +{
> > +     int i, j = 0;
> > +
> > +     i = vq->done_idx;
> > +     while (i != vq->upend_idx) {
> > +             /* len = 1 means DMA done */
> 
> Hmm. Guests aren't likely to use len 1 in practice,
> but I think it's better to support this.

Will check guest.

> I'd suggest sticking extra stuff in id, IIRC only values
> < vq size are legal there, anything else we can use.
> Also, pls add some defines for special values, better than
> a comment:
>         if (len == VHOST_DMA_DONE_LEN)
OK.

> > +             if (vq->heads[i].len == 1) {
> > +                     /* reset len = 0 */
> > +                     vq->heads[i].len = 0;
> > +                     i = (i + 1) % UIO_MAXIOV;
> > +                     ++j;
> > +             } else
> > +                     break;
> > +     }
> > +     if (j) {
> 
> Pls add some comments to explain the logic here.
OK.

> > +             if (i > vq->done_idx)
> > +                     vhost_add_used_n(vq, &vq->heads[vq->done_idx],
> j);
> > +             else {
> > +                     vhost_add_used_n(vq, &vq->heads[vq->done_idx],
> > +                                      UIO_MAXIOV - vq->done_idx);
> > +                     vhost_add_used_n(vq, vq->heads, i);
> > +             }
> > +             vq->done_idx = i;
> > +             vhost_signal(vq->dev, vq);
> > +             atomic_sub(j, &vq->refcnt);
> > +     }
> > +}
> > +
> >  /* Caller should have device mutex */
> >  void vhost_dev_cleanup(struct vhost_dev *dev)
> >  {
> >       int i;
> > +     unsigned long begin = jiffies;
> > +
> >  
> >       for (i = 0; i < dev->nvqs; ++i) {
> >               if (dev->vqs[i].kick && dev->vqs[i].handle_kick) {
> > @@ -405,6 +439,11 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
> >                       eventfd_ctx_put(dev->vqs[i].call_ctx);
> >               if (dev->vqs[i].call)
> >                       fput(dev->vqs[i].call);
> > +             /* wait for all lower device DMAs done, then notify
> guest */
> > +             while (atomic_read(&dev->vqs[i].refcnt)) {
> > +                     if (time_after(jiffies, begin + 5 * HZ))
> 
> Hmm, does this actually busy-wait?  Let's at least sleep here.
> Or maybe some wakeup scheme can be cooked up.
> For example, have a kref with release function that signals some
> completion.

Will do.

> >
> +                             vhost_zerocopy_signal_used(&dev->vqs[i]);
> > +             }
> >               vhost_vq_reset(dev, dev->vqs + i);
> >       }
> >       vhost_dev_free_iovecs(dev);
> > @@ -1416,3 +1455,12 @@ void vhost_disable_notify(struct
> vhost_virtqueue
> > *vq)
> >               vq_err(vq, "Failed to enable notification at %p: %d
> \n",
> >                      &vq->used->flags, r);
> >  }
> > +
> > +void vhost_zerocopy_callback(struct sk_buff *skb)
> > +{
> > +     int idx = skb_shinfo(skb)->ubuf.desc;
> > +     struct vhost_virtqueue *vq = skb_shinfo(skb)->ubuf.arg;
> > +
> > +     /* set len = 1 to mark this desc buffers done DMA */
> > +     vq->heads[idx].len = 1;
> > +}
> 
> So any kind of callback like that, that goes into the skb,
> will be racy wrt module unloading because module can go away
> after you mark dma done and before this function returns.
> Solution is to have a core function that does the
> final signalling (e.g. sock_wfree is in core).
> Would be nice to fix, even though this race is
> completely theoretical, I don't believe it will
> trigger in practice.

I run lots of stress tests, and never hit this. 

But I can try to fix it.

> 
> > diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> > index b3363ae..ec032a0 100644
> > --- a/drivers/vhost/vhost.h
> > +++ b/drivers/vhost/vhost.h
> > @@ -108,6 +108,14 @@ struct vhost_virtqueue {
> >       /* Log write descriptors */
> >       void __user *log_base;
> >       struct vhost_log *log;
> > +     /* vhost zerocopy support */
> > +     atomic_t refcnt; /* num of outstanding zerocopy DMAs */
> > +     /* index of zerocopy pending DMA buffers */
> > +     int upend_idx;
> > +     /* index of zerocopy done DMA buffers, but not notify guest
> yet */
> > +     int done_idx;
> 
> Pls try to find more descriptive names for the above,
> and clarify the comments: I could not tell what do the
> comments mean.
> 
> upend_idx seems to be a copy of avail idx?
> done_idx is ... ?

OK.

> > +     /* notify vhost zerocopy DMA buffers has done in lower device
> */
> 
> Do you mean 'notify vhost that zerocopy DMA is complete'?
> 
> > +     void (*callback)(struct sk_buff *);
> 
> Is this actually used?
> If yes rename it zerocopy_dma_done or something like this?

You might be right, I used to use it, but the current code level doesn't
need it any more.

> >  };
> >  
> >  struct vhost_dev {
> > @@ -154,6 +162,8 @@ bool vhost_enable_notify(struct vhost_virtqueue
> *);
> >  
> >  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log
> *log,
> >                   unsigned int log_num, u64 len);
> > +void vhost_zerocopy_callback(struct sk_buff *skb);
> > +void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq);
> >  
> >  #define vq_err(vq, fmt, ...) do {
> \
> >               pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
> > 

