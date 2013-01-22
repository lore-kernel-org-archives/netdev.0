From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v5 01/45] percpu_rwlock: Introduce the global
 reader-writer lock backend
Date: Tue, 22 Jan 2013 10:45:06 -0800
Message-ID: <20130122104506.32b4e581@nehalam.linuxnetplumber.net>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
	<20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Jan 2013 13:03:22 +0530
"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:

> A straight-forward (and obvious) algorithm to implement Per-CPU Reader-Writer
> locks can also lead to too many deadlock possibilities which can make it very
> hard/impossible to use. This is explained in the example below, which helps
> justify the need for a different algorithm to implement flexible Per-CPU
> Reader-Writer locks.
> 
> We can use global rwlocks as shown below safely, without fear of deadlocks:
> 
> Readers:
> 
>          CPU 0                                CPU 1
>          ------                               ------
> 
> 1.    spin_lock(&random_lock);             read_lock(&my_rwlock);
> 
> 
> 2.    read_lock(&my_rwlock);               spin_lock(&random_lock);
> 
> 
> Writer:
> 
>          CPU 2:
>          ------
> 
>        write_lock(&my_rwlock);
> 
> 
> We can observe that there is no possibility of deadlocks or circular locking
> dependencies here. Its perfectly safe.
> 
> Now consider a blind/straight-forward conversion of global rwlocks to per-CPU
> rwlocks like this:
> 
> The reader locks its own per-CPU rwlock for read, and proceeds.
> 
> Something like: read_lock(per-cpu rwlock of this cpu);
> 
> The writer acquires all per-CPU rwlocks for write and only then proceeds.
> 
> Something like:
> 
>   for_each_online_cpu(cpu)
> 	write_lock(per-cpu rwlock of 'cpu');
> 
> 
> Now let's say that for performance reasons, the above scenario (which was
> perfectly safe when using global rwlocks) was converted to use per-CPU rwlocks.
> 
> 
>          CPU 0                                CPU 1
>          ------                               ------
> 
> 1.    spin_lock(&random_lock);             read_lock(my_rwlock of CPU 1);
> 
> 
> 2.    read_lock(my_rwlock of CPU 0);       spin_lock(&random_lock);
> 
> 
> Writer:
> 
>          CPU 2:
>          ------
> 
>       for_each_online_cpu(cpu)
>         write_lock(my_rwlock of 'cpu');
> 
> 
> Consider what happens if the writer begins his operation in between steps 1
> and 2 at the reader side. It becomes evident that we end up in a (previously
> non-existent) deadlock due to a circular locking dependency between the 3
> entities, like this:
> 
> 
> (holds              Waiting for
>  random_lock) CPU 0 -------------> CPU 2  (holds my_rwlock of CPU 0
>                                                for write)
>                ^                   |
>                |                   |
>         Waiting|                   | Waiting
>           for  |                   |  for
>                |                   V
>                 ------ CPU 1 <------
> 
>                 (holds my_rwlock of
>                  CPU 1 for read)
> 
> 
> 
> So obviously this "straight-forward" way of implementing percpu rwlocks is
> deadlock-prone. One simple measure for (or characteristic of) safe percpu
> rwlock should be that if a user replaces global rwlocks with per-CPU rwlocks
> (for performance reasons), he shouldn't suddenly end up in numerous deadlock
> possibilities which never existed before. The replacement should continue to
> remain safe, and perhaps improve the performance.
> 
> Observing the robustness of global rwlocks in providing a fair amount of
> deadlock safety, we implement per-CPU rwlocks as nothing but global rwlocks,
> as a first step.
> 
> 
> Cc: David Howells <dhowells@redhat.com>
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

We got rid of brlock years ago, do we have to reintroduce it like this?
The problem was that brlock caused starvation.
