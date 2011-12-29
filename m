From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 19:36:20 +0100
Message-ID: <1325183780.2607.60.camel@edumazet-laptop>
References: <1324664907.2915.5.camel@edumazet-laptop>
	 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
	 <1324668083.2915.15.camel@edumazet-laptop>
	 <1325132760.2607.15.camel@edumazet-laptop>
	 <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
	 <1325149922.2607.33.camel@edumazet-laptop> <20111229165249.GB2948@hell>
	 <1325178950.2607.46.camel@edumazet-laptop> <20111229174323.GC2948@hell>
	 <1325182236.2607.50.camel@edumazet-laptop> <20111229182502.GD2948@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:54056 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab1L2Sg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 13:36:28 -0500
Received: by wibhm6 with SMTP id hm6so6467813wib.19
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 10:36:26 -0800 (PST)
In-Reply-To: <20111229182502.GD2948@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 d=C3=A9cembre 2011 =C3=A0 19:25 +0100, Hagen Paul Pfeifer a=
 =C3=A9crit :
> * Eric Dumazet | 2011-12-29 19:10:36 [+0100]:
>=20
> >I dont quite understand the question. The patch I posted is supposed=
 to
> >fix the problem. What do you want to tell to the user ?
>=20
> I assumed that the patch makes it possible to replace standard tfifo?=
! Tfifo
> provides strict ordering, other qdisc's do not. So I thought if someo=
ne use
> netem rate|jitter with e.g. SFQ then this should be mentioned somewhe=
re. E.g.
> "rate|jitter can only be used with tfifo qdisc". Correct me if I am w=
rong.
>=20

Current netem uses a single queue, default tfifo.

Then if you change this tfifo by SFQ, you lose tfifo, and netem doesnt
work at all.

I claim we cannot remove tfifo.

After my patch, you now have :

1) An internal mandatory tfifo queue, to fulfill time_to_send
requirements.

2) An optional qdisc (SFQ in your example), where packets are queued
once dequeued from tfifo at the right time (after netem delay/rate
respected), eventually a packet can finaly be delivered to device with =
a
_bigger_ delay than the one predicted in tfifo, because of trafic
shaping happening in this optional qdisc.


=46ull netem block :

              +---------+                   +--------+
-->>-enqueue--| tfifo   |---->>>>--enqueue--|  SFQ   |-dequeue--->>>>>=20
              +---------+                   +--------+
