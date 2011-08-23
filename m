From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 03/10] ixgbe: Drop the TX work limit and instead just
 leave it to budget
Date: Mon, 22 Aug 2011 21:04:57 -0700
Message-ID: <CAKgT0UeUCyNRbfvkGKdyi17K6T-fSHukMGYwyJu2xOmAiBDZNA@mail.gmail.com>
References: <4E52920F.7060603@intel.com>
	<20110822.135644.683110224886588181.davem@davemloft.net>
	<4E52DEEF.40504@intel.com>
	<20110822.164027.1830363266993513959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:58519 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab1HWEE5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 00:04:57 -0400
Received: by yie30 with SMTP id 30so4065564yie.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 21:04:57 -0700 (PDT)
In-Reply-To: <20110822.164027.1830363266993513959.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2011 at 4:40 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Mon, 22 Aug 2011 15:57:51 -0700
>
>> The problem was occurring even without large rings.
>> I was seeing issues with rings just 256 descriptors in size.
>
> And the default in the ixgbe driver is 512 entries which I think
> itself is quite excessive. =A0Something like 128 is more in line with
> what I'd call a sane default.

Are you suggesting I change the the ring size, the TX quota, or both?

> So the only side effect of your change is to decrease the TX quota to
> 64 (the default NAPI quota) from it's current value of 512
> (IXGBE_DEFAULT_TXD).

Yeah, that pretty much sums it up.  However as I said in the earlier
email I am counting SKBs freed instead of descriptors.  As such we
will probably end up cleaning more like 128 descriptors per TX clean
just due to our context descriptors that are also occupying space in
the ring.

> Talking about the existing code, I can't even see how the current
> driver private TX quota can trigger except in the most extreme cases.
> This is because the quota is set the same as the size you're setting
> the TX ring to.

I'm not sure if it ever met the quota either.  I suspect not since
under the routing workloads I would see the RX interrupts get disabled
but the TX interrupts keep going.

>> The problem seemed to be that the TX cleanup being a multiple of
>> budget was allowing one CPU to overwhelm the other and the fact that
>> the TX was essentially unbounded was just allowing the issue to
>> feedback on itself.
>
> I still don't understand what issue you could even be running into.
>
> On each CPU we round robin against all NAPI requestors for that CPU.
>
> In your routing test setup, we should have one cpu doing the RX and
> another different cpu doing TX.
>
> Therefore if the TX cpu simply spins in a loop doing nothing but TX
> reclaim work it should not really matter.

Doing a unidirectional test was fine and everything worked as you
describe.  It was doing a bidirectional test with two ports and a
single queue for each port that was the issue.  Specifically what
would happen is that one direction would tend to dominate over the
other so I would end up with a 60/40 split with either upstream or
downstream dominating.  By using the budget as the quota I found the
results were generally much closer to 50/50 and the overall result of
the two flows combined was higher.  I suspect it had to do with TX
work getting backlogged on the ring and acting as a feedback mechanism
to prevent the RX work on that CPU from getting squashed.

> And if you hit the TX budget on the TX cpu, it's just going to come
> right back into the ixgbe NAPI handler and thus the TX reclaim
> processing not even a dozen cycles later.
>
> The only effect is to have us go through the whole function call
> sequence and data structure setup into local variables more than you
> would be doing so before.

I suppose that is possible.  It all depends on the type of packets
being sent.  For single sends without any offloads we would only be
cleaning 64 descriptors per call to ixgbe_poll,  with an offloaded
checksum or VLAN it would be 128 descriptors per call, and with TSO we
probably still wouldn't consume the budget since the sk_buff
consumption rate would be too low.

I can try testing the throughput with pktgen tomorrow to see if it
improves by increasing the TX budget.  I suppose there could be a few
factors affecting this since the budget value also determines the
number of buffers we clean before we call netif_wake_queue to
re-enable the transmit path.

>> In addition since the RX and TX workload was balanced it kept both
>> locked into polling while the CPU was saturated instead of allowing
>> the TX to become interrupt driven. =A0In addition since the TX was
>> working on the same budget as the RX the number of SKBs freed up in
>> the TX path would match the number consumed when being reallocated
>> on the RX path.
>
> So the only conclusion I can come to is that what happens is we're no=
w
> executing what are essentially wasted cpu cycles and this takes us
> over the threshold such that we poll more and take interrupts less.
> And this improves performance.
>
> That's pretty unwise if you ask me, we should do something useful wit=
h
> cpu cycles instead of wasting them merely to make us poll more.

The thing is we are probably going to be wasting those cycles anyway.
In the case of bidirectional routing I was always locked into RX
polling with this change in place or not.  The only difference is that
the TX will likely clean itself completely with each poll versus the
possibility of leaving a few buffers behind when it hits the 64 quota.

>> The problem seemed to be present as long as I allowed the TX budget =
to
>> be a multiple of the RX budget. =A0The easiest way to keep things
>> balanced and avoid allowing the TX from one CPU to overwhelm the RX =
on
>> another was just to keep the budgets equal.
>
> You're executing 10 or 20 cpu cycles after every 64 TX reclaims,
> that's the only effect of these changes. =A0That's not even long enou=
gh
> for a cache line to transfer between two cpus.

It sounds like I may not have been seeing this due to the type of
workload I was focusing on.  I'll try generating some data with pktgen
and netperf tomorrow to see how this holds up under small packet
transmit only traffic since those are the cases most likely to get
into the state you mention.

Also I would appreciate it if you had any suggestions on other
workloads I might need to focus on in order to determine the impact of
this change.

Thanks,

Alex
