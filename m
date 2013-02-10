From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 04/45] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Mon, 11 Feb 2013 01:50:10 +0530
Message-ID: <511800FA.1060007@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com> <20130208231017.GK2666@linux.vnet.ibm.com> <5117F0C0.2030605@linux.vnet.ibm.com> <20130210201312.GB6236@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	namhyung@kernel.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130210201312.GB6236@redhat.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/11/2013 01:43 AM, Oleg Nesterov wrote:
> On 02/11, Srivatsa S. Bhat wrote:
>>
>> On 02/09/2013 04:40 AM, Paul E. McKenney wrote:
>>>> +static void announce_writer_inactive(struct percpu_rwlock *pcpu_rwlock)
>>>> +{
>>>> +	unsigned int cpu;
>>>> +
>>>> +	drop_writer_signal(pcpu_rwlock, smp_processor_id());
>>>
>>> Why do we drop ourselves twice?  More to the point, why is it important to
>>> drop ourselves first?
>>>
>>
>> I don't see where we are dropping ourselves twice. Note that we are no longer
>> in the cpu_online_mask, so the 'for' loop below won't include us. So we need
>> to manually drop ourselves. It doesn't matter whether we drop ourselves first
>> or later.
> 
> Yes, but this just reflects its usage in cpu-hotplug. cpu goes away under
> _write_lock.
> 

Ah, right. I guess the code still has remnants from the older version in which
this locking scheme wasn't generic and was tied to cpu-hotplug alone..

> Perhaps _write_lock/unlock shoud use for_each_possible_cpu() instead?
> 

Hmm, that wouldn't be too bad.

> Hmm... I think this makes sense anyway. Otherwise, in theory,
> percpu_write_lock(random_non_hotplug_lock) can race with cpu_up?
> 

Yeah, makes sense. Will change it to for_each_possible_cpu().
And I had previously fixed such races with lglocks with a complicated scheme (to
avoid the costly for_each_possible loop), which was finally rewritten to use
for_each_possible_cpu() for the sake of simplicity..
Regards,
Srivatsa S. Bhat
