From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 23:21:45 +0100
Message-ID: <1289427705.17691.52.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
	 <4CDADC17.6070506@candelatech.com>
	 <1289413120.2469.12.camel@edumazet-laptop>
	 <4CDAE713.7020309@candelatech.com>
	 <1289421187.2469.127.camel@edumazet-laptop>  <4CDB1021.507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63637 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757115Ab0KJWVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 17:21:51 -0500
Received: by eye27 with SMTP id 27so785761eye.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 14:21:50 -0800 (PST)
In-Reply-To: <4CDB1021.507@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 13:35 -0800, Ben Greear a =C3=A9cri=
t :


> So an application that must deal with wraps must poll at the minimal
> time interval for wrapping 32-bit counters at whatever speed, or it
> must pay attention to the driver to somehow know that this magic driv=
er
> can *really* do 64-bit stats properly?
>=20

Are you aware that you speak of something that is not specified at all
in linux ?

=46requency of polling is not part of any RFC. This usually is tunable =
in
the _application_. Some people sample stats every 5 minutes, some sampl=
e
every second, and hit the "xxx driver updates its stats every two
seconds, this sucks"

I wrote SNMP apps based on /proc/net/dev and all just work, with any
versions, any driver. Of course, some of them broke 6 years ago because
they were 32bit legacy application, running on a 64bit kernel. I never
asked David to change /proc/net/dev to cap counters to 32bit.

When 128bit cpu come, some userland changes are needed to parse 128bit
numbers.

In anycase, apps dont have to know a particular driver provides 64bit o=
r
32bit counter. Only choice for them is to automatically detect the
wraparound, because they fetch a STRING, not a Counter32 or Counter64

This works for all drivers, legacy, new, Intel or whatever. If a driver
changes from 32 to 64, nothing special happens in /proc/net/dev.

RRD for example handles this just fine.

> Please note that just because a counter is less than the previous rea=
d,
> that doesn't by itself tell us if it wrapped once or twice.  And, if =
we
> don't know at which number of bits it wraps, then we don't know how m=
any
> to add even if we are certain it wrapped only once.
>=20

I repeat : Nothing in /proc/net/dev can tell you when a counter will
wrap (the counter width).

You also need to use the correct polling frequency, depending on max
speed. It was already the case with 32bit counters, 64bit ones only gav=
e
some extra range.

> In general, I want to treat eth0 the same as eth5, and not worry that=
 one
> is 10/100 realtek and the other a 10G Intel.
>=20


> If netlink reports stats64, then those should only wrap at 64 bits,
> and if it reports stats32, then wrap at 32-bits.
>=20

I believe you are mistaken. We provide stats64 for all drivers, even
32bit legacy ones. rtnetlink has no way to report counter widths,
because nobody cared.



