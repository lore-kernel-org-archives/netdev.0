From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Thu, 27 Jun 2013 15:36:11 +0530
Message-ID: <51CC0E93.1080608@linux.vnet.ibm.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com> <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com> <20130625220026.GG3828@linux.vnet.ibm.com> <51CAF624.6060004@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com> <20130626143424.GN3828@linux.vnet.ibm.com> <1372258271.18733.256.camel@gandalf.local.home> <20130626152148.GA4405@mtj.dyndns.org> <51CB3159.8000509@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B72AB@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, peterz@infradead.org,
	fweisbec@gmail.com, oleg@redhat.com, walken@google.com,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	vincent.guittot@linaro.org, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, Steven Rostedt <rostedt@goodmis.org>,
	namhyung@kernel.org, tglx@linutronix.de, laijs@cn.fujitsu.com,
	zhong@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sbw@mit.edu,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B72AB@saturn3.aculab.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27/2013 02:24 PM, David Laight wrote:
>>>>> It would also increase the latency of CPU-hotunplug operations.
>>>>
>>>> Is that a big deal?
>>>
>>> I thought that was the whole deal with this patchset - making cpu
>>> hotunplugs lighter and faster mostly for powersaving.  That said, just
>>> removing stop_machine call would be a pretty good deal and I don't
>>> know how meaningful reducing CPU hotunplug latency is.  Srivatsa?
>>>
>>
>> Keeping the hotunplug latency is important for suspend/resume, where
>> we take all non-boot CPUs in a loop. That's an interesting use-case
>> where intrusiveness doesn't matter much, but latency does. So yes,
>> making CPU hotplug faster is also one of the goals of this patchset.
> 
> If you are removing all but one of the cpu, the you only need
> one rcu cycle (remove everything from the list first).
> 

Hmm, yeah, but IIRC, back when we discussed this last time[1], we felt that
would make the code a little bit hard to understand. But I think we can
give it a shot to see how that goes and decide based on that. So thanks
for bringing that up again!

BTW, one thing I'd like to emphasize again here is that we will not use
the RCU-like concept to have 2 different masks - a stable online mask
and an actual online mask (this is one of the approaches that we had
discussed earlier[2]). The reason why we don't wanna go down that path is,
its hard to determine who can survive by just looking at the stable online
mask, and who needs to be aware of the actual online mask. That will
surely lead to more bugs and headache.

So the use of an RCU-like concept here would only be to ensure that all
preempt-disabled sections complete, and we can switch the synchronization
scheme to global rwlocks, like what we had proposed earlier[3]. So, that
still requires call-sites to be converted from preempt_disable() to
get/put_online_cpus_atomic().

I just wanted to clarify where exactly the RCU concept would fit in,
in the stop-machine() replacement scheme...


> I'd also guess that you can't suspend a cpu until you can sleep
> the process that is running on it - so if a process has pre-emption
> disabled you aren't going to complete suspend until the process
> sleeps (this wouldn't be true if you suspended the cpu with its
> current stack - but if suspend is removing the non-boot cpus first
> it must be doing so from the scheduler idle loop).
> 
> If you are doing suspend for aggressive power saving, then all the
> processes (and processors) will already be idle. However you
> probably wouldn't want the memory accesses to determine this on
> a large NUMA system with 1024+ processors.
> 

References:

[1]. http://lkml.indiana.edu/hypermail/linux/kernel/1212.2/01979.html
[2]. http://thread.gmane.org/gmane.linux.kernel/1405145/focus=29336
[3]. http://thread.gmane.org/gmane.linux.documentation/9520/focus=1443258
     http://thread.gmane.org/gmane.linux.power-management.general/29464/focus=1407948

Regards,
Srivatsa S. Bhat
