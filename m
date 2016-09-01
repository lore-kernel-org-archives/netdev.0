From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 01 Sep 2016 06:25:34 -0700
Message-ID: <1472736334.5019.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472650688.32433.115.camel@redhat.com>
         <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831164216.2901190c@redhat.com>
         <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831214043.2f44cf08@redhat.com>
         <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831235116.33b1946b@redhat.com> <20160901130231.58355405@redhat.com>
         <20160901115356.GT10153@twins.programming.kicks-ass.net>
         <20160901142925.63a5031b@redhat.com> <20160901143859.730826ed@redhat.com>
         <1472734643.5019.9.camel@edumazet-glaptop3.roam.corp.google.com>
         <89b605ce-5281-ba41-2921-116bb3073098@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <89b605ce-5281-ba41-2921-116bb3073098@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-01 at 15:00 +0200, Hannes Frederic Sowa wrote:
> On 01.09.2016 14:57, Eric Dumazet wrote:
> > On Thu, 2016-09-01 at 14:38 +0200, Jesper Dangaard Brouer wrote:
> > 
> >> Correction, on the server-under-test, I'm actually running RHEL7.2
> >>
> >>
> >>> How do I verify/check if I have enabled a cpu-cgroup?
> >>
> >> Hannes says I can look in "/proc/self/cgroup"
> >>
> >>  $ cat /proc/self/cgroup
> >>  7:net_cls:/
> >>  6:blkio:/
> >>  5:devices:/
> >>  4:perf_event:/
> >>  3:cpu,cpuacct:/
> >>  2:cpuset:/
> >>  1:name=systemd:/user.slice/user-1000.slice/session-c1.scope
> >>  
> >> And that "/" indicate I've not enabled cgroups, right?
> >>
> > 
> > In my experience, I found that times displayed by top are often off for
> > softirq processing.
> > 
> > Before applying my patch, top shows very small amount of cpu time for
> > udp_rcv and ksoftirqd/0 , while obviously cpu 0 is completely busy.
> > 
> > Make sure to try latest Linus tree, as I did yesterday, because
> > apparently things are better than a few weeks back.
> > 
> > BTW, even 'perf top' has sometimes problems showing me cycles spent in
> > softirq. I need to make sure the cpu processing NIC interrupts also
> > spend cycles in some user space program to get meaningful results.
> 
> I think that ksoftirqd time is actually accounted to system:
> 
> excerpt from irqtime_account_process_tick in kernel/sched/cputime.c
> 
> 	if (this_cpu_ksoftirqd() == p) {
> 		/*
> 		 * ksoftirqd time do not get accounted in cpu_softirq_time.
> 		 * So, we have to handle it separately here.
> 		 * Also, p->stime needs to be updated for ksoftirqd.
> 		 */
> 		__account_system_time(p, cputime, scaled, CPUTIME_SOFTIRQ);
> 	} else if (user_tick) {
> 

Tell me more about kernel/sched/cputime.c stability over recent linux
versions ;)

git log --oneline v4.2.. kernel/sched/cputime.c
03cbc732639ddcad15218c4b2046d255851ff1e3 sched/cputime: Resync steal time when guest & host lose sync
173be9a14f7b2e901cf77c18b1aafd4d672e9d9e sched/cputime: Fix NO_HZ_FULL getrusage() monotonicity regression
26f2c75cd2cf10a6120ef02ca9a94db77cc9c8e0 sched/cputime: Fix omitted ticks passed in parameter
f9bcf1e0e0145323ba2cf72ecad5264ff3883eb1 sched/cputime: Fix steal time accounting
08fd8c17686c6b09fa410a26d516548dd80ff147 Merge tag 'for-linus-4.8-rc0-tag' of git://git.kernel.org/pub/scm/linux/kernel/git/xen/tip
553bf6bbfd8a540c70aee28eb50e24caff456a03 sched/cputime: Drop local_irq_save/restore from irqtime_account_irq()
0cfdf9a198b0d4f5ad6c87d894db7830b796b2cc sched/cputime: Clean up the old vtime gen irqtime accounting completely
b58c35840521bb02b150e1d0d34ca9197f8b7145 sched/cputime: Replace VTIME_GEN irq time code with IRQ_TIME_ACCOUNTING code
57430218317e5b280a80582a139b26029c25de6c sched/cputime: Count actually elapsed irq & softirq time
ecb23dc6f2eff0ce64dd60351a81f376f13b12cc xen: add steal_clock support on x86
807e5b80687c06715d62df51a5473b231e3e8b15 sched/cputime: Add steal time support to full dynticks CPU time accounting
f9c904b7613b8b4c85b10cd6b33ad41b2843fa9d sched/cputime: Fix steal_account_process_tick() to always return jiffies
ff9a9b4c4334b53b52ee9279f30bd5dd92ea9bdd sched, time: Switch VIRT_CPU_ACCOUNTING_GEN to jiffy granularity
c9bed1cf51011c815d88288b774865d013ca78a8 Merge tag 'for-linus-4.5-rc0-tag' of git://git.kernel.org/pub/scm/linux/kernel/git/xen/tip
1fe7c4ef88bd32e039f5f4126537c3f20c340414 missing include asm/paravirt.h in cputime.c
b7ce2277f087fd052e7e1bbf432f7fecbee82bb6 sched/cputime: Convert vtime_seqlock to seqcount
e592539466380279a9e6e6fdfe4545aa54f22593 sched/cputime: Introduce vtime accounting check for readers
55dbdcfa05533f44c9416070b8a9f6432b22314a sched/cputime: Rename vtime_accounting_enabled() to vtime_accounting_cpu_enabled()
cab245d68c38afff1a4c4d018ab7e1d316982f5d sched/cputime: Correctly handle task guest time on housekeepers
7098c1eac75dc03fdbb7249171a6e68ce6044a5a sched/cputime: Clarify vtime symbols and document them
7877a0ba5ec63c7b0111b06c773f1696fa17b35a sched/cputime: Remove extra cost in task_cputime()
2541117b0cf79977fa11a0d6e17d61010677bd7b sched/cputime: Fix invalid gtime in proc
9eec50b8bbe1535c440a1ee88c1958f78fc55957 kvm/x86: Hyper-V HV_X64_MSR_VP_RUNTIME support
9d7fb04276481c59610983362d8e023d262b58ca sched/cputime: Guarantee stime + utime == rtime
