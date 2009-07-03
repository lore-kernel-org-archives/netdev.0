From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 10:04:01 -0400
Message-ID: <20090703140401.GA10256@Krystal>
References: <20090703081219.GE2902@jolsa.lab.eng.brq.redhat.com> <20090703081445.GG2902@jolsa.lab.eng.brq.redhat.com> <20090703090606.GA3902@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jiri Olsa <jolsa@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org, eric.dumazet@gmail.com,
	Paul McKenney <Paul.McKenney@us.ibm.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757968AbZGCOGT@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090703090606.GA3902@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ingo Molnar (mingo@elte.hu) wrote:
> 
> * Jiri Olsa <jolsa@redhat.com> wrote:
> 
> > +++ b/arch/x86/include/asm/spinlock.h
> > @@ -302,4 +302,7 @@ static inline void __raw_write_unlock(raw_rwlock_t *rw)
> >  #define _raw_read_relax(lock)	cpu_relax()
> >  #define _raw_write_relax(lock)	cpu_relax()
> >  
> > +/* The {read|write|spin}_lock() on x86 are full memory barriers. */
> > +#define smp_mb__after_lock() do { } while (0)
> 

Hm. Looking at http://lkml.org/lkml/2009/6/23/192, a very basic question
comes to my mind :

Why don't we create a read_lock without acquire semantic instead (e.g.
read_lock_nomb(), or something with a better name like __read_lock()) ?
On architectures where memory barriers are needed to provide the acquire
semantic, it would be faster to do :

__read_lock();
smp_mb();

than :

read_lock(); <- e.g. lwsync + isync or something like that
smp_mb(); <- full sync.

Second point : __add_wait_queue/waitqueue_active/wake_up_interruptible
would probably benefit from adding comments about their combined use
with other checks and how nice memory barriers are.

Mathieu


> Two small stylistic comments, please make this an inline function:
> 
> static inline void smp_mb__after_lock(void) { }
> #define smp_mb__after_lock
> 
> (untested)
> 
> > +/* The lock does not imply full memory barrier. */
> > +#ifndef smp_mb__after_lock
> > +#define smp_mb__after_lock() smp_mb()
> > +#endif
> 
> ditto.
> 
> 	Ingo

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
