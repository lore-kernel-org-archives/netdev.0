From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Fri, 7 Jul 2017 12:33:49 +0200
Message-ID: <20170707103349.yohrygljglwx6qn2@gmail.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
 <20170706162024.GD2393@linux.vnet.ibm.com>
 <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
 <20170707083128.wqk6msuuhtyykhpu@gmail.com>
 <20170707084427.vdsmwkgqx6uvg7tw@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "manfred@colorfullife.com" <manfred@colorfullife.com>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170707084427.vdsmwkgqx6uvg7tw@hirez.programming.kicks-ass.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Peter Zijlstra <peterz@infradead.org> wrote:

> You missed the one in do_exit(), which I thought was the original one.

Indeed, it's raw_spin_unlock_wait() which my git grep pattern missed.

But it's not the original spin_unlock_wait(): the pi_lock and priority inheritance 
is a newfangled invention that Linus (rightfully) resisted for years.

The original spin_unlock_wait() was for the global scheduler_lock, long gone.

Here's the full history of the original spin_unlock_wait() usecase in the 
do_exit() path, for the historically interested:

 [1997/04] v2.1.36:

      the spin_unlock_wait() primitive gets introduced as part of release()

 [1998/08] v2.1.114:

      the release() usecase gets converted to an open coded spin_lock()+unlock() 
      poll loop over scheduler_lock

 [1999/05] v2.3.11pre3:

      open coded loop is changed over to poll p->has_cpu

 [1999/07] v2.3.12pre6:

      ->has_cpu loop poll loop is converted to a spin_lock()+unlock() 
      poll loop over runqueue_lock

 [2000/06] 2.4.0-test6pre4:

      combined open coded p->has_cpu poll loop is added back, in addition to the
      lock()+unlock() loop

 [2000/11] 2.4.0-test12pre4:

      lock+unlock loop is changed from scheduler_lock to task_lock

 [2001/11] v2.4.14.9:

       ->has_cpu gets renamed to ->cpus_runnable

 [2001/12] v2.5.1.10:

       poll loop is factored out from exit()'s release() function 
       to the scheduler's new wait_task_inactive() function

 ...

 [2017/07] v4.12:

      wait_task_inactive() is still alive and kicking. Its poll loop has
      increased in complexity, but it still does not use spin_unlock_wait()

So it was always a mess, and we relatively early flipped from the clever 
spin_unlock_wait() implementation to an open coded lock+unlock poll loop.

TL;DR: The original do_exit() usecase is gone, it does not use spin_unlock_wait(),
       since 1998.

Thanks,

	Ingo
