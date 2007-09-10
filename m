From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Mon, 10 Sep 2007 08:22:06 -0400
Message-ID: <6370BBDF-0C79-41EB-BD2A-02AA0D216924@mac.com>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <200709091902.55388.vda.linux@googlemail.com> <20070909191839.1fa10e88@laptopd505.fenrus.org> <200709101156.30010.vda.linux@googlemail.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
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
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759172AbXIJMWk@vger.kernel.org>
In-Reply-To: <200709101156.30010.vda.linux@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sep 10, 2007, at 06:56:29, Denys Vlasenko wrote:
> On Sunday 09 September 2007 19:18, Arjan van de Ven wrote:
>> On Sun, 9 Sep 2007 19:02:54 +0100
>> Denys Vlasenko <vda.linux@googlemail.com> wrote:
>>
>>> Why is all this fixation on "volatile"? I don't think people want  
>>> "volatile" keyword per se, they want atomic_read(&x) to _always_  
>>> compile into an memory-accessing instruction, not register access.
>>
>> and ... why is that?  is there any valid, non-buggy code sequence  
>> that makes that a reasonable requirement?
>
> Well, if you insist on having it again:
>
> Waiting for atomic value to be zero:
>
>         while (atomic_read(&x))
>                 continue;
>
> gcc may happily convert it into:
>
>         reg = atomic_read(&x);
>         while (reg)
>                 continue;

Bzzt.  Even if you fixed gcc to actually convert it to a busy loop on  
a memory variable, you STILL HAVE A BUG as it may *NOT* be gcc that  
does the conversion, it may be that the CPU does the caching of the  
memory value.  GCC has no mechanism to do cache-flushes or memory- 
barriers except through our custom inline assembly.  Also, you  
probably want a cpu_relax() in there somewhere to avoid overheating  
the CPU.  Thirdly, on a large system it may take some arbitrarily  
large amount of time for cache-propagation to update the value of the  
variable in your local CPU cache.  Finally, if atomics are based on  
based on spinlock+interrupt-disable then you will sit in a tight busy- 
loop of spin_lock_irqsave()->spin_unlock_irqrestore().  Depending on  
your system's internal model this may practically lock up your core  
because the spin_lock() will take the cacheline for exclusive access  
and doing that in a loop can prevent any other CPU from doing any  
operation on it!  Since your IRQs are disabled you even have a very  
small window that an IRQ will come along and free it up long enough  
for the update to take place.

The earlier code segment of:
> while(atomic_read(&x) > 0)
> 	atomic_dec(&x);
is *completely* buggy because you could very easily have 4 CPUs doing  
this on an atomic variable with a value of 1 and end up with it at  
negative 3 by the time you are done.  Moreover all the alternatives  
are also buggy, with the sole exception of this rather obvious- 
seeming one:
> atomic_set(&x, 0);

You simply CANNOT use an atomic_t as your sole synchronizing  
primitive, it doesn't work!  You virtually ALWAYS want to use an  
atomic_t in the following types of situations:

(A) As an object refcount.  The value is never read except as part of  
an atomic_dec_return().  Why aren't you using "struct kref"?

(B) As an atomic value counter (number of processes, for example).   
Just "reading" the value is racy anyways, if you want to enforce a  
limit or something then use atomic_inc_return(), check the result,  
and use atomic_dec() if it's too big.  If you just want to return the  
statistics then you are going to be instantaneous-point-in-time anyways.

(C) As an optimization value (statistics-like, but exact accuracy  
isn't important).

Atomics are NOT A REPLACEMENT for the proper kernel subsystem, like  
completions, mutexes, semaphores, spinlocks, krefs, etc.  It's not  
useful for synchronization, only for keeping track of simple integer  
RMW values.  Note that atomic_read() and atomic_set() aren't very  
useful RMW primitives (read-nomodify-nowrite and read-set-zero- 
write).  Code which assumes anything else is probably buggy in other  
ways too.

So while I see no real reason for the "volatile" on the atomics, I  
also see no real reason why it's terribly harmful.  Regardless of the  
"volatile" on the operation the CPU is perfectly happy to cache it  
anyways so it doesn't buy you any actual "always-access-memory"  
guarantees.  If you are just interested in it as an optimization you  
could probably just read the properly-aligned integer counter  
directly, an atomic read on most CPUs.

If you really need it to hit main memory *every* *single* *time*  
(Why?  Are you using it instead of the proper kernel subsystem?)   
then you probably need a custom inline assembly helper anyways.

Cheers,
Kyle Moffett
