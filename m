From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] vhost: replace vhost_workqueue with per-vhost	kthread
Date: Mon, 31 May 2010 17:38:41 +0200
Message-ID: <4C03D801.9090106@kernel.org>
References: <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com> <4C02C961.9050606@kernel.org> <20100531143945.GA6497@redhat.com> <4C03D0BE.1040601@kernel.org> <20100531153104.GA9452@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100531153104.GA9452@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 05/31/2010 05:31 PM, Oleg Nesterov wrote:
>> I might have slightly over engineered this part not knowing the
>> expected workload.  ->queue_seq/->done_seq pair is to guarantee that
>> flushers never get starved.
> 
> Ah, indeed.
> 
> Well, afaics we do not need 2 counters anyway, both vhost_poll_queue()
> and vhost_poller() could increment the single counter and the flusher
> can take bit 0 into account. But I agree 2 counters are much more clean.

Right, we can do that too.  Cool. :-)

>>>> +static int vhost_poller(void *data)
>>>> +{
>>>> +	struct vhost_dev *dev = data;
>>>> +	struct vhost_poll *poll;
>>>> +
>>>> +repeat:
>>>> +	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
>>>
>>> I don't understand the comment... why do we need this barrier?
>>
>> So that either kthread_stop()'s should_stop = 1 in kthread_stop() is
>> visible to kthread_should_stop() or task state is set to RUNNING.
> 
> Of course, you are right. I am really surprized I asked this question ;)

This part is always a bit tricky tho.  Maybe it would be a good idea
to make kthread_stop() do periodic wakeups.  It's already injecting
one rather unexpected wake up into the mix anyway so there isn't much
point in avoiding multiple and it would make designing kthread loops
easier.  Or maybe what we need is something like kthread_idle() which
encapsulates the check and sleep part.

Thanks.

-- 
tejun
