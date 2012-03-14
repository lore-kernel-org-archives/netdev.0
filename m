From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch_sfq: revert dont put new flow at the end of flows
Date: Wed, 14 Mar 2012 07:04:59 -0700
Message-ID: <1331733899.2456.66.camel@edumazet-laptop>
References: <1327570722.8191.46.camel@probook>
	 <1331697865.2456.19.camel@edumazet-laptop>
	 <CAA93jw4kYqCWg424SXkrtQeg9bPfpfgH-x_7tjg=m8uxk_GNaA@mail.gmail.com>
	 <1331724732.7651.58.camel@probook>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <netoptimizer@brouer.com>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42045 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754393Ab2CNOFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 10:05:04 -0400
Received: by yenl12 with SMTP id l12so1821199yen.19
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 07:05:03 -0700 (PDT)
In-Reply-To: <1331724732.7651.58.camel@probook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 mars 2012 =C3=A0 12:32 +0100, Jesper Dangaard Brouer a =C3=
=A9crit :
> ons, 14 03 2012 kl. 04:52 +0000, skrev Dave Taht:
> > On Wed, Mar 14, 2012 at 4:04 AM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:

> > As the depth of the sfq queue increases it gets increasingly hard t=
o
> > trigger the problem. I've been using values in the 200-300 range, a=
nd
> > in combination with red, haven't seen it happen.
>=20
> I don't think you should adjust the "depth", but instead "limit" or
> "flows".
>=20
> The problem can be solved by SFQ parameter tuning.  Perhaps, we could
> just change the default parameters?
>=20
> The problem occurs when all flows have ONE packet, then sfq_drop()
> cannot find a good flow to drop packets from...
>=20
> This situation can occur because the default setting is "limit=3D127"
> packets and "flows=3D127".  If we just make sure that "limit" > "flow=
s",
> then one flow with >=3D2 packets should exist, which is then chosen f=
or
> drop.
> My practical experiments show that "limit" should be between 10-20
> packets larger than "flows" (I'm not completely sure why this is
> needed). =20
>=20

There are many ways to starve SFQ if we dont revert the patch or add ne=
w
logic in linux-3.4

Even if we change default settings, we can have following situation :

SFQ in a state with several regular flows in queue, correctly behaving
because they are nice.

loop repeat_as_many_times_you_can_think
 enqueue : packet comes for a new flow X.
           OK lets favor this new flow against 'old' ones.
 dequeue : takes the packet for flow X.
           forget about flow X since dequeue all its packets.
endloop

All other flows are in a frozen state.
