From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 29252] New: IPv6 doesn't work in a kvm guest.
Date: Wed, 09 Mar 2011 15:58:18 -0800 (PST)
Message-ID: <20110309.155818.212679516.davem@davemloft.net>
References: <bug-29252-10286@https.bugzilla.kernel.org/>
	<20110217142517.b9919481.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, slash@ac.auone-net.jp,
	ernstp@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56148
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752262Ab1CIX5l convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 18:57:41 -0500
In-Reply-To: <20110217142517.b9919481.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, the following should address both bugs, #29252 and #30462, please
give it some testing.

--------------------
ipv6: Don't create clones of nonexthop routes forever.

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

The issue is that there is nothing that stops the cloning process.
Every route call will find the same route in the same condition,
reclone it, and insert.

This causes two problems:

1) If the in6_rt_ins() call succeeds, we get tons of crap in the
   routing tree.

2) If the int6_rt_ins() call fails, we get no networking to that
   destination.

We've had reports of both cases.

End the loop and the failures by keying on the RTF_CACHE flag which
will only be set in the clone routes.

Reported-by: slash@ac.auone-net.jp
Reported-by: Ernst Sj=F6strand <ernstp@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 904312e..8963635 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -739,8 +739,10 @@ restart:
=20
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt =3D rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
-	else
+	else if (!(rt->rt6i_flags & RTF_CACHE))
 		nrt =3D rt6_alloc_clone(rt, &fl->fl6_dst);
+	else
+		goto out2;
=20
 	dst_release(&rt->dst);
 	rt =3D nrt ? : net->ipv6.ip6_null_entry;
