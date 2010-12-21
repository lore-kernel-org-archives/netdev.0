From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 21 Dec 2010 11:57:17 +0100
Message-ID: <1292929037.2720.12.camel@edumazet-laptop>
References: <20101221101506.GA8149@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44129 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab0LUK5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 05:57:21 -0500
Received: by wwa36 with SMTP id 36so3991576wwa.1
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 02:57:20 -0800 (PST)
In-Reply-To: <20101221101506.GA8149@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 d=C3=A9cembre 2010 =C3=A0 10:15 +0000, Jarek Poplawski a =C3=
=A9crit :
> On 2010-12-21 00:16, Eric Dumazet wrote:
> > SFQ is currently 'limited' to small packets, because it uses a 16bi=
t
> > allotment number per flow. Switch it to 18bit, and use appropriate
> > handling to make sure this allotment is in [1 .. quantum] range bef=
ore a
> > new packet is dequeued, so that fairness is respected.
>=20
> Well, such two important changes should be in separate patches.
>=20
> The change of allotment limit looks OK (but I would try scaling, e.g.
> in 16-byte chunks, btw).
>=20

Hmm, we could scale by 2 or 3 and keep 16bit allot/hash (faster than
18/14 bit bitfields on x86). Not sure its worth it (it adds two shifts
per packet)


> The change in fair treatment looks dubious. A flow which uses exactly
> it's quantum in one round will be skipped in the next round. A flow
> which uses a bit more than its quantum in one round, will be skipped
> too, while we should only give it less this time to keep the sum up t=
o
> 2 quantums. (The usual algorithm is to check if a flow has enough
> "tickets" for sending its next packet.)

Hmm...=20

A flow which uses exactly its quantum in one round wont be skipped in
the next round.

I only made the "I pass my round to next slot in chain" in one place
instead of two, maybe you missed the removal at the end of
sfq_dequeue() ?

-	} else if ((slot->allot -=3D qdisc_pkt_len(skb)) <=3D 0) {
-		q->tail =3D slot;
-		slot->allot +=3D q->quantum;
+	} else {
+		slot->allot -=3D qdisc_pkt_len(skb);
	}

Now the check is performed at the beginning of sfq_dequeue(), to be abl=
e
to charge a previously sent 'big packet' multiple times (faulty flow
wont send a packet before passing xx rounds)

I believe I just did the right thing. The "allot" is incremented when
current flow "pass its round to next slot", and decremented when a
packet is dequeued from this slot. Before being allowed to dequeue a
packet, "allot" must be 'positive'.



