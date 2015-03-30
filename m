From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single CAN
 frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 12:41:54 +0200
Message-ID: <55192872.7000108@hartkopp.net>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <5519210E.40005@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5519210E.40005@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.03.2015 12:10, Marc Kleine-Budde wrote:

>>
>> +	/* eliminate multiple filter matches for the same skb */
>> +	if (*this_cpu_ptr(ro->uniq_skb) == oskb &&
>> +	    ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
>> +			return;
>> +	} else {
>> +		*this_cpu_ptr(ro->uniq_skb) = oskb;
>> +		*this_cpu_ptr(ro->uniq_tstamp) = oskb->tstamp;
>> +	}
>> +
>
> What happens if you're preempted somewhere in this code, it's not
> atomic? I think, if we only have to take care about the skb, an atomic
> compare exchange would work. But we have two variables....If you use a
> struct (see previous mail), I think the usage of get_cpu_ptr(),
> git_cpu_ptr() ensures that we're not preempted.
>

Please check out

https://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/

And especially 
https://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/x173.html#LOCK-SOFTIRQS-SAME

When a softirq processes an incoming skb this remains on that selected CPU.

The mutithread-test from Andre just lead to the problem that the (former 
single instance) variables ro->uniq_skb and ro->uniq_tstamp have been used by 
different CPUs which made the checks unreliable.

So following the documentation and other examples in kernel source you can

- use spinlocks in can_receive() in af_can.c (instead of rcu_read_lock())
- use per-CPU variables to allow the softirq to run in parallel

Just make the variables atomic (as you suggested) is as bad as introduce 
spinlocks in can_receive() as you reduce the skb processing to just one 
thread. So at least percpu is the best for performance but needs to create a 
vector of variables (percpu).

Putting a struct into these percpu handling can be done - but does it increase 
the readability in this case?

Regards,
Oliver


