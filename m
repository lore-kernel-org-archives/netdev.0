From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 12:20:48 -0400
Message-ID: <20090519162048.GB28034@hmsreliant.think-freely.org>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, lav@yar.ru,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60049 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbZESQVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 12:21:06 -0400
Content-Disposition: inline
In-Reply-To: <4A12D10D.3000504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 05:32:29PM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > On 19-05-2009 04:35, Stephen Hemminger wrote:
> >> Begin forwarded message:
> >>
> >> Date: Mon, 18 May 2009 14:10:20 GMT
> >> From: bugzilla-daemon@bugzilla.kernel.org
> >> To: shemminger@linux-foundation.org
> >> Subject: [Bug 13339] New: rtable leak in ipv4/route.c
> >>
> >>
> >> http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> > ...
> >> 2.6.29 patch has introduced flexible route cache rebuilding. Unfor=
tunately the
> >> patch has at least one critical flaw, and another problem.
> >>
> >> rt_intern_hash calculates rthi pointer, which is later used for ne=
w entry
> >> insertion. The same loop calculates cand pointer which is used to =
clean the
> >> list. If the pointers are the same, rtable leak occurs, as first t=
he cand is
> >> removed then the new entry is appended to it.
> >>
> >> This leak leads to unregister_netdevice problem (usage count > 0).
> >>
> >> Another problem of the patch is that it tries to insert the entrie=
s in certain
> >> order, to facilitate counting of entries distinct by all but QoS p=
arameters.
> >> Unfortunately, referencing an existing rtable entry moves it to li=
st beginning,
> >> to speed up further lookups, so the carefully built order is destr=
oyed.
>=20
> We could change rt_check_expire() to be smarter and handle any order =
in chains.
>=20
> This would let rt_intern_hash() be simpler.
>=20
> As its a more performance critical path, all would be good :)
>=20
> >>
> >> For the first problem the simplest patch it to set rthi=3D0 when r=
thi=3D=3Dcand, but
> >> it will also destroy the ordering.
> >=20
> > I think fixing this bug fast is more important than this
> > ordering or counting. Could you send your patch proposal?
> >=20
>=20

I was thinking something along these lines (also completely untested). =
 The
extra check in rt_intern hash prevents us from identifying a 'group lea=
der' that
is about to be deleted, and sets rthi to point at the group leader rath=
er than
the last entry in the group as it previously did, which we then mark wi=
th the
new flag in the dst_entry (updating it on rt_free of course).  This let=
s us
identify the boundaries of a group, so when we do a move to front herui=
stic, we
can move the entire group rather than just the single entry.    I prefe=
r this to
Erics approach since, even though rt_check_expire isn't in a performanc=
e
critical path, the addition of the extra list search when the list is u=
nordered
makes rt_check_expire run in O(n^2) rather than O(n), which I think wil=
l have a
significant impact on high traffic systems.  Since the ordered list cre=
ation was
done at almost zero performance cost in rt_intern_hash, I'd like to kee=
p it if
at all possible.

There is of course a shortcomming in my patch in that it doesn't actual=
ly do
anything currently with DST_GRPLDR other than set/clear it appropriatel=
y, I've
yet to identify where the route cache move to front heruistic is implem=
ented.
If someone could show me where that is, I'd be happy to finish this pat=
ch.

Neil

