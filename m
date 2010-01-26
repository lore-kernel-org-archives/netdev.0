From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to
	hw_breakpoint
Date: Tue, 26 Jan 2010 03:10:42 +0100
Message-ID: <20100126021041.GN5087@nowhere>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3BED.6030705@kernel.org> <20100126010239.GK5087@nowhere> <4B5E4308.8020105@kernel.org> <20100126020113.GM5087@nowhere>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753477Ab0AZCKt@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100126020113.GM5087@nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 03:01:14AM +0100, Frederic Weisbecker wrote:
> On Tue, Jan 26, 2010 at 10:19:04AM +0900, Tejun Heo wrote:
> > Hello,
> > 
> > On 01/26/2010 10:02 AM, Frederic Weisbecker wrote:
> > > Well, sorry I must be missing something obvious, but is it impossible
> > > to make per_cpu(var, cpu) returning something cast in:
> > > 
> > > 	(typeof(var) __force)
> > > 
> > > Or I guess you did that already and it is not working with static
> > > arrays, or?
> > 
> > Yeap, the definition looks like
> > 
> >  #define SHIFT_PERCPU_PTR(__p, __offset)	({			\
> > 	__verify_pcpu_ptr((__p));					\
> > 	RELOC_HIDE((typeof(*(__p)) __kernel __force *)(__p), (__offset)); \
> >  })
> > 
> >  #define per_cpu(var, cpu) \
> > 	(*SHIFT_PERCPU_PTR(&(var), per_cpu_offset(cpu)))
> > 
> > but it just ends up putting the __force at the wrong layer.  It seems
> > that (typeof(var) __kernel __force) tell sparse var is in the kernel
> > address space but not its members.
> 
> 
> So, may be it considers you are applying the address space overriding
> to the pointer to the type and not to the type itself.
> 
> Consider:
> 
> 	int __percpu i;
> 
> What you do above *might* be considered as if SHIFT_PERCPU_PTR
> returns something of a type:
> 
> 	int * __percpu i;
> 
> So the pointer is in the normal address space, but its content is in
> __percpu address space.
> 
> What if you do this:
> 
> 
> #define SHIFT_PERCPU_PTR(__p, __offset)      ({                      \
>       __verify_pcpu_ptr((__p));                                       \
>       RELOC_HIDE((__p), (__offset)); \
> })
> 
> #define per_cpu(var, cpu) \
>       (typeof(var) __kernel __force)(*SHIFT_PERCPU_PTR(&(var), per_cpu_offset(cpu)))
> 
> This should work because &(var) should be dereferencable directly, since
> it is not of type "__force t" but of type "*__force t"
> 
> And you're not doing anymore this:
> 
> 	*(int * __kernel __force) i;
> but
> 	*(int __kernel __force *) i;



The above is perhaps a bit confusing.
To be more clear, in the first case you only cast the pointer
to the type, which gives you a pointer valid in kernel space
to data valid in percpu space.

The second case gives you something valid in kernel space for both.
