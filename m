From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Mon, 23 Jun 2014 09:57:59 -0700
Message-ID: <CACT4Y+aFDvhNAXvRM-WMrak1PWtT3qG6XBLaKcJAebJ+LQg7aA@mail.gmail.com>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
 <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1406101726390.11647@dtop> <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
 <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
 <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.10.1406102114520.28698@dinf> <1402466090.3645.456.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1406110011170.11647@dtop> <alpine.DEB.2.02.1406110022550.11647@dtop>
 <alpine.DEB.2.02.1406110036490.11647@dtop> <1402490462.3645.463.camel@edumazet-glaptop2.roam.corp.google.com>
 <1402492373.3645.466.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1406111851140.18470@dtop> <1402544609.3645.473.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1406221202460.14871@dtop> <1403512412.16682.23.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1406230151480.19472@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:57750 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600AbaFWQ6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 12:58:19 -0400
Received: by mail-ie0-f169.google.com with SMTP id at1so6100838iec.28
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 09:58:19 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1406230151480.19472@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, 2014 at 1:55 AM, dormando <dormando@rydia.net> wrote:
> On Mon, 23 Jun 2014, Eric Dumazet wrote:
>
>> On Sun, 2014-06-22 at 12:07 -0700, dormando wrote:
>>
>> > Update on testing:
>> >
>> > I only have two machines that crash on their own frequently (more like
>> > one, even). Unfortunately something happened to the datacenter it's in and
>> > it was offline for a week. The machine normally crashes after 1.5-4d,
>> > averaging 2d.
>> >
>> > It's done about three days total time without a new crash. I also have the
>> > kernel running in another datacenter for ~10 days.. but it takes 30-150
>> > days to crash in that one.
>> >
>> > So, inconclusive, but still promising. If the machine survives the week it
>> > probably means it's fixed, or at least greatly reduced.
>> >
>> > I saw that one of your patches got queued for stable, but all three were
>> > necessary to fix udpkill. What's your plan for cleanup/upstreaming?
>> >
>> > Did you folks end up running udpkill under the tester thing?
>>
>> I did not test udpkill, as the known problem is the DST_NOCACHE flag.
>>
>> We end up calling sk_dst_set(sk, dst) with a dst having this flag set.
>>
>> So maybe DST_NOCACHE should be renamed, if we _can _ cache a dst like
>> this. Its meaning is really that dst_release() has to track when
>> refcount reaches 0 so that last owner fress dst, but we need to respect
>> rcu grace period.
>>
>> Fixing sk_dst_set() as I did is not enough, as it is only reducing race
>> window.
>
> Hrm. I'll have to spend more time trying to understand how to test this
> (beyond just putting a kernel into production and seeing if it crashes).
> Outside of udpkill it's been slightly hard to reproduce, and udpkill ran
> for over five hours with your previous patches.
>
> Do you or other folks have any methods for testing this?


Well, running with kasan should reduce time to crash by an order of magnitude.
Alexey, have we tried running udpkill with kasan?
