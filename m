From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Fri, 7 Jul 2017 10:44:27 +0200
Message-ID: <20170707084427.vdsmwkgqx6uvg7tw@hirez.programming.kicks-ass.net>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
 <20170706162024.GD2393@linux.vnet.ibm.com>
 <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
 <20170707083128.wqk6msuuhtyykhpu@gmail.com>
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
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170707083128.wqk6msuuhtyykhpu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2017 at 10:31:28AM +0200, Ingo Molnar wrote:
> Here's a quick list of all the use cases:
> 
>  net/netfilter/nf_conntrack_core.c:
> 
>    - This is I believe the 'original', historic spin_unlock_wait() usecase that
>      still exists in the kernel. spin_unlock_wait() is only used in a rare case, 
>      when the netfilter hash is resized via nf_conntrack_hash_resize() - which is 
>      a very heavy operation to begin with. It will no doubt get slower with the 
>      proposed changes, but it probably does not matter. A networking person 
>      Acked-by would be nice though.
> 
>  drivers/ata/libata-eh.c:
> 
>    - Locking of the ATA port in ata_scsi_cmd_error_handler(), presumably this can
>      race with IRQs and ioctls() on other CPUs. Very likely not performance 
>      sensitive in any fashion, on IO errors things stop for many seconds anyway.
> 
>  ipc/sem.c:
> 
>    - A rare race condition branch in the SysV IPC semaphore freeing code in 
>      exit_sem() - where even the main code flow is not performance sensitive, 
>      because typical database workloads get their semaphore arrays during startup 
>      and don't ever do heavy runtime allocation/freeing of them.
> 
>  kernel/sched/completion.c:
> 
>    - completion_done(). This is actually a (comparatively) rarely used completion 
>      API call - almost all the upstream usecases are in drivers, plus two in 
>      filesystems - neither usecase seems in a performance critical hot path. 
>      Completions typically involve scheduling and context switching, so in the 
>      worst case the proposed change adds overhead to a scheduling slow path.
> 

You missed the one in do_exit(), which I thought was the original one.
