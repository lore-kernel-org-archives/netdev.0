From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 28 Jan 2009 13:07:57 -0500
Message-ID: <20090128180757.GA9908@Krystal>
References: <20090115183942.GA6325@elte.hu> <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org> <200901282108.51864.rusty@rustcorp.com.au> <alpine.DEB.1.10.0901281148540.13825@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754525AbZA1SN3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0901281148540.13825@qirst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Christoph Lameter (cl@linux-foundation.org) wrote:
> On Wed, 28 Jan 2009, Rusty Russell wrote:
> 
> > AFAICT we'll need a hybrid: HAVE_NMISAFE_CPUOPS, and if not, use atomic_t
> > in ftrace (which isn't NMI safe on parisc or sparc/32 anyway, but I don't think we care).
> 
> Right.
> 

Ideally this should be done transparently so we don't have to #ifdef
code around HAVE_NMISAFE_CPUOPS everywhere in the tracer. We might
consider declaring an intermediate type with this kind of #ifdef in the
tracer code if we are the only one user though.

> 
> > Other than the shouting, I liked Christoph's system:
> > - CPU_INC = always safe (eg. local_irq_save/per_cpu(i)++/local_irq_restore)
> > - _CPU_INC = not safe against interrupts (eg. get_cpu/per_cpu(i)++/put_cpu)
> > - __CPU_INC = not safe against anything (eg. per_cpu(i)++)
> >
> > I prefer the name 'local' to the name 'cpu', but I'm not hugely fussed.
> 
> The term cpu is meaning multiple things at this point. So yes it may be
> better to go with glibc naming of thread local space.
> 

However using "local" for "per-cpu" could be confusing with the glibc
naming of thread local space, because "per-thread" and "per-cpu"
variables are different from a synchronization POV and we can end up
needing both (e.g. a thread local variable can never be accessed by
another thread, but a cpu local variable could be accessed by a
different CPU due to scheduling).

I'm currently thinking about implementing user-space per-cpu tracing buffers,
and the last thing I'd like is to have a "local" semantic clash between
the kernel and glibc. Ideally, we could have something like :

Atomic safe primitives (emulated with irq disable if the architecture
does not have atomic primitives) :
- atomic_thread_inc()
  * current mainline local_t local_inc().
- atomic_cpu_inc()
  * Your proposed CPU_INC.

Non-safe against interrupts, but safe against preemption :
- thread_inc()
  * no preempt_disable involved, because this deals with per-thread
    variables :
    * Simple var++
- cpu_inc()
  * disables preemption, per_cpu(i)++, enables preemption

Not safe against preemption nor interrupts :
- _thread_inc()
  * maps to thread_inc()
- _cpu_inc()
  * simple per_cpu(i)++

So maybe we don't really need thread_inc(), _thread_inc() and _cpu_inc,
because they map to standard C operations, but we may find that in some
architectures that the atomic_cpu_inc() is faster than the per_cpu(i)++,
and in those cases it would make sense to map e.g. _cpu_inc() to
atomic_cpu_inc().

Also note that don't think adding _ and __ prefixes to the operations
makes it clear for the programmer and reviewer what is safe against
what. OMHO, it will just make the code more obscure. One level of
underscore is about the limit I think people can "know" what this
"unsafe" version of the primitive does.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
