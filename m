From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 08 Jan 2015 09:17:49 -0800
Message-ID: <1420737469.5947.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	 <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54AEA498.5030202@uclouvain.be>
	 <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
	 <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:61291 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777AbbAHRSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 12:18:03 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so10617613ieb.7
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 09:18:02 -0800 (PST)
In-Reply-To: <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 08:25 -0800, Eric Dumazet wrote:
> On Thu, 2015-01-08 at 10:49 -0500, Neal Cardwell wrote:
> > On Thu, Jan 8, 2015 at 10:39 AM, S=C3=A9bastien Barr=C3=A9
> > <sebastien.barre@uclouvain.be> wrote:
> > > What do you and Neal think ?
> >=20
> > My preference is to have the whole expression detecting the case wh=
ere
> > the receiver got the probe packet encoded in a single expression. I
> > don't have a strong feeling about whether it should be stored in a
> > bool (to reduce the size of the diff) or written directly into the =
if
> > () expression (to reduce the size of the code). I'll defer to Eric =
on
> > which he thinks is better. :-)
>=20
> There is no shame using helpers with nice names to help understand th=
is
> TCP stack. Even if the helper is used exactly once.
>=20
> In this case, it seems we test 2 different conditions, so this could =
use
> 2 helpers with self describing names.
>=20
> When I see :=20
>=20
> > +     if (((ack =3D=3D tp->tlp_high_seq) &&
> > +          !(flag & (FLAG_SND_UNA_ADVANCED |
> > +                    FLAG_NOT_DUP | FLAG_DATA_SACKED))) ||
> > +         (!before(ack, tp->tlp_high_seq) && (flag & FLAG_DSACKING_=
ACK))) {
> >               tp->tlp_high_seq =3D 0;
>=20
> My brain hurts.

BTW, tlp_high_seq is used no matter what (initial value is 0).

While the probability ACK seq being exactly 0 is small (1 out of 2^32),
probability that !before(ack, tp->tlp_high_seq) being a false positive
is very high. Initial sequence number are supposed to be random.

I wonder if setting tp->tlp_high_seq to 0 is the right thing to do.
