From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/3] vhost: replace vhost_workqueue with per-vhost	kthread
Date: Mon, 31 May 2010 17:07:42 +0200
Message-ID: <4C03D0BE.1040601@kernel.org>
References: <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com> <4C02C961.9050606@kernel.org> <20100531143945.GA6497@redhat.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100531143945.GA6497@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 05/31/2010 04:39 PM, Oleg Nesterov wrote:
> On 05/30, Tejun Heo wrote:
>>
>> This conversion is to make each vhost use a dedicated kthread so that
>> resource control via cgroup can be applied.
> 
> Personally, I agree. I think This is better than play with workqueue thread.

Yeap, I think so too.  In vhost's case tho, as it exports a lot of
workqueue characteristics to vhost users, it's a bit more complex than
I wish it were.  It can probably be simplified more if someone who
knows the code better takes a look or maybe we need to make this kind
of things easier by providing a generic helpers if more cases like
this spring up, but if that happens probably the RTTD would be somehow
teaching workqueue how to deal with cgroups.  As this is the first
case, I guess open coding is okay for now.

> A couple of simple questions after the quick glance at the unapplied patch...
> 
>>  void vhost_poll_flush(struct vhost_poll *poll)
>>  {
>> -	flush_work(&poll->work);
>> +	int seq = poll->queue_seq;
>> +
>> +	if (seq - poll->done_seq > 0)
>> +		wait_event(poll->done, seq - poll->done_seq <= 0);
> 
> The check before wait_event() is not needed, please note that wait_event()
> checks the condition before __wait_event().

Heh... right, I was looking at __wait_event() and thinking "ooh... we
can skip lock in the fast path".  :-)

> What I can't understand is why we do have ->queue_seq and ->done_seq.
> 
> Isn't the single "bool poll->active" enough? vhost_poll_queue() sets
> ->active == T, vhost_poller() clears it before wake_up_all(poll->done).

I might have slightly over engineered this part not knowing the
expected workload.  ->queue_seq/->done_seq pair is to guarantee that
flushers never get starved.  Without sequencing queueings and
executions, flushers should wait for !pending && !active which can
take some time to come if the poll in question is very busy.

>> +static int vhost_poller(void *data)
>> +{
>> +	struct vhost_dev *dev = data;
>> +	struct vhost_poll *poll;
>> +
>> +repeat:
>> +	set_current_state(TASK_INTERRUPTIBLE);	/* mb paired w/ kthread_stop */
> 
> I don't understand the comment... why do we need this barrier?

So that either kthread_stop()'s should_stop = 1 in kthread_stop() is
visible to kthread_should_stop() or task state is set to RUNNING.

>> +	if (kthread_should_stop()) {
>> +		__set_current_state(TASK_RUNNING);
>> +		return 0;
>> +	}
>> +
>> +	poll = NULL;
>> +	spin_lock(&dev->poller_lock);
>> +	if (!list_empty(&dev->poll_list)) {
>> +		poll = list_first_entry(&dev->poll_list,
>> +					struct vhost_poll, node);
>> +		list_del_init(&poll->node);
>> +	}
>> +	spin_unlock(&dev->poller_lock);
>> +
>> +	if (poll) {
>> +		__set_current_state(TASK_RUNNING);
>> +		poll->fn(poll);
>> +		smp_wmb();	/* paired with rmb in vhost_poll_flush() */
>> +		poll->done_seq = poll->queue_seq;
>> +		wake_up_all(&poll->done);
>> +	} else
>> +		schedule();
>> +
>> +	goto repeat;
>> +}
> 
> Given that vhost_poll_queue() does list_add() and wake_up_process() under
> ->poller_lock, I don't think we need any barriers to change ->state.
> 
> IOW, can't vhost_poller() simply do
> 
> 	while(!kthread_should_stop()) {
> 
> 		poll = NULL;
> 		spin_lock(&dev->poller_lock);
> 		if (!list_empty(&dev->poll_list)) {
> 			...
> 		} else
> 			 __set_current_state(TASK_INTERRUPTIBLE);
> 		spin_unlock(&dev->poller_lock);
> 
> 		if (poll) {
> 			...
> 		} else
> 			schedule();
> 	}
> ?

But then kthread_stop() can happen between kthread_should_stop() and
__set_current_state(TASK_INTERRUPTIBLE) and poller can just sleep in
schedule() not knowing that.

Thank you.

-- 
tejun
