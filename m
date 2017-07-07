From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Fri, 7 Jul 2017 11:32:49 +0200
Message-ID: <20170707093249.3pskpxhf3ozfhrsr@gmail.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
 <20170707080621.dmhw2ryes7n3kgag@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
        "'paulmck@linux.vnet.ibm.com'" <paulmck@linux.vnet.ibm.com>,
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
        "parri.andrea@gmail.com" <parri.andrea@gmail
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170707080621.dmhw2ryes7n3kgag@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@kernel.org> wrote:

> 
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > > It might even be that this is the defined semantics of spin_unlock_wait().
> > 
> > As is, spin_unlock_wait() is somewhat ill defined. IIRC it grew from an 
> > optimization by Oleg and subsequently got used elsewhere. And it being the 
> > subtle bugger it is, there were bugs.
> 
> I believe the historical, original spin_unlock_wait() came from early SMP 
> optimizations of the networking code - and then spread elsewhere, step by step. 
> All but one of the networking uses went away since then - so I don't think there's 
> any original usecase left.

No - the original usecase was task teardown: I still remembered that but didn't 
find the commit - but it's there in very old Linux kernel patches, done by DaveM 
originally in v2.1.36 (!):

--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -136,6 +136,12 @@ void release(struct task_struct * p)
        }
        for (i=1 ; i<NR_TASKS ; i++)
                if (task[i] == p) {
+#ifdef __SMP__
+                       /* FIXME! Cheesy, but kills the window... -DaveM */
+                       while(p->processor != NO_PROC_ID)
+                               barrier();
+                       spin_unlock_wait(&scheduler_lock);
+#endif


Other code learned to use spin_unlock_wait(): the original version of 
[hard]irq_enter() was the second user, net_family_read_lock() was the third user, 
followed by more uses in networking. All but one of those are not present in the 
current upstream kernel anymore.

This task-teardown FIXME was fixed in v2.1.114 (was replaced by an open coded poll 
loop), but the spin_unlock_wait() primitive remained.

The rest is history! ;-)

Thanks,

	Ingo
