From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 11 Nov 2015 19:35:05 +0000
Message-ID: <yw1x37wcnxcm.fsf@unicorn.mansr.com>
References: <yw1xbnb0ny6k.fsf@unicorn.mansr.com>
	<20151111.141956.1056130800039910138.davem@davemloft.net>
	<yw1x7flonxs5.fsf@unicorn.mansr.com>
	<20151111.142650.1297832998846138251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151111.142650.1297832998846138251.davem@davemloft.net> (David
	Miller's message of "Wed, 11 Nov 2015 14:26:50 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: M=E5ns Rullg=E5rd <mans@mansr.com>
> Date: Wed, 11 Nov 2015 19:25:46 +0000
>
>> David Miller <davem@davemloft.net> writes:
>>=20
>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>> Date: Wed, 11 Nov 2015 19:17:07 +0000
>>>
>>>> David Miller <davem@davemloft.net> writes:
>>>>=20
>>>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>>>> Date: Wed, 11 Nov 2015 19:09:19 +0000
>>>>>
>>>>>> David Miller <davem@davemloft.net> writes:
>>>>>>=20
>>>>>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>>>>>> Date: Wed, 11 Nov 2015 18:25:05 +0000
>>>>>>>
>>>>>>>> If the TX DMA channel is idle when start_xmit is called, it ca=
n be
>>>>>>>> started immediately.  Checking the DMA status and starting it =
if
>>>>>>>> idle has to be done atomically somehow.
>>>>>>>
>>>>>>> ->ndo_start_xmit() is guaranteed to be invoked atomically, prot=
ected
>>>>>>> by the TX queue spinlock.
>>>>>>=20
>>>>>> Yes, but the DMA needs to be restarted from some other context i=
f it was
>>>>>> busy when start_xmit checked.
>>>>>
>>>>> Then you can probably use the TXQ lock in the interrupt handler j=
ust for
>>>>> that.
>>>>=20
>>>> That seems a bit heavy-handed when the critical section for this i=
s only
>>>> a tiny part of the start_xmit function.
>>>
>>> Then what synchornization primitive other than spin locks are you g=
oing
>>> to use for this?
>>>
>>> My point is that there is a spinlock the core code is _already_ tak=
ing,
>>> unconditionally, when ->ndo_start_xmit() executes.  And you can the=
refore
>>> take advantage of that rather than using another lock of your own.
>>=20
>> I get that.  But that remains locked for the duration of ndo_start_x=
mit()
>> whereas the part that needs to be synchronised with the DMA completi=
on
>> IRQ handler is tiny.  Having the IRQ handler spin for the duration o=
f
>> ndo_start_xmit() seemed silly to me.
>
> I don't think it's silly at all.

I'm sure I read somewhere that the time spent spinning on a lock should
be kept as small as possible.

> And unless you can measure it making a difference, don't knock the id=
ea.

I tried using netif_tx_lock() in the IRQ handler instead, and it locked
up solid.  Clearly that was the wrong thing to do.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
