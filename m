From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [RFC PATCH tip/master 2/3] kprobes: Allocate kretprobe instance if its free list is empty
Date: Wed, 29 Mar 2017 17:25:10 +0900
Message-ID: <20170329172510.e012406497fd38a54d5069b3@kernel.org>
References: <149076484118.24574.7083269903420611708.stgit@devbox>	<149076498222.24574.679546540523044200.stgit@devbox>	<20170329063005.GA12220@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alban Crequy <alban.crequy@gmail.com>, Alban Crequy <alban@kinvolk.io>, Alexei Starovoitov <ast@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Arnaldo Carvalho de Melo <acme@redhat.com>, Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, iago@kinvolk.io, michael@kinvolk.io, Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <systemtap-return-25241-gls-systemtap=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
In-Reply-To: <20170329063005.GA12220@gmail.com>
List-Id: netdev.vger.kernel.org

On Wed, 29 Mar 2017 08:30:05 +0200
Ingo Molnar <mingo@kernel.org> wrote:
> 
> * Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > @@ -1824,6 +1823,30 @@ void unregister_jprobes(struct jprobe **jps, int num)
> >  EXPORT_SYMBOL_GPL(unregister_jprobes);
> >  
> >  #ifdef CONFIG_KRETPROBES
> > +
> > +/* Try to use free instance first, if failed, try to allocate new instance */
> > +struct kretprobe_instance *kretprobe_alloc_instance(struct kretprobe *rp)
> > +{
> > +	struct kretprobe_instance *ri = NULL;
> > +	unsigned long flags = 0;
> > +
> > +	raw_spin_lock_irqsave(&rp->lock, flags);
> > +	if (!hlist_empty(&rp->free_instances)) {
> > +		ri = hlist_entry(rp->free_instances.first,
> > +				struct kretprobe_instance, hlist);
> > +		hlist_del(&ri->hlist);
> > +	}
> > +	raw_spin_unlock_irqrestore(&rp->lock, flags);
> > +
> > +	/* Populate max active instance if possible */
> > +	if (!ri && rp->maxactive < KRETPROBE_MAXACTIVE_ALLOC) {
> > +		ri = kmalloc(sizeof(*ri) + rp->data_size, GFP_ATOMIC);
> > +		if (ri)
> > +			rp->maxactive++;
> > +	}
> > +
> > +	return ri;
> > +}
> >  /*
> >   * This kprobe pre_handler is registered with every kretprobe. When probe
> >   * hits it will set up the return probe.
> > @@ -1846,14 +1869,8 @@ static int pre_handler_kretprobe(struct kprobe *p, struct pt_regs *regs)
> >  	}
> >  
> >  	/* TODO: consider to only swap the RA after the last pre_handler fired */
> > -	hash = hash_ptr(current, KPROBE_HASH_BITS);
> > -	raw_spin_lock_irqsave(&rp->lock, flags);
> > -	if (!hlist_empty(&rp->free_instances)) {
> > -		ri = hlist_entry(rp->free_instances.first,
> > -				struct kretprobe_instance, hlist);
> > -		hlist_del(&ri->hlist);
> > -		raw_spin_unlock_irqrestore(&rp->lock, flags);
> > -
> > +	ri = kretprobe_alloc_instance(rp);
> > +	if (ri) {
> >  		ri->rp = rp;
> >  		ri->task = current;
> >  
> > @@ -1868,13 +1885,13 @@ static int pre_handler_kretprobe(struct kprobe *p, struct pt_regs *regs)
> >  
> >  		/* XXX(hch): why is there no hlist_move_head? */
> >  		INIT_HLIST_NODE(&ri->hlist);
> > +		hash = hash_ptr(current, KPROBE_HASH_BITS);
> >  		kretprobe_table_lock(hash, &flags);
> >  		hlist_add_head(&ri->hlist, &kretprobe_inst_table[hash]);
> >  		kretprobe_table_unlock(hash, &flags);
> > -	} else {
> > +	} else
> >  		rp->nmissed++;
> > -		raw_spin_unlock_irqrestore(&rp->lock, flags);
> > -	}
> > +
> >  	return 0;
> >  }
> >  NOKPROBE_SYMBOL(pre_handler_kretprobe);
> 
> So this is something I missed while the original code was merged, but the concept 
> looks a bit weird: why do we do any "allocation" while a handler is executing?
> 
> That's fundamentally fragile. What's the maximum number of parallel 
> 'kretprobe_instance' required per kretprobe - one per CPU?

It depends on the place where we put the probe. If the probed function will be
blocked (yield to other tasks), then we need a same number of threads on
the system which can invoke the function. So, ultimately, it is same
as function_graph tracer, we need it for each thread.

> 
> If so then we should preallocate all of them when they are installed and not do 
> any alloc/free dance when executing them.
> 
> This will also speed them up, and increase robustness all around.

I see, kretprobe already do that, and I keep it on the code.

By default, kretprobe will allocate NR_CPU of kretprobe_instance for each
kretprobe. For usual usecase (deeper inside functions in kernel) that is OK.
However, as Lukasz reported, for the function near the syscall entry, it may
require more instances. In that case, kretprobe user needs to increase
maxactive before registering kretprobes, which will be done by Alban's patch.

However, the next question is, how many instances are actually needed.
User may have to do trial & error loop to find that. For professional users,
they will do that, but for the light users, they may not want to do that.

I'm also considering to provide a "knob" of disabing this dynamic allocation
feature on debugfs, which will help users who would like to avoid memory
allocation on kretprobe.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
