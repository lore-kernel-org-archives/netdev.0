From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 00/45] CPU hotplug: stop_machine()-free CPU hotplug
Date: Sat, 16 Feb 2013 01:10:44 +0530
Message-ID: <511E8F3C.2010406@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <510FBC01.2030405@linux.vnet.ibm.com>	<87haloiwv0.fsf@rustcorp.com.au> <51134596.4080106@linux.vnet.ibm.com> <20130208154113.GV17833@n2100.arm.linux.org.uk> <51152B81.2050501@linux.vnet.ibm.com>	<51153F72.1060005@linux.vnet.ibm.com> <CAKfTPtCe+cD7LLkb+D6pqG1SwG2V08ws=4XO3ttHEHV2qgmqPg@mail.gmail.com> <5118E2CD.90401@linux.vnet.ibm.com> <20130211190852.GA5695@linux.vnet.ibm.com> <5119BDFD.1000909@linux.vnet.ibm.com> <CAKfTPtAo2hQTfBKTVUuLKgsGJ2ZLD0UTR3fH9UFuJwyFt4n__w@mail.gmail.com>
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
In-Reply-To: <CAKfTPtAo2hQTfBKTVUuLKgsGJ2ZLD0UTR3fH9UFuJwyFt4n__w@mail.gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vincent,

On 02/15/2013 06:58 PM, Vincent Guittot wrote:
> Hi Srivatsa,
> 
> I have run some tests with you branch (thanks Paul for the git tree)
> and you will find results below.
>

Thank you very much for testing this patchset!
 
> The tests condition are:
> - 5 CPUs system in 2 clusters
> - The test plugs/unplugs CPU2 and it increases the system load each 20
> plug/unplug sequence with either more cyclictests threads
> - The test is done with all CPUs online and with only CPU0 and CPU2
> 
> The main conclusion is that there is no differences with and without
> your patches with my stress tests. I'm not sure that it was the
> expected results but the cpu_down is already quite low : 4-5ms in
> average
> 

Atleast my patchset doesn't perform _worse_ than mainline, with respect
to cpu_down duration :-)

So, here is the analysis:
Stop-machine() doesn't really slow down CPU-down operation, if the rest
of the CPUs are mostly running in userspace all the time. Because, the
CPUs running userspace workloads cooperate very eagerly with the stop-machine
dance - they receive the resched IPI, and allow the per-cpu cpu-stopper
thread to monopolize the CPU, almost immediately.

The scenario where stop-machine() takes longer to take effect is when
most of the online CPUs are running in kernelspace, because, then the
probability that they call preempt_disable() frequently (and hence inhibit
stop-machine) is higher. That's why, in my tests, I ran genload from LTP
which generated a lot of system-time (system-time in 'top' indicates activity
in kernelspace). Hence my patchset showed significant improvement over
mainline in my tests.

However, your test is very useful too, if we measure a different parameter:
the latency impact on the workloads running on the system (cyclic test).
One other important aim of this patchset is to make hotplug as less intrusive
as possible, for other workloads running on the system. So if you measure
the cyclictest numbers, I would expect my patchset to show better numbers
than mainline, when you do cpu-hotplug in parallel (same test that you did).
Mainline would run stop-machine and hence interrupt the cyclic test tasks
too often. My patchset wouldn't do that, and hence cyclic test should
ideally show better numbers.

I'd really appreciate if you could try that out and let me know how it
goes.. :-) Thank you very much!

Regards,
Srivatsa S. Bhat

> 
> 
> On 12 February 2013 04:58, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> On 02/12/2013 12:38 AM, Paul E. McKenney wrote:
>>> On Mon, Feb 11, 2013 at 05:53:41PM +0530, Srivatsa S. Bhat wrote:
>>>> On 02/11/2013 05:28 PM, Vincent Guittot wrote:
>>>>> On 8 February 2013 19:09, Srivatsa S. Bhat
>>>>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>>
>>> [ . . . ]
>>>
>>>>>> Adding Vincent to CC, who had previously evaluated the performance and
>>>>>> latency implications of CPU hotplug on ARM platforms, IIRC.
>>>>>>
>>>>>
>>>>> Hi Srivatsa,
>>>>>
>>>>> I can try to run some of our stress tests on your patches.
>>>>
>>>> Great!
>>>>
>>>>> Have you
>>>>> got a git tree that i can pull ?
>>>>>
>>>>
>>>> Unfortunately, no, none at the moment..  :-(
>>>
>>> You do need to create an externally visible git tree.
>>
>> Ok, I'll do that soon.
>>
>>>  In the meantime,
>>> I have added your series at rcu/bhat.2013.01.21a on -rcu:
>>>
>>> git://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-rcu.git
>>>
>>> This should appear soon on a kernel.org mirror near you.  ;-)
>>>
>>
>> Thank you very much, Paul! :-)
>>
>> Regards,
>> Srivatsa S. Bhat
>>


