From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 04/45] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Wed, 23 Jan 2013 11:57:40 -0800
Message-ID: <20130123195740.GI2373@mtj.dyndns.org>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
 <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com>
 <20130123185522.GG2373@mtj.dyndns.org>
 <51003B20.2060506@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, peterz@infradead.org, oleg@redhat.com,
	paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51003B20.2060506@linux.vnet.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Srivatsa.

On Thu, Jan 24, 2013 at 01:03:52AM +0530, Srivatsa S. Bhat wrote:
> Hmm.. I split it up into steps to help explain the reasoning behind
> the code sufficiently, rather than spring all of the intricacies at
> one go (which would make it very hard to write the changelog/comments
> also). The split made it easier for me to document it well in the
> changelog, because I could deal with reasonable chunks of code/complexity
> at a time. IMHO that helps people reading it for the first time to
> understand the logic easily.

I don't know.  It's a judgement call I guess.  I personally would much
prefer having ample documentation as comments in the source itself or
as a separate Documentation/ file as that's what most people are gonna
be looking at to figure out what's going on.  Maybe just compact it a
bit and add more in-line documentation instead?

> > The only two options are either punishing writers or identifying and
> > updating all such possible deadlocks.  percpu_rwsem does the former,
> > right?  I don't know how feasible the latter would be.
> 
> I don't think we can avoid looking into all the possible deadlocks,
> as long as we use rwlocks inside get/put_online_cpus_atomic() (assuming
> rwlocks are fair). Even with Oleg's idea of using synchronize_sched()
> at the writer, we still need to take care of locking rules, because the
> synchronize_sched() only helps avoid the memory barriers at the reader,
> and doesn't help get rid of the rwlocks themselves.

Well, percpu_rwlock don't have to use rwlock for the slow path.  It
can implement its own writer starving locking scheme.  It's not like
implementing slow path global rwlock logic is difficult.

> CPU 0                          CPU 1
> 
> read_lock(&rwlock)
> 
>                               write_lock(&rwlock) //spins, because CPU 0
>                               //has acquired the lock for read
> 
> read_lock(&rwlock)
>    ^^^^^
> What happens here? Does CPU 0 start spinning (and hence deadlock) or will
> it continue realizing that it already holds the rwlock for read?

I don't think rwlock allows nesting write lock inside read lock.
read_lock(); write_lock() will always deadlock.

Thanks.

-- 
tejun
