From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16120] New: Oops: 0000 [#1] SMP, unable to
 handle kernel NULL pointer dereference at (null)
Date: Sat, 05 Jun 2010 11:34:17 +0200
Message-ID: <1275730457.5238.14.camel@edumazet-laptop>
References: <bug-16120-10286@https.bugzilla.kernel.org/>
	 <20100604161737.25c7940a.akpm@linux-foundation.org>
	 <1275729426.5238.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, alex.vizor@gmail.com,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50824 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932651Ab0FEJeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:34:23 -0400
Received: by wyi11 with SMTP id 11so1390877wyi.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 02:34:21 -0700 (PDT)
In-Reply-To: <1275729426.5238.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 05 juin 2010 =C3=A0 11:17 +0200, Eric Dumazet a =C3=A9crit :
> Le vendredi 04 juin 2010 =C3=A0 16:17 -0700, Andrew Morton a =C3=A9cr=
it :
> > (switched to email.  Please respond via emailed reply-to-all, not v=
ia the
> > bugzilla web interface).
> >=20
> > On Fri, 4 Jun 2010 09:25:58 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> >=20
> > > https://bugzilla.kernel.org/show_bug.cgi?id=3D16120
> > >=20
> > >            Summary: Oops: 0000 [#1] SMP, unable to handle kernel =
NULL
> > >                     pointer dereference at (null)
> > >            Product: Platform Specific/Hardware
> > >            Version: 2.5
> > >     Kernel Version: 2.6.35-rc1
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: high
> > >           Priority: P1
> > >          Component: x86-64
> > >         AssignedTo: platform_x86_64@kernel-bugs.osdl.org
> > >         ReportedBy: alex.vizor@gmail.com
> > >         Regression: Yes
> > >=20
> > >=20
> > > Created an attachment (id=3D26647)
> > >  --> (https://bugzilla.kernel.org/attachment.cgi?id=3D26647) id)
>=20
> > > 2.6.35-rc1 kernel log
> > >=20
> > > It happens randomly, almost a week I used 2.6.35-rc1 and don't ha=
ve any
> > > problems. But since last day it happened twice.
> > >=20
> > > I attached kernel log, please inform me if I can help in investig=
ation.
> > >=20
> >=20
> > ip6mr_sk_done() oopsed.
>=20
> Only thing I found a first glance is a typo but this should not be th=
e
> root of the problem.
>=20

At a second glance, I think the problem is that we probably cleanup=20
in the wrong order.

ip6mr_rules_exit() is probably called before icmpv6_sk_exit() ?

I dont know how to fix this order, no more time for me until Monday.


We should reinit mr6_tables list in ip6mr_rules_exit() in any case


[PATCH] ip6mr: fixes

1) Fix a typo in ip6mr_for_each_table() definition

2) Re-initiliaze mr6_tables in ip6mr_rules_exit()

bugzilla report : https://bugzilla.kernel.org/attachment.cgi?id=3D26647

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 073071f..e2ff192 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -120,7 +120,7 @@ static void mroute_clean_tables(struct mr6_table *m=
rt);
 static void ipmr_expire_process(unsigned long arg);
=20
 #ifdef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
-#define ip6mr_for_each_table(mrt, met) \
+#define ip6mr_for_each_table(mrt, net) \
 	list_for_each_entry_rcu(mrt, &net->ipv6.mr6_tables, list)
=20
 static struct mr6_table *ip6mr_get_table(struct net *net, u32 id)
@@ -256,6 +256,7 @@ static void __net_exit ip6mr_rules_exit(struct net =
*net)
=20
 	list_for_each_entry_safe(mrt, next, &net->ipv6.mr6_tables, list)
 		ip6mr_free_table(mrt);
+	INIT_LIST_HEAD(&net->ipv6.mr6_tables);
 	fib_rules_unregister(net->ipv6.mr6_rules_ops);
 }
 #else


