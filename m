From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 00/45] CPU hotplug: stop_machine()-free CPU hotplug
Date: Mon, 18 Feb 2013 16:21:18 +0530
Message-ID: <512207A6.4000402@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <510FBC01.2030405@linux.vnet.ibm.com>	<87haloiwv0.fsf@rustcorp.com.au> <51134596.4080106@linux.vnet.ibm.com> <20130208154113.GV17833@n2100.arm.linux.org.uk> <51152B81.2050501@linux.vnet.ibm.com>	<51153F72.1060005@linux.vnet.ibm.com> <CAKfTPtCe+cD7LLkb+D6pqG1SwG2V08ws=4XO3ttHEHV2qgmqPg@mail.gmail.com> <5118E2CD.90401@linux.vnet.ibm.com> <20130211190852.GA5695@linux.vnet.ibm.com> <5119BDFD.1000909@linux.vnet.ibm.com> <CAKfTPtAo2hQTfBKTVUuLKgsGJ2ZLD0UTR3fH9UFuJwyFt4n__w@mail.gmail.com> <511E8F3C.2010406@linux.vnet.ibm.com> <CAKfTPtD=2jn1AVjuhVP1ot7_8x9-W4==hNGZET5N9tRE7gtyMw@mail.gmail.com> <512203B3.7090002@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	walken@google.com, mingo@kernel.org, linux-arch@vger.kernel.org,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>, rostedt@goodmis.org,
	rjw@sisk.pl, namhyung@kernel.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Vincent Guittot <vincent.guittot@linaro.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <512203B3.7090002@linux.vnet.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2013 04:04 PM, Srivatsa S. Bhat wrote:
> On 02/18/2013 03:54 PM, Vincent Guittot wrote:
>> On 15 February 2013 20:40, Srivatsa S. Bhat
>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>> Hi Vincent,
>>>
>>> On 02/15/2013 06:58 PM, Vincent Guittot wrote:
>>>> Hi Srivatsa,
>>>>
>>>> I have run some tests with you branch (thanks Paul for the git tree)
>>>> and you will find results below.
>>>>
>>>
>>> Thank you very much for testing this patchset!
>>>
>>>> The tests condition are:
>>>> - 5 CPUs system in 2 clusters
>>>> - The test plugs/unplugs CPU2 and it increases the system load each 20
>>>> plug/unplug sequence with either more cyclictests threads
>>>> - The test is done with all CPUs online and with only CPU0 and CPU2
>>>>
>>>> The main conclusion is that there is no differences with and without
>>>> your patches with my stress tests. I'm not sure that it was the
>>>> expected results but the cpu_down is already quite low : 4-5ms in
>>>> average
>>>>
>>>
>>> Atleast my patchset doesn't perform _worse_ than mainline, with respect
>>> to cpu_down duration :-)
>>
>> yes exactly and it has pass  more than 400 consecutive plug/unplug on
>> an ARM platform
>>
> 
> Great! However, did you turn on CPU_IDLE during your tests?
> 
> In my tests, I had turned off cpu idle in the .config, like I had mentioned in
> the cover letter. I'm struggling to get it working with CPU_IDLE/INTEL_IDLE
> turned on, because it gets into a lockup almost immediately. It appears that
> the lock-holder of clockevents_lock never releases it, for some reason..
> See below for the full log. Lockdep has not been useful in debugging this,
> unfortunately :-(
> 

Ah, nevermind, the following diff fixes it :-) I had applied this fix on v5
and tested but it still had races where I used to hit the lockups. Now after
I fixed all the memory barrier issues that Paul and Oleg pointed out in v5,
I applied this fix again and tested it just now - it works beautifully! :-)

I'll include this fix and post a v6 soon.

Regards,
Srivatsa S. Bhat

--------------------------------------------------------------------------->


diff --git a/kernel/time/clockevents.c b/kernel/time/clockevents.c
index 30b6de0..ca340fd 100644
--- a/kernel/time/clockevents.c
+++ b/kernel/time/clockevents.c
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/notifier.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 
 #include "tick-internal.h"
 
@@ -431,6 +432,7 @@ void clockevents_notify(unsigned long reason, void *arg)
 	unsigned long flags;
 	int cpu;
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&clockevents_lock, flags);
 	clockevents_do_notify(reason, arg);
 
@@ -459,6 +461,7 @@ void clockevents_notify(unsigned long reason, void *arg)
 		break;
 	}
 	raw_spin_unlock_irqrestore(&clockevents_lock, flags);
+	put_online_cpus_atomic();
 }
 EXPORT_SYMBOL_GPL(clockevents_notify);
 #endif

