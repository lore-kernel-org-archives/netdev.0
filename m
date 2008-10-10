From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 10 Oct 2008 11:15:11 +0200
Message-ID: <20081010091511.GC5116@elte.hu>
References: <20081009231759.GA8664@tservice.net.ru> <20081010080910.GA31723@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mike Galbraith <efault@gmx.de>
To: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:36361 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414AbYJJJPX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 05:15:23 -0400
Content-Disposition: inline
In-Reply-To: <20081010080910.GA31723@tservice.net.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


hi Evgeniy,

* Evgeniy Polyakov <s0mbre@tservice.net.ru> wrote:

> Hi Peter.
> 
> I've enabled kernel hacking option and scheduler debugging and turned
> off hrticks and performance jumped to 382 MB/s:
> 
> vanilla 27: 347.222
> no TSO/GSO: 357.331
> no hrticks: 382.983
> 
> I use tsc clocksource, also available acpi_pm and jiffies,
> with acpi_pm performance is even lower (I stopped test after it dropped
> below 340 MB/s mark), jiffies do not work at all, looks like sockets
> stuck in time_wait state when this clock source is used, although that
> may be some different issue.
> 
> So I think hrticks are guilty, but still not as good as .25 tree without
> mentioned changes (455 MB/s) and .24 (475 MB/s).

i'm glad that you are looking into this! That is an SMP box, right? If 
yes then could you try this sched-domains tuning utility i have written 
yesterday (incidentally):

  http://redhat.com/~mingo/cfs-scheduler/tune-sched-domains

just run it without options to see the current sched-domains options. On 
a testsystem i have it displays this:

# tune-sched-domains
usage: tune-sched-domains <val>
current val on cpu0/domain0:
SD flag: 47
+   1: SD_LOAD_BALANCE:          Do load balancing on this domain
+   2: SD_BALANCE_NEWIDLE:       Balance when about to become idle
+   4: SD_BALANCE_EXEC:          Balance on exec
+   8: SD_BALANCE_FORK:          Balance on fork, clone
-  16: SD_WAKE_IDLE:             Wake to idle CPU on task wakeup
+  32: SD_WAKE_AFFINE:           Wake task to waking CPU
-  64: SD_WAKE_BALANCE:          Perform balancing at task wakeup

then could you check what effects it has if you turn off 
SD_BALANCE_NEWIDLE? On my box i did it via:

# tune-sched-domains $[47-2]
changed /proc/sys/kernel/sched_domain/cpu0/domain0/flags: 47 => 45
SD flag: 45
+   1: SD_LOAD_BALANCE:          Do load balancing on this domain
-   2: SD_BALANCE_NEWIDLE:       Balance when about to become idle
+   4: SD_BALANCE_EXEC:          Balance on exec
+   8: SD_BALANCE_FORK:          Balance on fork, clone
-  16: SD_WAKE_IDLE:             Wake to idle CPU on task wakeup
+  32: SD_WAKE_AFFINE:           Wake task to waking CPU
-  64: SD_WAKE_BALANCE:          Perform balancing at task wakeup
changed /proc/sys/kernel/sched_domain/cpu0/domain1/flags: 1101 => 45
SD flag: 45
+   1: SD_LOAD_BALANCE:          Do load balancing on this domain
-   2: SD_BALANCE_NEWIDLE:       Balance when about to become idle
+   4: SD_BALANCE_EXEC:          Balance on exec
+   8: SD_BALANCE_FORK:          Balance on fork, clone
-  16: SD_WAKE_IDLE:             Wake to idle CPU on task wakeup
+  32: SD_WAKE_AFFINE:           Wake task to waking CPU
-  64: SD_WAKE_BALANCE:          Perform balancing at task wakeup

and please, when tuning such scheduler bits, could you run latest 
tip/master:

   http://people.redhat.com/mingo/tip.git/README

and you need to have CONFIG_SCHED_DEBUG=y enabled for the tuning knobs.

so that it's all in sync with upcoming scheduler changes/tunings/fixes.

It will also make it much easier for us to apply any fix patches you 
might send :-)

For advanced tuners: you can specify two or more domain flags options as 
well on the command line - that will be put into domain1/domain2/etc. I 
usually tune these flags via something like:

  tune-sched-domains $[1*1+1*2+1*4+1*8+0*16+1*32+1*64]

that makes it easy to set/clear each of the flags.

	Ingo
