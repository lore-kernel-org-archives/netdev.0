From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 21:44:25 +0200
Message-ID: <1287863065.2658.533.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>
	 <1287851745.2658.364.camel@edumazet-laptop>
	 <239681287855420@web159.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Joe Buehler <aspam@cox.net>
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55589 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758296Ab0JWToc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 15:44:32 -0400
Received: by wwe15 with SMTP id 15so2138021wwe.1
        for <netdev@vger.kernel.org>; Sat, 23 Oct 2010 12:44:31 -0700 (PDT)
In-Reply-To: <239681287855420@web159.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 23 octobre 2010 =C3=A0 21:37 +0400, "Oleg A. Arkhangelsky" a
=C3=A9crit :
> 23.10.2010, 20:36, "Eric Dumazet" <eric.dumazet@gmail.com>:
>=20
> > With a normal workload, on a dual cpu machine, a missing memory bar=
rier
> > can stay un-noticed for quite a long time. The race window is so sm=
all
> > that probability for the bug might be 0.0000001 % or something like
> > that :(
>=20
> Eric, I'd like to remind you that I've faced the similar problem on s=
imple x86.
>=20
> See http://kerneltrap.org/mailarchive/linux-netdev/2010/3/9/6271568
>=20
> Two main differences for our case:
>=20
> 1) There is no userspace workload (except for bgpd), no changes in in=
terfaces
> 2) We are not using multiple routing tables
>=20
> This panic was pretty rare in our case  (not more that 2 times per mo=
nth).
>=20
> Currently we're running fine with disabled CONFIG_IP_MULTIPLE_TABLES.
>=20

Okay ;)

I believe I found a bug, but really cant understand how it can triggers
on your workload (and Joe one, of course)

Here is a patch against net-next-2.6 for testing, it probably can
backported to old kernels.

Thanks

[PATCH] fib: fix fib_nl_newrule()

Some panic reports in fib_rules_lookup() show a rule could have a NULL
pointer as a next pointer in the rules_list.

This can actually happen because of a bug in fib_nl_newrule() : It
checks if current rule is the destination of unresolved gotos. (Other
rules have gotos to this about to be inserted rule)

Problem is it does the resolution of the gotos before the rule is
inserted in the rules_list (and has a valid next pointer)

=46ix this by moving the rules_list insertion before the changes on got=
os.

A lockless reader can not any more follow a ctarget pointer, unless
destination is ready (has a valid next pointer)

Reported-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru>
Reported-by: Joe Buehler <aspam@cox.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/fib_rules.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 1bc3f25..12b43cc 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -373,6 +373,11 @@ static int fib_nl_newrule(struct sk_buff *skb, str=
uct nlmsghdr* nlh, void *arg)
=20
 	fib_rule_get(rule);
=20
+	if (last)
+		list_add_rcu(&rule->list, &last->list);
+	else
+		list_add_rcu(&rule->list, &ops->rules_list);
+
 	if (ops->unresolved_rules) {
 		/*
 		 * There are unresolved goto rules in the list, check if
@@ -395,11 +400,6 @@ static int fib_nl_newrule(struct sk_buff *skb, str=
uct nlmsghdr* nlh, void *arg)
 	if (unresolved)
 		ops->unresolved_rules++;
=20
-	if (last)
-		list_add_rcu(&rule->list, &last->list);
-	else
-		list_add_rcu(&rule->list, &ops->rules_list);
-
 	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).pid);
 	flush_route_cache(ops);
 	rules_ops_put(ops);


