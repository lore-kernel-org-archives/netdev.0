From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 14:59:20 +0200
Message-ID: <48EB5D28.7000503@cosmosbay.com>
References: <20081006185026.GA10383@minyard.local>	<48EA8197.6080502@cosmosbay.com>	<20081006.144002.56418911.davem@davemloft.net>	<48EAF29D.8050203@cosmosbay.com> <m37i8k3hv1.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, minyard@acm.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.30]:30835 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224AbYJGM7b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 08:59:31 -0400
In-Reply-To: <m37i8k3hv1.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benny Amorsen a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>=20
>> Most UDP sockets are setup for long periods (RTP trafic), or if an a=
pplication really
>> wants to {open/send or receive one UDP frame/close} many sockets, it=
 already hits
>> RCU handling of its file structures and should not be slowed down th=
at much.
>>

I should have say 'Many' instead of 'Most' :)

>> By 'long period' I mean thousand of packets sent/received by each RT=
P session, being
>> voice (50 packets/second) or even worse video...
>=20
> Does DNS with port randomization need short lived sockets?
>=20

Yes very true, but current allocation of a random port can be very expe=
nsive,=20
since we scan all the UDP hash table to select the smaller hash chain.

We stop the scan if we find an empty slot, but on machines with say mor=
e than 200
bound UDP sockets, they are probably no empty slots. (UDP_HTABLE_SIZE i=
s 128)

bind(NULL port) algo is then O(N), N being number of bound UDP sockets.

So heavy DNS servers/proxies probably use a pool/range of pre-allocated=
 sockets
to avoid costs of allocating/freeing them ? If they dont care about tha=
t cost,
the extra call_rcu() will be unnoticed.

=46or pathological (yet very common :) ) cases like single DNS query/an=
swer, RCU
would mean :

Pros :
- one few rwlock hit when receiving the answer (if any)
Cons :
- one call_rcu() to delay socket freeing/reuse after RCU period.

So it might be a litle bit more expensive than without RCU

I agree I am more interested in optimizing UDP stack for heavy users li=
ke RTP=20
servers/proxies handling xxx.000 packets/second than DNS users/servers.
Shame on me :)

(2 weeks ago, Corey mentioned a 10x increase on UDP throughput on a 16-=
way machine,
that sounds promising)





