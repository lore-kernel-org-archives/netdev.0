From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to
	hw_breakpoint
Date: Tue, 26 Jan 2010 02:02:40 +0100
Message-ID: <20100126010239.GK5087@nowhere>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3BED.6030705@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752645Ab0AZBCr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B5E3BED.6030705@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 09:48:45AM +0900, Tejun Heo wrote:
> Hello, Frederic.
> 
> On 01/26/2010 09:19 AM, Frederic Weisbecker wrote:
> > On Tue, Jan 26, 2010 at 12:22:14AM +0900, Tejun Heo wrote:
> >> Add __percpu sparse annotations to hw_breakpoint.
> >>
> >> These annotations are to make sparse consider percpu variables to be
> >> in a different address space and warn if accessed without going
> >> through percpu accessors.  This patch doesn't affect normal builds.
> >>
> >> per_cpu(nr_task_bp_pinned, cpu) is replaced with
> >> &per_cpu(nr_task_bp_pinned[0], cpu).  This is the same to the compiler
> >> but allows per_cpu() macro to correctly drop __percpu designation for
> >> the returned pointer.
> > 
> > Ouch... It's unpleasant to see such workaround that messes up the
> > code just to make sparse happy.
> > 
> > I guess __percpu is an address_space attribute? Is there no
> > way to force the address space change directly from the
> > per_cpu() macro?
> 
> Yeah, per_cpu() macro does that but when things get a bit complicated
> with static percpu arrays.  In the above case, the variable is defined
> as
> 
>   static DEFINE_PER_CPU(unsigned int, nr_task_bp_pinned[HBP_NUM]);
> 
> which gets translated to
> 
>   static __attribute__((noderef, address_space(3))) \
> 	 __attribute__((section(.data.percpu))) \
> 	 __typeof__(unsigned int) nr_task_bp_pinned[HBP_NUM];
> 
> The above tells sparse that the members of nr_task_bp_pinned array are
> in address space 3 which is correct.  The problematic dereference was
> 
>   unsigned int *task_pinned = per_cpu(nr_task_bp_pinned, cpu)
> 
> per_cpu() macro changes the address space of the resulting address but
> it does so assuming that the parameter it got passed is the one which
> got declared to be in the percpu address space.  It casts
> nr_task_bp_pinned itself, which to the sparse isn't in the percpu
> address space, to the kernel address space.  So, the workaround is
> basically to give per_cpu() macro the same thing that was defined.
> 
> This type of usage (define as array, dereference the array as address)
> was the only place where I needed to work around to make address space
> change explicit.  There are two places which needed this and hwbreak
> was one.  The options were...
> 
> * Leave it alone.  We can live with a few additional sparse warnings.
> 
> * Make the proposed change.  It is slightly ugly but not cryptic or
>   difficult.
> 
> * Somehow teach per_cpu() macro or sparse how to handle the above
>   right.
> 
> I tried to improve per_cpu() macro but couldn't do it in any sane way.
> Leaving it alone isn't too bad either but given that the workaround is
> not horribly unreadable, I think it's best to use the slightly less
> elegant form in the few places where they are needed.



Ok.

Well, sorry I must be missing something obvious, but is it impossible
to make per_cpu(var, cpu) returning something cast in:

	(typeof(var) __force)

Or I guess you did that already and it is not working with static
arrays, or?

Is there a patch that shows per_cpu() macro changes in the batch?

Thanks.
