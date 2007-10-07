From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Sun, 07 Oct 2007 14:51:00 +0900 (JST)
Message-ID: <20071007.145100.00679926.takano@axe-inc.co.jp>
References: <20071004.184519.16476818.takano@axe-inc.co.jp>
	<Pine.LNX.4.64.0710041419560.31129@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, y-kodama@aist.go.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:52091 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbXJGGNY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2007 02:13:24 -0400
In-Reply-To: <Pine.LNX.4.64.0710041419560.31129@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Fri, 5 Oct 2007 13:02:07 +0300 (EEST)

> On Thu, 4 Oct 2007, TAKANO Ryousei wrote:
>=20
> > This patch allows to detect loss of retransmitted packets more
> > accurately by using the highest end sequence number among SACK=20
> > blocks.  Before the retransmission queue is scanned, the highest
> > end sequence number (high_end_seq) is retrieved, and this value
> > is compared with the ack_seq of each packet.
> >=20
> > Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
> > Signed-off-by: Yuetsu Kodama <y-kodama@aist.go.jp>
> > ---
> >  net/ipv4/tcp_input.c |   14 +++++++++++---
> >  1 files changed, 11 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index bbad2cd..12db4b3 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -978,6 +978,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
> >  	int cached_fack_count;
> >  	int i;
> >  	int first_sack_index;
> > +	__u32 high_end_seq;
>=20
> No __-types when not visible to userspace please.
>=20
I will fix it.

> >
> >  	if (!tp->sacked_out)
> >  		tp->fackets_out =3D 0;
> > @@ -1012,6 +1013,14 @@ tcp_sacktag_write_queue(struct sock *sk, str=
uct sk_buff *ack_skb, u32 prior_snd_
> >  	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_=
window))
> >  		return 0;
> > =20
> > +	/* Retrieve the highest end_seq among SACK blocks. */
> > +	high_end_seq =3D ntohl(sp[0].end_seq);
> > +	for (i =3D 1; i < num_sacks; i++) {
> > +		__u32 end_seq =3D ntohl(sp[i].end_seq);
> > +		if (after(end_seq, high_end_seq))
> > +			high_end_seq =3D end_seq;
> > +	}
> > +
>=20
> There's one problem... Net-2.6.24 tree includes SACK block validator=20
> which is being done in the marking loop. The SACK blocks would not ye=
t be=20
> validated in that position, yet this code should be protected by the=20
> validation! My intention is to move the validator earlier anyway (yet=
 to=20
> be split into smaller logical patches), see:
>=20
> http://marc.info/?l=3Dlinux-netdev&m=3D119062989408053&w=3D2
>=20
I will check the net-2.6.24 tree and your patch.

> >  	/* SACK fastpath:
> >  	 * if the only SACK change is the increase of the end_seq of
> >  	 * the first block then only apply that SACK block
> > @@ -1161,9 +1170,8 @@ tcp_sacktag_write_queue(struct sock *sk, stru=
ct sk_buff *ack_skb, u32 prior_snd_
> >  			}
> > =20
> >  			if ((sacked&TCPCB_SACKED_RETRANS) &&
> > -			    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
> > -			    (!lost_retrans || after(end_seq, lost_retrans)))
> > -				lost_retrans =3D end_seq;
> > +			    after(high_end_seq, TCP_SKB_CB(skb)->ack_seq))
> > +				lost_retrans =3D high_end_seq;
>=20
> Just couple of thoughts, not that this change itself is incorrect...
>=20
> In case sacktag uses fastpath, this code won't be executed for the sk=
b's=20
> that we would like to check (those with SACKED_RETRANS set, that are=20
> below the fastpath_skb_hint). We will eventually deal with the whole =
queue=20
> when fastpath_skb_hint gets set to NULL, with the next cumulative ACK=
 that=20
> fully ACKs an skb at the latest. Maybe there's a need for a larger su=
rgery=20
> than this to fix it. I think we need additional field to tcp_sock to =
avoid=20
> doing a full-walk per ACK:
>=20
I think the problem occurs in slowpath. For example, in case when the r=
eceiver
detects and sends back a new SACK block, the sender may fail to detect =
loss
of a retransmitted packet.

> Keep minimum of TCP_SKB_CB(skb)->ack_seq of rexmitted segments in=20
> tcp_sock, when that's exceeded by SACK block, do a full-walk in the=20
> lost_retrans worker loop like the old code does...
>=20
>=20
> In future, please base your work to current development tree instead =
of=20
> linus' tree (net-2.6.24 at this point of time, there's also tcp-2.6 b=
ut=20
> it's currently a bit outdated).
>=20
Thanks for your suggestion. SACK processing has a heavy workload and=20
it is complex. I agree to make efforts toward a more generic solution.=20
Your recv_sack_cache patch seems valuable. I will continue to work in=20
the net-2.6.24 tree, and resend our patches.=20
Anyway, first of all, I would like to share this problem with kernel=20
developers.

BTW, what is difference among netdev-2.6, net-2.6 (net-2.6.24), and=20
tcp-2.6? I am not familiar with linux kernel development process.

>=20
> --=20
>  i.

Regards,
Ryousei Takano
