From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Sun, 11 Jul 2010 19:46:22 +0200
Message-ID: <1278870382.2538.180.camel@edumazet-laptop>
References: <4C358AAA.9080400@kernel.org>
	 <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>
	 <1278867977.2538.167.camel@edumazet-laptop>
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
In-Reply-To: <1278867977.2538.167.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 11 juillet 2010 =C3=A0 19:06 +0200, Eric Dumazet a =C3=A9cr=
it :
> Le dimanche 11 juillet 2010 =C3=A0 19:09 +0300, Ilpo J=C3=A4rvinen a =
=C3=A9crit :
> > On Thu, 8 Jul 2010, Tejun Heo wrote:
> >=20
> > > We've been seeing oops in tcp_xmit_retransmit_queue() w/ 2.6.32.1=
5.
> > > Please see the attached photoshoot.  This is happening on a HPC
> > > cluster and very interestingly caused by one particular job.  How=
 long
> > > it takes isn't clear yet (at least more than a day) but when it
> > > happens it happens on a lot of machines in relatively short time.
> > >=20
> > > With a bit of disassemblying, I've found that the oops is happeni=
ng
> > > during tcp_for_write_queue_from() because the skb->next points to
> > > NULL.
> > >=20
> > >  void tcp_xmit_retransmit_queue(struct sock *sk)
> > >  {
> > >  ...
> > > 	if (tp->retransmit_skb_hint) {
> > > 		skb =3D tp->retransmit_skb_hint;
> > > 		last_lost =3D TCP_SKB_CB(skb)->end_seq;
> > > 		if (after(last_lost, tp->retransmit_high))
> > > 			last_lost =3D tp->retransmit_high;
> > > 	} else {
> > > 		skb =3D tcp_write_queue_head(sk);
> > > 		last_lost =3D tp->snd_una;
> > > 	}
> > >=20
> > >  =3D>	tcp_for_write_queue_from(skb, sk) {
> > > 		 __u8 sacked =3D TCP_SKB_CB(skb)->sacked;
> > >=20
> > > 		 if (skb =3D=3D tcp_send_head(sk))
> > > 			 break;
> > > 		 /* we could do better than to assign each time */
> > > 		 if (hole =3D=3D NULL)
> > >=20
> > > This can happen for one of the following reasons,
> > >=20
> > > 1. tp->retransmit_skb_hint is NULL and tcp_write_queue_head() is =
NULL
> > >    too.  ie. tcp_xmit_retransmit_queue() is called on an empty wr=
ite
> > >    queue for some reason.
> > >=20
> > > 2. tp->retransmit_skb_hint is pointing to a skb which is not on t=
he
> > >    write_queue.  ie. somebody forgot to update hint while removin=
g the
> > >    skb from the write queue.
> >=20
> > Once again I've read the unlinkers through, and only thing that cou=
ld=20
> > cause this is tcp_send_synack (others do deal with the hints) but I=
 think=20
> > Eric already proposed a patch to that but we never got anywhere due=
 to=20
> > some counterargument why it wouldn't take place (too far away for m=
e to=20
> > remember, see archives about the discussions). ...But if you want b=
e dead=20
> > sure some WARN_ON there might not hurt. Also the purging of the who=
le=20
> > queue was a similar suspect I then came across (but that would only=
=20
> > materialize with sk reuse happening e.g., with nfs which the other =
guys=20
> > weren't using).
> >=20
>=20
> Hmm.
>=20
> This sounds familiar to me, but I cannot remember the discussion you
> mention or the patch.
>=20
> Or maybe it was the TCP transaction thing ? (including data in SYN or
> SYN-ACK packet)

Hmm, I cannot find where we reset restransmit_skb_hint in
tcp_mtu_probe(), if we call tcp_unlink_write_queue().

if (skb->len <=3D copy) {
	/* We've eaten all the data from this skb.
	 * Throw it away. */
	TCP_SKB_CB(nskb)->flags |=3D TCP_SKB_CB(skb)->flags;
<<>>	tcp_unlink_write_queue(skb, sk);
	sk_wmem_free_skb(sk, skb);
} else {


Sorry if this was already discussed. We might add a comment here in any=
case ;)
