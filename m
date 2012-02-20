From: Tom Lendacky <toml@us.ibm.com>
Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
Date: Mon, 20 Feb 2012 09:50:37 -0600
Message-ID: <OFC071CE44.FE2F733D-ON862579AA.0055FCA0-862579AA.0057082B@us.ibm.com>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com> <1329519726-25763-2-git-send-email-aliguori@us.ibm.com> <20120219144145.GA16620@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Anthony Liguori <aliguori@us.ibm.com>, netdev@vger.kernel.org,
	Cristian Viana <vianac@br.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:58211 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab2BTPwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 10:52:31 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <toml@us.ibm.com>;
	Mon, 20 Feb 2012 08:52:30 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id A349DC90056
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 10:51:35 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KFokGD408906
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 10:51:03 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KFojxV020776
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 10:50:46 -0500
In-Reply-To: <20120219144145.GA16620@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 02/19/2012 08:41:45 AM:

> From: "Michael S. Tsirkin" <mst@redhat.com>
> To: Anthony Liguori/Austin/IBM@IBMUS
> Cc: netdev@vger.kernel.org, Tom Lendacky/Austin/IBM@IBMUS, Cristian
> Viana <vianac@br.ibm.com>
> Date: 02/19/2012 08:42 AM
> Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
>
> On Fri, Feb 17, 2012 at 05:02:05PM -0600, Anthony Liguori wrote:
> > This patch allows vhost to have multiple worker threads for devices
such as
> > virtio-net which may have multiple virtqueues.
> >
> > Since virtqueues are a lockless ring queue, in an ideal world data is
being
> > produced by the producer as fast as data is being consumed by the
consumer.
> > These loops will continue to consume data until none is left.
> >
> > vhost currently multiplexes the consumer side of the queue on a
> single thread
> > by attempting to read from the queue until everything is read or it
cannot
> > process anymore.  This means that activity on one queue may stall
> another queue.
>
> There's actually an attempt to address this: look up
> VHOST_NET_WEIGHT in the code. I take it, this isn't effective?
>
> > This is exacerbated when using any form of polling to read from
> the queues (as
> > we'll introduce in the next patch).  By spawning a thread per-
> virtqueue, this
> > is addressed.
> >
> > The only problem with this patch right now is how the wake up of
> the threads is
> > done.  It's essentially a broadcast and we have seen lock contention as
a
> > result.
>
> On which lock?

The mutex lock in the vhost_virtqueue struct.  This really shows up when
running with patch 2/2 and increasing the spin_threshold. Both threads wake
up and try to acquire the mutex.  As the spin_threshold increases you end
up
with one of the threads getting blocked for a longer and longer time and
unable to do any RX processing that might be needed.

Tom

>
> > We've tried some approaches to signal a single thread but I'm not
> > confident that that code is correct yet so I'm only sending the
broadcast
> > version.
>
> Yes, that looks like an obvious question.
>
> > Here are some performance results from this change.  There's a modest
> > improvement with stream although a fair bit of variability too.
> >
> > With RR, there's pretty significant improvements as the instance
> rate drives up.
>
> Interesting. This was actually tested at one time and we saw
> a significant performance improvement from using
> a single thread especially with a single
> stream in the guest. Profiling indicated that
> with a single thread we get too many context
> switches between TX and RX, since guest networking
> tends to run TX and RX processing on the same
> guest VCPU.
>
> Maybe we were wrong or maybe this went away
> for some reason. I'll see if this can be reproduced.
>
> >
> > Test, Size, Instance, Baseline, Patch, Relative
> >
> > TCP_RR
> >    Tx:256 Rx:256
> >       1   9,639.66   10,164.06   105.44%
> >       10   62,819.55   54,059.78   86.06%
> >       30   84,715.60   131,241.86   154.92%
> >       60   124,614.71   148,720.66   119.34%
> >
> > UDP_RR
> >    Tx:256 Rx:256
> >       1   9,652.50   10,343.72   107.16%
> >       10   53,830.26   58,235.90   108.18%
> >       30   89,471.01   97,634.53   109.12%
> >       60   103,640.59   164,035.01   158.27%
> >
> > TCP_STREAM
> >    Tx: 256
> >       1   2,622.63   2,610.71   99.55%
> >       4   4,928.02   4,812.05   97.65%
> >
> >    Tx: 1024
> >       1   5,639.89   5,751.28   101.97%
> >       4   5,874.72   6,575.55   111.93%
> >
> >    Tx: 4096
> >       1   6,257.42   7,655.22   122.34%
> >       4   5,370.78   6,044.83   112.55%
> >
> >    Tx: 16384
> >       1   6,346.63   7,267.44   114.51%
> >       4   5,198.02   5,657.12   108.83%
> >
> > TCP_MAERTS
> >    Rx: 256
> >       1   2,091.38   1,765.62   84.42%
> >       4   5,319.52   5,619.49   105.64%
> >
> >    Rx: 1024
> >       1   7,030.66   7,593.61   108.01%
> >       4   9,040.53   7,275.84   80.48%
> >
> >    Rx: 4096
> >       1   9,160.93   9,318.15   101.72%
> >       4   9,372.49   8,875.63   94.70%
> >
> >    Rx: 16384
> >       1   9,183.28   9,134.02   99.46%
> >       4   9,377.17   8,877.52   94.67%
> >
> >                      106.46%
>
> One point missing here is the ratio of
> throughput divided by host CPU utilization.
>
> The concern being to avoid hurting
> heavily loaded systems.
>
> These numbers also tend to be less variable as
> they depend less on host scheduler decisions.
>
>
> > Cc: Tom Lendacky <toml@us.ibm.com>
> > Cc: Cristian Viana <vianac@br.ibm.com>
> > Signed-off-by: Anthony Liguori <aliguori@us.ibm.com>
> > ---
> >  drivers/vhost/net.c   |    6 ++++-
> >  drivers/vhost/vhost.c |   51 +++++++++++++++++++++++++++++
> +------------------
> >  drivers/vhost/vhost.h |    8 +++++-
> >  3 files changed, 43 insertions(+), 22 deletions(-)
> >
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index 9dab1f5..47175cd 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -33,6 +33,10 @@ static int experimental_zcopytx;
> >  module_param(experimental_zcopytx, int, 0444);
> >  MODULE_PARM_DESC(experimental_zcopytx, "Enable Experimental Zero Copy
TX");
> >
> > +static int workers = 2;
> > +module_param(workers, int, 0444);
> > +MODULE_PARM_DESC(workers, "Set the number of worker threads");
> > +
> >  /* Max number of bytes transferred before requeueing the job.
> >   * Using this limit prevents one virtqueue from starving others. */
> >  #define VHOST_NET_WEIGHT 0x80000
> > @@ -504,7 +508,7 @@ static int vhost_net_open(struct inode *inode,
> struct file *f)
> >     dev = &n->dev;
> >     n->vqs[VHOST_NET_VQ_TX].handle_kick = handle_tx_kick;
> >     n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
> > -   r = vhost_dev_init(dev, n->vqs, VHOST_NET_VQ_MAX);
> > +   r = vhost_dev_init(dev, n->vqs, workers, VHOST_NET_VQ_MAX);
> >     if (r < 0) {
> >        kfree(n);
> >        return r;
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index c14c42b..676cead 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -144,9 +144,12 @@ static inline void vhost_work_queue(struct
> vhost_dev *dev,
> >
> >     spin_lock_irqsave(&dev->work_lock, flags);
> >     if (list_empty(&work->node)) {
> > +      int i;
> > +
> >        list_add_tail(&work->node, &dev->work_list);
> >        work->queue_seq++;
> > -      wake_up_process(dev->worker);
> > +      for (i = 0; i < dev->nworkers; i++)
> > +         wake_up_process(dev->workers[i]);
> >     }
> >     spin_unlock_irqrestore(&dev->work_lock, flags);
> >  }
> > @@ -287,7 +290,7 @@ static void vhost_dev_free_iovecs(struct vhost_dev
*dev)
> >  }
> >
> >  long vhost_dev_init(struct vhost_dev *dev,
> > -          struct vhost_virtqueue *vqs, int nvqs)
> > +          struct vhost_virtqueue *vqs, int nworkers, int nvqs)
> >  {
> >     int i;
> >
> > @@ -300,7 +303,9 @@ long vhost_dev_init(struct vhost_dev *dev,
> >     dev->mm = NULL;
> >     spin_lock_init(&dev->work_lock);
> >     INIT_LIST_HEAD(&dev->work_list);
> > -   dev->worker = NULL;
> > +   dev->nworkers = min(nworkers, VHOST_MAX_WORKERS);
> > +   for (i = 0; i < dev->nworkers; i++)
> > +      dev->workers[i] = NULL;
> >
> >     for (i = 0; i < dev->nvqs; ++i) {
> >        dev->vqs[i].log = NULL;
> > @@ -354,7 +359,7 @@ static int vhost_attach_cgroups(struct vhost_dev
*dev)
> >  static long vhost_dev_set_owner(struct vhost_dev *dev)
> >  {
> >     struct task_struct *worker;
> > -   int err;
> > +   int err, i;
> >
> >     /* Is there an owner already? */
> >     if (dev->mm) {
> > @@ -364,28 +369,34 @@ static long vhost_dev_set_owner(struct vhost_dev
*dev)
> >
> >     /* No owner, become one */
> >     dev->mm = get_task_mm(current);
> > -   worker = kthread_create(vhost_worker, dev, "vhost-%d", current->
pid);
> > -   if (IS_ERR(worker)) {
> > -      err = PTR_ERR(worker);
> > -      goto err_worker;
> > -   }
> > +   for (i = 0; i < dev->nworkers; i++) {
> > +      worker = kthread_create(vhost_worker, dev, "vhost-%d.%d",
> current->pid, i);
> > +      if (IS_ERR(worker)) {
> > +         err = PTR_ERR(worker);
> > +         goto err_worker;
> > +      }
> >
> > -   dev->worker = worker;
> > -   wake_up_process(worker);   /* avoid contributing to loadavg */
> > +      dev->workers[i] = worker;
> > +      wake_up_process(worker);   /* avoid contributing to loadavg */
> > +   }
> >
> >     err = vhost_attach_cgroups(dev);
> >     if (err)
> > -      goto err_cgroup;
> > +      goto err_worker;
> >
> >     err = vhost_dev_alloc_iovecs(dev);
> >     if (err)
> > -      goto err_cgroup;
> > +      goto err_worker;
> >
> >     return 0;
> > -err_cgroup:
> > -   kthread_stop(worker);
> > -   dev->worker = NULL;
> > +
> >  err_worker:
> > +   for (i = 0; i < dev->nworkers; i++) {
> > +      if (dev->workers[i]) {
> > +         kthread_stop(dev->workers[i]);
> > +         dev->workers[i] = NULL;
> > +      }
> > +   }
> >     if (dev->mm)
> >        mmput(dev->mm);
> >     dev->mm = NULL;
> > @@ -475,9 +486,11 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
> >                 lockdep_is_held(&dev->mutex)));
> >     RCU_INIT_POINTER(dev->memory, NULL);
> >     WARN_ON(!list_empty(&dev->work_list));
> > -   if (dev->worker) {
> > -      kthread_stop(dev->worker);
> > -      dev->worker = NULL;
> > +   for (i = 0; i < dev->nworkers; i++) {
> > +      if (dev->workers[i]) {
> > +         kthread_stop(dev->workers[i]);
> > +         dev->workers[i] = NULL;
> > +      }
> >     }
> >     if (dev->mm)
> >        mmput(dev->mm);
> > diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> > index a801e28..fa5e75e 100644
> > --- a/drivers/vhost/vhost.h
> > +++ b/drivers/vhost/vhost.h
> > @@ -18,6 +18,9 @@
> >  #define VHOST_DMA_DONE_LEN   1
> >  #define VHOST_DMA_CLEAR_LEN   0
> >
> > +/* Maximum number of worker threads per-vhost device */
> > +#define VHOST_MAX_WORKERS   8
> > +
> >  struct vhost_device;
> >
> >  struct vhost_work;
> > @@ -157,10 +160,11 @@ struct vhost_dev {
> >     struct eventfd_ctx *log_ctx;
> >     spinlock_t work_lock;
> >     struct list_head work_list;
> > -   struct task_struct *worker;
> > +   int nworkers;
> > +   struct task_struct *workers[VHOST_MAX_WORKERS];
> >  };
> >
> > -long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue
> *vqs, int nvqs);
> > +long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue
> *vqs, int nworkers, int nvqs);
> >  long vhost_dev_check_owner(struct vhost_dev *);
> >  long vhost_dev_reset_owner(struct vhost_dev *);
> >  void vhost_dev_cleanup(struct vhost_dev *);
> > --
> > 1.7.4.1
>
