From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 11 Nov 2015 18:25:05 +0000
Message-ID: <yw1xk2poo0la.fsf@unicorn.mansr.com>
References: <20151110.211121.422193831316296487.davem@davemloft.net>
	<yw1xa8qkpvy3.fsf@unicorn.mansr.com>
	<yw1x6118pu0o.fsf@unicorn.mansr.com>
	<20151111.112423.1751428739163066569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151111.112423.1751428739163066569.davem@davemloft.net> (David
	Miller's message of "Wed, 11 Nov 2015 11:24:23 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: M=E5ns Rullg=E5rd <mans@mansr.com>
> Date: Wed, 11 Nov 2015 13:04:07 +0000
>
>> M=E5ns Rullg=E5rd <mans@mansr.com> writes:
>>=20
>>> David Miller <davem@davemloft.net> writes:
>>>
>>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>>> Date: Wed, 11 Nov 2015 00:40:09 +0000
>>>>
>>>>> When the DMA complete interrupt arrives, the next chain should be
>>>>> kicked off as quickly as possible, and I don't see why that would
>>>>> benefit from being done in napi context.
>>>>
>>>> NAPI isn't about low latency, it's about fairness and interrupt
>>>> mitigation.
>>>>
>>>> You probably don't even realize that all of the TX SKB freeing you=
 do
>>>> in the hardware interrupt handler end up being actually processed =
by a
>>>> scheduled software interrupt anyways.
>>>>
>>>> So you are gaining almost nothing by not doing TX completion in NA=
PI
>>>> context, whereas by doing so you would be gaining a lot including
>>>> more simplified locking or even the ability to do no locking at al=
l.
>>>
>>> TX completion is separate from restarting the DMA, and moving that =
to
>>> NAPI may well be a good idea.  Should I simply napi_schedule() if t=
he
>>> hardware indicates TX is complete and do the cleanup in the NAPI po=
ll
>>> function?
>>=20
>> I tried that, and throughput (as measured by iperf3) dropped by 2%.
>> Maybe I did something wrong.
>
> Did you fix all the locking in that change?
>
> Since all of your TX handling runs in software interrupt context, you
> can stop using IRQ locking and use BH locking driver-wide instead.
>
> And actually, no locking is really needed for TX processing.  With
> proper memory barriers and properly crafter queue state tests, you
> can run completely lockless.
>
> Again, look at example drivers.  I know, for example, that
> drivers/net/ethernet/broadcom/tg3.c runs TX lockless.  You'll
> see that tg3_tx() takes no locks at all.

The way the hardware works, once a DMA operation has been started,
adding more packets to the active chain can't be done reliably.  For
that reason, if start_xmit is called (with xmit_more zero) while a DMA
operation is in progress, the new packet(s) must be queued until the
hardware raises the DMA complete interrupt.  At that time, the next
pending DMA chain, if any, can be kicked off.  If the TX DMA channel is
idle when start_xmit is called, it can be started immediately.  Checkin=
g
the DMA status and starting it if idle has to be done atomically
somehow.

There is a separate indication for actual TX completion, and the
interrupt for that can be set to only fire every 7 frames or when a
timeout expires.  When this happens, the TX cleanup needs to run, and
that can obviously be done from NAPI without using any locks.

Bear in mind that this hardware is quite primitive compared to modern
high-performance Ethernet controllers from the likes of Intel and
Broadcom.  The documentation I have is dated 2003.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
