From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 18:15:50 +0100
Message-ID: <1325178950.2607.46.camel@edumazet-laptop>
References: <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	 <1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	 <1324664907.2915.5.camel@edumazet-laptop>
	 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
	 <1324668083.2915.15.camel@edumazet-laptop>
	 <1325132760.2607.15.camel@edumazet-laptop>
	 <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
	 <1325149922.2607.33.camel@edumazet-laptop> <20111229165249.GB2948@hell>
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
Received: from mail-we0-f174.google.com ([74.125.82.174]:37656 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab1L2RPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 12:15:55 -0500
Received: by werm1 with SMTP id m1so6236930wer.19
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 09:15:54 -0800 (PST)
In-Reply-To: <20111229165249.GB2948@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 d=C3=A9cembre 2011 =C3=A0 17:52 +0100, Hagen Paul Pfeifer a=
 =C3=A9crit :
> * Eric Dumazet | 2011-12-29 10:12:02 [+0100]:
>=20
> >> Also, the whole tfifo idea is only to support the wierd idea that
> >> if doing random delay that packets should get reordered based on t=
he
> >> results of the random value; it was an behavior some users wanted
> >> because that is what NISTnet did.
> >
> >tfifo supports a time ordered queuing, wich mimics some jitter in th=
e
> >network. This seems quite useful.
> >
> >I see what you suggest : adding 'time_to_send' in the generic qdisc =
cb.
> >
> >But it makes no sense if we attach a reordering qdisc, like SFQ :
> >A 'high prio' packet will block the whole netem because we'll have t=
o
> >throttle since this packet time_to_send will be in the future, while
> >many other elligible packets are in queue.
>=20
> In other words netem jitter and a qdisc !tfifo will not work. Correct=
? The
> rate extension also peak the last packet to get the reference time (a=
ssuming a
> strict ordering):
>=20

Yep, current situation is borked. It assumes we _use_ tfifo, for delay
jitters but also for rate extension.

> [...]
> now =3D netem_skb_cb(skb_peek_tail(list))->time_to_send;
> [...]
>=20
>=20
> We should avoid a different (unseeable) behavior depending on the que=
ue
> (tfifo, SFQ).  Another point: operate netem and qdisc on the same com=
puter can
> lead to timing abnormalities. In our test setups we operate qdisc/tcp=
/whatever
> setups and netem on more then on computer.
>=20

After my patch you could use netem as a delay module before a complex
qdisc setup for example.

[ Simulating a 10ms delay on a 10Gigabit link is expensive, since you
need to allow up to ~150.000 packets in tfifo. Maybe we should switch t=
o
tbfifo [giving a limit in bytes, not packets ] ]
