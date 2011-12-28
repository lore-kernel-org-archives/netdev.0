From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Wed, 28 Dec 2011 18:30:05 +0100
Message-ID: <CACPM=kX2hcGt3XXDJkCAcOjv=5oqSHChhhphUAyRhR_PsNFEEQ@mail.gmail.com>
References: <1325075319-13464-1-git-send-email-gurligebis@gentoo.org>
	<1325083051.2327.47.camel@deadeye>
	<CACPM=kWpGnBOuKPUK9MgzyETe4VmvEtVXkYtPA_+Xgn=COkCPw@mail.gmail.com>
	<1325092423.2327.70.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Roger Luethi <rl@hellgate.ch>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:36753 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753864Ab1L1RaH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 12:30:07 -0500
In-Reply-To: <1325092423.2327.70.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/12/28 Ben Hutchings <bhutchings@solarflare.com>:
> On Wed, 2011-12-28 at 16:14 +0100, Bjarke Istrup Pedersen wrote:
>> 2011/12/28 Ben Hutchings <bhutchings@solarflare.com>:
>> > On Wed, 2011-12-28 at 12:28 +0000, Bjarke Istrup Pedersen wrote:
>> >> Working around problem causing high CPU load and hanging system w=
hen
>> >> there is alot of network trafic.
>> >>
>> >> It is kind of an ugly way to work around it, but it allows the So=
ekris
>> >> net5501 to have trafic between two of it's NICs without hanging s=
o much
>> >> that the watchdog kicks in and does a hard reboot of the system.
>> >>
>> >> There is more info on the problem here:
>> >> http://http://lists.soekris.com/pipermail/soekris-tech/2010-Octob=
er/016889.html
>> >>
>> >> Tested with positive results on two Soekris net5501-70 boxes.
>> >
>> > This is completely wrong. =A0In a UP configuration the extra spinl=
ock
>> > calls have no effect (except perhaps a small delay). =A0In an SMP
>> > configuration they will cause rhine_tx() to deadlock when it also =
tries
>> > to acquire the spinlock.
>> >
>> > Ben.
>>
>> Okay, the Soekris net5501-70 boxes are single-core, and I haven't go=
t
>> any SMP boxes with that nic.
>> Is there a better solution for the problem then, to avoid it hanging
>> the box on a non-smp machine with a slow (500mhz) cpu?
>
> If the system actually hangs then I assume there is some bug in the
> driver. =A0I would guess the actual problem is that the interrupt and=
 NAPI
> handlers are running constantly so that user processes never run (whi=
ch
> I think counts as soft lockup).
>
> If the hardware supports it, interrupt moderation may help a little b=
y
> slightly reducing the per-packet processing cost, but it isn't a full
> solution. =A0Or you can use a real-time kernel, which schedules inter=
rupt
> and NAPI handlers as tasks, and adjust priorities so that user proces=
ses
> can still run. =A0But that brings its own problems (including general=
ly
> lower throughput).
>
> Ben.

That would be an option, but I don't think the hardware supports it,
and it doesn't fix the problems in the driver, just hides them.
=46rom what I can read in the thread I linked to in the patch, the
problem only exists in the Linux driver - *BSD isn't affected by this,
on the same hardware.

Since the hack here fixes the problem on non-smp machines, it seems
like there are some race conditions in the interrupt code in the
driver, like you mention.
I'm not well enough into this driver to be able to pinpoint what's
causing it, but if somebody else is, and got some ideas, I'll be more
than willing to test :)

/Bjarke

> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
