From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 15:24:50 -0400
Message-ID: <20090519192450.GF28034@hmsreliant.think-freely.org>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com> <20090519162048.GB28034@hmsreliant.think-freely.org> <4A12FEDA.7040806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, lav@yar.ru,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60208 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbZESTZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 15:25:08 -0400
Content-Disposition: inline
In-Reply-To: <4A12FEDA.7040806@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 08:47:54PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> > On Tue, May 19, 2009 at 05:32:29PM +0200, Eric Dumazet wrote:
> >> Jarek Poplawski a =E9crit :
> >>> On 19-05-2009 04:35, Stephen Hemminger wrote:
> >>>> Begin forwarded message:
> >>>>
> >>>> Date: Mon, 18 May 2009 14:10:20 GMT
> >>>> From: bugzilla-daemon@bugzilla.kernel.org
> >>>> To: shemminger@linux-foundation.org
> >>>> Subject: [Bug 13339] New: rtable leak in ipv4/route.c
> >>>>
> >>>>
> >>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> >>> ...
> >>>> 2.6.29 patch has introduced flexible route cache rebuilding. Unf=
ortunately the
> >>>> patch has at least one critical flaw, and another problem.
> >>>>
> >>>> rt_intern_hash calculates rthi pointer, which is later used for =
new entry
> >>>> insertion. The same loop calculates cand pointer which is used t=
o clean the
> >>>> list. If the pointers are the same, rtable leak occurs, as first=
 the cand is
> >>>> removed then the new entry is appended to it.
> >>>>
> >>>> This leak leads to unregister_netdevice problem (usage count > 0=
).
> >>>>
> >>>> Another problem of the patch is that it tries to insert the entr=
ies in certain
> >>>> order, to facilitate counting of entries distinct by all but QoS=
 parameters.
> >>>> Unfortunately, referencing an existing rtable entry moves it to =
list beginning,
> >>>> to speed up further lookups, so the carefully built order is des=
troyed.
> >> We could change rt_check_expire() to be smarter and handle any ord=
er in chains.
> >>
> >> This would let rt_intern_hash() be simpler.
> >>
> >> As its a more performance critical path, all would be good :)
> >>
> >>>> For the first problem the simplest patch it to set rthi=3D0 when=
 rthi=3D=3Dcand, but
> >>>> it will also destroy the ordering.
> >>> I think fixing this bug fast is more important than this
> >>> ordering or counting. Could you send your patch proposal?
> >>>
> >=20
> > I was thinking something along these lines (also completely unteste=
d).  The
> > extra check in rt_intern hash prevents us from identifying a 'group=
 leader' that
> > is about to be deleted, and sets rthi to point at the group leader =
rather than
> > the last entry in the group as it previously did, which we then mar=
k with the
> > new flag in the dst_entry (updating it on rt_free of course).  This=
 lets us
> > identify the boundaries of a group, so when we do a move to front h=
eruistic, we
> > can move the entire group rather than just the single entry.    I p=
refer this to
> > Erics approach since, even though rt_check_expire isn't in a perfor=
mance
> > critical path, the addition of the extra list search when the list =
is unordered
> > makes rt_check_expire run in O(n^2) rather than O(n), which I think=
 will have a
> > significant impact on high traffic systems.  Since the ordered list=
 creation was
> > done at almost zero performance cost in rt_intern_hash, I'd like to=
 keep it if
> > at all possible.
> >=20
> > There is of course a shortcomming in my patch in that it doesn't ac=
tually do
> > anything currently with DST_GRPLDR other than set/clear it appropri=
ately, I've
> > yet to identify where the route cache move to front heruistic is im=
plemented.
> > If someone could show me where that is, I'd be happy to finish this=
 patch.
> >=20
>=20
> O(n^2) ? Not exactly ...
>=20
you're right, on closer examination, its not O(n^2), but its not what y=
ou have
below either I don't think
=20
> N * (Y + x)  instead of N * (Y),  where x <=3D Y/100, and we can make=
 x being 0
> in fact with proper prefetching.
>=20
=46rom the way I read you patch (which is actually pretty clever as I l=
ook at it),
you add an extra loop that searches from the start of the given chain t=
o the
point at which the outer loop is set looking for a duplicate, so that e=
ach
rtable entry which varies only by non-hash relevant values is counted o=
nly once.
Thats good.  But that means for a chain of n nodes in which you are che=
cking the
ith node for duplicates you need to visit at worst i other nodes, so to=
 process
the entire chain we need to visit SUM(i=3D1..n)(i) =3D=3D (n(n-1)/2) no=
des rather than
the simply linear search requireing the inspection of only n nodes.  I =
see how
with prefetching the cost of the additional node visitation can be mini=
mized,
but thats still a significantly larger set of nodes to check per expira=
tion run.

> Real cost is bringing into CPU cache the information needed, by two
> orders of magnitude. (one cache line miss : more than 200 cycles,
> and we need at least two cache lines per rtable.)

> Adding 'group' notion to dst entries is overengineering an already
> too complex ipv4/route.c file, that is almost unreadable these days,
> since even you can not spot the point where we move the entry at chai=
n
> front.
>=20
> Hint : search for /* Put it first */ in rt_intern_hash()
>=20
Ah! So its not actually on rtable access (i.e. route lookup) that we do=
 a
move-to-front, its only when we're hashing in new entries.  That explai=
ns why I
didn't see it, I was thinking route lookups moved the entry to the fron=
t, not
inserts.

> Moving whole group in front would defeat the purpose of move, actuall=
y,
> since rank in chain is used to decay the timeout in garbage collector=
=2E
> (search for tmo >>=3D 1; )
>=20
Argh, so the list is implicitly ordered by expiration time.  That reall=
y defeats
the entire purpose of doing grouping in the ilst at all.  If thats the =
case,
then I agree, its probably better to to take the additional visitation =
hit in in
check_expire above than to try and preserve ordering.=20

Thanks
Neil

