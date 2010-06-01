From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] vhost: replace vhost_workqueue with per-vhost
	kthread
Date: Tue, 1 Jun 2010 07:13:33 -0700
Message-ID: <20100601141333.GA3228@linux.vnet.ibm.com>
References: <4BFE9ABA.6030907@kernel.org>
 <20100527163954.GA21710@redhat.com>
 <4BFEA434.6080405@kernel.org>
 <20100527173207.GA21880@redhat.com>
 <4BFEE216.2070807@kernel.org>
 <20100528150830.GB21880@redhat.com>
 <4BFFE742.2060205@kernel.org>
 <20100530112925.GB27611@redhat.com>
 <4C02C961.9050606@kernel.org>
 <20100531152221.GB2987@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100531152221.GB2987@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 31, 2010 at 06:22:21PM +0300, Michael S. Tsirkin wrote:
> On Sun, May 30, 2010 at 10:24:01PM +0200, Tejun Heo wrote:
> > Replace vhost_workqueue with per-vhost kthread.  Other than callback
> > argument change from struct work_struct * to struct vhost_poll *,
> > there's no visible change to vhost_poll_*() interface.
> 
> I would prefer a substructure vhost_work, even just to make
> the code easier to review and compare to workqueue.c.

Either way this plays out, the rcu_dereference_check() calls will need
to be adjusted to reflect the change.

							Thanx, Paul

> > This conversion is to make each vhost use a dedicated kthread so that
> > resource control via cgroup can be applied.
> > 
> > Partially based on Sridhar Samudrala's patch.
> > 
> > Cc: Michael S. Tsirkin <mst@redhat.com>
> > Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>
> > ---
> > Okay, here is three patch series to convert vhost to use per-vhost
> > kthread, add cgroup_attach_task_current_cg() and apply it to the vhost
> > kthreads.  The conversion is mostly straight forward although flush is
> > slightly tricky.
> > 
> > The problem is that I have no idea how to test this.
> 
> It's a 3 step process:
> 
> 1. 
> Install qemu-kvm under fc13, or build recent one from source,
> get it from here:
> git://git.kernel.org/pub/scm/virt/kvm/qemu-kvm.git
> 
> 2. install guest under it:
> qemu-img create -f qcow2 disk.qcow2 100G
> Now get some image (e.g. fedora 13 in fc13.iso)
> and install guest:
> qemu-kvm -enable-kvm -m 1G -cdrom fc13.iso -drive file=disk.qcow2
> 
> 
> 3. set up networking. I usually simply do host to guest 
> on a special subnet for testing purposes:
> 
> Set up a bridge named mstbr0:
> 
> ifconfig mstbr0 down
> brctl delbr mstbr0
> brctl addbr mstbr0
> brctl setfd mstbr0 0
> ifconfig mstbr0 11.0.0.1
> 
> cat > ifup << EOF
> #!/bin/sh -x
> /sbin/ifconfig msttap0 0.0.0.0 up
> brctl addif mstbr0 msttap0
> EOF
> 
> 
> qemu-kvm -enable-kvm -m 1G -cdrom fc13.iso -drive file=disk.qcow2
>  -net nic,model=virtio,netdev=foo -netdev
> tap,id=foo,ifname=msttap0,script=/home/mst/ifup,downscript=no,vhost=on
> 
> after you set up the guest, log into it and
> ifconfig eth0 11.0.0.2
> 
> You should now be able to ping guest to host and back.
> Use something like netperf to stress the connection.
> Close qemu with kill -9 and unload module to test flushing code.
> 
> 
> 
> > Index: work/drivers/vhost/vhost.c
> > ===================================================================
> > --- work.orig/drivers/vhost/vhost.c
> > +++ work/drivers/vhost/vhost.c
> 
> ...
> 
> > @@ -125,10 +139,50 @@ static void vhost_vq_reset(struct vhost_
> >  	vq->log_ctx = NULL;
> >  }
> > 
> > +static int vhost_poller(void *data)
> > +{
> > +	struct vhost_dev *dev = data;
> > +	struct vhost_poll *poll;
> > +
> > +repeat:
> > +	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
> > +
> > +	if (kthread_should_stop()) {
> > +		__set_current_state(TASK_RUNNING);
> > +		return 0;
> > +	}
> > +
> > +	poll = NULL;
> > +	spin_lock(&dev->poller_lock);
> > +	if (!list_empty(&dev->poll_list)) {
> > +		poll = list_first_entry(&dev->poll_list,
> > +					struct vhost_poll, node);
> > +		list_del_init(&poll->node);
> > +	}
> > +	spin_unlock(&dev->poller_lock);
> > +
> > +	if (poll) {
> > +		__set_current_state(TASK_RUNNING);
> > +		poll->fn(poll);
> > +		smp_wmb();	/* paired with rmb in vhost_poll_flush() */
> > +		poll->done_seq = poll->queue_seq;
> > +		wake_up_all(&poll->done);
> 
> 
> This seems to add wakeups on data path, which uses spinlocks etc.
> OTOH workqueue.c adds a special barrier
> entry which only does a wakeup when needed.
> Right?
> 
> > +	} else
> > +		schedule();
> > +
> > +	goto repeat;
> > +}
> > +
> >  long vhost_dev_init(struct vhost_dev *dev,
> >  		    struct vhost_virtqueue *vqs, int nvqs)
> >  {
> > +	struct task_struct *poller;
> >  	int i;
> > +
> > +	poller = kthread_create(vhost_poller, dev, "vhost-%d", current->pid);
> > +	if (IS_ERR(poller))
> > +		return PTR_ERR(poller);
> > +
> >  	dev->vqs = vqs;
> >  	dev->nvqs = nvqs;
> >  	mutex_init(&dev->mutex);
> > @@ -136,6 +190,9 @@ long vhost_dev_init(struct vhost_dev *de
> >  	dev->log_file = NULL;
> >  	dev->memory = NULL;
> >  	dev->mm = NULL;
> > +	spin_lock_init(&dev->poller_lock);
> > +	INIT_LIST_HEAD(&dev->poll_list);
> > +	dev->poller = poller;
> > 
> >  	for (i = 0; i < dev->nvqs; ++i) {
> >  		dev->vqs[i].dev = dev;
> > @@ -143,8 +200,7 @@ long vhost_dev_init(struct vhost_dev *de
> >  		vhost_vq_reset(dev, dev->vqs + i);
> >  		if (dev->vqs[i].handle_kick)
> >  			vhost_poll_init(&dev->vqs[i].poll,
> > -					dev->vqs[i].handle_kick,
> > -					POLLIN);
> > +					dev->vqs[i].handle_kick, POLLIN, dev);
> >  	}
> >  	return 0;
> >  }
> > @@ -217,6 +273,8 @@ void vhost_dev_cleanup(struct vhost_dev
> >  	if (dev->mm)
> >  		mmput(dev->mm);
> >  	dev->mm = NULL;
> > +
> > +	kthread_stop(dev->poller);
> >  }
> > 
> >  static int log_access_ok(void __user *log_base, u64 addr, unsigned long sz)
> > @@ -1113,16 +1171,3 @@ void vhost_disable_notify(struct vhost_v
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
> 
> I note that destroy_workqueue does a flush, kthread_stop
> doesn't. Right? Sure we don't need to check nothing is in one of
> the lists? Maybe add a BUG_ON?
> 
> > -}
> > Index: work/drivers/vhost/vhost.h
> > ===================================================================
> > --- work.orig/drivers/vhost/vhost.h
> > +++ work/drivers/vhost/vhost.h
> > @@ -5,7 +5,6 @@
> >  #include <linux/vhost.h>
> >  #include <linux/mm.h>
> >  #include <linux/mutex.h>
> > -#include <linux/workqueue.h>
> >  #include <linux/poll.h>
> >  #include <linux/file.h>
> >  #include <linux/skbuff.h>
> > @@ -20,19 +19,26 @@ enum {
> >  	VHOST_NET_MAX_SG = MAX_SKB_FRAGS + 2,
> >  };
> > 
> > +struct vhost_poll;
> > +typedef void (*vhost_poll_fn_t)(struct vhost_poll *poll);
> > +
> >  /* Poll a file (eventfd or socket) */
> >  /* Note: there's nothing vhost specific about this structure. */
> >  struct vhost_poll {
> > +	vhost_poll_fn_t		  fn;
> >  	poll_table                table;
> >  	wait_queue_head_t        *wqh;
> >  	wait_queue_t              wait;
> > -	/* struct which will handle all actual work. */
> > -	struct work_struct        work;
> > +	struct list_head	  node;
> > +	wait_queue_head_t	  done;
> >  	unsigned long		  mask;
> > +	struct vhost_dev	 *dev;
> > +	int			  queue_seq;
> > +	int			  done_seq;
> >  };
> > 
> > -void vhost_poll_init(struct vhost_poll *poll, work_func_t func,
> > -		     unsigned long mask);
> > +void vhost_poll_init(struct vhost_poll *poll, vhost_poll_fn_t fn,
> > +		     unsigned long mask, struct vhost_dev *dev);
> >  void vhost_poll_start(struct vhost_poll *poll, struct file *file);
> >  void vhost_poll_stop(struct vhost_poll *poll);
> >  void vhost_poll_flush(struct vhost_poll *poll);
> > @@ -63,7 +69,7 @@ struct vhost_virtqueue {
> >  	struct vhost_poll poll;
> > 
> >  	/* The routine to call when the Guest pings us, or timeout. */
> > -	work_func_t handle_kick;
> > +	vhost_poll_fn_t handle_kick;
> > 
> >  	/* Last available index we saw. */
> >  	u16 last_avail_idx;
> > @@ -86,11 +92,11 @@ struct vhost_virtqueue {
> >  	struct iovec hdr[VHOST_NET_MAX_SG];
> >  	size_t hdr_size;
> >  	/* We use a kind of RCU to access private pointer.
> > -	 * All readers access it from workqueue, which makes it possible to
> > -	 * flush the workqueue instead of synchronize_rcu. Therefore readers do
> > +	 * All readers access it from poller, which makes it possible to
> > +	 * flush the vhost_poll instead of synchronize_rcu. Therefore readers do
> >  	 * not need to call rcu_read_lock/rcu_read_unlock: the beginning of
> > -	 * work item execution acts instead of rcu_read_lock() and the end of
> > -	 * work item execution acts instead of rcu_read_lock().
> > +	 * vhost_poll execution acts instead of rcu_read_lock() and the end of
> > +	 * vhost_poll execution acts instead of rcu_read_lock().
> >  	 * Writers use virtqueue mutex. */
> >  	void *private_data;
> >  	/* Log write descriptors */
> > @@ -110,6 +116,9 @@ struct vhost_dev {
> >  	int nvqs;
> >  	struct file *log_file;
> >  	struct eventfd_ctx *log_ctx;
> > +	spinlock_t poller_lock;
> > +	struct list_head poll_list;
> > +	struct task_struct *poller;
> >  };
> > 
> >  long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue *vqs, int nvqs);
> > @@ -136,9 +145,6 @@ bool vhost_enable_notify(struct vhost_vi
> >  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
> >  		    unsigned int log_num, u64 len);
> > 
> > -int vhost_init(void);
> > -void vhost_cleanup(void);
> > -
> >  #define vq_err(vq, fmt, ...) do {                                  \
> >  		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
> >  		if ((vq)->error_ctx)                               \
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
