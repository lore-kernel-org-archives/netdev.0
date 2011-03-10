From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 29252] New: IPv6 doesn't work in a kvm guest.
Date: Wed, 09 Mar 2011 20:04:37 -0800 (PST)
Message-ID: <20110309.200437.226773227.davem@davemloft.net>
References: <20110217142517.b9919481.akpm@linux-foundation.org>
	<20110309.155818.212679516.davem@davemloft.net>
	<20110309.192012.193710171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, slash@ac.auone-net.jp,
	ernstp@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47584
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751421Ab1CJEEA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 23:04:00 -0500
In-Reply-To: <20110309.192012.193710171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>
Date: Wed, 09 Mar 2011 19:20:12 -0800 (PST)

> From: David Miller <davem@davemloft.net>
> Date: Wed, 09 Mar 2011 15:58:18 -0800 (PST)
>=20
>> Ok, the following should address both bugs, #29252 and #30462, pleas=
e
>> give it some testing.
>>=20
>> --------------------
>> ipv6: Don't create clones of nonexthop routes forever.
>=20
> Nevermind, this patch has problems, I'm still debugging and trying to
> come up with a proper fix.
>=20
> Thanks in advance for your patience.

Ok, I'm more confident in this version of the fix.  It passes all of
my tests, and I've added instrumentation to make sure various cases
are performing the operations the way I expect them to.

--------------------
ipv6: Don't create clones of host routes.
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=3D29252
Addresses https://bugzilla.kernel.org/show_bug.cgi?id=3D30462

In commit d80bc0fd262ef840ed4e82593ad6416fa1ba3fc4 ("ipv6: Always
clone offlink routes.") we forced the kernel to always clone offlink
routes.

The reason we do that is to make sure we never bind an inetpeer to a
prefixed route.

The logic turned on here has existed in the tree for many years,
but was always off due to a protecting CPP define.  So perhaps
it's no surprise that there is a logic bug here.

The problem is that we canot clone a route that is already a
host route (ie. has DST_HOST set).  Because if we do, an identical
entry already exists in the routing tree and therefore the
ip6_rt_ins() call is going to fail.

This sets off a series of failures and high cpu usage, because when
ip6_rt_ins() fails we loop retrying this operation a few times in
order to handle a race between two threads trying to clone and insert
the same host route at the same time.

=46ix this by simply using the route as-is when DST_HOST is set.

Reported-by: slash@ac.auone-net.jp
Reported-by: Ernst Sj=F6strand <ernstp@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 904312e..e7db701 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -739,8 +739,10 @@ restart:
=20
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt =3D rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
-	else
+	else if (!(rt->dst.flags & DST_HOST))
 		nrt =3D rt6_alloc_clone(rt, &fl->fl6_dst);
+	else
+		goto out2;
=20
 	dst_release(&rt->dst);
 	rt =3D nrt ? : net->ipv6.ip6_null_entry;
--=20
1.7.4.1

