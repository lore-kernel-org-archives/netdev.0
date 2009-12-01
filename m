From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Tue, 1 Dec 2009 09:39:23 +0000
Message-ID: <20091201093923.GA7573@ff.dom.local>
References: <4B0F8A5D.1040806@gmail.com> <20091128000401.GA3713@ami.dom.local> <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com> <20091130111020.GA7114@ff.dom.local> <412e6f7f0911301832o53e479f0x42345065b0b1616f@mail.gmail.com> <20091201080151.GA6408@ff.dom.local> <20091201084332.GB6408@ff.dom.local> <412e6f7f0912010118l19b3a759n925138fbc6dd6f56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <martin.devera@cdi.cz>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:42275 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbZLAJjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 04:39:22 -0500
Received: by bwz27 with SMTP id 27so3253182bwz.21
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 01:39:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0912010118l19b3a759n925138fbc6dd6f56@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2009 at 05:18:32PM +0800, Changli Gao wrote:
> On Tue, Dec 1, 2009 at 4:43 PM, Jarek Poplawski <jarkao2@gmail.com> w=
rote:
> > On Tue, Dec 01, 2009 at 08:01:51AM +0000, Jarek Poplawski wrote:
> >> On Tue, Dec 01, 2009 at 10:32:26AM +0800, Changli Gao wrote:
> >> > On Mon, Nov 30, 2009 at 7:10 PM, Jarek Poplawski <jarkao2@gmail.=
com> wrote:
> > ...
> >> > > And this patch is very similar, except ->peek()/dequeue(). Add=
itional
> >> > > lookups are done instead of dequeuing the first found class, w=
hich
> >> > > might be quite long in some cases.
> >> >
> >> > If the quantum is set correctly, there isn't difference except o=
f a
> >> > comparison. In the other case, I think some additional CPU cycle=
s are
> >> > better than overflow.
> >>
> >> No, my main point is there _is_ a difference when the quantum is s=
et
> >> correctly. Just these additional lookups.
> >
> > And, again, there are less invasive ways to fix such overflow, like
> >
> > htb_dequeue_tree()
> > {
> > ...
> > =A0 =A0 =A0 =A0if (likely(skb !=3D NULL)) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cl->un.leaf.deficit[level] -=3D qdis=
c_pkt_len(skb);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cl->un.leaf.deficit[level] < 0) =
{
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cl->un.leaf.deficit[=
level] +=3D cl->quantum;
> >
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cl->un.leaf.defic=
it[level] < 0)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->u=
n.leaf.deficit[level] =3D -cl->quantum;
>=20
> How about this:
>          if (cl->un.leaf.deficit[level] < 0) {
>                 cl->un.leaf.deficit[level] =3D 0;
>                 if (!(cl->warned & HTB_WARN_QUANTUM_SMALL)) {
>                         printk(KERN_WARNING
>                                "HTB: quantum of class %X is small.
> Consider r2q change.\n",
>                                cl->common.classid);
>                     cl->warned |=3D HTB_WARN_QUANTUM_SMALL;
>                 }
>          }

I guess you mean q->warned. Maybe unlikely() would be useful too.
Otherwise, it's acceptable to me, especially when you write you really
hit this problem (not theoretical only ;-)

Jarek P.
