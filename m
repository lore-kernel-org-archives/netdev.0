From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Sun, 11 Jul 2010 19:06:17 +0200
Message-ID: <1278867977.2538.167.camel@edumazet-laptop>
References: <4C358AAA.9080400@kernel.org>
	 <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tejun Heo <tj@kernel.org>, "David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 11 juillet 2010 =C3=A0 19:09 +0300, Ilpo J=C3=A4rvinen a =C3=
=A9crit :
> On Thu, 8 Jul 2010, Tejun Heo wrote:
>=20
> > We've been seeing oops in tcp_xmit_retransmit_queue() w/ 2.6.32.15.
> > Please see the attached photoshoot.  This is happening on a HPC
> > cluster and very interestingly caused by one particular job.  How l=
ong
> > it takes isn't clear yet (at least more than a day) but when it
> > happens it happens on a lot of machines in relatively short time.
> >=20
> > With a bit of disassemblying, I've found that the oops is happening
> > during tcp_for_write_queue_from() because the skb->next points to
> > NULL.
> >=20
> >  void tcp_xmit_retransmit_queue(struct sock *sk)
> >  {
> >  ...
> > 	if (tp->retransmit_skb_hint) {
> > 		skb =3D tp->retransmit_skb_hint;
> > 		last_lost =3D TCP_SKB_CB(skb)->end_seq;
> > 		if (after(last_lost, tp->retransmit_high))
> > 			last_lost =3D tp->retransmit_high;
> > 	} else {
> > 		skb =3D tcp_write_queue_head(sk);
> > 		last_lost =3D tp->snd_una;
> > 	}
> >=20
> >  =3D>	tcp_for_write_queue_from(skb, sk) {
> > 		 __u8 sacked =3D TCP_SKB_CB(skb)->sacked;
> >=20
> > 		 if (skb =3D=3D tcp_send_head(sk))
> > 			 break;
> > 		 /* we could do better than to assign each time */
> > 		 if (hole =3D=3D NULL)
> >=20
> > This can happen for one of the following reasons,
> >=20
> > 1. tp->retransmit_skb_hint is NULL and tcp_write_queue_head() is NU=
LL
> >    too.  ie. tcp_xmit_retransmit_queue() is called on an empty writ=
e
> >    queue for some reason.
> >=20
> > 2. tp->retransmit_skb_hint is pointing to a skb which is not on the
> >    write_queue.  ie. somebody forgot to update hint while removing =
the
> >    skb from the write queue.
>=20
> Once again I've read the unlinkers through, and only thing that could=
=20
> cause this is tcp_send_synack (others do deal with the hints) but I t=
hink=20
> Eric already proposed a patch to that but we never got anywhere due t=
o=20
> some counterargument why it wouldn't take place (too far away for me =
to=20
> remember, see archives about the discussions). ...But if you want be =
dead=20
> sure some WARN_ON there might not hurt. Also the purging of the whole=
=20
> queue was a similar suspect I then came across (but that would only=20
> materialize with sk reuse happening e.g., with nfs which the other gu=
ys=20
> weren't using).
>=20

Hmm.

This sounds familiar to me, but I cannot remember the discussion you
mention or the patch.

Or maybe it was the TCP transaction thing ? (including data in SYN or
SYN-ACK packet)

> > 3. The hint is pointing to a skb on the list but the list itself is
> >    corrupt.
> >=20
> > I added some debug code and the crash is happening when
> > tp->retransmit_skb_hint is not NULL but tp->retransmit_skb_hint->ne=
xt
> > is NULL.  So, #1 is out; unfortunately, I didn't have debug code in
> > place to discern between #2 and #3.
> >=20
> > Does anything ring a bell?  This is a production system and debuggi=
ng
> > affects quite a number of people.  I can put debug code in to disce=
rn
> > between #2 and #3 but I'm basically shooting in the dark and it wou=
ld
> > be great if someone has a better idea.
>=20
> Thanks for taking this up. I've been kind of waiting somebody to show=
 up=20
> who actually has some way of reproducing it. Once I had one guy in th=
e=20
> hook but his ability to reproduce was for some reason lost when he tr=
ied=20
> with a debug patch [1].=20
>=20
> I now realize that the debug patch should probably also print the wri=
te=20
> queue too when the problem is caught in order to discern the cases yo=
u=20
> mention.
>=20
> Something along these lines:
>=20
> tcp_for_write_queue(skb, sk) {
> 	printk("skb %p (%u-%u) next %p prev %p sacked %u\n", ...);
> }
>=20
> Anyway, my debugging patch should be such that in a lucky case it avo=
ids=20
> crashing the system too, though price to pay might then be a stuck=20
> connection. In case #3 I'd expect the box to die elsewhere in TCP cod=
e=20
> pretty soon anyway so it depends whether avoiding oops is really so=20
> useful, but if you're lucky other mechanism in TCP will recover=20
> the lost one for you (basically RTO driven retransmission).
>=20
