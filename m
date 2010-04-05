From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] vhost: Make it more scalable by creating a vhost
	thread per device.
Date: Mon, 05 Apr 2010 10:35:11 -0700
Message-ID: <1270488911.27874.43.camel@w-sridhar.beaverton.ibm.com>
References: <1270229480.13897.8.camel@w-sridhar.beaverton.ibm.com>
	 <20100404111433.GD3189@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Lendacky <toml@us.ibm.com>, netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:42721 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240Ab0DERfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 13:35:31 -0400
In-Reply-To: <20100404111433.GD3189@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-04-04 at 14:14 +0300, Michael S. Tsirkin wrote:
> On Fri, Apr 02, 2010 at 10:31:20AM -0700, Sridhar Samudrala wrote:
> > Make vhost scalable by creating a separate vhost thread per vhost
> > device. This provides better scaling across multiple guests and with
> > multiple interfaces in a guest.
> 
> Thanks for looking into this. An alternative approach is
> to simply replace create_singlethread_workqueue with
> create_workqueue which would get us a thread per host CPU.
> 
> It seems that in theory this should be the optimal approach
> wrt CPU locality, however, in practice a single thread
> seems to get better numbers. I have a TODO to investigate this.
> Could you try looking into this?

Yes. I tried using create_workqueue(), but the results were not good
atleast when the number of guest interfaces is less than the number
of CPUs. I didn't try more than 8 guests.
Creating a separate thread per guest interface seems to be more
scalable based on the testing i have done so far.

I will try some more tests and get some numbers to compare the following
3 options.
- single vhost thread
- vhost thread per cpu
- vhost thread per guest virtio interface

Thanks
Sridhar
> 
> > 
> > I am seeing better aggregated througput/latency when running netperf
> > across multiple guests or multiple interfaces in a guest in parallel
> > with this patch.
> 
> Any numbers? What happens to CPU utilization?
> 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> > 
> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> > index a6a88df..29aa80f 100644
> > --- a/drivers/vhost/net.c
> > +++ b/drivers/vhost/net.c
> > @@ -339,8 +339,10 @@ static int vhost_net_open(struct inode *inode, struct file *f)
> >  		return r;
> >  	}
> >  
> > -	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT);
> > -	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN);
> > +	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT,
> > +			&n->dev);
> > +	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN,
> > +			&n->dev);
> >  	n->tx_poll_state = VHOST_NET_POLL_DISABLED;
> >  
> >  	f->private_data = n;
> > @@ -643,25 +645,14 @@ static struct miscdevice vhost_net_misc = {
> >  
> >  int vhost_net_init(void)
> >  {
> > -	int r = vhost_init();
> > -	if (r)
> > -		goto err_init;
> > -	r = misc_register(&vhost_net_misc);
> > -	if (r)
> > -		goto err_reg;
> > -	return 0;
> > -err_reg:
> > -	vhost_cleanup();
> > -err_init:
> > -	return r;
> > -
> > +	return misc_register(&vhost_net_misc);
> >  }
> > +
> >  module_init(vhost_net_init);
> >  
> >  void vhost_net_exit(void)
> >  {
> >  	misc_deregister(&vhost_net_misc);
> > -	vhost_cleanup();
> >  }
> >  module_exit(vhost_net_exit);
> >  
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > index 7bd7a1e..243f4d3 100644
> > --- a/drivers/vhost/vhost.c
> > +++ b/drivers/vhost/vhost.c
> > @@ -36,8 +36,6 @@ enum {
> >  	VHOST_MEMORY_F_LOG = 0x1,
> >  };
> >  
> > -static struct workqueue_struct *vhost_workqueue;
> > -
> >  static void vhost_poll_func(struct file *file, wait_queue_head_t *wqh,
> >  			    poll_table *pt)
> >  {
> > @@ -56,18 +54,19 @@ static int vhost_poll_wakeup(wait_queue_t *wait, unsigned mode, int sync,
> >  	if (!((unsigned long)key & poll->mask))
> >  		return 0;
> >  
> > -	queue_work(vhost_workqueue, &poll->work);
> > +	queue_work(poll->dev->wq, &poll->work);
> >  	return 0;
> >  }
> >  
> >  /* Init poll structure */
> >  void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
> > -		     unsigned long mask)
> > +		     unsigned long mask, struct vhost_dev *dev)
> >  {
> >  	INIT_WORK(&poll->work, func);
> >  	init_waitqueue_func_entry(&poll->wait, vhost_poll_wakeup);
> >  	init_poll_funcptr(&poll->table, vhost_poll_func);
> >  	poll->mask = mask;
> > +	poll->dev = dev;
> >  }
> >  
> >  /* Start polling a file. We add ourselves to file's wait queue. The caller must
> > @@ -96,7 +95,7 @@ void vhost_poll_flush(struct vhost_poll *poll)
> >  
> >  void vhost_poll_queue(struct vhost_poll *poll)
> >  {
> > -	queue_work(vhost_workqueue, &poll->work);
> > +	queue_work(poll->dev->wq, &poll->work);
> >  }
> >  
> >  static void vhost_vq_reset(struct vhost_dev *dev,
> > @@ -128,6 +127,11 @@ long vhost_dev_init(struct vhost_dev *dev,
> >  		    struct vhost_virtqueue *vqs, int nvqs)
> >  {
> >  	int i;
> > +
> > +	dev->wq = create_singlethread_workqueue("vhost");
> > +	if (!dev->wq)
> > +		return -ENOMEM;
> > +
> >  	dev->vqs = vqs;
> >  	dev->nvqs = nvqs;
> >  	mutex_init(&dev->mutex);
> > @@ -143,7 +147,7 @@ long vhost_dev_init(struct vhost_dev *dev,
> >  		if (dev->vqs[i].handle_kick)
> >  			vhost_poll_init(&dev->vqs[i].poll,
> >  					dev->vqs[i].handle_kick,
> > -					POLLIN);
> > +					POLLIN, dev);
> >  	}
> >  	return 0;
> >  }
> > @@ -216,6 +220,8 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
> >  	if (dev->mm)
> >  		mmput(dev->mm);
> >  	dev->mm = NULL;
> > +
> > +	destroy_workqueue(dev->wq);
> >  }
> >  
> >  static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
> > @@ -1095,16 +1101,3 @@ void vhost_disable_notify(struct vhost_virtqueue *vq)
> >  		vq_err(vq, "Failed to enable notification at %p: %d\n",
> >  		       &vq->used->flags, r);
> >  }
> > -
> > -int vhost_init(void)
> > -{
> > -	vhost_workqueue = create_singlethread_workqueue("vhost");
> > -	if (!vhost_workqueue)
> > -		return -ENOMEM;
> > -	return 0;
> > -}
> > -
> > -void vhost_cleanup(void)
> > -{
> > -	destroy_workqueue(vhost_workqueue);
> > -}
> > diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> > index 44591ba..60fefd0 100644
> > --- a/drivers/vhost/vhost.h
> > +++ b/drivers/vhost/vhost.h
> > @@ -29,10 +29,11 @@ struct vhost_poll {
> >  	/* struct which will handle all actual work. */
> >  	struct work_struct        work;
> >  	unsigned long		  mask;
> > +	struct vhost_dev	 *dev;
> >  };
> >  
> >  void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
> > -		     unsigned long mask);
> > +		     unsigned long mask, struct vhost_dev *dev);
> >  void vhost_poll_start(struct vhost_poll *poll, struct file *file);
> >  void vhost_poll_stop(struct vhost_poll *poll);
> >  void vhost_poll_flush(struct vhost_poll *poll);
> > @@ -110,6 +111,7 @@ struct vhost_dev {
> >  	int nvqs;
> >  	struct file *log_file;
> >  	struct eventfd_ctx *log_ctx;
> > +	struct workqueue_struct *wq;
> >  };
> >  
> >  long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
> > @@ -136,9 +138,6 @@ bool vhost_enable_notify(struct vhost_virtqueue *);
> >  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
> >  		    unsigned int log_num, u64 len);
> >  
> > -int vhost_init(void);
> > -void vhost_cleanup(void);
> > -
> >  #define vq_err(vq, fmt, ...) do {                                  \
> >  		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
> >  		if ((vq)->error_ctx)                               \
> > 
> > 
> > 

