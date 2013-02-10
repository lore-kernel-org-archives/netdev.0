From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 04/45] percpu_rwlock: Implement the core design of
	Per-CPU Reader-Writer Locks
Date: Sun, 10 Feb 2013 20:50:42 +0100
Message-ID: <20130210195042.GA6236@redhat.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com> <20130208231017.GK2666@linux.vnet.ibm.com> <20130210180607.GA1375@redhat.com> <5117F403.1050300@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	rusty@rustcorp.com.au, mingo@kernel.org, akpm@linux-foundation.org,
	namhyung@kernel.org, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	rjw@sisk.pl, sbw@mit.edu, fweisbec@gmail.com,
	linux@arm.linux.org.uk, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5117F403.1050300@linux.vnet.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/11, Srivatsa S. Bhat wrote:
>
> On 02/10/2013 11:36 PM, Oleg Nesterov wrote:
> >>> +static void announce_writer_inactive(struct percpu_rwlock *pcpu_rwlock)
> >>> +{
> >>> +   unsigned int cpu;
> >>> +
> >>> +   drop_writer_signal(pcpu_rwlock, smp_processor_id());
> >>
> >> Why do we drop ourselves twice?  More to the point, why is it important to
> >> drop ourselves first?
> >
> > And don't we need mb() _before_ we clear ->writer_signal ?
> >
>
> Oh, right! Or, how about moving announce_writer_inactive() to _after_
> write_unlock()?

Not sure this will help... but, either way it seems we have another
problem...

percpu_rwlock tries to be "generic". This means we should "ignore" its
usage in hotplug, and _write_lock should not race with _write_unlock.

IOW. Suppose that _write_unlock clears ->writer_signal. We need to ensure
that this can't race with another write which wants to set this flag.
Perhaps it should be counter as well, and it should be protected by
the same ->global_rwlock, but _write_lock() should drop it before
sync_all_readers() and then take it again?

> >>> +static inline void sync_reader(struct percpu_rwlock *pcpu_rwlock,
> >>> +			       unsigned int cpu)
> >>> +{
> >>> +	smp_rmb(); /* Paired with smp_[w]mb() in percpu_read_[un]lock() */
> >>
> >> As I understand it, the purpose of this memory barrier is to ensure
> >> that the stores in drop_writer_signal() happen before the reads from
> >> ->reader_refcnt in reader_uses_percpu_refcnt(), thus preventing the
> >> race between a new reader attempting to use the fastpath and this writer
> >> acquiring the lock.  Unless I am confused, this must be smp_mb() rather
> >> than smp_rmb().
> >
> > And note that before sync_reader() we call announce_writer_active() which
> > already adds mb() before sync_all_readers/sync_reader, so this rmb() looks
> > unneeded.
> >
>
> My intention was to help the writer see the ->reader_refcnt drop to zero
> ASAP; hence I used smp_wmb() at reader and smp_rmb() here at the writer.

Hmm, interesting... Not sure, but can't really comment. However I can
answer your next question:

> Please correct me if my understanding of memory barriers is wrong here..

Who? Me??? No we have paulmck for that ;)

Oleg.

