From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net v2 2/2] ipv6: fix ECMP route replacement
Date: Fri, 15 May 2015 10:51:52 +0200
Message-ID: <20150515085151.GA32190@unicorn.suse.cz>
References: <cover.1431546602.git.mkubecek@suse.cz>
 <c1fd1b1527dc2a6905d4eeff04f1e4ed3f93964e.1431546602.git.mkubecek@suse.cz>
 <5554F073.4080501@6wind.com>
 <20150514214907.GA20301@lion>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	roopa <roopa@cumulusnetworks.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150514214907.GA20301@lion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 14, 2015 at 11:49:07PM +0200, Michal Kubecek wrote:
> On Thu, May 14, 2015 at 08:58:59PM +0200, Nicolas Dichtel wrote:
> > Le 13/05/2015 21:59, Michal Kubecek a =E9crit :
> > >When replacing an IPv6 multipath route with "ip route replace", i.=
e.
> > >NLM_F_CREATE | NLM_F_REPLACE, fib6_add_rt2node() replaces only fir=
st
> > >matching route without fixing its siblings, resulting in corrupted
> > >siblings linked list; removing one of the siblings can then end in=
 an
> > >infinite loop.
> > >
> > >Replacing the whole set of nexthops does IMHO make more sense than
> > >replacing a random one. We also need to remove the NLM_F_REPLACE f=
lag
> > >after replacing old nexthops by first new so that each subsequent
> > >nexthop does not replace previous one.
> > >
> > >Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (E=
CMP)")
> > >Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> > >---
> > >  net/ipv6/ip6_fib.c | 17 ++++++++++++++---
> > >  net/ipv6/route.c   |  8 +++++---
> > >  2 files changed, 19 insertions(+), 6 deletions(-)
> > >
> > >diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> > >index 96dbffff5a24..abf4e4e5bdab 100644
> > >--- a/net/ipv6/ip6_fib.c
> > >+++ b/net/ipv6/ip6_fib.c
> > >@@ -815,6 +815,8 @@ add:
> > >  		}
> > >
> > >  	} else {
> > >+		struct rt6_info *next;
> > >+
> > >  		if (!found) {
> > >  			if (add)
> > >  				goto add;
> > >@@ -828,15 +830,24 @@ add:
> > >
> > >  		*ins =3D rt;
> > >  		rt->rt6i_node =3D fn;
> > >-		rt->dst.rt6_next =3D iter->dst.rt6_next;
> > >+
> > >+		/* skip potential siblings */
> > >+		next =3D iter->dst.rt6_next;
> > >+		while (next && next->rt6i_metric =3D=3D rt->rt6i_metric)
> > >+			next =3D next->dst.rt6_next;
> > I wonder if we should not loop over the siblings list here
> > (rt->rt6i_siblings).  Only routes that match 'rt6_qualify_for_ecmp(=
)'
> > are siblings.
>=20
> Problem with looping over the siblings list is that then we would hav=
e
> to find each of them in the (unidirectional) list linked by dst.rt6_n=
ext
> to be able to delete them from this list.  Do we at least know that a=
ll
> routes in this list with matching metric and rt6_qualify_for_ecmp() a=
re
> siblings? If so, we could still do the cleanup on one pass over the
> dst.rt6_next list.

Hm... it's still a bit more complicated. In the "replace" case, we brea=
k
the loop once we find any route with matching metric, i.e. we can find =
a
non-ECMP one even if there are some ECMP siblings farther in the chain.
As far as I can see, replacing such route would cause an inconsistency
as nsiblings would no longer match the number of ECMP-able routes in th=
e
chain.

IMHO it's not completely clear what the "replace" semantics should be
for multiple routes (and, worse, for a mix of non-ECMP and ECMP ones).
One possible approach would be

  - when new route is ECMP-able, try to find an ECMP-able route and
    replace it with all its siblings
  - if there is none, fall back to replacing first matching non-ECMP
    route (or just add if creating is allowed)
  - when new route is not ECMP-able (can this really happen with
    NLM_F_REPLACE?), replace first matching non-ECMP or insert new one

But I still rather feel like replacing all existing matching routes
would better reflect what I expect "replace" to do.

                                                        Michal Kubecek

> > >+		rt->dst.rt6_next =3D next;
> > >+
> > >  		atomic_inc(&rt->rt6i_ref);
> > >  		inet6_rt_notify(RTM_NEWROUTE, rt, info);
> > >  		if (!(fn->fn_flags & RTN_RTINFO)) {
> > >  			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
> > >  			fn->fn_flags |=3D RTN_RTINFO;
> > >  		}
> > >-		fib6_purge_rt(iter, fn, info->nl_net);
> > >-		rt6_release(iter);
> > >+		while (iter !=3D next) {
> > >+			fib6_purge_rt(iter, fn, info->nl_net);
> > >+			rt6_release(iter);
> > >+			iter =3D iter->dst.rt6_next;
> > >+		}
> > Same here.
