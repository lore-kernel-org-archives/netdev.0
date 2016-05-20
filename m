From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Thu, 19 May 2016 21:49:42 -0700
Message-ID: <573E9766.7080105@gmail.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
 <1463684190.18194.228.camel@edumazet-glaptop3.roam.corp.google.com>
 <1463686523.18194.232.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Udd+8PtOfZzR3VqEGyUPLifEjDzK0x3cezxcN9Ltq_KzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33697 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbcETEt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 00:49:59 -0400
Received: by mail-pf0-f178.google.com with SMTP id 206so37553141pfu.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 21:49:59 -0700 (PDT)
In-Reply-To: <CAKgT0Udd+8PtOfZzR3VqEGyUPLifEjDzK0x3cezxcN9Ltq_KzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-19 01:39 PM, Alexander Duyck wrote:
> On Thu, May 19, 2016 at 12:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2016-05-19 at 11:56 -0700, Eric Dumazet wrote:
>>
>>> Removing busylock helped in all cases I tested. (at least on x86 as
>>> David pointed out)
>>>
>>> As I said, we need to revisit busylock now that spinlocks are different.
>>>
>>> In one case (20 concurrent UDP netperf), I even got a 500 % increase.
>>>
>>> With busylock :
>>>
>>> lpaa5:~# sar -n DEV 4 4|grep eth0
>>> Average:         eth0     12.19 112797.12      1.95  37672.28      0.00      0.00      0.69
>>>
>>
>>
>> Hmpf, my sysctl logic was inverted. Really these results made little
>> sense.
>>
>> Sorry for the noise. At least we have 8% confirmed gain with this
>> stuff ;)
> 
> Unfortunately I see a 21% regression when you place the qdisc under
> load from multiple CPUs/nodes.  In my testing I dropped from around
> 1.05 Mpps to around 827 Kpps when I removed the busylock.
> 
> My test setup is pretty straight forward and the results I have seen
> are consistent between runs.  I have a system with 32 threads / 16
> cores spread over 2 NUMA nodes.  I reduce the number of queues on a
> 10Gb/s NIC to 1.  I kill irqbalance and disable CPU power states.  I
> then start a quick "for" loop that will schedule one UDP_STREAM
> netperf session on each CPU using a small payload size like 32.
> 
> On a side note, if I move everything onto one node I can push about
> 2.4 Mpps and the busylock doesn't seem to really impact things, but if
> I go to both nodes then I see the performance regression as described
> above.  I was thinking about it and I don't think the MCS type locks
> would have that much of an impact.  If anything I think that xmit_more
> probably has a bigger effect given that it allows us to grab multiple
> frames with each fetch and thereby reduce the lock contention on the
> dequeue side.
> 
>>> Presumably it would tremendously help if the actual kfree_skb()
>>> was done after qdisc lock is released, ie not from the qdisc->enqueue()
>>> method.
>>>
>>
>> This part is still valid.
>>
>> We could have a per cpu storage of one skb pointer, so that we do not
>> have to change all ->enqueue() prototypes.
> 
> I fully agree with that.
> 
> One thought I had is if we could move to a lockless dequeue path for
> the qdisc then we could also get rid of the busy lock.  I know there
> has been talk about doing away with qdisc locks or changing the inner
> mechanics of the qdisc itself in the past, I'm CCing Jesper and John
> for that reason.  Maybe it is time for us to start looking into that
> so we can start cleaning out some of the old cruft we have in this
> path.
> 
> - Alex
> 

I plan to start looking at this again in June when I have some
more time FWIW. The last set of RFCs I sent out bypassed both the
qdisc lock and the busy poll lock. I remember thinking this was a
net win at the time but I only did very basic testing e.g. firing
up n sessions of pktgen.

And because we are talking about cruft I always thought the gso_skb
requeue logic could be done away with as well. As far as I can tell
it must be there from some historic code that has been re-factored
or deleted pre-git days. It would be much better I think (no data)
to use byte queue limits or some other way to ensure the driver can
consume the packet vs popping and pushing skbs around.

.John
