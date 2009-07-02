From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [GIT]: Networking
Date: Thu, 02 Jul 2009 12:13:24 -0400
Message-ID: <4A4CDCA4.3040505@nvidia.com>
References: <20090630.213927.180401151.davem@davemloft.net> <20090702075724.GA10608@elte.hu> <4A4C9125.8020705@gmail.com> <4A4CBE7D.2060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:6381 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbZGBVn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 17:43:59 -0400
In-Reply-To: <4A4CBE7D.2060603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
>=20
>>Ingo Molnar a =E9crit :
>>
>>>>The following changes since commit 52989765629e7d182b4f146050ebba0a=
bf2cb0b7:
>>>>  Linus Torvalds (1):
>>>>        Merge git://git.kernel.org/.../davem/net-2.6
>>>>
>>>>are available in the git repository at:
>>>>
>>>>  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git mas=
ter
>>>
>>>Hm, something in this lot quickly wrecked networking here - see the=20
>>>tx timeout dump below. It starts with:
>>>
>>>[  351.004596] WARNING: at net/sched/sch_generic.c:246 dev_watchdog+=
0x10b/0x19c()
>>>[  351.011815] Hardware name: System Product Name
>>>[  351.016220] NETDEV WATCHDOG: eth0 (forcedeth): transmit queue 0 t=
imed out
>>>
>>>Config attached. Unfortunately i've got no time to do bisection=20
>>>today.
>>
>>
>>
>>forcedeth might have a problem, in its netif_wake_queue() logic, but
>>I could not see why a recent patch could make this problem visible no=
w.
>>
>>CPU0/1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
>>is not a new cpu either :)
>>
>>forcedeth uses an internal tx_stop without appropriate barrier.
>>
>>Could you try following patch ?
>>
>>(random guess as I dont have much time right now)
>=20
>=20
> Oh well this patch was soooo stupid, sorry Ingo.
>=20
>=20
> We might have a race in napi_schedule(), leaving interrupts disabled =
forever.
> I cannot test this patch, I dont have the hardware...
>=20
> Thanks
>=20
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index 1094d29..3b4e076 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -3514,11 +3514,13 @@ static irqreturn_t nv_nic_irq(int foo, void *=
data)
>  	nv_msi_workaround(np);
> =20
>  #ifdef CONFIG_FORCEDETH_NAPI
> -	napi_schedule(&np->napi);
> -
> -	/* Disable furthur irq's
> -	   (msix not enabled with napi) */
> -	writel(0, base + NvRegIrqMask);
> +	if (napi_schedule_prep(&np->napi)) {
> +		/*
> +		 * Disable further irq's (msix not enabled with napi)
> +		 */
> +		writel(0, base + NvRegIrqMask);
> +		__napi_schedule(&np->napi);
> +	}

Yes, good catch. There is a race condition here with napi poll.

I would prefer to do the following to keep the code simple and clean.

writel(0, base + NvRegIrqMask);
napi_schedule(&np->napi);

=2E....

> =20
>  #else
>  	do
> @@ -3615,12 +3617,13 @@ static irqreturn_t nv_nic_irq_optimized(int f=
oo, void *data)
>  	nv_msi_workaround(np);
> =20
>  #ifdef CONFIG_FORCEDETH_NAPI
> -	napi_schedule(&np->napi);
> -
> -	/* Disable furthur irq's
> -	   (msix not enabled with napi) */
> -	writel(0, base + NvRegIrqMask);
> -
> +	if (napi_schedule_prep(&np->napi)) {
> +		/*
> +		 * Disable further irq's (msix not enabled with napi)
> +		 */
> +		writel(0, base + NvRegIrqMask);
> +		__napi_schedule(&np->napi);
> +	}
>  #else
>  	do
>  	{
