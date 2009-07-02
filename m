From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT]: Networking
Date: Fri, 03 Jul 2009 00:32:54 +0200
Message-ID: <4A4D3596.8060209@gmail.com>
References: <20090630.213927.180401151.davem@davemloft.net> <20090702075724.GA10608@elte.hu> <4A4C9125.8020705@gmail.com> <4A4CBE7D.2060603@gmail.com> <4A4CDCA4.3040505@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39494 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755022AbZGBWdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 18:33:01 -0400
In-Reply-To: <4A4CDCA4.3040505@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla a =E9crit :
>=20
>=20
> Eric Dumazet wrote:
>> Eric Dumazet a =E9crit :
>>
>>> Ingo Molnar a =E9crit :
>>>
>>>>> The following changes since commit
>>>>> 52989765629e7d182b4f146050ebba0abf2cb0b7:
>>>>>  Linus Torvalds (1):
>>>>>        Merge git://git.kernel.org/.../davem/net-2.6
>>>>>
>>>>> are available in the git repository at:
>>>>>
>>>>>  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git ma=
ster
>>>>
>>>> Hm, something in this lot quickly wrecked networking here - see th=
e
>>>> tx timeout dump below. It starts with:
>>>>
>>>> [  351.004596] WARNING: at net/sched/sch_generic.c:246
>>>> dev_watchdog+0x10b/0x19c()
>>>> [  351.011815] Hardware name: System Product Name
>>>> [  351.016220] NETDEV WATCHDOG: eth0 (forcedeth): transmit queue 0
>>>> timed out
>>>>
>>>> Config attached. Unfortunately i've got no time to do bisection to=
day.
>>>
>>>
>>>
>>> forcedeth might have a problem, in its netif_wake_queue() logic, bu=
t
>>> I could not see why a recent patch could make this problem visible =
now.
>>>
>>> CPU0/1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
>>> is not a new cpu either :)
>>>
>>> forcedeth uses an internal tx_stop without appropriate barrier.
>>>
>>> Could you try following patch ?
>>>
>>> (random guess as I dont have much time right now)
>>
>>
>> Oh well this patch was soooo stupid, sorry Ingo.
>>
>>
>> We might have a race in napi_schedule(), leaving interrupts disabled
>> forever.
>> I cannot test this patch, I dont have the hardware...
>>
>> Thanks
>>
>> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
>> index 1094d29..3b4e076 100644
>> --- a/drivers/net/forcedeth.c
>> +++ b/drivers/net/forcedeth.c
>> @@ -3514,11 +3514,13 @@ static irqreturn_t nv_nic_irq(int foo, void
>> *data)
>>      nv_msi_workaround(np);
>> =20
>>  #ifdef CONFIG_FORCEDETH_NAPI
>> -    napi_schedule(&np->napi);
>> -
>> -    /* Disable furthur irq's
>> -       (msix not enabled with napi) */
>> -    writel(0, base + NvRegIrqMask);
>> +    if (napi_schedule_prep(&np->napi)) {
>> +        /*
>> +         * Disable further irq's (msix not enabled with napi)
>> +         */
>> +        writel(0, base + NvRegIrqMask);
>> +        __napi_schedule(&np->napi);
>> +    }
>=20
> Yes, good catch. There is a race condition here with napi poll.
>=20
> I would prefer to do the following to keep the code simple and clean.
>=20
> writel(0, base + NvRegIrqMask);
> napi_schedule(&np->napi);


CC trimmed down to network devs only :)

It would be racy too ...

check drivers/net/amd8111e.c, drivers/net/natsemi.c ...

If this cpu inconditionaly calls writel(0, base + NvRegIrqMask);=20
while another cpu just called writel(np->irqmask, base + NvRegIrqMask),
we end with disabled interrupts ?

