From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [RFC PATCH tip/master 2/3] kprobes: Allocate kretprobe instance
 if its free list is empty
Date: Thu, 30 Mar 2017 09:39:08 +0900
Message-ID: <20170330093908.70106bda02c5f5915b0375ba@kernel.org>
References: <149076484118.24574.7083269903420611708.stgit@devbox>
        <149076498222.24574.679546540523044200.stgit@devbox>
        <20170329063005.GA12220@gmail.com>
        <20170329172510.e012406497fd38a54d5069b3@kernel.org>
        <943c03db-0bfb-d03f-5ebb-fc7e6a5b5519@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>,
        Alban Crequy <alban.crequy@gmail.com>,
        Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iago@kinvolk.io, michael@kinvolk.io,
        Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Josh Stone <jistone@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <943c03db-0bfb-d03f-5ebb-fc7e6a5b5519@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Mar 2017 10:18:48 -0700
Josh Stone <jistone@redhat.com> wrote:

> On 03/29/2017 01:25 AM, Masami Hiramatsu wrote:
> > On Wed, 29 Mar 2017 08:30:05 +0200
> > Ingo Molnar <mingo@kernel.org> wrote:
> >>
> >> * Masami Hiramatsu <mhiramat@kernel.org> wrote:
> >>
> >>> @@ -1824,6 +1823,30 @@ void unregister_jprobes(struct jprobe **jps, int num)
> >>>  EXPORT_SYMBOL_GPL(unregister_jprobes);
> >>>  
> >>>  #ifdef CONFIG_KRETPROBES
> >>> +
> >>> +/* Try to use free instance first, if failed, try to allocate new instance */
> >>> +struct kretprobe_instance *kretprobe_alloc_instance(struct kretprobe *rp)
> >>> +{
> >>> +	struct kretprobe_instance *ri = NULL;
> >>> +	unsigned long flags = 0;
> >>> +
> >>> +	raw_spin_lock_irqsave(&rp->lock, flags);
> >>> +	if (!hlist_empty(&rp->free_instances)) {
> >>> +		ri = hlist_entry(rp->free_instances.first,
> >>> +				struct kretprobe_instance, hlist);
> >>> +		hlist_del(&ri->hlist);
> >>> +	}
> >>> +	raw_spin_unlock_irqrestore(&rp->lock, flags);
> >>> +
> >>> +	/* Populate max active instance if possible */
> >>> +	if (!ri && rp->maxactive < KRETPROBE_MAXACTIVE_ALLOC) {
> >>> +		ri = kmalloc(sizeof(*ri) + rp->data_size, GFP_ATOMIC);
> >>> +		if (ri)
> >>> +			rp->maxactive++;
> >>> +	}
> >>> +
> >>> +	return ri;
> >>> +}
> >>>  /*
> >>>   * This kprobe pre_handler is registered with every kretprobe. When probe
> >>>   * hits it will set up the return probe.
> >>> @@ -1846,14 +1869,8 @@ static int pre_handler_kretprobe(struct kprobe *p, struct pt_regs *regs)
> >>>  	}
> >>>  
> >>>  	/* TODO: consider to only swap the RA after the last pre_handler fired */
> >>> -	hash = hash_ptr(current, KPROBE_HASH_BITS);
> >>> -	raw_spin_lock_irqsave(&rp->lock, flags);
> >>> -	if (!hlist_empty(&rp->free_instances)) {
> >>> -		ri = hlist_entry(rp->free_instances.first,
> >>> -				struct kretprobe_instance, hlist);
> >>> -		hlist_del(&ri->hlist);
> >>> -		raw_spin_unlock_irqrestore(&rp->lock, flags);
> >>> -
> >>> +	ri = kretprobe_alloc_instance(rp);
> >>> +	if (ri) {
> >>>  		ri->rp = rp;
> >>>  		ri->task = current;
> >>>  
> >>> @@ -1868,13 +1885,13 @@ static int pre_handler_kretprobe(struct kprobe *p, struct pt_regs *regs)
> >>>  
> >>>  		/* XXX(hch): why is there no hlist_move_head? */
> >>>  		INIT_HLIST_NODE(&ri->hlist);
> >>> +		hash = hash_ptr(current, KPROBE_HASH_BITS);
> >>>  		kretprobe_table_lock(hash, &flags);
> >>>  		hlist_add_head(&ri->hlist, &kretprobe_inst_table[hash]);
> >>>  		kretprobe_table_unlock(hash, &flags);
> >>> -	} else {
> >>> +	} else
> >>>  		rp->nmissed++;
> >>> -		raw_spin_unlock_irqrestore(&rp->lock, flags);
> >>> -	}
> >>> +
> >>>  	return 0;
> >>>  }
> >>>  NOKPROBE_SYMBOL(pre_handler_kretprobe);
> >>
> >> So this is something I missed while the original code was merged, but the concept 
> >> looks a bit weird: why do we do any "allocation" while a handler is executing?
> >>
> >> That's fundamentally fragile. What's the maximum number of parallel 
> >> 'kretprobe_instance' required per kretprobe - one per CPU?
> > 
> > It depends on the place where we put the probe. If the probed function will be
> > blocked (yield to other tasks), then we need a same number of threads on
> > the system which can invoke the function. So, ultimately, it is same
> > as function_graph tracer, we need it for each thread.
> 
> Isn't it also possible that the function may be reentrant?  Whether by
> plain recursion or an interrupt call, this leads to multiple live
> instances even for a given thread.

Yes, that's another possible case, but I don't think that's so serious in kernel
because we have very limited kernel stack, which means the recursion may not
so deep.

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
