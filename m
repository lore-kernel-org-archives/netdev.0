From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 00/45] CPU hotplug: stop_machine()-free CPU hotplug
Date: Mon, 18 Feb 2013 16:04:27 +0530
Message-ID: <512203B3.7090002@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <510FBC01.2030405@linux.vnet.ibm.com>	<87haloiwv0.fsf@rustcorp.com.au> <51134596.4080106@linux.vnet.ibm.com> <20130208154113.GV17833@n2100.arm.linux.org.uk> <51152B81.2050501@linux.vnet.ibm.com>	<51153F72.1060005@linux.vnet.ibm.com> <CAKfTPtCe+cD7LLkb+D6pqG1SwG2V08ws=4XO3ttHEHV2qgmqPg@mail.gmail.com> <5118E2CD.90401@linux.vnet.ibm.com> <20130211190852.GA5695@linux.vnet.ibm.com> <5119BDFD.1000909@linux.vnet.ibm.com> <CAKfTPtAo2hQTfBKTVUuLKgsGJ2ZLD0UTR3fH9UFuJwyFt4n__w@mail.gmail.com> <511E8F3C.2010406@linux.vnet.ibm.com> <CAKfTPtD=2jn1AVjuhVP1ot7_8x9-W4==hNGZET5N9tRE7gtyMw@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKfTPtD=2jn1AVjuhVP1ot7_8x9-W4==hNGZET5N9tRE7gtyMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2013 03:54 PM, Vincent Guittot wrote:
> On 15 February 2013 20:40, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> Hi Vincent,
>>
>> On 02/15/2013 06:58 PM, Vincent Guittot wrote:
>>> Hi Srivatsa,
>>>
>>> I have run some tests with you branch (thanks Paul for the git tree)
>>> and you will find results below.
>>>
>>
>> Thank you very much for testing this patchset!
>>
>>> The tests condition are:
>>> - 5 CPUs system in 2 clusters
>>> - The test plugs/unplugs CPU2 and it increases the system load each 20
>>> plug/unplug sequence with either more cyclictests threads
>>> - The test is done with all CPUs online and with only CPU0 and CPU2
>>>
>>> The main conclusion is that there is no differences with and without
>>> your patches with my stress tests. I'm not sure that it was the
>>> expected results but the cpu_down is already quite low : 4-5ms in
>>> average
>>>
>>
>> Atleast my patchset doesn't perform _worse_ than mainline, with respect
>> to cpu_down duration :-)
> 
> yes exactly and it has pass  more than 400 consecutive plug/unplug on
> an ARM platform
>

Great! However, did you turn on CPU_IDLE during your tests?

In my tests, I had turned off cpu idle in the .config, like I had mentioned in
the cover letter. I'm struggling to get it working with CPU_IDLE/INTEL_IDLE
turned on, because it gets into a lockup almost immediately. It appears that
the lock-holder of clockevents_lock never releases it, for some reason..
See below for the full log. Lockdep has not been useful in debugging this,
unfortunately :-(

>>
>> So, here is the analysis:
>> Stop-machine() doesn't really slow down CPU-down operation, if the rest
>> of the CPUs are mostly running in userspace all the time. Because, the
>> CPUs running userspace workloads cooperate very eagerly with the stop-machine
>> dance - they receive the resched IPI, and allow the per-cpu cpu-stopper
>> thread to monopolize the CPU, almost immediately.
>>
>> The scenario where stop-machine() takes longer to take effect is when
>> most of the online CPUs are running in kernelspace, because, then the
>> probability that they call preempt_disable() frequently (and hence inhibit
>> stop-machine) is higher. That's why, in my tests, I ran genload from LTP
>> which generated a lot of system-time (system-time in 'top' indicates activity
>> in kernelspace). Hence my patchset showed significant improvement over
>> mainline in my tests.
>>
> 
> ok, I hadn't noticed this important point for the test
> 
>> However, your test is very useful too, if we measure a different parameter:
>> the latency impact on the workloads running on the system (cyclic test).
>> One other important aim of this patchset is to make hotplug as less intrusive
>> as possible, for other workloads running on the system. So if you measure
>> the cyclictest numbers, I would expect my patchset to show better numbers
>> than mainline, when you do cpu-hotplug in parallel (same test that you did).
>> Mainline would run stop-machine and hence interrupt the cyclic test tasks
>> too often. My patchset wouldn't do that, and hence cyclic test should
>> ideally show better numbers.
> 
> In fact, I haven't looked at the results as i was more interested by
> the load that was generated
> 
>>
>> I'd really appreciate if you could try that out and let me know how it
>> goes.. :-) Thank you very much!
> 
> ok, I'm going to try to run a test series
> 

Great! Thank you :-)
Regards,
Srivatsa S. Bhat

--------------------------------------------------------------------------------

Lockup observed while running this patchset, with CPU_IDLE and INTEL_IDLE turned
on in the .config:

 smpboot: CPU 1 is now offline
Kernel panic - not syncing: Watchdog detected hard LOCKUP on cpu 11
Pid: 0, comm: swapper/11 Not tainted 3.8.0-rc7+stpmch13-1 #8
Call Trace:
 <NMI>  [<ffffffff815a319e>] panic+0xc9/0x1ee
 [<ffffffff810fdd41>] watchdog_overflow_callback+0xb1/0xc0
 [<ffffffff8113ab5c>] __perf_event_overflow+0x9c/0x330
 [<ffffffff81028a88>] ? x86_perf_event_set_period+0xd8/0x160
 [<ffffffff8113b514>] perf_event_overflow+0x14/0x20
 [<ffffffff8102ee54>] intel_pmu_handle_irq+0x1c4/0x360
 [<ffffffff815a8ef1>] perf_event_nmi_handler+0x21/0x30
 [<ffffffff815a8366>] nmi_handle+0xb6/0x200
 [<ffffffff815a82b0>] ? oops_begin+0xd0/0xd0
 [<ffffffff815a85c8>] default_do_nmi+0x68/0x220
 [<ffffffff815a8840>] do_nmi+0xc0/0x110
 [<ffffffff815a7911>] end_repeat_nmi+0x1e/0x2e
 [<ffffffff812a3f98>] ? delay_tsc+0x38/0xb0
 [<ffffffff812a3f98>] ? delay_tsc+0x38/0xb0
 [<ffffffff812a3f98>] ? delay_tsc+0x38/0xb0
 <<EOE>>  [<ffffffff812a3f1f>] __delay+0xf/0x20
 [<ffffffff812aba1e>] do_raw_spin_lock+0x7e/0x150
 [<ffffffff815a64c1>] _raw_spin_lock_irqsave+0x61/0x70
 [<ffffffff810c0758>] ? clockevents_notify+0x28/0x150
 [<ffffffff815a6d37>] ? _raw_spin_unlock_irqrestore+0x77/0x80
 [<ffffffff810c0758>] clockevents_notify+0x28/0x150
 [<ffffffff8130459f>] intel_idle+0xaf/0xe0
 [<ffffffff81472ee0>] ? disable_cpuidle+0x20/0x20
 [<ffffffff81472ef9>] cpuidle_enter+0x19/0x20
 [<ffffffff814734c1>] cpuidle_wrap_enter+0x41/0xa0
 [<ffffffff81473530>] cpuidle_enter_tk+0x10/0x20
 [<ffffffff81472f17>] cpuidle_enter_state+0x17/0x50
 [<ffffffff81473899>] cpuidle_idle_call+0xd9/0x290
 [<ffffffff810203d5>] cpu_idle+0xe5/0x140
 [<ffffffff8159c603>] start_secondary+0xdd/0xdf
BUG: spinlock lockup suspected on CPU#2, migration/2/19
 lock: clockevents_lock+0x0/0x40, .magic: dead4ead, .owner: swapper/8/0, .owner_cpu: 8
Pid: 19, comm: migration/2 Not tainted 3.8.0-rc7+stpmch13-1 #8
Call Trace:
 [<ffffffff812ab878>] spin_dump+0x78/0xc0
 [<ffffffff812abac6>] do_raw_spin_lock+0x126/0x150
 [<ffffffff815a64c1>] _raw_spin_lock_irqsave+0x61/0x70
 [<ffffffff810c0758>] ? clockevents_notify+0x28/0x150
 [<ffffffff810c0758>] clockevents_notify+0x28/0x150
 [<ffffffff8159e08f>] hrtimer_cpu_notify+0xe3/0x107
 [<ffffffff815ab5ec>] notifier_call_chain+0x5c/0x120
 [<ffffffff8108d7de>] __raw_notifier_call_chain+0xe/0x10
 [<ffffffff8105e540>] __cpu_notify+0x20/0x40
 [<ffffffff81592003>] take_cpu_down+0x53/0x80
 [<ffffffff810ed3ba>] cpu_stopper_thread+0xfa/0x1e0
 [<ffffffff81591fb0>] ? enable_nonboot_cpus+0xf0/0xf0
 [<ffffffff815a5039>] ? __schedule+0x469/0x890
 [<ffffffff810ed2c0>] ? res_counter_init+0x60/0x60
 [<ffffffff810ed2c0>] ? res_counter_init+0x60/0x60
 [<ffffffff8108576e>] kthread+0xee/0x100
 [<ffffffff81085680>] ? __init_kthread_worker+0x70/0x70
 [<ffffffff815b092c>] ret_from_fork+0x7c/0xb0
 [<ffffffff81085680>] ? __init_kthread_worker+0x70/0x70
sending NMI to all CPUs:
NMI backtrace for cpu 3
CPU 3 
Pid: 0, comm: swapper/3 Not tainted 3.8.0-rc7+stpmch13-1 #8 IBM IBM System x -[7870C4Q]-/68Y8033     
RIP: 0010:[<ffffffff81304589>]  [<ffffffff81304589>] intel_idle+0x99/0xe0
RSP: 0018:ffff8808db57bdd8  EFLAGS: 00000046
RAX: 0000000000000020 RBX: 0000000000000008 RCX: 0000000000000001
RDX: 0000000000000000 RSI: ffff8808db57bfd8 RDI: ffffffff815a6d37
RBP: ffff8808db57be08 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000003
R13: 0000000000000020 R14: ffffffff81a9c000 R15: 0000000000000003
FS:  0000000000000000(0000) GS:ffff8808ffcc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fffbbb902f8 CR3: 0000000001a0c000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper/3 (pid: 0, threadinfo ffff8808db57a000, task ffff8808db578380)
Stack:
 0000000000000000 0000000300000001 ffff8808db57be18 ffff8808ffcda070
 000000bd1ad2c5de ffffffff81472ee0 ffff8808db57be18 ffffffff81472ef9
 ffff8808db57be78 ffffffff814734c1 ffff8808ffcc0000 0000000100000046
Call Trace:
 [<ffffffff81472ee0>] ? disable_cpuidle+0x20/0x20
 [<ffffffff81472ef9>] cpuidle_enter+0x19/0x20
 [<ffffffff814734c1>] cpuidle_wrap_enter+0x41/0xa0
 [<ffffffff81473530>] cpuidle_enter_tk+0x10/0x20
 [<ffffffff81472f17>] cpuidle_enter_state+0x17/0x50
 [<ffffffff81473899>] cpuidle_idle_call+0xd9/0x290
 [<ffffffff810203d5>] cpu_idle+0xe5/0x140
 [<ffffffff8159c603>] start_secondary+0xdd/0xdf
Code: ff 48 8d 86 38 e0 ff ff 83 e2 08 75 1e 31 d2 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 69 7d 79 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 91 c1 db 
NMI backtrace for cpu 5
CPU 5 
Pid: 0, comm: swapper/5 Not tainted 3.8.0-rc7+stpmch13-1 #8 IBM IBM System x -[7870C4Q]-/68Y8033     
RIP: 0010:[<ffffffff81304589>]  [<ffffffff81304589>] intel_idle+0x99/0xe0
RSP: 0018:ffff8808db583dd8  EFLAGS: 00000046
RAX: 0000000000000020 RBX: 0000000000000008 RCX: 0000000000000001
RDX: 0000000000000000 RSI: ffff8808db583fd8 RDI: ffffffff815a6d37
RBP: ffff8808db583e08 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000003
R13: 0000000000000020 R14: ffffffff81a9c000 R15: 0000000000000003
FS:  0000000000000000(0000) GS:ffff88117fc40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffffff600400 CR3: 0000000001a0c000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper/5 (pid: 0, threadinfo ffff8808db582000, task ffff8808db580400)
Stack:
 0000000000000000 0000000500000001 ffff8808db583e18 ffff88117fc5a070
 000000bd1af68ce5 ffffffff81472ee0 ffff8808db583e18 ffffffff81472ef9
 ffff8808db583e78 ffffffff814734c1 ffff88117fc40000 0000000100000046
Call Trace:
 [<ffffffff81472ee0>] ? disable_cpuidle+0x20/0x20
 [<ffffffff81472ef9>] cpuidle_enter+0x19/0x20
 [<ffffffff814734c1>] cpuidle_wrap_enter+0x41/0xa0
 [<ffffffff81473530>] cpuidle_enter_tk+0x10/0x20
 [<ffffffff81472f17>] cpuidle_enter_state+0x17/0x50
 [<ffffffff81473899>] cpuidle_idle_call+0xd9/0x290
 [<ffffffff810203d5>] cpu_idle+0xe5/0x140
 [<ffffffff8159c603>] start_secondary+0xdd/0xdf
Code: ff 48 8d 86 38 e0 ff ff 83 e2 08 75 1e 31 d2 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 69 7d 79 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 91 c1 db 
NMI backtrace for cpu 6
CPU 6 
Pid: 0, comm: swapper/6 Not tainted 3.8.0-rc7+stpmch13-1 #8 IBM IBM System x -[7870C4Q]-/68Y8033     
RIP: 0010:[<ffffffff81304589>]  [<ffffffff81304589>] intel_idle+0x99/0xe0
RSP: 0018:ffff8808db589dd8  EFLAGS: 00000046
RAX: 0000000000000010 RBX: 0000000000000004 RCX: 0000000000000001
RDX: 0000000000000000 RSI: ffff8808db589fd8 RDI: ffffffff815a6d37
RBP: ffff8808db589e08 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000002
R13: 0000000000000010 R14: ffffffff81a9c000 R15: 0000000000000002
FS:  0000000000000000(0000) GS:ffff88117fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fde168df000 CR3: 0000000001a0c000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper/6 (pid: 0, threadinfo ffff8808db588000, task ffff8808db586440)
Stack:
 0000000000000000 0000000600000001 ffff8808db589e18 ffff88117fc9a070
 000000bd1af4a55f ffffffff81472ee0 ffff8808db589e18 ffffffff81472ef9
 ffff8808db589e78 ffffffff814734c1 ffff88117fc80000 0000000b00000046
Call Trace:
 [<ffffffff81472ee0>] ? disable_cpuidle+0x20/0x20
 [<ffffffff81472ef9>] cpuidle_enter+0x19/0x20
 [<ffffffff814734c1>] cpuidle_wrap_enter+0x41/0xa0
 [<ffffffff81473530>] cpuidle_enter_tk+0x10/0x20
 [<ffffffff81472f17>] cpuidle_enter_state+0x17/0x50
 [<ffffffff81473899>] cpuidle_idle_call+0xd9/0x290
 [<ffffffff810203d5>] cpu_idle+0xe5/0x140
 [<ffffffff8159c603>] start_secondary+0xdd/0xdf
Code: ff 48 8d 86 38 e0 ff ff 83 e2 08 75 1e 31 d2 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e8 0f 01 c9 <85> 1d 69 7d 79 00 75 0e 48 8d 75 dc bf 05 00 00 00 e8 91 c1 db 
3h
