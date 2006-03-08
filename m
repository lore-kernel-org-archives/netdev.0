From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/4] net: percpufy frequently used vars --
 proto.sockets_allocated
Date: Tue, 7 Mar 2006 18:16:02 -0800
Message-ID: <20060307181602.77030e2a.akpm@osdl.org>
References: <20060308015808.GA9062@localhost.localdomain>
	<20060308020227.GD9062@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752031AbWCHCSF@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060308020227.GD9062@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>
> --- linux-2.6.16-rc5mm3.orig/include/net/sock.h	2006-03-07 15:09:22.000000000 -0800
>  +++ linux-2.6.16-rc5mm3/include/net/sock.h	2006-03-07 15:09:52.000000000 -0800
>  @@ -543,7 +543,7 @@ struct proto {
>   	/* Memory pressure */
>   	void			(*enter_memory_pressure)(void);
>   	struct percpu_counter	*memory_allocated;	/* Current allocated memory. */
>  -	atomic_t		*sockets_allocated;	/* Current number of sockets. */
>  +	int                     *sockets_allocated;     /* Current number of sockets (percpu counter). */
>   
>   	/*
>   	 * Pressure flag: try to collapse.
>  @@ -579,6 +579,24 @@ struct proto {
>   	} stats[NR_CPUS];
>   };
>   
>  +static inline int read_sockets_allocated(struct proto *prot)
>  +{
>  +	int total = 0;
>  +	int cpu;
>  +	for_each_cpu(cpu)
>  +		total += *per_cpu_ptr(prot->sockets_allocated, cpu);
>  +	return total;
>  +}

This is likely too big to be inlined, plus sock.h doesn't include enough
headers to reliably compile this code.

>  +static inline void mod_sockets_allocated(int *sockets_allocated, int count)
>  +{
>  +	(*per_cpu_ptr(sockets_allocated, get_cpu())) += count;
>  +	put_cpu();
>  +}
>  +

Ditto.
