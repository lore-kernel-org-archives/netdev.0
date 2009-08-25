From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: TSecr != 0 check in inet_lro.c
Date: Tue, 25 Aug 2009 14:50:38 +0300
Message-ID: <200908251450.38751.opurdila@ixiacom.com>
References: <200908250054.50664.opurdila@ixiacom.com> <4A9379C9.6050108@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Jan-Bernd Themann" <themann@de.ibm.com>, netdev@vger.kernel.org,
	Christoph Raisch <raisch@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19568 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752589AbZHYLxW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 07:53:22 -0400
In-Reply-To: <4A9379C9.6050108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 25 August 2009 08:42:33 Eric Dumazet wrote:
> Octavian Purdila a =E9crit :
> > Hi,
> >
> > We are seeing a performance issue with TSO/LRO which we tracked dow=
n to
> > the TSecr !=3D0 check in lro_tcp_ip_check.
>
> ouch...
>
> > It happens when the LRO side's TSval wraps around and gets to 0. Th=
at
> > triggers the TSO side to send packets with TSecr set to 0, which me=
ans
> > that such packets won't be aggregated - and that will put a lot of =
burden
> > on the stack which will result in lots of drops.
>
> Probability of such event is 1 / 2^32 or so ?
>

Yes, its pretty low, but the timestamps are taken from jiffies and jiff=
ies are=20
initialized to -300*HZ so it will happen in 5 minutes after every reboo=
t :)

> > I'm failing to understand the purpose of this check. Any hints? :)
>
> rfc1323 badly interpreted ?
>
> I remember tsecr=3D0 was forbidden by Linux, while apparently rfc is =
not
> so clear.
>
> rfc1323 : 3.2
>          The Timestamp Echo Reply field (TSecr) is only valid if the =
ACK
>          bit is set in the TCP header; if it is valid, it echos a tim=
es-
>          tamp value that was sent by the remote TCP in the TSval fiel=
d
>          of a Timestamps option.  When TSecr is not valid, its value
>          must be zero.  The TSecr value will generally be from the mo=
st
>          recent Timestamp option that was received; however, there ar=
e
>          exceptions that are explained below.
>
> Note how this is not saying "a zero Tsecr value is not valid"

That is my understanding as well.

> I could not find why : "When TSecr is not valid, its value
> must be zero", and why we consider a zero value to be not meaningfull=
=2E..
>
> ...
>
> So we dont have a bit saying we received a tsecr, we use the
> 'if saw_tstamp AND tsecr is not null' convention...

Alright, its starting to make sense. So, it looks like we can remove th=
e check=20
from inet_lro, and that may even reduce the probability of receiving a =
zero=20
TSecr in the stack. Right?

Thanks for you help!

tavi
