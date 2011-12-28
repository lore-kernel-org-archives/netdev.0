From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Wed, 28 Dec 2011 16:14:39 +0100
Message-ID: <CACPM=kWpGnBOuKPUK9MgzyETe4VmvEtVXkYtPA_+Xgn=COkCPw@mail.gmail.com>
References: <1325075319-13464-1-git-send-email-gurligebis@gentoo.org>
	<1325083051.2327.47.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Roger Luethi <rl@hellgate.ch>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64934 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875Ab1L1POk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 10:14:40 -0500
In-Reply-To: <1325083051.2327.47.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/12/28 Ben Hutchings <bhutchings@solarflare.com>:
> On Wed, 2011-12-28 at 12:28 +0000, Bjarke Istrup Pedersen wrote:
>> Working around problem causing high CPU load and hanging system when
>> there is alot of network trafic.
>>
>> It is kind of an ugly way to work around it, but it allows the Soekr=
is
>> net5501 to have trafic between two of it's NICs without hanging so m=
uch
>> that the watchdog kicks in and does a hard reboot of the system.
>>
>> There is more info on the problem here:
>> http://http://lists.soekris.com/pipermail/soekris-tech/2010-October/=
016889.html
>>
>> Tested with positive results on two Soekris net5501-70 boxes.
>
> This is completely wrong. =A0In a UP configuration the extra spinlock
> calls have no effect (except perhaps a small delay). =A0In an SMP
> configuration they will cause rhine_tx() to deadlock when it also tri=
es
> to acquire the spinlock.
>
> Ben.

Okay, the Soekris net5501-70 boxes are single-core, and I haven't got
any SMP boxes with that nic.
Is there a better solution for the problem then, to avoid it hanging
the box on a non-smp machine with a slow (500mhz) cpu?

/Bjarke

> [...]
>> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethe=
rnet/via/via-rhine.c
>> index f34dd99..8c77dcd 100644
>> --- a/drivers/net/ethernet/via/via-rhine.c
>> +++ b/drivers/net/ethernet/via/via-rhine.c
>> @@ -1567,6 +1567,9 @@ static irqreturn_t rhine_interrupt(int irq, vo=
id *dev_instance)
>> =A0 =A0 =A0 =A0 int boguscnt =3D max_interrupt_work;
>> =A0 =A0 =A0 =A0 int handled =3D 0;
>>
>> + =A0 =A0 =A0 if (!spin_trylock(&rp->lock))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_RETVAL(handled);
>> +
>> =A0 =A0 =A0 =A0 while ((intr_status =3D get_intr_status(dev))) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 handled =3D 1;
>>
>> @@ -1616,6 +1619,8 @@ static irqreturn_t rhine_interrupt(int irq, vo=
id *dev_instance)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 }
>>
>> + =A0 =A0 =A0 spin_unlock(&rp->lock);
>> +
>> =A0 =A0 =A0 =A0 if (debug > 3)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "exiting interrupt, =
status=3D%08x\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ioread16(ioad=
dr + IntrStatus));
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
