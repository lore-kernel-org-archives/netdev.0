From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH v5 07/45] CPU hotplug: Provide APIs to prevent CPU offline from atomic context
Date: Tue, 29 Jan 2013 19:21:19 +0900
Message-ID: <87mwvsuw68.fsf@sejong.aot.lge.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
	<20130122073446.13822.39253.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	rjw@sisk.pl, sbw@mit.edu, fweisbec@gmail.com,
	linux@arm.linux.org.uk, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130122073446.13822.39253.stgit@srivatsabhat.in.ibm.com>
	(Srivatsa S. Bhat's message of "Tue, 22 Jan 2013 13:04:54 +0530")
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Srivatsa,

On Tue, 22 Jan 2013 13:04:54 +0530, Srivatsa S. Bhat wrote:
> @@ -246,15 +291,21 @@ struct take_cpu_down_param {
>  static int __ref take_cpu_down(void *_param)
>  {
>  	struct take_cpu_down_param *param = _param;
> -	int err;
> +	unsigned long flags;
> +	int err = 0;

It seems no need to set 'err' to 0.

Thanks,
Namhyung

> +
> +	percpu_write_lock_irqsave(&hotplug_pcpu_rwlock, &flags);
>  
>  	/* Ensure this CPU doesn't handle any more interrupts. */
>  	err = __cpu_disable();
>  	if (err < 0)
> -		return err;
> +		goto out;
>  
>  	cpu_notify(CPU_DYING | param->mod, param->hcpu);
> -	return 0;
> +
> +out:
> +	percpu_write_unlock_irqrestore(&hotplug_pcpu_rwlock, &flags);
> +	return err;
>  }
>  
>  /* Requires cpu_add_remove_lock to be held */
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
