From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16120] New: Oops: 0000 [#1] SMP, unable to
 handle kernel NULL pointer dereference at (null)
Date: Mon, 07 Jun 2010 11:48:40 +0200
Message-ID: <1275904120.2545.40.camel@edumazet-laptop>
References: <bug-16120-10286@https.bugzilla.kernel.org/>
	 <20100604161737.25c7940a.akpm@linux-foundation.org>
	 <1275729426.5238.6.camel@edumazet-laptop>
	 <1275730457.5238.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, alex.vizor@gmail.com,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64236 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab0FGJsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 05:48:50 -0400
Received: by fxm8 with SMTP id 8so1895556fxm.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 02:48:44 -0700 (PDT)
In-Reply-To: <1275730457.5238.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 05 juin 2010 =C3=A0 11:34 +0200, Eric Dumazet a =C3=A9crit :
> Le samedi 05 juin 2010 =C3=A0 11:17 +0200, Eric Dumazet a =C3=A9crit =
:
> > Le vendredi 04 juin 2010 =C3=A0 16:17 -0700, Andrew Morton a =C3=A9=
crit :
> > > (switched to email.  Please respond via emailed reply-to-all, not=
 via the
> > > bugzilla web interface).
> > >=20
> > > On Fri, 4 Jun 2010 09:25:58 GMT
> > > bugzilla-daemon@bugzilla.kernel.org wrote:
> > >=20
> > > > https://bugzilla.kernel.org/show_bug.cgi?id=3D16120
> > > >=20
> > > >            Summary: Oops: 0000 [#1] SMP, unable to handle kerne=
l NULL
> > > >                     pointer dereference at (null)
> > > >            Product: Platform Specific/Hardware
> > > >            Version: 2.5
> > > >     Kernel Version: 2.6.35-rc1
> > > >           Platform: All
> > > >         OS/Version: Linux
> > > >               Tree: Mainline
> > > >             Status: NEW
> > > >           Severity: high
> > > >           Priority: P1
> > > >          Component: x86-64
> > > >         AssignedTo: platform_x86_64@kernel-bugs.osdl.org
> > > >         ReportedBy: alex.vizor@gmail.com
> > > >         Regression: Yes
> > > >=20
> > > >=20
> > > > Created an attachment (id=3D26647)
> > > >  --> (https://bugzilla.kernel.org/attachment.cgi?id=3D26647) id=
)
> >=20
> > > > 2.6.35-rc1 kernel log
> > > >=20
> > > > It happens randomly, almost a week I used 2.6.35-rc1 and don't =
have any
> > > > problems. But since last day it happened twice.
> > > >=20
> > > > I attached kernel log, please inform me if I can help in invest=
igation.
> > > >=20
> > >=20
> > > ip6mr_sk_done() oopsed.
> >=20
> > Only thing I found a first glance is a typo but this should not be =
the
> > root of the problem.
> >=20
>=20

I was able to reproduce the problem here, and following patch solves it=
=2E

(I see David already committed first patch about macro typo)

Thanks !

[PATCH net-2.6] ipmr: dont corrupt lists

ipmr_rules_exit() and ip6mr_rules_exit() free a list of items, but
forget to properly remove these items from list. List head is not
changed and still points to freed memory.

This can trigger a fault later when icmpv6_sk_exit() is called.

=46ix is to either reinit list, or use list_del() to properly remove it=
ems
from list before freeing them.

bugzilla report : https://bugzilla.kernel.org/show_bug.cgi?id=3D16120

Introduced by commit d1db275dd3f6e4 (ipv6: ip6mr: support multiple
tables) and commit f0ad0860d01e (ipv4: ipmr: support multiple tables)

Reported-by: Alex Zhavnerchik <alex.vizor@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/ipmr.c  |    4 +++-
 net/ipv6/ip6mr.c |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 856123f..757f25e 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -267,8 +267,10 @@ static void __net_exit ipmr_rules_exit(struct net =
*net)
 {
 	struct mr_table *mrt, *next;
=20
-	list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list)
+	list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list) {
+		list_del(&mrt->list);
 		kfree(mrt);
+	}
 	fib_rules_unregister(net->ipv4.mr_rules_ops);
 }
 #else
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 89c0b07..66078da 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -254,8 +254,10 @@ static void __net_exit ip6mr_rules_exit(struct net=
 *net)
 {
 	struct mr6_table *mrt, *next;
=20
-	list_for_each_entry_safe(mrt, next, &net->ipv6.mr6_tables, list)
+	list_for_each_entry_safe(mrt, next, &net->ipv6.mr6_tables, list) {
+		list_del(&mrt->list);
 		ip6mr_free_table(mrt);
+	}
 	fib_rules_unregister(net->ipv6.mr6_rules_ops);
 }
 #else


