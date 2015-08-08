From: Bandan Das <bsd@redhat.com>
Subject: Re: [RFC PATCH 1/4] vhost: Introduce a universal thread to serve all users
Date: Sat, 08 Aug 2015 18:40:38 -0400
Message-ID: <jpgsi7ts8t5.fsf@linux.bootlegged.copy>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
	<1436760455-5686-2-git-send-email-bsd@redhat.com>
	<OF8AF3E3F8.F0120188-ONC2257E8E.00740E46-C2257E90.0035BD30@il.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: cgroups@vger.kernel.org, jasowang@redhat.com, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, Razya Ladelsky <RAZYA@il.ibm.com>
To: Eyal Moscovici <EYALMO@il.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <OF8AF3E3F8.F0120188-ONC2257E8E.00740E46-C2257E90.0035BD30@il.ibm.com>
	(Eyal Moscovici's message of "Tue, 28 Jul 2015 12:46:56 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eyal Moscovici <EYALMO@il.ibm.com> writes:

> Hi, 
>
> Do you know what is the overhead of switching the vhost thread from one 
> cgroup to another?

I misinterpreted this question earlier. I think what you are asking here is
that when the vm process is moved from one cgroup to another, what is the
overhead of moving the vhost thread to the new cgroup.

This design does not provide any hooks for the vhost thread to move to
a new cgroup. Rather, I think a better approach is to create a new vhost
thread and bind the process to it if the process is migrated to a new
cgroup. This is much less complicated, and there's a good chance that
it's impossible to migrate the vhost thread since it's serving other guests.
I will address this in v2.

> Eyal Moscovici
> HL-Cloud Infrastructure Solutions
> IBM Haifa Research Lab
>
>
>
> From:   Bandan Das <bsd@redhat.com>
> To:     kvm@vger.kernel.org
> Cc:     netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
> mst@redhat.com, Eyal Moscovici/Haifa/IBM@IBMIL, Razya 
> Ladelsky/Haifa/IBM@IBMIL, cgroups@vger.kernel.org, jasowang@redhat.com
> Date:   07/13/2015 07:08 AM
> Subject:        [RFC PATCH 1/4] vhost: Introduce a universal thread to 
> serve all users
>
>
>
> vhost threads are per-device, but in most cases a single thread
> is enough. This change creates a single thread that is used to
> serve all guests.
>
> However, this complicates cgroups associations. The current policy
> is to attach the per-device thread to all cgroups of the parent process
> that the device is associated it. This is no longer possible if we
> have a single thread. So, we end up moving the thread around to
> cgroups of whichever device that needs servicing. This is a very
> inefficient protocol but seems to be the only way to integrate
> cgroups support.
>
> Signed-off-by: Razya Ladelsky <razya@il.ibm.com>
> Signed-off-by: Bandan Das <bsd@redhat.com>
> ---
>  drivers/vhost/scsi.c  |  15 +++--
>  drivers/vhost/vhost.c | 150 
> ++++++++++++++++++++++++--------------------------
>  drivers/vhost/vhost.h |  19 +++++--
>  3 files changed, 97 insertions(+), 87 deletions(-)
>
> diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
> index ea32b38..6c42936 100644
> --- a/drivers/vhost/scsi.c
> +++ b/drivers/vhost/scsi.c
> @@ -535,7 +535,7 @@ static void vhost_scsi_complete_cmd(struct 
> vhost_scsi_cmd *cmd)
>  
>                  llist_add(&cmd->tvc_completion_list, 
> &vs->vs_completion_list);
>  
> -                vhost_work_queue(&vs->dev, &vs->vs_completion_work);
> +                vhost_work_queue(vs->dev.worker, 
> &vs->vs_completion_work);
>  }
>  
>  static int vhost_scsi_queue_data_in(struct se_cmd *se_cmd)
> @@ -1282,7 +1282,7 @@ vhost_scsi_send_evt(struct vhost_scsi *vs,
>                  }
>  
>                  llist_add(&evt->list, &vs->vs_event_list);
> -                vhost_work_queue(&vs->dev, &vs->vs_event_work);
> +                vhost_work_queue(vs->dev.worker, &vs->vs_event_work);
>  }
>  
>  static void vhost_scsi_evt_handle_kick(struct vhost_work *work)
> @@ -1335,8 +1335,8 @@ static void vhost_scsi_flush(struct vhost_scsi *vs)
>                  /* Flush both the vhost poll and vhost work */
>                  for (i = 0; i < VHOST_SCSI_MAX_VQ; i++)
>                                  vhost_scsi_flush_vq(vs, i);
> -                vhost_work_flush(&vs->dev, &vs->vs_completion_work);
> -                vhost_work_flush(&vs->dev, &vs->vs_event_work);
> +                vhost_work_flush(vs->dev.worker, 
> &vs->vs_completion_work);
> +                vhost_work_flush(vs->dev.worker, &vs->vs_event_work);
>  
>                  /* Wait for all reqs issued before the flush to be 
> finished */
>                  for (i = 0; i < VHOST_SCSI_MAX_VQ; i++)
> @@ -1584,8 +1584,11 @@ static int vhost_scsi_open(struct inode *inode, 
> struct file *f)
>                  if (!vqs)
>                                  goto err_vqs;
>  
> -                vhost_work_init(&vs->vs_completion_work, 
> vhost_scsi_complete_cmd_work);
> -                vhost_work_init(&vs->vs_event_work, vhost_scsi_evt_work);
> +                vhost_work_init(&vs->dev, &vs->vs_completion_work,
> + vhost_scsi_complete_cmd_work);
> +
> +                vhost_work_init(&vs->dev, &vs->vs_event_work,
> +                                                vhost_scsi_evt_work);
>  
>                  vs->vs_events_nr = 0;
>                  vs->vs_events_missed = false;
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 2ee2826..951c96b 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -11,6 +11,8 @@
>   * Generic code for virtio server in host kernel.
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/eventfd.h>
>  #include <linux/vhost.h>
>  #include <linux/uio.h>
> @@ -28,6 +30,9 @@
>  
>  #include "vhost.h"
>  
> +/* Just one worker thread to service all devices */
> +static struct vhost_worker *worker;
> +
>  enum {
>                  VHOST_MEMORY_MAX_NREGIONS = 64,
>                  VHOST_MEMORY_F_LOG = 0x1,
> @@ -58,13 +63,15 @@ static int vhost_poll_wakeup(wait_queue_t *wait, 
> unsigned mode, int sync,
>                  return 0;
>  }
>  
> -void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn)
> +void vhost_work_init(struct vhost_dev *dev,
> +                                     struct vhost_work *work, 
> vhost_work_fn_t fn)
>  {
>                  INIT_LIST_HEAD(&work->node);
>                  work->fn = fn;
>                  init_waitqueue_head(&work->done);
>                  work->flushing = 0;
>                  work->queue_seq = work->done_seq = 0;
> +                work->dev = dev;
>  }
>  EXPORT_SYMBOL_GPL(vhost_work_init);
>  
> @@ -78,7 +85,7 @@ void vhost_poll_init(struct vhost_poll *poll, 
> vhost_work_fn_t fn,
>                  poll->dev = dev;
>                  poll->wqh = NULL;
>  
> -                vhost_work_init(&poll->work, fn);
> +                vhost_work_init(dev, &poll->work, fn);
>  }
>  EXPORT_SYMBOL_GPL(vhost_poll_init);
>  
> @@ -116,30 +123,30 @@ void vhost_poll_stop(struct vhost_poll *poll)
>  }
>  EXPORT_SYMBOL_GPL(vhost_poll_stop);
>  
> -static bool vhost_work_seq_done(struct vhost_dev *dev, struct vhost_work 
> *work,
> -                                                                unsigned 
> seq)
> +static bool vhost_work_seq_done(struct vhost_worker *worker,
> +                                                                struct 
> vhost_work *work, unsigned seq)
>  {
>                  int left;
>  
> -                spin_lock_irq(&dev->work_lock);
> +                spin_lock_irq(&worker->work_lock);
>                  left = seq - work->done_seq;
> -                spin_unlock_irq(&dev->work_lock);
> +                spin_unlock_irq(&worker->work_lock);
>                  return left <= 0;
>  }
>  
> -void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work)
> +void vhost_work_flush(struct vhost_worker *worker, struct vhost_work 
> *work)
>  {
>                  unsigned seq;
>                  int flushing;
>  
> -                spin_lock_irq(&dev->work_lock);
> +                spin_lock_irq(&worker->work_lock);
>                  seq = work->queue_seq;
>                  work->flushing++;
> -                spin_unlock_irq(&dev->work_lock);
> -                wait_event(work->done, vhost_work_seq_done(dev, work, 
> seq));
> -                spin_lock_irq(&dev->work_lock);
> +                spin_unlock_irq(&worker->work_lock);
> +                wait_event(work->done, vhost_work_seq_done(worker, work, 
> seq));
> +                spin_lock_irq(&worker->work_lock);
>                  flushing = --work->flushing;
> -                spin_unlock_irq(&dev->work_lock);
> +                spin_unlock_irq(&worker->work_lock);
>                  BUG_ON(flushing < 0);
>  }
>  EXPORT_SYMBOL_GPL(vhost_work_flush);
> @@ -148,29 +155,30 @@ EXPORT_SYMBOL_GPL(vhost_work_flush);
>   * locks that are also used by the callback. */
>  void vhost_poll_flush(struct vhost_poll *poll)
>  {
> -                vhost_work_flush(poll->dev, &poll->work);
> +                vhost_work_flush(poll->dev->worker, &poll->work);
>  }
>  EXPORT_SYMBOL_GPL(vhost_poll_flush);
>  
> -void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work)
> +void vhost_work_queue(struct vhost_worker *worker,
> +                                      struct vhost_work *work)
>  {
>                  unsigned long flags;
>  
> -                spin_lock_irqsave(&dev->work_lock, flags);
> +                spin_lock_irqsave(&worker->work_lock, flags);
>                  if (list_empty(&work->node)) {
> -                                list_add_tail(&work->node, 
> &dev->work_list);
> +                                list_add_tail(&work->node, 
> &worker->work_list);
>                                  work->queue_seq++;
> -                                spin_unlock_irqrestore(&dev->work_lock, 
> flags);
> -                                wake_up_process(dev->worker);
> + spin_unlock_irqrestore(&worker->work_lock, flags);
> +                                wake_up_process(worker->thread);
>                  } else {
> -                                spin_unlock_irqrestore(&dev->work_lock, 
> flags);
> + spin_unlock_irqrestore(&worker->work_lock, flags);
>                  }
>  }
>  EXPORT_SYMBOL_GPL(vhost_work_queue);
>  
>  void vhost_poll_queue(struct vhost_poll *poll)
>  {
> -                vhost_work_queue(poll->dev, &poll->work);
> +                vhost_work_queue(poll->dev->worker, &poll->work);
>  }
>  EXPORT_SYMBOL_GPL(vhost_poll_queue);
>  
> @@ -203,19 +211,18 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>  
>  static int vhost_worker(void *data)
>  {
> -                struct vhost_dev *dev = data;
> +                struct vhost_worker *worker = data;
>                  struct vhost_work *work = NULL;
>                  unsigned uninitialized_var(seq);
>                  mm_segment_t oldfs = get_fs();
>  
>                  set_fs(USER_DS);
> -                use_mm(dev->mm);
>  
>                  for (;;) {
>                                  /* mb paired w/ kthread_stop */
>                                  set_current_state(TASK_INTERRUPTIBLE);
>  
> -                                spin_lock_irq(&dev->work_lock);
> +                                spin_lock_irq(&worker->work_lock);
>                                  if (work) {
>                                                  work->done_seq = seq;
>                                                  if (work->flushing)
> @@ -223,21 +230,35 @@ static int vhost_worker(void *data)
>                                  }
>  
>                                  if (kthread_should_stop()) {
> - spin_unlock_irq(&dev->work_lock);
> + spin_unlock_irq(&worker->work_lock);
>  __set_current_state(TASK_RUNNING);
>                                                  break;
>                                  }
> -                                if (!list_empty(&dev->work_list)) {
> -                                                work = 
> list_first_entry(&dev->work_list,
> +                                if (!list_empty(&worker->work_list)) {
> +                                                work = 
> list_first_entry(&worker->work_list,
>                  struct vhost_work, node);
>  list_del_init(&work->node);
>                                                  seq = work->queue_seq;
>                                  } else
>                                                  work = NULL;
> -                                spin_unlock_irq(&dev->work_lock);
> +                                spin_unlock_irq(&worker->work_lock);
>  
>                                  if (work) {
> +                                                struct vhost_dev *dev = 
> work->dev;
> +
>  __set_current_state(TASK_RUNNING);
> +
> +                                                if (current->mm != 
> dev->mm) {
> + unuse_mm(current->mm);
> + use_mm(dev->mm);
> +                                                }
> +
> +                                                /* TODO: Consider a more 
> elegant solution */
> +                                                if (worker->owner != 
> dev->owner) {
> +                                                                /* Should 
> check for return value */
> + cgroup_attach_task_all(dev->owner, current);
> + worker->owner = dev->owner;
> +                                                }
>                                                  work->fn(work);
>                                                  if (need_resched())
>  schedule();
> @@ -245,7 +266,6 @@ static int vhost_worker(void *data)
>                                                  schedule();
>  
>                  }
> -                unuse_mm(dev->mm);
>                  set_fs(oldfs);
>                  return 0;
>  }
> @@ -304,9 +324,8 @@ void vhost_dev_init(struct vhost_dev *dev,
>                  dev->log_file = NULL;
>                  dev->memory = NULL;
>                  dev->mm = NULL;
> -                spin_lock_init(&dev->work_lock);
> -                INIT_LIST_HEAD(&dev->work_list);
> -                dev->worker = NULL;
> +                dev->worker = worker;
> +                dev->owner = current;
>  
>                  for (i = 0; i < dev->nvqs; ++i) {
>                                  vq = dev->vqs[i];
> @@ -331,31 +350,6 @@ long vhost_dev_check_owner(struct vhost_dev *dev)
>  }
>  EXPORT_SYMBOL_GPL(vhost_dev_check_owner);
>  
> -struct vhost_attach_cgroups_struct {
> -                struct vhost_work work;
> -                struct task_struct *owner;
> -                int ret;
> -};
> -
> -static void vhost_attach_cgroups_work(struct vhost_work *work)
> -{
> -                struct vhost_attach_cgroups_struct *s;
> -
> -                s = container_of(work, struct 
> vhost_attach_cgroups_struct, work);
> -                s->ret = cgroup_attach_task_all(s->owner, current);
> -}
> -
> -static int vhost_attach_cgroups(struct vhost_dev *dev)
> -{
> -                struct vhost_attach_cgroups_struct attach;
> -
> -                attach.owner = current;
> -                vhost_work_init(&attach.work, vhost_attach_cgroups_work);
> -                vhost_work_queue(dev, &attach.work);
> -                vhost_work_flush(dev, &attach.work);
> -                return attach.ret;
> -}
> -
>  /* Caller should have device mutex */
>  bool vhost_dev_has_owner(struct vhost_dev *dev)
>  {
> @@ -366,7 +360,6 @@ EXPORT_SYMBOL_GPL(vhost_dev_has_owner);
>  /* Caller should have device mutex */
>  long vhost_dev_set_owner(struct vhost_dev *dev)
>  {
> -                struct task_struct *worker;
>                  int err;
>  
>                  /* Is there an owner already? */
> @@ -377,28 +370,15 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
>  
>                  /* No owner, become one */
>                  dev->mm = get_task_mm(current);
> -                worker = kthread_create(vhost_worker, dev, "vhost-%d", 
> current->pid);
> -                if (IS_ERR(worker)) {
> -                                err = PTR_ERR(worker);
> -                                goto err_worker;
> -                }
> -
>                  dev->worker = worker;
> -                wake_up_process(worker);                /* avoid 
> contributing to loadavg */
> -
> -                err = vhost_attach_cgroups(dev);
> -                if (err)
> -                                goto err_cgroup;
>  
>                  err = vhost_dev_alloc_iovecs(dev);
>                  if (err)
> -                                goto err_cgroup;
> +                                goto err_alloc;
>  
>                  return 0;
> -err_cgroup:
> -                kthread_stop(worker);
> +err_alloc:
>                  dev->worker = NULL;
> -err_worker:
>                  if (dev->mm)
>                                  mmput(dev->mm);
>                  dev->mm = NULL;
> @@ -472,11 +452,6 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool 
> locked)
>                  /* No one will access memory at this point */
>                  kfree(dev->memory);
>                  dev->memory = NULL;
> -                WARN_ON(!list_empty(&dev->work_list));
> -                if (dev->worker) {
> -                                kthread_stop(dev->worker);
> -                                dev->worker = NULL;
> -                }
>                  if (dev->mm)
>                                  mmput(dev->mm);
>                  dev->mm = NULL;
> @@ -1567,11 +1542,32 @@ EXPORT_SYMBOL_GPL(vhost_disable_notify);
>  
>  static int __init vhost_init(void)
>  {
> +                struct vhost_worker *w =
> +                                kzalloc(sizeof(*w), GFP_KERNEL);
> +                if (!w)
> +                                return -ENOMEM;
> +
> +                w->thread = kthread_create(vhost_worker,
> +                                                                   w, 
> "vhost-worker");
> +                if (IS_ERR(w->thread))
> +                                return PTR_ERR(w->thread);
> +
> +                worker = w;
> +                spin_lock_init(&worker->work_lock);
> +                INIT_LIST_HEAD(&worker->work_list);
> +                wake_up_process(worker->thread);
> +                pr_info("Created universal thread to service 
> requests\n");
> +
>                  return 0;
>  }
>  
>  static void __exit vhost_exit(void)
>  {
> +                if (worker) {
> +                                kthread_stop(worker->thread);
> +                                WARN_ON(!list_empty(&worker->work_list));
> +                                kfree(worker);
> +                }
>  }
>  
>  module_init(vhost_init);
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 8c1c792..2f204ce 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -22,6 +22,7 @@ struct vhost_work {
>                  int flushing;
>                  unsigned                                  queue_seq;
>                  unsigned                                  done_seq;
> +                struct vhost_dev          *dev;
>  };
>  
>  /* Poll a file (eventfd or socket) */
> @@ -35,8 +36,8 @@ struct vhost_poll {
>                  struct vhost_dev                 *dev;
>  };
>  
> -void vhost_work_init(struct vhost_work *work, vhost_work_fn_t fn);
> -void vhost_work_queue(struct vhost_dev *dev, struct vhost_work *work);
> +void vhost_work_init(struct vhost_dev *dev,
> +                                     struct vhost_work *work, 
> vhost_work_fn_t fn);
>  
>  void vhost_poll_init(struct vhost_poll *poll, vhost_work_fn_t fn,
>                                       unsigned long mask, struct vhost_dev 
> *dev);
> @@ -44,7 +45,6 @@ int vhost_poll_start(struct vhost_poll *poll, struct 
> file *file);
>  void vhost_poll_stop(struct vhost_poll *poll);
>  void vhost_poll_flush(struct vhost_poll *poll);
>  void vhost_poll_queue(struct vhost_poll *poll);
> -void vhost_work_flush(struct vhost_dev *dev, struct vhost_work *work);
>  long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user 
> *argp);
>  
>  struct vhost_log {
> @@ -116,11 +116,22 @@ struct vhost_dev {
>                  int nvqs;
>                  struct file *log_file;
>                  struct eventfd_ctx *log_ctx;
> +                /* vhost shared worker */
> +                struct vhost_worker *worker;
> +                /* for cgroup support */
> +                struct task_struct *owner;
> +};
> +
> +struct vhost_worker {
>                  spinlock_t work_lock;
>                  struct list_head work_list;
> -                struct task_struct *worker;
> +                struct task_struct *thread;
> +                struct task_struct *owner;
>  };
>  
> +void vhost_work_queue(struct vhost_worker *worker,
> +                                      struct vhost_work *work);
> +void vhost_work_flush(struct vhost_worker *worker, struct vhost_work 
> *work);
>  void vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int 
> nvqs);
>  long vhost_dev_set_owner(struct vhost_dev *dev);
>  bool vhost_dev_has_owner(struct vhost_dev *dev);
