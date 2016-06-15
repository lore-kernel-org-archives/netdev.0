From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next v2] tcp: use RFC6298 compliant TCP RTO calculation
Date: Wed, 15 Jun 2016 11:02:14 -0700
Message-ID: <CAK6E8=fgQitOiXwjjn0gq93w7m5DQ2OHr_wvq-oGeAF2fhE-uA@mail.gmail.com>
References: <CAK6E8=dWLF+gRprxEbHRLnkRNHmf5sbedtv2Dt1jOqKPh7fmjA@mail.gmail.com>
 <20160614191841.21496-1-dmetz@mytum.de> <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
 <20160615174114.GA16217@virgo.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Metz <dmetz@mytum.de>, netdev <netdev@vger.kernel.org>,
	Daniel Metz <daniel.metz@rohde-schwarz.com>,
	Eric Dumazet <edumazet@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34169 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbcFOSCy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 14:02:54 -0400
Received: by mail-io0-f181.google.com with SMTP id 5so28220562ioy.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 11:02:54 -0700 (PDT)
In-Reply-To: <20160615174114.GA16217@virgo.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 10:41 AM, Hagen Paul Pfeifer <hagen@jauu.net> w=
rote:
>
> * Yuchung Cheng | 2016-06-14 14:33:18 [-0700]:
>
> >> +               tp->rttvar_us =3D tp->mdev_us;
> >AFAICT we can update rttvar_us directly and don't need mdev_us anymo=
re?
>
> Yes, v3 will remove mdev_us.
>
> >This is more aggressive than  RFC6298 that RTO <- SRTT + max (G,
> >K*RTTVAR) where G =3D MIN_RTO =3D 200ms
> >
> >based on our discussion, in the spirit of keeping RTO more
> >conservative, I recommend we implement RFC formula. Acks being delay=
ed
> >over 200ms is not uncommon (unfortunately due to bloat or other
> >issues).
> >
> >Also I think we should change __tcp_set_rto so that the formula
> >applies to backoffs or ICMP timeouts calculations too.
>
> We are a unsure what you mean Yuchung. We believe this patch not to b=
e more
> aggressive than RFC 6298. In fact, we believe it to be RFC 6298 compl=
iant, as
> in RFC 6298, G is the clock granularity and we don=E2=80=99t see wher=
e it deviates
> from the RFC. However, it is more aggressive than =E2=80=9CRTO <- SRT=
T + max (G,
> K*RTTVAR) where G =3D MIN_RTO =3D 200ms=E2=80=9D. Which formula do yo=
u want to implement?
Let me explain in a different way:

* RFC6298 applies a lower bound of 1 second to RTO (section 2.4)

* Linux currently applies a lower bound of 200ms (min_rto) to
K*RTTVAR, but /not/ RTO itself.

* This patch applies the lower bound of 200ms to RTO, similar to RFC629=
8


Let's say the SRTT is 100ms and RTT variations is 10ms. The variation
is low because we've been sending large chunks, and RTT is fairly
stable, and we sample on every ACK. The RTOs produced are

RFC6298: RTO=3D1s
Linux: RTO=3D300ms
This patch: RTO=3D200ms

Then we send 1 packet out. The receiver delays the ACK up to 200ms.
The actual RTT can be longer because other network components further
delay the data or the ACK. This patch would surely fire the RTO
spuriously.

so we can either implement RFC6298 faithfully, or apply the
lower-bound as-is, or something in between. But the current patch
as-is is more aggressive. Did I miss something?


>
>
> Hagen
