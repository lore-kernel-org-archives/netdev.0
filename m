From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] Staging: Octeon:  Free transmit SKBs in a timely
 manner.
Date: Mon, 15 Feb 2010 22:11:11 +0100
Message-ID: <1266268271.2859.22.camel@edumazet-laptop>
References: <4B79AAA6.60005@caviumnetworks.com>
	 <1266264799-3510-4-git-send-email-ddaney@caviumnetworks.com>
	 <1266265673.2859.5.camel@edumazet-laptop>
	 <4B79B15F.7030506@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:40841 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089Ab0BOVLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 16:11:16 -0500
Received: by bwz5 with SMTP id 5so1421293bwz.1
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 13:11:15 -0800 (PST)
In-Reply-To: <4B79B15F.7030506@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 f=C3=A9vrier 2010 =C3=A0 12:41 -0800, David Daney a =C3=A9c=
rit :
> On 02/15/2010 12:27 PM, Eric Dumazet wrote:
> > Le lundi 15 f=C3=A9vrier 2010 =C3=A0 12:13 -0800, David Daney a =C3=
=A9crit :
> >> If we wait for the once-per-second cleanup to free transmit SKBs,
> >> sockets with small transmit buffer sizes might spend most of their
> >> time blocked waiting for the cleanup.
> >>
> >> Normally we do a cleanup for each transmitted packet.  We add a
> >> watchdog type timer so that we also schedule a timeout for 150uS a=
fter
> >> a packet is transmitted.  The watchdog is reset for each transmitt=
ed
> >> packet, so for high packet rates, it never expires.  At these high
> >> rates, the cleanups are done for each packet so the extra watchdog
> >> initiated cleanups are not needed.
> >
> > s/needed/fired/
> >
>=20
> or perhaps s/are not needed/are neither needed nor fired/
>=20
> > Hmm, but re-arming a timer for each transmited packet must have a c=
ost ?
> >
>=20
> The cost is fairly low (less than 10 processor clock cycles).  We did=
n't=20
> add this for amusement, people actually do things like only send UDP=20
> packets from userspace.  Since we can fill the transmit queue faster=20
> than it is emptied, the socket transmit buffer is quickly consumed.  =
If=20
> we don't free the SKBs in short order, the transmitting process get t=
o=20
> take a long sleep (until our previous once per second clean up task w=
as=20
> run).

I understand this, but traditionaly, NIC drivers dont use a timer, but =
a
'TX complete' interrupt, that usually fires a few us after packet
submission on Gigabit speed.

A fast program could try to send X small udp packets in less than 150
us, X being greater than the size of your TX ring.

So your patch makes the window smaller, but it still is there (at
physical layer, we'll see a burst of packets, a ~100us delay, then a
second burst)



