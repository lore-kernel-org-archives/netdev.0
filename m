From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Sun, 16 May 2010 23:26:20 +0200
Message-ID: <1274045180.2299.38.camel@edumazet-laptop>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>
	 <1274040928.2299.17.camel@edumazet-laptop>  <4BF056F0.8010008@ans.pl>
	 <1274042826.2299.26.camel@edumazet-laptop>  <4BF05FC2.4020804@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:63550 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144Ab0EPV01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 17:26:27 -0400
Received: by wwi17 with SMTP id 17so116944wwi.19
        for <netdev@vger.kernel.org>; Sun, 16 May 2010 14:26:25 -0700 (PDT)
In-Reply-To: <4BF05FC2.4020804@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 16 mai 2010 =C3=A0 23:12 +0200, Krzysztof Ol=C4=99dzki a =C3=
=A9crit :
> On 2010-05-16 22:47, Eric Dumazet wrote:
> > Le dimanche 16 mai 2010 =C3=A0 22:34 +0200, Krzysztof Ol=C4=99dzki =
a =C3=A9crit :
> >> On 2010-05-16 22:15, Eric Dumazet wrote:
> >
> >>> All tx packets through bonding will use txqueue 0, since bnx2 doe=
snt
> >>> provide a ndo_select_queue() function.
> >>
> >> OK, that explains everything. Thank you Eric. I assume it may take=
 some
> >> time for bonding to become multiqueue aware and/or bnx2x to provid=
e
> >> ndo_select_queue?
> >>
> >
> > bonding might become multiqueue aware, there are several patches
> > floating around.
> >
> > But with your ping tests, it wont change the selected txqueue anywa=
y (it
> > will be the same for any targets, because skb_tx_hash() wont hash t=
he
> > destination address, only the skb->protocol.
>=20
> What do you mean by "wont hash the destination address, only the=20
> skb->protocol"? It won't hash the destination address for ICMP or for=
=20
> all IP protocols?

locally generated ICMP packets all use same tx queue, because
sk->sk_hash is not set :

        if (skb->sk && skb->sk->sk_hash)
                hash =3D skb->sk->sk_hash;
        else
                hash =3D (__force u16) skb->protocol;

        hash =3D jhash_1word(hash, hashrnd);

        return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
=20



However, replies will spread four queues, if hardware is capable to
perform hashing of ICMP packets, using IP addresses (source/destination=
)

>=20
> My normal workload is TCP and UDP based so if it is only ICMP then th=
ere=20
> is no problem. Actually I have noticeably more UDP traffic than an=20
> average network, mainly because of LWAPP/CAPWAP, so I'm interested in=
=20
> good performance for both TCP and UDP.
>=20
> During my initial tests ICMP ping showed the same behavior like UDP/T=
CP=20
> with iperf, so I sticked with it. I'll redo everyting with UDP and TC=
P=20
> of course. :)
>=20
> >> BTW: With a normal router workload, should I expect big performanc=
e drop
> >> when receiving and forwarding the same packet using different CPUs=
?
> >> Bonding provides very important functionality, I'm not able to dro=
p it. :(
> >>
> >
> > Not sure what you mean by forwarding same packet using different CP=
Us.
> > You probably meant different queues, because in normal case, only o=
ne
> > cpu is involved (the one receiving the packet is also the one
> > transmitting it, unless you have congestion or trafic shaping)
>=20
> I mean to receive it on a one CPU and to send it on a different one. =
I=20
> would like to assing different vectors (eth1-0 .. eth1-4) to differen=
t=20
> CPUs, but with bnx2x+bonding packets are received on queues 1-4 (eth1=
-1=20
> .. eth1-4) and sent from queue 0 (eth1-0). So, for a one packet, two=20
> different CPUs will be involved (RX on q1-q4, TX on q0).

As I said, (unless you use RPS), one forwarded packet only uses one CPU=
=2E
How tx queue is selected is another story. We try to do a 1-1 mapping.

>=20
> > If you have 4 cpus, you can use following patch and have a transpar=
ent
> > bonding against multiqueue.
>=20
> Thanks! If I get it right: with the patch, packets should be sent usi=
ng=20
> the same CPU (queue?) that was used when receiving?

Yes, for forwarding loads.

(You might use 5 or 8 instead of 4, because its not clear to me if bnx2
has 5 txqueues or 4 in your case)

>=20
> > Still bonding xmit path hits a global
> > rwlock, so performance is not what you can get without bonding.
>=20
> It may not be perfect, but it should be much better than nothing, rig=
ht?
>=20

Sure.


