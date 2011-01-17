From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.9)
Date: Mon, 17 Jan 2011 09:25:32 -0800
Message-ID: <20110117092532.7d5f5a5b@nehalam>
References: <20110113092706.154748c2@s6510>
	<1294951069.3403.11.camel@edumazet-laptop>
	<20110113153436.70d3c0a3@s6510>
	<4D305598.1010207@trash.net>
	<4D3055C2.3060807@trash.net>
	<1295015043.3937.20.camel@edumazet-laptop>
	<20110114154521.54cc8ef5@nehalam>
	<1295077542.3977.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43185 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397Ab1AQRZf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 12:25:35 -0500
In-Reply-To: <1295077542.3977.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 15 Jan 2011 08:45:42 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 14 janvier 2011 =E0 15:45 -0800, Stephen Hemminger a =E9c=
rit :
> > CHOKe ("CHOose and Kill" or "CHOose and Keep") is an alternative
> > packet scheduler based on the Random Exponential Drop (RED) algorit=
hm.
> >=20
> > The core idea is:
> >   For every packet arrival:
> >   	Calculate Qave
> > 	if (Qave < minth)=20
> > 	     Queue the new packet
> > 	else=20
> > 	     Select randomly a packet from the queue=20
> > 	     if (both packets from same flow)
> > 	     then Drop both the packets
> > 	     else if (Qave > maxth)
> > 	          Drop packet
> > 	     else
> > 	       	  Admit packet with proability p (same as RED)
> >=20
> > See also:
> >   Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a state=
less active
> >    queue management scheme for approximating fair bandwidth allocat=
ion",=20
> >   Proceeding of INFOCOM'2000, March 2000.
> >=20
> > Help from:
> >      Eric Dumazet <eric.dumazet@gmail.com>
> >      Patrick McHardy <kaber@trash.net>
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > ---
> > This version is based on net-next, and assumes Eric's patch for
> > corrected bstats is already applied.
> >=20
> > 0.9 incorporate patches from Patrick/Eric
> >     rework the peek_random and drop code to simplify and fix bug wh=
ere
> >     random_N needs to called with full length (including holes).
>=20
> Nice catch, I now have more "matched" counts after my test :
>=20
> qdisc choke 11: parent 1:11 limit 130000b min 10833b max 32500b ewma =
13 Plog 21 Scell_log 30
>  Sent 93944198 bytes 170889 pkt (dropped 829140, overlimits 436686 re=
queues 0)=20
>  rate 48bit 0pps backlog 0b 0p requeues 0=20
>   marked 0 early 436686 pdrop 0 other 0 matched 196227
>=20
> You missed the qdisc_bstats_update() move from enqueue() to dequeue()
>=20
> And some minor CodingStyle / checkpatch.pl changes, here is my
> latest diff on top of 0.9
>=20
> I believe you can release v1 :)
>=20
> Thanks !

I rolled in your changes. But there is one more change I want to make.
The existing flow match based on hash is vulnerable to side-channel DoS=
 attack.
It is possible for a hostile flow to send packets that match the same
hash value which would effectively kill a targeted flow.

The solution is to match based on full source and destination, not hash=
 value.
Still coding that up.



--=20
