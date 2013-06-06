From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v9 net-next 2/7] net: add low latency socket poll
Date: Thu, 06 Jun 2013 15:50:42 +0300
Message-ID: <51B085A2.5090306@linux.intel.com>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>    <20130605103421.11172.82925.stgit@ladj378.jer.intel.com>   <1370445714.24311.268.camel@edumazet-glaptop>   <51AF59B0.6080101@linux.intel.com>  <1370446760.24311.275.camel@edumazet-glaptop>  <51AF5D5A.8030907@linux.intel.com> <1370447966.24311.284.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370447966.24311.284.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/06/2013 18:59, Eric Dumazet wrote:
> On Wed, 2013-06-05 at 18:46 +0300, Eliezer Tamir wrote:
>> On 05/06/2013 18:39, Eric Dumazet wrote:
>>> On Wed, 2013-06-05 at 18:30 +0300, Eliezer Tamir wrote:
>>>> On 05/06/2013 18:21, Eric Dumazet wrote:
>>
>>>>> It would also make sense to give end_time as a parameter, so that the
>>>>> polling() code could really give  a end_time for the whole duration of
>>>>> poll().
>>>>>
>>>>> (You then should test can_poll_ll(end_time) _before_ call to
>>>>> ndo_ll_poll())
>>>>
>>>> how would you handle a nonblocking operation in that case?
>>>> I guess if we have a socket option, then we don't need to handle none
>>>> blocking any diffrent, since the user specified exactly how much time to
>>>> waste polling. right?
>>>
>>> If the thread already spent 50us in the poll() system call, it for sure
>>> should not call any ndo_ll_poll(). This makes no more sense at this
>>> point.
>>
>> what about a non-blocking read from a socket?
>> Right now we assume this means poll only once since the application will
>> repeat as needed.
>>
>> maybe add a "once" parameter that will cause sk_poll_ll() to ignore end
>> time and only try once?
>
> extern bool __sk_poll_ll(struct sock *sk, cycles_t end);
>
> static inline bool sk_poll_ll(struct sock *sk, bool nonblock)
> {
> 	return __sk_poll_ll(sk, nonblock, ll_end_time());
> }
>
> In the poll() code, we should call ll_end_time() once, even if we poll
> 1000 fds.

Right now we have three uses for sk_poll_ll

1. blocking read - In this case we loop until:
   a !skb_queue_empty(&sk->sk_receive_queue)
or
   b !can_poll_ll(end_time)

2. non-blocking read - only try once, ignoring end time.

3. poll/select - for each socket we only try once (nonblock==1),
  we loop in poll/select until we are lucky or run out of time.

For 1 we want to loop inside sk_poll_ll() but for 3 we loop in poll/select.

So it seems all we need is for sk_poll_ll() to not call ll_end_time() if 
nonblock is set.

( something like cycles_t end_time = nonblock ? 0 : ll_end_time(); )

Or we could move out looping in all cases to the calling function.
Does this mean we should push out rcu_read_lock_bh() into the caller
  as well?

-Eliezer
