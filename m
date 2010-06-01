From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 3/3] vhost: apply cpumask and cgroup to vhost workers
Date: Tue, 01 Jun 2010 10:19:14 -0700
Message-ID: <1275412754.989.10.camel@w-sridhar.beaverton.ibm.com>
References: <20100527163954.GA21710@redhat.com>
	 <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com>
	 <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com>
	 <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com>
	 <4C02C961.9050606@kernel.org> <20100531152221.GB2987@redhat.com>
	 <4C03D983.9010905@kernel.org> <20100531160020.GC3067@redhat.com>
	 <4C04D453.9040208@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Oleg Nesterov <oleg@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4C04D453.9040208@kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-06-01 at 11:35 +0200, Tejun Heo wrote:
> Apply the cpumask and cgroup of the initializing task to the created
> vhost worker.
> 
> Based on Sridhar Samudrala's patch.  Li Zefan spotted a bug in error
> path (twice), fixed (twice).
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  drivers/vhost/vhost.c |   34 ++++++++++++++++++++++++++++++----
>  1 file changed, 30 insertions(+), 4 deletions(-)
> 
> Index: work/drivers/vhost/vhost.c
> ===================================================================
> --- work.orig/drivers/vhost/vhost.c
> +++ work/drivers/vhost/vhost.c
> @@ -23,6 +23,7 @@
>  #include <linux/highmem.h>
>  #include <linux/slab.h>
>  #include <linux/kthread.h>
> +#include <linux/cgroup.h>
> 
>  #include <linux/net.h>
>  #include <linux/if_packet.h>
> @@ -187,11 +188,29 @@ long vhost_dev_init(struct vhost_dev *de
>  		    struct vhost_virtqueue *vqs, int nvqs)
>  {
>  	struct task_struct *worker;
> -	int i;
> +	cpumask_var_t mask;
> +	int i, ret = -ENOMEM;
> +
> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> +		goto out_free_mask;

I think this is another bug in the error path. You should simply
do a return instead of a goto here when aloc_cpu_mask fails.

Thanks
Sridhar
> 
>  	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
> -	if (IS_ERR(worker))
> -		return PTR_ERR(worker);
> +	if (IS_ERR(worker)) {
> +		ret = PTR_ERR(worker);
> +		goto out_free_mask;
> +	}
> +
> +	ret = sched_getaffinity(current->pid, mask);
> +	if (ret)
> +		goto out_stop_worker;
> +
> +	ret = sched_setaffinity(worker->pid, mask);
> +	if (ret)
> +		goto out_stop_worker;
> +
> +	ret = cgroup_attach_task_current_cg(worker);
> +	if (ret)
> +		goto out_stop_worker;
> 
>  	dev->vqs = vqs;
>  	dev->nvqs = nvqs;
> @@ -214,7 +233,14 @@ long vhost_dev_init(struct vhost_dev *de
>  	}
> 
>  	wake_up_process(worker);	/* avoid contributing to loadavg */
> -	return 0;
> +	ret = 0;
> +	goto out_free_mask;
> +
> +out_stop_worker:
> +	kthread_stop(worker);
> +out_free_mask:
> +	free_cpumask_var(mask);
> +	return ret;
>  }
> 
>  /* Caller should have device mutex */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

