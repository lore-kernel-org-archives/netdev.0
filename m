From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next v2] tcp: use RFC6298 compliant TCP RTO
 calculation
Date: Thu, 16 Jun 2016 11:07:35 +0200 (CEST)
Message-ID: <1771240333.25844.1466068055580@office.mailbox.org>
References: <CAK6E8=dWLF+gRprxEbHRLnkRNHmf5sbedtv2Dt1jOqKPh7fmjA@mail.gmail.com>
 <20160614191841.21496-1-dmetz@mytum.de>
 <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
 <20160615174114.GA16217@virgo.localdomain>
 <CAK6E8=fgQitOiXwjjn0gq93w7m5DQ2OHr_wvq-oGeAF2fhE-uA@mail.gmail.com>
 <16f7fad2-e8e3-44b7-af09-43467840bd00@mytum.de>
 <CANn89iLY27dQLXEmk9GMtACjjE0CWxqSK2FdM-Zo5HM5iA82XQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	Daniel Metz <daniel.metz@rohde-schwarz.com>
To: Daniel Metz <dmetz@mytum.de>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mailbox.org ([80.241.60.215]:47395 "EHLO mx2.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323AbcFPJHr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 05:07:47 -0400
In-Reply-To: <CANn89iLY27dQLXEmk9GMtACjjE0CWxqSK2FdM-Zo5HM5iA82XQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On June 15, 2016 at 10:38 PM Eric Dumazet <edumazet@google.com> wrote=
:
>
> I guess the problem is that some folks use smaller rto than
> RTAX_RTO_MIN , look at tcp_rto_min()

Due to the nature of the Linux calculation, this is probably more of a =
reason to use the RFC 6298 calculation. When a smaller MinRTO as 200ms =
is used, the Linux =E2=80=9Cadvantage=E2=80=9D to account for Delayed A=
CKs up to 200ms is decreased. Assuming a MinRTO of 0ms, the Linux abili=
ty and the RFC ability to account for sudden Delayed ACKs is pretty equ=
al: zero.=20

To illustrate this: RTT: 50ms, RTTVAR: 0ms, MinRTO: 50ms, Delayed ACKs:=
 200ms.=20

Before any ACK is delayed:

Linux RTO ~ 100+ms (tested)=20
RFC 6298 RTO ~ 50+ms (tested)=20

RTT of first delayed ACK if it is not shortened due to another data pac=
ket: ~250ms=20

This is not tied to the RTT:
RTT 1000ms, RTTVAR: 0ms, MinRTO: 50ms, Delayed ACKs: 200ms=20

Before any ACK is delayed:

Linux RTO ~ 1050+ms (tested)=20
RFC 6298 RTO ~ 1000+ms (tested)

RTT of first delayed ACK if it is not shortened due to another data pac=
ket: ~1200ms=20

A RFC 6298 problem we run in so far was with extremely steady RTTs and =
sender limited data. A Spurious Retransmission occurred from time to ti=
me in this case.

Hagen
