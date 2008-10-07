From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 7 Oct 2008 16:07:29 +0200
Message-ID: <20081007160729.60c076c4@speedy>
References: <20081006185026.GA10383@minyard.local>
	<48EA8197.6080502@cosmosbay.com>
	<20081006.144002.56418911.davem@davemloft.net>
	<48EAF29D.8050203@cosmosbay.com>
	<m37i8k3hv1.fsf@ursa.amorsen.dk>
	<48EB5D28.7000503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	David Miller <davem@davemloft.net>, minyard@acm.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53491 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbYJGOHh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 10:07:37 -0400
In-Reply-To: <48EB5D28.7000503@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2008 14:59:20 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Benny Amorsen a =C3=A9crit :
> > Eric Dumazet <dada1@cosmosbay.com> writes:
> >=20
> >> Most UDP sockets are setup for long periods (RTP trafic), or if an=
 application really
> >> wants to {open/send or receive one UDP frame/close} many sockets, =
it already hits
> >> RCU handling of its file structures and should not be slowed down =
that much.
> >>
>=20
> I should have say 'Many' instead of 'Most' :)
>=20
> >> By 'long period' I mean thousand of packets sent/received by each =
RTP session, being
> >> voice (50 packets/second) or even worse video...
> >=20
> > Does DNS with port randomization need short lived sockets?
> >=20
>=20
> Yes very true, but current allocation of a random port can be very ex=
pensive,=20
> since we scan all the UDP hash table to select the smaller hash chain=
=2E
>=20
> We stop the scan if we find an empty slot, but on machines with say m=
ore than 200
> bound UDP sockets, they are probably no empty slots. (UDP_HTABLE_SIZE=
 is 128)
>=20
> bind(NULL port) algo is then O(N), N being number of bound UDP socket=
s.
>=20
> So heavy DNS servers/proxies probably use a pool/range of pre-allocat=
ed sockets
> to avoid costs of allocating/freeing them ? If they dont care about t=
hat cost,
> the extra call_rcu() will be unnoticed.
>=20
> For pathological (yet very common :) ) cases like single DNS query/an=
swer, RCU
> would mean :
>=20
> Pros :
> - one few rwlock hit when receiving the answer (if any)
> Cons :
> - one call_rcu() to delay socket freeing/reuse after RCU period.
>=20
> So it might be a litle bit more expensive than without RCU
>=20
> I agree I am more interested in optimizing UDP stack for heavy users =
like RTP=20
> servers/proxies handling xxx.000 packets/second than DNS users/server=
s.
> Shame on me :)
>=20
> (2 weeks ago, Corey mentioned a 10x increase on UDP throughput on a 1=
6-way machine,
> that sounds promising)

The idea of keeping chains short is the problem. That code should just =
be pulled because
it doesn't help that much, and also creates bias on the port randomizat=
ion.
