From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 10 Oct 2008 13:40:42 +0200
Message-ID: <20081010114042.GA19487@elte.hu>
References: <20081009231759.GA8664@tservice.net.ru> <20081010080910.GA31723@tservice.net.ru> <20081010091511.GC5116@elte.hu> <20081010113100.GA1030@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mike Galbraith <efault@gmx.de>, Nick Piggin <npiggin@suse.de>
To: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:40596 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121AbYJJLkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 07:40:53 -0400
Content-Disposition: inline
In-Reply-To: <20081010113100.GA1030@tservice.net.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Evgeniy Polyakov <s0mbre@tservice.net.ru> wrote:

> Hi Ingo.
> 
> On Fri, Oct 10, 2008 at 11:15:11AM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> 
> > > 
> > > I use tsc clocksource, also available acpi_pm and jiffies,
> > > with acpi_pm performance is even lower (I stopped test after it dropped
> > > below 340 MB/s mark), jiffies do not work at all, looks like sockets
> > > stuck in time_wait state when this clock source is used, although that
> > > may be some different issue.
> > > 
> > > So I think hrticks are guilty, but still not as good as .25 tree without
> > > mentioned changes (455 MB/s) and .24 (475 MB/s).
> > 
> > i'm glad that you are looking into this! That is an SMP box, right? If 
> > yes then could you try this sched-domains tuning utility i have written 
> > yesterday (incidentally):
> > 
> >   http://redhat.com/~mingo/cfs-scheduler/tune-sched-domains
> 
> I've removed SD_BALANCE_NEWIDLE:
> # ./tune-sched-domains $[191-2]
> changed /proc/sys/kernel/sched_domain/cpu0/domain0/flags: 191 => 189
> SD flag: 189
> +   1: SD_LOAD_BALANCE:          Do load balancing on this domain
> -   2: SD_BALANCE_NEWIDLE:       Balance when about to become idle
> +   4: SD_BALANCE_EXEC:          Balance on exec
> +   8: SD_BALANCE_FORK:          Balance on fork, clone
> +  16: SD_WAKE_IDLE:             Wake to idle CPU on task wakeup
> +  32: SD_WAKE_AFFINE:           Wake task to waking CPU
> -  64: SD_WAKE_BALANCE:          Perform balancing at task wakeup
> + 128: SD_SHARE_CPUPOWER:        Domain members share cpu power
> changed /proc/sys/kernel/sched_domain/cpu0/domain1/flags: 47 => 189
> SD flag: 189
> +   1: SD_LOAD_BALANCE:          Do load balancing on this domain
> -   2: SD_BALANCE_NEWIDLE:       Balance when about to become idle
> +   4: SD_BALANCE_EXEC:          Balance on exec
> +   8: SD_BALANCE_FORK:          Balance on fork, clone
> +  16: SD_WAKE_IDLE:             Wake to idle CPU on task wakeup
> +  32: SD_WAKE_AFFINE:           Wake task to waking CPU
> -  64: SD_WAKE_BALANCE:          Perform balancing at task wakeup
> + 128: SD_SHARE_CPUPOWER:        Domain members share cpu power
> 
> And got noticeble improvement (each new line has fixes from previous):
> 
> vanilla 27: 347.222
> no TSO/GSO: 357.331
> no hrticks: 382.983
> no balance: 389.802
> 
> > and please, when tuning such scheduler bits, could you run latest 
> > tip/master:
> > 
> >    http://people.redhat.com/mingo/tip.git/README
> > 
> > and you need to have CONFIG_SCHED_DEBUG=y enabled for the tuning knobs.
> > 
> > so that it's all in sync with upcoming scheduler changes/tunings/fixes.
> 
> Ok, I've started to pull it down, I will reply back when things are
> ready.

make sure you have this fix in tip/master already:

  5b7dba4: sched_clock: prevent scd->clock from moving backwards

Note: Mike is 100% correct in suggesting that a very good cpu_clock() is 
needed for precise scheduling.

i've also Cc:-ed Nick.

	Ingo
