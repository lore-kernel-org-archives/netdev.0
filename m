From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Wed, 18 May 2011 11:32:43 +0300
Message-ID: <20110518083243.GF7589@redhat.com>
References: <1305579414.3456.49.camel@localhost.localdomain>
 <20110516212401.GF18148@redhat.com>
 <1305606683.10756.3.camel@localhost.localdomain>
 <20110517055503.GA26989@redhat.com>
 <1305645734.10756.14.camel@localhost.localdomain>
 <20110517152840.GA2389@redhat.com>
 <1305646444.10756.16.camel@localhost.localdomain>
 <1305665419.10756.33.camel@localhost.localdomain>
 <20110517212827.GC7589@redhat.com>
 <1305695674.10756.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305695674.10756.93.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2011 at 10:14:34PM -0700, Shirley Ma wrote:
> On Wed, 2011-05-18 at 00:28 +0300, Michael S. Tsirkin wrote:
> > On Tue, May 17, 2011 at 01:50:19PM -0700, Shirley Ma wrote:
> > > Resubmit the patch with most update. This patch passed some
> > > live-migration test against RHEL6.2. I will run more stress test w/i
> > > live migration.
> > > 
> > > Signed-off-by: Shirley Ma <xma@us.ibm.com>
> > 
> > Cool. cleanup path needs a fix - are you use you can
> > not use kobj or some other existing refcounting?
> I will look at this.
> 
> > Is perf regressiion caused by tx ring overrun gone now?
> Nope.
> 
> > I added some comments about how we might be aqble
> > to complete requests out of order but it's not a must.
> Ok.
> 
> > > ---
> > > 
> > >  drivers/vhost/net.c   |   37 +++++++++++++++++++++++++++++++-
> > >  drivers/vhost/vhost.c |   55
> > ++++++++++++++++++++++++++++++++++++++++++++++++-
> > >  drivers/vhost/vhost.h |   12 ++++++++++
> > >  3 files changed, 101 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > > index 2f7c76a..6bd6e28 100644
> > > --- a/drivers/vhost/net.c
> > > +++ b/drivers/vhost/net.c
> > > @@ -32,6 +32,9 @@
> > >   * Using this limit prevents one virtqueue from starving others. */
> > >  #define VHOST_NET_WEIGHT 0x80000
> > >  
> > > +/* MAX number of TX used buffers for outstanding zerocopy */
> > > +#define VHOST_MAX_ZEROCOPY_PEND 128 
> > > +
> > >  enum {
> > >       VHOST_NET_VQ_RX = 0,
> > >       VHOST_NET_VQ_TX = 1,
> > > @@ -129,6 +132,7 @@ static void handle_tx(struct vhost_net *net)
> > >       int err, wmem;
> > >       size_t hdr_size;
> > >       struct socket *sock;
> > > +     struct skb_ubuf_info pend;
> > >  
> > >       /* TODO: check that we are running from vhost_worker? */
> > >       sock = rcu_dereference_check(vq->private_data, 1);
> > > @@ -151,6 +155,10 @@ static void handle_tx(struct vhost_net *net)
> > >       hdr_size = vq->vhost_hlen;
> > >  
> > >       for (;;) {
> > > +             /* Release DMAs done buffers first */
> > > +             if (atomic_read(&vq->refcnt) >
> > VHOST_MAX_ZEROCOPY_PEND)
> > > +                     vhost_zerocopy_signal_used(vq, false);
> > > +
> > >               head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
> > >                                        ARRAY_SIZE(vq->iov),
> > >                                        &out, &in,
> > > @@ -166,6 +174,13 @@ static void handle_tx(struct vhost_net *net)
> > >                               set_bit(SOCK_ASYNC_NOSPACE,
> > &sock->flags);
> > >                               break;
> > >                       }
> > > +                     /* If more outstanding DMAs, queue the work */
> > > +                     if (sock_flag(sock->sk, SOCK_ZEROCOPY) &&
> > > +                         (atomic_read(&vq->refcnt) >
> > VHOST_MAX_ZEROCOPY_PEND)) {
> > > +                             tx_poll_start(net, sock);
> > > +                             set_bit(SOCK_ASYNC_NOSPACE,
> > &sock->flags);
> > > +                             break;
> > > +                     }
> > >                       if (unlikely(vhost_enable_notify(vq))) {
> > >                               vhost_disable_notify(vq);
> > >                               continue;
> > > @@ -188,17 +203,35 @@ static void handle_tx(struct vhost_net *net)
> > >                              iov_length(vq->hdr, s), hdr_size);
> > >                       break;
> > >               }
> > > +             /* use msg_control to pass vhost zerocopy ubuf info to
> > skb */
> > > +             if (sock_flag(sock->sk, SOCK_ZEROCOPY)) {
> > > +                     vq->heads[vq->upend_idx].id = head;
> > > +                     if (len <= 128)
> > 
> > I thought we have a constant for that?
> 
> Yes, fixed it already. I might change it to PAGE_SIZE for now since the
> small message sizes regression issue.
> 
> > > +                             vq->heads[vq->upend_idx].len =
> > VHOST_DMA_DONE_LEN;
> > > +                     else {
> > > +                             vq->heads[vq->upend_idx].len = len;
> > > +                             pend.callback =
> > vhost_zerocopy_callback;
> > > +                             pend.arg = vq;
> > > +                             pend.desc = vq->upend_idx;
> > > +                             msg.msg_control = &pend;
> > > +                             msg.msg_controllen = sizeof(pend);
> > > +                     }
> > > +                     atomic_inc(&vq->refcnt);
> > > +                     vq->upend_idx = (vq->upend_idx + 1) %
> > UIO_MAXIOV;
> > 
> > Ok, so we deal with a cyclic ring apparently? What guarantees we don't
> > overrun it?
> 
> VHOST_MAX_PEND (which is 128) should prevent it from overrun normally.
> In the case of none DMAs can be done, the maximum entries are the ring
> size, which is much smaller or equal to UIO_MAXIOV for current
> implementation. 
> 
> Maybe I should add some condition check if it is overrun then exits?

If this can't happen, maybe add a comment why. A check + WARN_ON
can't hurt either.

> > 
> > > +             }
> > >               /* TODO: Check specific error and bomb out unless
> > ENOBUFS? */
> > >               err = sock->ops->sendmsg(NULL, sock, &msg, len);
> > >               if (unlikely(err < 0)) {
> > > -                     vhost_discard_vq_desc(vq, 1);
> > > +                     if (!sock_flag(sock->sk, SOCK_ZEROCOPY))
> > > +                             vhost_discard_vq_desc(vq, 1);
> > 
> > How are errors handled with zerocopy?
> 
> I thought about it before: if error after macvtap skb is allocated, then
> that skb has a callback which will set DMA done for add_used, if the
> error before macvtap skb is allocated, then it can reverse as copy case.
> To avoid the complexity check, I decided to not handle it.

I think we need to handle it, errors do happen.
macvtap should either don't invoke callback on error or return success.
Then it's simple.

> > 
> > >                       tx_poll_start(net, sock);
> > >                       break;
> > >               }
> > >               if (err != len)
> > >                       pr_debug("Truncated TX packet: "
> > >                                " len %d != %zd\n", err, len);
> > > -             vhost_add_used_and_signal(&net->dev, vq, head, 0);
> > > +             if (!sock_flag(sock->sk, SOCK_ZEROCOPY))
> > > +                     vhost_add_used_and_signal(&net->dev, vq, head,
> > 0);
> > >               total_len += len;
> > >               if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
> > >                       vhost_poll_queue(&vq->poll);
> > > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > > index 2ab2912..ce799d6 100644
> > > --- a/drivers/vhost/vhost.c
> > > +++ b/drivers/vhost/vhost.c
> > > @@ -174,6 +174,9 @@ static void vhost_vq_reset(struct vhost_dev
> > *dev,
> > >       vq->call_ctx = NULL;
> > >       vq->call = NULL;
> > >       vq->log_ctx = NULL;
> > > +     vq->upend_idx = 0;
> > > +     vq->done_idx = 0;
> > > +     atomic_set(&vq->refcnt, 0);
> > >  }
> > >  
> > >  static int vhost_worker(void *data)
> > > @@ -230,7 +233,7 @@ static long vhost_dev_alloc_iovecs(struct
> > vhost_dev *dev)
> > >                                              UIO_MAXIOV,
> > GFP_KERNEL);
> > >               dev->vqs[i].log = kmalloc(sizeof *dev->vqs[i].log *
> > UIO_MAXIOV,
> > >                                         GFP_KERNEL);
> > > -             dev->vqs[i].heads = kmalloc(sizeof *dev->vqs[i].heads
> > *
> > > +             dev->vqs[i].heads = kzalloc(sizeof *dev->vqs[i].heads
> > *
> > >                                           UIO_MAXIOV, GFP_KERNEL);
> > 
> > Which fields need to be initialized actually?
> 
> Nope, already fixed it with kmalloc.
> 
> > >  
> > >               if (!dev->vqs[i].indirect || !dev->vqs[i].log ||
> > > @@ -385,6 +388,38 @@ long vhost_dev_reset_owner(struct vhost_dev
> > *dev)
> > >       return 0;
> > >  }
> > >  
> > > +/* 
> > > +     comments
> > > +*/
> > 
> > Hmm.
> 
> Fixed it in previous patch already.
> 
> > > +void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq, bool
> > shutdown)
> > > +{
> > > +     int i, j = 0;
> > > +
> > > +     i = vq->done_idx;
> > > +     while (i != vq->upend_idx) {
> > 
> > A for loop might be clearer.
> Ok.
> 
> > > +             if ((vq->heads[i].len == VHOST_DMA_DONE_LEN) ||
> > shutdown) {
> > 
> > On shutdown, we signal all buffers used to the guest?
> > Why?
> 
> We signal all outstand DMAs in the case of driver has some DMA issue to
> prevent us from shutting down. I am afraid vhost cleanup could wait
> forever.

Yes but then
1. guest can reuse the buffers for something else, before device reads them
2. vhost-net module can go away
etc

IMO that this happens in finite time is one of the things driver should
guarantee when it sets the zcopy flags.

BTW we must flush these on memory table change too, right?

> > > +                     /* reset len = 0 */
> > 
> > comment not very helpful.
> > Could you explain what this does instead?
> > Or better use some constant instead of 0 ...
> 
> Fixed it already.
> 
> > > +                     vq->heads[i].len = 0;
> > > +                     i = (i + 1) % UIO_MAXIOV;
> > > +                     ++j;
> > > +             } else
> > > +                     break;
> > 
> > Hmm so if the 1st entry does not complete, you do not signal anything?
> 
> No used buffers to guest, should we signal still?

This is just myself noting that we still force used entries
to be in order. It's ok from correctness pov but likely
is at least part of the reason you still see
TX ring overruns.

> > > +     }
> > 
> > Looking at this loop, done idx is the consumer and used idx
> > is the producer, right?
> 
> Yes.
> 
> > > +     if (j) {
> > > +             /* comments */
> > 
> > Yes?
> > 
> > > +             if (i > vq->done_idx)
> > > +                     vhost_add_used_n(vq, &vq->heads[vq->done_idx],
> > j);
> > > +             else {
> > > +                     vhost_add_used_n(vq, &vq->heads[vq->done_idx],
> > > +                                      UIO_MAXIOV - vq->done_idx);
> > > +                     vhost_add_used_n(vq, vq->heads, i);
> > > +             }
> > > +             vq->done_idx = i;
> > > +             vhost_signal(vq->dev, vq);
> > > +             atomic_sub(j, &vq->refcnt);
> > 
> > Code will likely be simpler if you call vhost_add_used once for
> > each head in the first loop. Possibly add_used_signal might be
> > a good idea too.
> 
> Ok.
> 
> > > +     }
> > > +}
> > > +
> > >  /* Caller should have device mutex */
> > >  void vhost_dev_cleanup(struct vhost_dev *dev)
> > >  {
> > > @@ -395,6 +430,11 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
> > >                       vhost_poll_stop(&dev->vqs[i].poll);
> > >                       vhost_poll_flush(&dev->vqs[i].poll);
> > >               }
> > > +             /* wait for all lower device DMAs done, then notify
> > guest */
> > > +             if (atomic_read(&dev->vqs[i].refcnt)) {
> > > +                     msleep(1000);
> > > +                     vhost_zerocopy_signal_used(&dev->vqs[i],
> > true);
> > > +             }
> > 
> > This needs to be fixed somehow. Use a completion object and wait
> > on it?
> 
> Worried about what if the driver has some DMAs issue, which would
> prevent vhost from shutting down.

This needs to be fixed in the driver then.

> > >               if (dev->vqs[i].error_ctx)
> > >                       eventfd_ctx_put(dev->vqs[i].error_ctx);
> > >               if (dev->vqs[i].error)
> > > @@ -603,6 +643,10 @@ static long vhost_set_vring(struct vhost_dev
> > *d, int ioctl, void __user *argp)
> > >  
> > >       mutex_lock(&vq->mutex);
> > >  
> > > +     /* force all lower device DMAs done */
> > > +     if (atomic_read(&vq->refcnt)) 
> > > +             vhost_zerocopy_signal_used(vq, true);
> > > +
> > >       switch (ioctl) {
> > >       case VHOST_SET_VRING_NUM:
> > >               /* Resizing ring with an active backend?
> > > @@ -1416,3 +1460,12 @@ void vhost_disable_notify(struct
> > vhost_virtqueue *vq)
> > >               vq_err(vq, "Failed to enable notification at %p: %d
> > \n",
> > >                      &vq->used->flags, r);
> > >  }
> > > +
> > > +void vhost_zerocopy_callback(struct sk_buff *skb)
> > > +{
> > > +     int idx = skb_shinfo(skb)->ubuf.desc;
> > > +     struct vhost_virtqueue *vq = skb_shinfo(skb)->ubuf.arg;
> > > +
> > > +     /* set len = 1 to mark this desc buffers done DMA */
> > 
> > this comment can now go.
> 
> Yes, it's gone already.
> 
> > > +     vq->heads[idx].len = VHOST_DMA_DONE_LEN;
> > > +}
> > > diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> > > index b3363ae..8e3ecc7 100644
> > > --- a/drivers/vhost/vhost.h
> > > +++ b/drivers/vhost/vhost.h
> > > @@ -13,6 +13,10 @@
> > >  #include <linux/virtio_ring.h>
> > >  #include <asm/atomic.h>
> > >  
> > > +/* This is for zerocopy, used buffer len is set to 1 when lower
> > device DMA
> > > + * done */
> > > +#define VHOST_DMA_DONE_LEN   1
> > > +
> > >  struct vhost_device;
> > >  
> > >  struct vhost_work;
> > > @@ -108,6 +112,12 @@ struct vhost_virtqueue {
> > >       /* Log write descriptors */
> > >       void __user *log_base;
> > >       struct vhost_log *log;
> > > +     /* vhost zerocopy support */
> > > +     atomic_t refcnt; /* num of outstanding zerocopy DMAs */
> > 
> > future enhancement idea: this is used apparently under vq lock
> > so no need for an atomic?
> 
> It is also used in skb vhost zerocopy callback.
> 
> > > +     /* copy of avail idx to monitor outstanding DMA zerocopy
> > buffers */
> > 
> > looking at code upend_idx seems to be calculated independently
> > of guest avail idx - could you clarify pls?
> 
> Yes, you are right. Should change it to: upend_idx is used to track
> vring ids for outstanding zero-copy DMA buffers?

mention producer-consumer index in a head array used as
a circular ring datastructure.

> > > +     int upend_idx;
> > > +     /* copy of used idx to monintor DMA done zerocopy buffers */
> > 
> > monitor
> 
> Ok.
> 
> > > +     int done_idx;
> > 
> > 
> > I think in reality these are just producer and consumer
> > in the head structure which for zero copy is used
> Yes.
> 
> > 
> > >  };
> > >  
> > >  struct vhost_dev {
> > > @@ -154,6 +164,8 @@ bool vhost_enable_notify(struct vhost_virtqueue
> > *);
> > >  
> > >  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log
> > *log,
> > >                   unsigned int log_num, u64 len);
> > > +void vhost_zerocopy_callback(struct sk_buff *skb);
> > > +void vhost_zerocopy_signal_used(struct vhost_virtqueue *vq, bool
> > shutdown);
> > >  
> > >  #define vq_err(vq, fmt, ...) do {
> > \
> > >               pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
> > > 
