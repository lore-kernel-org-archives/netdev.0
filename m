From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [RFC][PATCH 2/2] TCP: skip processing cached SACK blocks
Date: Sun, 07 Oct 2007 15:11:45 +0900 (JST)
Message-ID: <20071007.151145.32909699.takano@axe-inc.co.jp>
References: <20071004.184456.40407483.takano@axe-inc.co.jp>
	<Pine.LNX.4.64.0710041516170.31129@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, y-kodama@aist.go.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:63188 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbXJGGN2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 02:13:28 -0400
In-Reply-To: <Pine.LNX.4.64.0710041516170.31129@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ilpo,

Thanks for your reply.=20
Most of my response are in the reply to patch 1/2.

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 2/2] TCP: skip processing cached SACK blocks
Date: Fri, 5 Oct 2007 13:37:21 +0300 (EEST)

> On Thu, 4 Oct 2007, TAKANO Ryousei wrote:
>=20
> > This patch allows to process only newly reported SACK blocks at the
> > sender side. An ACK packet contains up to three SACK blocks, and so=
me
>=20
>   "A SACK option that specifies n blocks will have a length of 8*n+2
>    bytes, so the 40 bytes available for TCP options can specify a
>    maximum of 4 blocks.  It is expected that SACK will often be used =
in
>    conjunction with the Timestamp option used for RTTM [Jacobson92],
>    which takes an additional 10 bytes (plus two bytes of padding); th=
us
>    a maximum of 3 SACK blocks will be allowed in this case." [RFC2018=
]
>=20
> :-)
>=20
Yes, indeed:-)

> > of them may be already reported and processed blocks.  This patch=20
> > prevents processing of such already processed SACK blocks.
> >=20
> > Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
> > Signed-off-by: Yuetsu Kodama <y-kodama@aist.go.jp>
> > ---
> >  net/ipv4/tcp_input.c |   24 ++++++++++++++++++++++++
> >  1 files changed, 24 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index bbad2cd..9615fc9 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -978,6 +978,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
> >  	int cached_fack_count;
> >  	int i;
> >  	int first_sack_index;
> > +	u8 sack_block_skip[4] =3D {0,0,0,0};
> > =20
> >  	if (!tp->sacked_out)
> >  		tp->fackets_out =3D 0;
> > @@ -1012,6 +1013,21 @@ tcp_sacktag_write_queue(struct sock *sk, str=
uct sk_buff *ack_skb, u32 prior_snd_
> >  	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_=
window))
> >  		return 0;
> > =20
> > +	/* Skip processing cached SACK blocks. */
> > +	for (i =3D 0; i < num_sacks; i++) {
> > +		__be32 start_seq =3D sp[i].start_seq;
> > +		__be32 end_seq =3D sp[i].end_seq;
> > +		int j;
> > +
> > +		for (j =3D 0; j < ARRAY_SIZE(tp->recv_sack_cache); j++) {
> > +			if ((tp->recv_sack_cache[j].start_seq =3D=3D start_seq) &&
> > +			    (tp->recv_sack_cache[j].end_seq =3D=3D end_seq)) {
> > +				sack_block_skip[i] =3D 1;
> > +				break;
> > +			}
> > +		}
> > +	}
> > +
>=20
> I'm somewhat against adding more and more special cases to sacktag,=20
> there's still need for more special cases after this one to avoid ver=
y=20
> expensive processing (I guess they just won't occur in your scenario)=
!
> ...I would rather remove whole special case mess of the fastpath and
> have a more generic solution (see the patch I point into in the reply
> to patch 1/2)...
>=20
> >  	/* SACK fastpath:
> >  	 * if the only SACK change is the increase of the end_seq of
> >  	 * the first block then only apply that SACK block
> > @@ -1051,11 +1067,16 @@ tcp_sacktag_write_queue(struct sock *sk, st=
ruct sk_buff *ack_skb, u32 prior_snd_
> >  				if (after(ntohl(sp[j].start_seq),
> >  					  ntohl(sp[j+1].start_seq))){
> >  					struct tcp_sack_block_wire tmp;
> > +					u8 sbtmp;
> > =20
> >  					tmp =3D sp[j];
> >  					sp[j] =3D sp[j+1];
> >  					sp[j+1] =3D tmp;
> > =20
> > +					sbtmp =3D sack_block_skip[j];
> > +					sack_block_skip[j] =3D sack_block_skip[j+1];
> > +					sack_block_skip[j+1] =3D sbtmp;
> > +
> >  					/* Track where the first SACK block goes to */
> >  					if (j =3D=3D first_sack_index)
> >  						first_sack_index =3D j+1;
> > @@ -1083,6 +1104,9 @@ tcp_sacktag_write_queue(struct sock *sk, stru=
ct sk_buff *ack_skb, u32 prior_snd_
> >  		int fack_count;
> >  		int dup_sack =3D (found_dup_sack && (i =3D=3D first_sack_index))=
;
> > =20
> > +		if (sack_block_skip[i])
>=20
> DSACKs must always be processed, so please add:
>=20
> && !dup_sack
>=20
I did not notice DSACKs. Thanks.

> > +			continue;
>=20
> By doing this skipping here, you actually end up crippling lost_retra=
ns=20
> detection even more than it was broken before. ...You probably didn't=
 just=20
> notice that during tests because of unrelated suboptimal behavior (in=
=20
> fastpath_skb_hint handling). ...Anyway, correctness of this should be=
=20
> evaluated against the fixed lost_retrans, rather than the already=20
> broken one.
>=20
You can find the result that the average goodput slightly improves
against the only PATCH #1 (fixed lost_retrans) applied kernel.
Sorry, our web page is down this weekend for the power outage.

http://projects.gtrc.aist.go.jp/gnet/sack-bug.html

> > +
> >  		skb =3D cached_skb;
> >  		fack_count =3D cached_fack_count;
>=20
> Other than what's noted above:
>=20
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
>=20
> --=20
>  i.

Regards,
Ryousei Takano
