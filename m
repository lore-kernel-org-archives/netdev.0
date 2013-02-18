From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 07/46] percpu_rwlock: Allow writers to be readers,
 and add lockdep annotations
Date: Mon, 18 Feb 2013 22:01:26 +0530
Message-ID: <5122575E.5030405@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123913.26245.7713.stgit@srivatsabhat.in.ibm.com> <CANN689Ec4g7jMapv8ChAEom+gEDQ8RDVLa07CKwJ==YO+MUUrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org, mingo@kernel.org,
	linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	paulmck@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, rusty@rustcorp.com.au,
	rostedt@goodmis.org, rjw@sisk.pl, namhyung@kernel.org,
	tglx@linutronix.de, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, oleg@redhat.com,
	vincent.guittot@linaro.org, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Michel Lespinasse <walken@google.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CANN689Ec4g7jMapv8ChAEom+gEDQ8RDVLa07CKwJ==YO+MUUrA@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2013 09:21 PM, Michel Lespinasse wrote:
> On Mon, Feb 18, 2013 at 8:39 PM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> @@ -200,6 +217,16 @@ void percpu_write_lock_irqsave(struct percpu_rwlock *pcpu_rwlock,
>>
>>         smp_mb(); /* Complete the wait-for-readers, before taking the lock */
>>         write_lock_irqsave(&pcpu_rwlock->global_rwlock, *flags);
>> +
>> +       /*
>> +        * It is desirable to allow the writer to acquire the percpu-rwlock
>> +        * for read (if necessary), without deadlocking or getting complaints
>> +        * from lockdep. To achieve that, just increment the reader_refcnt of
>> +        * this CPU - that way, any attempt by the writer to acquire the
>> +        * percpu-rwlock for read, will get treated as a case of nested percpu
>> +        * reader, which is safe, from a locking perspective.
>> +        */
>> +       this_cpu_inc(pcpu_rwlock->rw_state->reader_refcnt);
> 
> I find this quite disgusting, but once again this may be because I
> don't like unfair recursive rwlocks.
> 

:-)

> In my opinion, the alternative of explicitly not taking the read lock
> when one already has the write lock sounds *much* nicer.

I don't seem to recall any strong reasons to do it this way, so I don't have
any strong opinions on doing it this way. But one of the things to note is that,
in the CPU Hotplug case, the readers are *way* more hotter than the writer.
So avoiding extra checks/'if' conditions/memory barriers in the reader-side
is very welcome. (If we slow down the read-side, we get a performance hit
even when *not* doing hotplug!). Considering this, the logic used in this
patchset seems better, IMHO.

Regards,
Srivatsa S. Bhat
