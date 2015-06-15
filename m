From: Roman Khimov <khimov@altell.ru>
Subject: Re: [PATCH] net: fix search limit handling in skb_find_text()
Date: Mon, 15 Jun 2015 22:37:31 +0300
Message-ID: <1847765.0Hbie9lSro@mate.hex>
References: <1434359518-16897-1-git-send-email-khimov@altell.ru> <20150615170639.GA21117@salvia>
Reply-To: khimov@altell.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Phil Oester <kernel@linuxace.com>,
	Thomas Graf <tgraf@suug.ch>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150615170639.GA21117@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 15 =D0=B8=D1=8E=
=D0=BD=D1=8F 2015 19:06:39 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=BE=D0=B2=D0=
=B0=D1=82=D0=B5=D0=BB=D1=8C Pablo Neira Ayuso =D0=BD=D0=B0=D0=BF=D0=B8=D1=
=81=D0=B0=D0=BB:
> On Mon, Jun 15, 2015 at 12:11:58PM +0300, Roman I Khimov wrote:
> > Suppose that we're trying to use an xt_string netfilter module to m=
atch a
> > string in a specially crafted packet that has "a nice string" start=
ing at
> > offset 28.
> >=20
> > It could be done in iptables like this:
> >=20
> > -A some_chain -m string --string "a nice string" --algo bm --from 2=
8 --to
> > 38 -j DROP
> >=20
> > And it would work as expected. Now changing that to
> >=20
> > -A some_chain -m string --string "a nice string" --algo bm --from 2=
9 --to
> > 38 -j DROP
> >=20
> > breaks the match, as expected. But, if we try to make
> >=20
> > -A some_chain -m string --string "a nice string" --algo bm --from 2=
0 --to
> > 28 -j DROP
> >=20
> > then it suddenly works again! So the 'to' parameter seems to be inc=
lusive,
> > not working as an offset after which no search should be done. OK, =
now if
> > we try:
> >=20
> > -A some_chain -m string --string "a nice string" --algo bm --from 2=
8 --to
> > 28 -j DROP
> Can you reproduce the same behaviour with the km algo?

Will try tomorrow MSK time.

> > The first behaviour (matching at 'to' offset) comes from skb_find_t=
ext()
> > comparison. The second one (not matching if 'from' and 'to' are equ=
al)
> > comes from skb_seq_read() check for (abs_offset >=3D st->upper_offs=
et).
> >=20
> > I think that the way skb_find_text() handles 'to' is wrong and shou=
ld be
> > fixed so that we always have predictable behaviour -- only match be=
fore
> > 'to' offset.
> >=20
> > There are currently only five usages of skb_find_text() in the kern=
el and
> > it looks to me that none of them expect to match something at the '=
to'
> > offset, so probably this change is safe.
>=20
> So both 'from' and 'to' are inclusive which seems consistent to me. I=
f
> you make 'to' non-inclusive, then that will change the third example
> above, right?=20

Yep.

> That will break existing setups for people that are
> relying on this behaviour. This has been exposed in this way for long
> time, so we should avoid that breakage.

Yes, that could be an issue, but there are other skb_find_text() usages=
 and to=20
me they suggest that the intended behaviour is to stop search at 'to' o=
ffset.=20
In nf_conntrack_amanda.c, for example:

        start =3D skb_find_text(skb, dataoff, skb->len,
                              search[SEARCH_CONNECT].ts);
=2E..
        stop =3D skb_find_text(skb, start, skb->len,
                             search[SEARCH_NEWLINE].ts);
=2E..
        stop +=3D start;
=2E..
                off =3D skb_find_text(skb, start, stop, search[i].ts);

=46irst of all, nothing can ever match at skb->len, and second, it look=
s like=20
the third usage is also expecting to search from offset 'start' to offs=
et=20
'stop', not to 'stop + 1'.

em_text_match() in net/sched/em_text.c is also suspicious.

> I would suggest you fix the --from X --to Y where X =3D=3D Y which is=
 not
> doing what people would expect.

That would certainly make things consistent, but I'm not sure we want i=
t to be=20
consistent this way.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
