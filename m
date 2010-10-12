From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Tue, 12 Oct 2010 19:40:45 +0200
Message-ID: <1286905245.2703.3.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:60614 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757306Ab0JLRlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 13:41:24 -0400
Received: by wwb22 with SMTP id 22so52059wwb.1
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 10:41:11 -0700 (PDT)
In-Reply-To: <loom.20101012T185411-307@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 octobre 2010 =C3=A0 17:14 +0000, Joe Buehler a =C3=A9crit :
> I am seeing a kernel panic (NULL pointer) in fib_rules_lookup.  There
> were some other reports for 2.6.32 back in March and May.  It looks t=
o
> me as though "rules_list" is not in a good state when fib_rules_looku=
p
> traverses it.
>=20
> My application is bringing TAP interfaces up and down and making
> changes to associated routing tables at a fairly good clip (say, a fe=
w
> times a second).  That use case seems to be similar to a previously
> reported crash case.
>=20
> This is a MIPS kernel (Cavium Octeon) running two CPUs SMP.  I am
> using 2.6.27.7 patched by Cavium for hardware support reasons.  I
> cannot upgrade because the vendor patches are non-trivial to
> forward-port.
>=20
> Here is one stack trace:
>=20
> [<ffffffff814671ec>] fib_rules_lookup+0x11c/0x1a8
> [<ffffffff814bd144>] fib_lookup+0x2c/0x48
> [<ffffffff814788d8>] __ip_route_output_key+0x918/0xf38
> [<ffffffff81478f30>] ip_route_output_flow+0x38/0x2e8
> [<ffffffff8149fd1c>] tcp_v4_connect+0x134/0x498
> [<ffffffff814aef80>] inet_stream_connect+0xf8/0x2f0
> [<ffffffff81442680>] sys_connect+0xe0/0xf8
> [<ffffffff8114528c>] handle_sys+0x12c/0x148
>=20
> Here is another:
>=20
> [<ffffffff814671ec>] fib_rules_lookup+0x11c/0x1a8
> [<ffffffff814bd144>] fib_lookup+0x2c/0x48
> [<ffffffff814b6550>] fib_validate_source+0xb0/0x4c0
> [<ffffffff8147a524>] ip_route_input+0x11a4/0x13c0
> [<ffffffff8147c304>] ip_rcv_finish+0x2f4/0x4c0
> [<ffffffff81454220>] process_backlog+0xa8/0x160
> [<ffffffff81451ea8>] net_rx_action+0x190/0x2e0
> [<ffffffff81166978>] __do_softirq+0xf0/0x218
> [<ffffffff81166b18>] do_softirq+0x78/0x80
> [<ffffffff81100e30>] plat_irq_dispatch+0x130/0x1e0
> [<ffffffff81130948>] ret_from_irq+0x0/0x4
> [<ffffffff8151167c>] _cond_resched+0x34/0x50
> [<ffffffff81148b60>] fpu_emulator_cop1Handler+0x90/0x1c80
> [<ffffffff81136f4c>] do_cpu+0x24c/0x360
> [<ffffffff81130940>] ret_from_exception+0x0/0x8
>=20
> *IF* my reading of the disassembled code at point of panic is correct=
,
>  the "pos" pointer in list_for_each_entry_rcu appears to be NULL.
>=20
> Looking at the code in net/core/fib_rules.c I see some uses of the
> "rules_list" using rcu and some apparently not.  Has something simple
> been overlooked?
>=20
> I need this fixed so will try adding a spinlock to protect rules_list
> if necessary.

2.6.27 is a bit old, you might try :

commit 7fa7cb7109d07c29ab28bb877bc7049a0150dbe5
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Mon Sep 27 04:18:27 2010 +0000

    fib: use atomic_inc_not_zero() in fib_rules_lookup
   =20
    It seems we dont use appropriate refcount increment in an
    rcu_read_lock() protected section.
   =20
    fib_rule_get() might increment a null refcount and bad things could
    happen.
   =20
    While fib_nl_delrule() respects an rcu grace period before calling
    fib_rule_put(), fib_rules_cleanup_ops() calls fib_rule_put() withou=
t a
    grace period.
   =20
    Note : after this patch, we might avoid the synchronize_rcu() call =
done
    in fib_nl_delrule()
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 42e84e0..d078728 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -225,9 +225,11 @@ jumped:
 			err =3D ops->action(rule, fl, flags, arg);
=20
 		if (err !=3D -EAGAIN) {
-			fib_rule_get(rule);
-			arg->rule =3D rule;
-			goto out;
+			if (likely(atomic_inc_not_zero(&rule->refcnt))) {
+				arg->rule =3D rule;
+				goto out;
+			}
+			break;
 		}
 	}
=20


