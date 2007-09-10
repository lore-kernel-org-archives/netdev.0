From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Mon, 10 Sep 2007 14:38:35 +0100
Message-ID: <200709101438.36710.vda.linux@googlemail.com>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <200709101156.30010.vda.linux@googlemail.com> <6370BBDF-0C79-41EB-BD2A-02AA0D216924@mac.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing
To: Kyle Moffett <mrmacman_g4@mac.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759923AbXIJNjG@vger.kernel.org>
In-Reply-To: <6370BBDF-0C79-41EB-BD2A-02AA0D216924@mac.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 September 2007 13:22, Kyle Moffett wrote:
> On Sep 10, 2007, at 06:56:29, Denys Vlasenko wrote:
> > On Sunday 09 September 2007 19:18, Arjan van de Ven wrote:
> >> On Sun, 9 Sep 2007 19:02:54 +0100
> >> Denys Vlasenko <vda.linux@googlemail.com> wrote:
> >>
> >>> Why is all this fixation on "volatile"? I don't think people want  
> >>> "volatile" keyword per se, they want atomic_read(&x) to _always_  
> >>> compile into an memory-accessing instruction, not register access.
> >>
> >> and ... why is that?  is there any valid, non-buggy code sequence  
> >> that makes that a reasonable requirement?
> >
> > Well, if you insist on having it again:
> >
> > Waiting for atomic value to be zero:
> >
> >         while (atomic_read(&x))
> >                 continue;
> >
> > gcc may happily convert it into:
> >
> >         reg = atomic_read(&x);
> >         while (reg)
> >                 continue;
> 
> Bzzt.  Even if you fixed gcc to actually convert it to a busy loop on  
> a memory variable, you STILL HAVE A BUG as it may *NOT* be gcc that  
> does the conversion, it may be that the CPU does the caching of the  
> memory value.  GCC has no mechanism to do cache-flushes or memory- 
> barriers except through our custom inline assembly.

CPU can cache the value all right, but it cannot use that cached value
*forever*, it has to react to invalidate cycles on the shared bus
and re-fetch new data.

IOW: atomic_read(&x) which compiles down to memory accessor
will work properly.

> the CPU.  Thirdly, on a large system it may take some arbitrarily  
> large amount of time for cache-propagation to update the value of the  
> variable in your local CPU cache.

Yes, but "arbitrarily large amount of time" is actually measured
in nanoseconds here. Let's say 1000ns max for hundreds of CPUs?

> Also, you   
> probably want a cpu_relax() in there somewhere to avoid overheating  
> the CPU.

Yes, but 
1. CPU shouldn't overheat (in a sense that it gets damaged),
   it will only use more power than needed.
2. cpu_relax() just throttles down my CPU, so it's performance
   optimization only. Wait, it isn't, it's a barrier too.
   Wow, "cpu_relax" is a barrier? How am I supposed to know
   that without reading lkml flamewars and/or header files?

Let's try reading headers. asm-x86_64/processor.h:

#define cpu_relax()   rep_nop()

So, is it a barrier? No clue yet.

/* REP NOP (PAUSE) is a good thing to insert into busy-wait loops. */
static inline void rep_nop(void)
{
        __asm__ __volatile__("rep;nop": : :"memory");
}

Comment explicitly says that it is "a good thing" (doesn't say
that it is mandatory) and says NOTHING about barriers!

Barrier-ness is not mentioned and is hidden in "memory" clobber.

Do you think it's obvious enough for average driver writer?
I think not, especially that it's unlikely for him to even start
suspecting that it is a memory barrier based on the "cpu_relax"
name.

> You simply CANNOT use an atomic_t as your sole synchronizing
> primitive, it doesn't work!  You virtually ALWAYS want to use an  
> atomic_t in the following types of situations:
> 
> (A) As an object refcount.  The value is never read except as part of  
> an atomic_dec_return().  Why aren't you using "struct kref"?
> 
> (B) As an atomic value counter (number of processes, for example).   
> Just "reading" the value is racy anyways, if you want to enforce a  
> limit or something then use atomic_inc_return(), check the result,  
> and use atomic_dec() if it's too big.  If you just want to return the  
> statistics then you are going to be instantaneous-point-in-time anyways.
> 
> (C) As an optimization value (statistics-like, but exact accuracy  
> isn't important).
> 
> Atomics are NOT A REPLACEMENT for the proper kernel subsystem, like  
> completions, mutexes, semaphores, spinlocks, krefs, etc.  It's not  
> useful for synchronization, only for keeping track of simple integer  
> RMW values.  Note that atomic_read() and atomic_set() aren't very  
> useful RMW primitives (read-nomodify-nowrite and read-set-zero- 
> write).  Code which assumes anything else is probably buggy in other  
> ways too.

You are basically trying to educate me how to use atomic properly.
You don't need to do it, as I am (currently) not a driver author.

I am saying that people who are already using atomic_read()
(and who unfortunately did not read your explanation above)
will still sometimes use atomic_read() as a way to read atomic value
*from memory*, and will create nasty heisenbugs for you to debug.
--
vda
