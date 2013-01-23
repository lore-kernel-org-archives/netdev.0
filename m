From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 04/45] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Wed, 23 Jan 2013 10:55:22 -0800
Message-ID: <20130123185522.GG2373@mtj.dyndns.org>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
 <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, peterz@infradead.org, oleg@redhat.com,
	paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Srivatsa.

First of all, I'm not sure whether we need to be this step-by-step
when introducing something new.  It's not like we're transforming an
existing implementation and it doesn't seem to help understanding the
series that much either.

On Tue, Jan 22, 2013 at 01:03:53PM +0530, Srivatsa S. Bhat wrote:
> Using global rwlocks as the backend for per-CPU rwlocks helps us avoid many
> lock-ordering related problems (unlike per-cpu locks). However, global

So, unfortunately, this already seems broken, right?  The problem here
seems to be that previously, say, read_lock() implied
preempt_disable() but as this series aims to move away from it, it
introduces the problem of locking order between such locks and the new
contruct.

The only two options are either punishing writers or identifying and
updating all such possible deadlocks.  percpu_rwsem does the former,
right?  I don't know how feasible the latter would be.  Srivatsa,
you've been looking at all the places which would require conversion,
how difficult would doing the latter be?

> +#define reader_uses_percpu_refcnt(pcpu_rwlock, cpu)			\
> +		(ACCESS_ONCE(per_cpu(*((pcpu_rwlock)->reader_refcnt), cpu)))
> +
> +#define reader_nested_percpu(pcpu_rwlock)				\
> +			(__this_cpu_read(*((pcpu_rwlock)->reader_refcnt)) > 1)
> +
> +#define writer_active(pcpu_rwlock)					\
> +			(__this_cpu_read(*((pcpu_rwlock)->writer_signal)))

Why are these in the public header file?  Are they gonna be used to
inline something?

> +static inline void raise_writer_signal(struct percpu_rwlock *pcpu_rwlock,
> +				       unsigned int cpu)
> +{
> +	per_cpu(*pcpu_rwlock->writer_signal, cpu) = true;
> +}
> +
> +static inline void drop_writer_signal(struct percpu_rwlock *pcpu_rwlock,
> +				      unsigned int cpu)
> +{
> +	per_cpu(*pcpu_rwlock->writer_signal, cpu) = false;
> +}
> +
> +static void announce_writer_active(struct percpu_rwlock *pcpu_rwlock)
> +{
> +	unsigned int cpu;
> +
> +	for_each_online_cpu(cpu)
> +		raise_writer_signal(pcpu_rwlock, cpu);
> +
> +	smp_mb(); /* Paired with smp_rmb() in percpu_read_[un]lock() */
> +}
> +
> +static void announce_writer_inactive(struct percpu_rwlock *pcpu_rwlock)
> +{
> +	unsigned int cpu;
> +
> +	drop_writer_signal(pcpu_rwlock, smp_processor_id());
> +
> +	for_each_online_cpu(cpu)
> +		drop_writer_signal(pcpu_rwlock, cpu);
> +
> +	smp_mb(); /* Paired with smp_rmb() in percpu_read_[un]lock() */
> +}

It could be just personal preference but I find the above one line
wrappers more obfuscating than anything else.  What's the point of
wrapping writer_signal = true/false into a separate function?  These
simple wrappers just add layers that people have to dig through to
figure out what's going on without adding anything of value.  I'd much
prefer collapsing these into the percpu_write_[un]lock().

Thanks.

-- 
tejun
