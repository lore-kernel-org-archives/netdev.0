From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH UPDATED 3/3] vhost: apply cpumask and cgroup to vhost
 pollers
Date: Mon, 31 May 2010 15:48:29 +0800
Message-ID: <4C0369CD.70008@cn.fujitsu.com>
References: <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com> <4C02C99D.9070204@kernel.org> <4C030CB8.505@cn.fujitsu.com> <4C035E22.9010001@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Oleg Nesterov <oleg@redhat.com>,
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
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4C035E22.9010001@kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  	poller = kthread_create(vhost_poller, dev, "vhost-%d", current->pid);
> -	if (IS_ERR(poller))
> -		return PTR_ERR(poller);
> +	if (IS_ERR(poller)) {
> +		ret = PTR_ERR(poller);
> +		goto out;

here...

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
> +	if (ret && poller)

It's still buggy..

> +		kthread_stop(poller);
> +	free_cpumask_var(mask);
> +	return ret;
>  }
> 
>  /* Caller should have device mutex */
> 
> 
