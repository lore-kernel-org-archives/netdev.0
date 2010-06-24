From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] vhost: apply cpumask and cgroup to vhost pollers
Date: Thu, 24 Jun 2010 11:11:35 +0300
Message-ID: <20100624081135.GA937@redhat.com>
References: <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com> <4C02C99D.9070204@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C02C99D.9070204@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 30, 2010 at 10:25:01PM +0200, Tejun Heo wrote:
> Apply the cpumask and cgroup of the initializing task to the created
> vhost poller.
> 
> Based on Sridhar Samudrala's patch.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>


I wanted to apply this, but modpost fails:
ERROR: "sched_setaffinity" [drivers/vhost/vhost_net.ko] undefined!
ERROR: "sched_getaffinity" [drivers/vhost/vhost_net.ko] undefined!

Did you try building as a module?

> ---
>  drivers/vhost/vhost.c |   36 +++++++++++++++++++++++++++++++-----
>  1 file changed, 31 insertions(+), 5 deletions(-)
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
> @@ -176,12 +177,30 @@ repeat:
>  long vhost_dev_init(struct vhost_dev *dev,
>  		    struct vhost_virtqueue *vqs, int nvqs)
>  {
> -	struct task_struct *poller;
> -	int i;
> +	struct task_struct *poller = NULL;
> +	cpumask_var_t mask;
> +	int i, ret = -ENOMEM;
> +
> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> +		goto out;
> 
>  	poller = kthread_create(vhost_poller, dev, "vhost-%d", current->pid);
> -	if (IS_ERR(poller))
> -		return PTR_ERR(poller);
> +	if (IS_ERR(poller)) {
> +		ret = PTR_ERR(poller);
> +		goto out;
> +	}
> +
> +	ret = sched_getaffinity(current->pid, mask);
> +	if (ret)
> +		goto out;
> +
> +	ret = sched_setaffinity(poller->pid, mask);
> +	if (ret)
> +		goto out;
> +
> +	ret = cgroup_attach_task_current_cg(poller);
> +	if (ret)
> +		goto out;
> 
>  	dev->vqs = vqs;
>  	dev->nvqs = nvqs;
> @@ -202,7 +221,14 @@ long vhost_dev_init(struct vhost_dev *de
>  			vhost_poll_init(&dev->vqs[i].poll,
>  					dev->vqs[i].handle_kick, POLLIN, dev);
>  	}
> -	return 0;
> +
> +	wake_up_process(poller);	/* avoid contributing to loadavg */
> +	ret = 0;
> +out:
> +	if (ret)
> +		kthread_stop(poller);
> +	free_cpumask_var(mask);
> +	return ret;
>  }
> 
>  /* Caller should have device mutex */
