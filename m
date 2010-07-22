From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Thu, 22 Jul 2010 23:21:40 +0200
Message-ID: <4C48B664.9000109@kernel.org>
References: <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com> <4C02C961.9050606@kernel.org> <20100531152221.GB2987@redhat.com> <4C03D983.9010905@kernel.org> <20100531160020.GC3067@redhat.com> <4C04D41B.4050704@kernel.org> <4C06A580.9060300@kernel.org> <20100722155840.GA1743@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
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
In-Reply-To: <20100722155840.GA1743@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/22/2010 05:58 PM, Michael S. Tsirkin wrote:
> All the tricky barrier pairing made me uncomfortable.  So I came up with
> this on top (untested): if we do all operations under the spinlock, we
> can get by without barriers and atomics.  And since we need the lock for
> list operations anyway, this should have no paerformance impact.
> 
> What do you think?

I've created kthread_worker in wq#for-next tree and already converted
ivtv to use it.  Once this lands in mainline, I think converting vhost
to use it would be better choice.  kthread worker code uses basically
the same logic used in the vhost_workqueue code but is better
organized and documented.  So, I think it would be better to stick
with the original implementation, as otherwise we're likely to just
decrease test coverage without much gain.

  http://git.kernel.org/?p=linux/kernel/git/tj/wq.git;a=commitdiff;h=b56c0d8937e665a27d90517ee7a746d0aa05af46;hp=53c5f5ba42c194cb13dd3083ed425f2c5b1ec439

> @@ -151,37 +161,37 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>  static int vhost_worker(void *data)
>  {
>  	struct vhost_dev *dev = data;
> -	struct vhost_work *work;
> +	struct vhost_work *work = NULL;
>  
> -repeat:
> -	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
> +	for (;;) {
> +		set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
>  
> -	if (kthread_should_stop()) {
> -		__set_current_state(TASK_RUNNING);
> -		return 0;
> -	}
> +		if (kthread_should_stop()) {
> +			__set_current_state(TASK_RUNNING);
> +			return 0;
> +		}
>  
> -	work = NULL;
> -	spin_lock_irq(&dev->work_lock);
> -	if (!list_empty(&dev->work_list)) {
> -		work = list_first_entry(&dev->work_list,
> -					struct vhost_work, node);
> -		list_del_init(&work->node);
> -	}
> -	spin_unlock_irq(&dev->work_lock);
> +		spin_lock_irq(&dev->work_lock);
> +		if (work) {
> +			work->done_seq = work->queue_seq;
> +			if (work->flushing)
> +				wake_up_all(&work->done);

I don't think doing this before executing the function is correct, so
you'll have to release the lock, execute the function, regrab the lock
and then do the flush processing.

Thanks.

-- 
tejun
