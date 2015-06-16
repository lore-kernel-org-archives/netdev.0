From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: fix search limit handling in skb_find_text()
Date: Tue, 16 Jun 2015 12:48:41 +0200
Message-ID: <20150616104841.GA4163@salvia>
References: <1434359518-16897-1-git-send-email-khimov@altell.ru>
 <20150615170639.GA21117@salvia>
 <1847765.0Hbie9lSro@mate.hex>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Phil Oester <kernel@linuxace.com>,
	Thomas Graf <tgraf@suug.ch>
To: Roman Khimov <khimov@altell.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1847765.0Hbie9lSro@mate.hex>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 15, 2015 at 10:37:31PM +0300, Roman Khimov wrote:
> =D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 15 =D0=B8=D1=
=8E=D0=BD=D1=8F 2015 19:06:39 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=BE=D0=B2=
=D0=B0=D1=82=D0=B5=D0=BB=D1=8C Pablo Neira Ayuso =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB:
> > On Mon, Jun 15, 2015 at 12:11:58PM +0300, Roman I Khimov wrote:
> > > Suppose that we're trying to use an xt_string netfilter module to=
 match a
> > > string in a specially crafted packet that has "a nice string" sta=
rting at
> > > offset 28.
> > >=20
> > > It could be done in iptables like this:
> > >=20
> > > -A some_chain -m string --string "a nice string" --algo bm --from=
 28 --to
> > > 38 -j DROP
> > >=20
> > > And it would work as expected. Now changing that to
> > >=20
> > > -A some_chain -m string --string "a nice string" --algo bm --from=
 29 --to
> > > 38 -j DROP
> > >=20
> > > breaks the match, as expected. But, if we try to make
> > >=20
> > > -A some_chain -m string --string "a nice string" --algo bm --from=
 20 --to
> > > 28 -j DROP
> > >=20
> > > then it suddenly works again! So the 'to' parameter seems to be i=
nclusive,
> > > not working as an offset after which no search should be done. OK=
, now if
> > > we try:
> > >=20
> > > -A some_chain -m string --string "a nice string" --algo bm --from=
 28 --to
> > > 28 -j DROP
> > Can you reproduce the same behaviour with the km algo?
>=20
> Will try tomorrow MSK time.

Thanks, wait for your feedback on this.

> > > The first behaviour (matching at 'to' offset) comes from skb_find=
_text()
> > > comparison. The second one (not matching if 'from' and 'to' are e=
qual)
> > > comes from skb_seq_read() check for (abs_offset >=3D st->upper_of=
fset).
> > >=20
> > > I think that the way skb_find_text() handles 'to' is wrong and sh=
ould be
> > > fixed so that we always have predictable behaviour -- only match =
before
> > > 'to' offset.
> > >=20
> > > There are currently only five usages of skb_find_text() in the ke=
rnel and
> > > it looks to me that none of them expect to match something at the=
 'to'
> > > offset, so probably this change is safe.
> >=20
> > So both 'from' and 'to' are inclusive which seems consistent to me.=
 If
> > you make 'to' non-inclusive, then that will change the third exampl=
e
> > above, right?=20
>=20
> Yep.
>=20
> > That will break existing setups for people that are
> > relying on this behaviour. This has been exposed in this way for lo=
ng
> > time, so we should avoid that breakage.
>=20
> Yes, that could be an issue, but there are other skb_find_text() usag=
es and to=20
> me they suggest that the intended behaviour is to stop search at 'to'=
 offset.=20
> In nf_conntrack_amanda.c, for example:
>=20
>         start =3D skb_find_text(skb, dataoff, skb->len,
>                               search[SEARCH_CONNECT].ts);
> ...
>         stop =3D skb_find_text(skb, start, skb->len,
>                              search[SEARCH_NEWLINE].ts);
> ...
>         stop +=3D start;
> ...
>                 off =3D skb_find_text(skb, start, stop, search[i].ts)=
;
>
> First of all, nothing can ever match at skb->len, and second, it look=
s like=20
> the third usage is also expecting to search from offset 'start' to of=
fset=20
> 'stop', not to 'stop + 1'.

Then, please fix the Amanda helper.

Look, Amanda is an in-tree client of this textsearch infrastructure,
so it's not exposed to userspace, we can fix it.

But if we change the existing behaviour, users may be relying on it
and we'll get things broken for them. Someone else will come later one
with another patch to say: "hey, --to used to be inclusive but this is
not the case anymore and it's breaking my setup".

> em_text_match() in net/sched/em_text.c is also suspicious.

Please, elaborate.

> > I would suggest you fix the --from X --to Y where X =3D=3D Y which =
is not
> > doing what people would expect.
>=20
> That would certainly make things consistent, but I'm not sure we want=
 it to be=20
> consistent this way.

We have a contract with users that we can't break, so far the corner
case that doesn't work if --from X --to Y where X =3D=3D Y. If that
didn't work since the beginning, then we're 100% sure nobody has been
using it, so let's fix it.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
