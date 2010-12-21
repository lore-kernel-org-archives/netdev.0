From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 21 Dec 2010 11:39:21 +0000
Message-ID: <20101221113920.GB8813@ff.dom.local>
References: <20101221101506.GA8149@ff.dom.local> <1292929037.2720.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:43216 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab0LULj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 06:39:29 -0500
Received: by bwz16 with SMTP id 16so4392475bwz.4
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 03:39:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292929037.2720.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 11:57:17AM +0100, Eric Dumazet wrote:
> Le mardi 21 d=E9cembre 2010 ?? 10:15 +0000, Jarek Poplawski a =E9crit=
 :
> > On 2010-12-21 00:16, Eric Dumazet wrote:
> > > SFQ is currently 'limited' to small packets, because it uses a 16=
bit
> > > allotment number per flow. Switch it to 18bit, and use appropriat=
e
> > > handling to make sure this allotment is in [1 .. quantum] range b=
efore a
> > > new packet is dequeued, so that fairness is respected.
> >=20
> > Well, such two important changes should be in separate patches.
> >=20
> > The change of allotment limit looks OK (but I would try scaling, e.=
g.
> > in 16-byte chunks, btw).
> >=20
>=20
> Hmm, we could scale by 2 or 3 and keep 16bit allot/hash (faster than
> 18/14 bit bitfields on x86). Not sure its worth it (it adds two shift=
s
> per packet)

I'm OK with any of those methods.

> > The change in fair treatment looks dubious. A flow which uses exact=
ly
> > it's quantum in one round will be skipped in the next round. A flow
> > which uses a bit more than its quantum in one round, will be skippe=
d
> > too, while we should only give it less this time to keep the sum up=
 to
> > 2 quantums. (The usual algorithm is to check if a flow has enough
> > "tickets" for sending its next packet.)
>=20
> Hmm...=20
>=20
> A flow which uses exactly its quantum in one round wont be skipped in
> the next round.
>=20
> I only made the "I pass my round to next slot in chain" in one place
> instead of two, maybe you missed the removal at the end of
> sfq_dequeue() ?
>=20
> -	} else if ((slot->allot -=3D qdisc_pkt_len(skb)) <=3D 0) {
> -		q->tail =3D slot;
> -		slot->allot +=3D q->quantum;
> +	} else {
> +		slot->allot -=3D qdisc_pkt_len(skb);
> 	}
>=20
> Now the check is performed at the beginning of sfq_dequeue(), to be a=
ble
> to charge a previously sent 'big packet' multiple times (faulty flow
> wont send a packet before passing xx rounds)
>=20
> I believe I just did the right thing. The "allot" is incremented when
> current flow "pass its round to next slot", and decremented when a
> packet is dequeued from this slot. Before being allowed to dequeue a
> packet, "allot" must be 'positive'.

Simply try to check my examples before and after. There is no skipping
of a round now. It's a serious change. Somebody tried to avoid it at
all in the current implementation. You should also think about fairness
of normal (but different) size packets.

Jarek P.
