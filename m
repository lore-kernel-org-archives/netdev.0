From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 11:24:23 -0500 (EST)
Message-ID: <20151111.112423.1751428739163066569.davem@davemloft.net>
References: <20151110.211121.422193831316296487.davem@davemloft.net>
	<yw1xa8qkpvy3.fsf@unicorn.mansr.com>
	<yw1x6118pu0o.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1x6118pu0o.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: M=E5ns Rullg=E5rd <mans@mansr.com>
Date: Wed, 11 Nov 2015 13:04:07 +0000

> M=E5ns Rullg=E5rd <mans@mansr.com> writes:
>=20
>> David Miller <davem@davemloft.net> writes:
>>
>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>> Date: Wed, 11 Nov 2015 00:40:09 +0000
>>>
>>>> When the DMA complete interrupt arrives, the next chain should be
>>>> kicked off as quickly as possible, and I don't see why that would
>>>> benefit from being done in napi context.
>>>
>>> NAPI isn't about low latency, it's about fairness and interrupt
>>> mitigation.
>>>
>>> You probably don't even realize that all of the TX SKB freeing you =
do
>>> in the hardware interrupt handler end up being actually processed b=
y a
>>> scheduled software interrupt anyways.
>>>
>>> So you are gaining almost nothing by not doing TX completion in NAP=
I
>>> context, whereas by doing so you would be gaining a lot including
>>> more simplified locking or even the ability to do no locking at all=
=2E
>>
>> TX completion is separate from restarting the DMA, and moving that t=
o
>> NAPI may well be a good idea.  Should I simply napi_schedule() if th=
e
>> hardware indicates TX is complete and do the cleanup in the NAPI pol=
l
>> function?
>=20
> I tried that, and throughput (as measured by iperf3) dropped by 2%.
> Maybe I did something wrong.

Did you fix all the locking in that change?

Since all of your TX handling runs in software interrupt context, you
can stop using IRQ locking and use BH locking driver-wide instead.

And actually, no locking is really needed for TX processing.  With
proper memory barriers and properly crafter queue state tests, you
can run completely lockless.

Again, look at example drivers.  I know, for example, that
drivers/net/ethernet/broadcom/tg3.c runs TX lockless.  You'll
see that tg3_tx() takes no locks at all.
