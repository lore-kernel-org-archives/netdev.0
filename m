From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 08/26] locking: Remove spin_unlock_wait() generic
 definitions
Date: Mon, 3 Jul 2017 17:54:38 -0700
Message-ID: <20170704005438.GA19389@linux.vnet.ibm.com>
References: <20170630123815.GT2393@linux.vnet.ibm.com>
 <20170630131339.GA14118@arm.com>
 <20170630221840.GI2393@linux.vnet.ibm.com>
 <20170703131514.GE1573@arm.com>
 <20170703161851.GY2393@linux.vnet.ibm.com>
 <CA+55aFzA+dk8P-wWFX_rYE09A-3uCL8_7ZNG4jC1+c0x4COQkQ@mail.gmail.com>
 <20170703171338.GG1573@arm.com>
 <20170703223011.GI2393@linux.vnet.ibm.com>
 <CA+55aFy4QPFypce_N0jC-QjhTU9GKZ2i11HewKKOfo0hCHn7Sw@mail.gmail.com>
 <20170704003936.GJ2393@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Will Deacon <will.deacon@arm.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Manfred Spraul <manfred@colorfullife.com>,
        Tejun Heo <tj@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Alan Stern <stern@rowland.harvard.edu>,
        Andrea Parri <parri.andrea@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170704003936.GJ2393@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 03, 2017 at 05:39:36PM -0700, Paul E. McKenney wrote:
> On Mon, Jul 03, 2017 at 03:49:42PM -0700, Linus Torvalds wrote:
> > On Mon, Jul 3, 2017 at 3:30 PM, Paul E. McKenney
> > <paulmck@linux.vnet.ibm.com> wrote:
> > >
> > > That certainly is one interesting function, isn't it?  I wonder what
> > > happens if you replace the raw_spin_is_locked() calls with an
> > > unlock under a trylock check?  ;-)
> > 
> > Deadlock due to interrupts again?
> 
> Unless I am missing something subtle, the kgdb_cpu_enter() function in
> question has a local_irq_save() over the "interesting" portion of its
> workings, so interrupt-handler self-deadlock should not happen.
> 
> > Didn't your spin_unlock_wait() patches teach you anything? Checking
> > state is fundamentally different from taking the lock. Even a trylock.
> 
> That was an embarrassing bug, no two ways about it.  :-/
> 
> > I guess you could try with the irqsave versions. But no, we're not doing that.
> 
> Again, no need in this case.
> 
> But I agree with Will's assessment of this function...
> 
> The raw_spin_is_locked() looks to be asking if -any- CPU holds the
> dbg_slave_lock, and the answer could of course change immediately
> on return from raw_spin_is_locked().  Perhaps the theory is that
> if other CPU holds the lock, this CPU is supposed to be subjected to
> kgdb_roundup_cpus().  Except that the CPU that held dbg_slave_lock might
> be just about to release that lock.  Odd.
> 
> Seems like there should be a get_online_cpus() somewhere, but maybe
> that constraint is to be manually enforced.

Except that invoking get_online_cpus() from an exception handler would
be of course be a spectacularly bad idea.  I would feel better if the
num_online_cpus() was under the local_irq_save(), but perhaps this code
is relying on the stop_machine().  Except that it appears we could
deadlock with offline waiting for stop_machine() to complete and kdbg
waiting for all CPUs to report, including those in stop_machine().

Looks like the current situation is "Don't use kdbg if there is any
possibility of CPU-hotplug operations."  Not necessarily an unreasonable
restriction.

But I need to let me eyes heal a bit before looking at this more.

							Thanx, Paul
