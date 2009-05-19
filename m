From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 19:17:03 +0200
Message-ID: <20090519171703.GA2749@ami.dom.local>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com> <20090519162330.GC28034@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>, lav@yar.ru,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:41492 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbZESRTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 13:19:00 -0400
Received: by bwz22 with SMTP id 22so3964919bwz.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 10:19:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090519162330.GC28034@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 12:23:30PM -0400, Neil Horman wrote:
> On Tue, May 19, 2009 at 05:32:29PM +0200, Eric Dumazet wrote:
> > Jarek Poplawski a =E9crit :
> > > On 19-05-2009 04:35, Stephen Hemminger wrote:
> > >> Begin forwarded message:
> > >>
> > >> Date: Mon, 18 May 2009 14:10:20 GMT
> > >> From: bugzilla-daemon@bugzilla.kernel.org
> > >> To: shemminger@linux-foundation.org
> > >> Subject: [Bug 13339] New: rtable leak in ipv4/route.c
> > >>
> > >>
> > >> http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> > > ...
> > >> 2.6.29 patch has introduced flexible route cache rebuilding. Unf=
ortunately the
> > >> patch has at least one critical flaw, and another problem.
> > >>
> > >> rt_intern_hash calculates rthi pointer, which is later used for =
new entry
> > >> insertion. The same loop calculates cand pointer which is used t=
o clean the
> > >> list. If the pointers are the same, rtable leak occurs, as first=
 the cand is
> > >> removed then the new entry is appended to it.
> > >>
> > >> This leak leads to unregister_netdevice problem (usage count > 0=
).
> > >>
> > >> Another problem of the patch is that it tries to insert the entr=
ies in certain
> > >> order, to facilitate counting of entries distinct by all but QoS=
 parameters.
> > >> Unfortunately, referencing an existing rtable entry moves it to =
list beginning,
> > >> to speed up further lookups, so the carefully built order is des=
troyed.
> >=20
> > We could change rt_check_expire() to be smarter and handle any orde=
r in chains.
> >=20
> > This would let rt_intern_hash() be simpler.
> >=20
> > As its a more performance critical path, all would be good :)
> >=20
> > >>
> > >> For the first problem the simplest patch it to set rthi=3D0 when=
 rthi=3D=3Dcand, but
> > >> it will also destroy the ordering.
> > >=20
> > > I think fixing this bug fast is more important than this
> > > ordering or counting. Could you send your patch proposal?
> > >=20
> >=20
>=20
> Of course, it helps if I attach the patch :)
>=20
>=20
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 6be3b08..a39db6d 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -47,6 +47,7 @@ struct dst_entry
>  #define DST_NOXFRM		2
>  #define DST_NOPOLICY		4
>  #define DST_NOHASH		8
> +#define DST_GRPLDR		16
>  	unsigned long		expires;
> =20
>  	unsigned short		header_len;	/* more space at head required */
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index c4c60e9..0120f0e 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -610,6 +610,8 @@ static inline int ip_rt_proc_init(void)
> =20
>  static inline void rt_free(struct rtable *rt)
>  {
> +	if (rt->u.dst.flags & DST_GRPLDR)
> +		rt->u.dst.rt_next->u.dst.flag |=3D DST_GRPLDR;
>  	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
>  }
> =20
> @@ -1143,8 +1145,11 @@ restart:
>  		 * relvant to the hash function together, which we use to adjust
>  		 * our chain length
>  		 */
> -		if (*rthp && compare_hash_inputs(&(*rthp)->fl, &rt->fl))
> +		if (!*rthi && *rthp &&=20
> +		    compare_hash_inputs(&(*rthp)->fl, &rt->fl) &&
> +		    (cand !=3D rth))
>  			rthi =3D rth;

Does it really prevent cand =3D=3D rthi in the next loop?

I didn't check Eric's patch yet, but I really don't know what's wrong
with something as simple as below for -stable, until "proper" fix is
analyzed and tested.

Jarek P.
---

 net/ipv4/route.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c4c60e9..f4e6c7a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1157,6 +1157,8 @@ restart:
 		if (chain_length > ip_rt_gc_elasticity) {
 			*candp =3D cand->u.dst.rt_next;
 			rt_free(cand);
+			if (rthi =3D=3D cand)
+				rthi =3D NULL;
 		}
 	} else {
 		if (chain_length > rt_chain_length_max) {
