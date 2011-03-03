From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] udp: udp_sendmsg() fix
Date: Thu, 03 Mar 2011 18:07:23 +0100
Message-ID: <1299172043.2983.142.camel@edumazet-laptop>
References: <1299169686.2983.129.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42726 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982Ab1CCRLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 12:11:39 -0500
Received: by ewy6 with SMTP id 6so432858ewy.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 09:11:37 -0800 (PST)
In-Reply-To: <1299169686.2983.129.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 17:28 +0100, Eric Dumazet a =C3=A9crit :
> Just had this while working on latest net-next-2.6
>=20
> [11483.697210] BUG: unable to handle kernel NULL pointer dereference =
at
> 0000002a
> [11483.697233] IP: [<c12b0638>] dst_release+0x18/0x60
> [11483.697252] *pdpt =3D 0000000034917001 *pde =3D 0000000000000000=20
> [11483.697270] Oops: 0002 [#1] SMP=20
> [11483.697283] last sysfs
> file: /sys/devices/virtual/net/bond0/bonding/active_slave
> [11483.697299] Modules linked in: pktgen ipmi_si ipmi_msghandler hpil=
o
> tg3 bonding ipv6
> [11483.697335]=20
> [11483.697340] Pid: 5490, comm: ntpd Not tainted
> 2.6.38-rc5-02884-g0853e6c-dirty #974 HP ProLiant BL460c G1
> [11483.697366] EIP: 0060:[<c12b0638>] EFLAGS: 00010282 CPU: 4
> [11483.697392] EIP is at dst_release+0x18/0x60
> [11483.697416] EAX: ffffffea EBX: ffffffea ECX: 00000000 EDX: 6e14a8c=
0
> [11483.697444] ESI: ffffffff EDI: ffffffea EBP: f445fd18 ESP: f445fd1=
0
> [11483.697471]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [11483.697497] Process ntpd (pid: 5490, ti=3Df445e000 task=3Df3542490
> task.ti=3Df445e000)
> [11483.697540] Stack:
> [11483.697562]  f3401400 ffffffea f445fdc0 c12fc9d2 00000030 f445fd3c
> c12a1c01 00000282
> [11483.697619]  00000008 00000030 0dfeaa0a 6e14a8c0 7b001000 00000000
> 0dfeaa0a f445fda0
> [11483.697680]  00000000 00000000 c12dbd90 00000000 f445ff38 00000000
> 00000000 00000000
> [11483.697741] Call Trace:
> [11483.697764]  [<c12fc9d2>] udp_sendmsg+0x282/0x6e0
> [11483.697790]  [<c12a1c01>] ? memcpy_toiovec+0x51/0x70
> [11483.697818]  [<c12dbd90>] ? ip_generic_getfrag+0x0/0xb0
> [11483.697848]  [<c1184e00>] ? timerqueue_add+0x30/0xc0
> [11483.697874]  [<c1304ae5>] inet_sendmsg+0x45/0xa0
> [11483.697901]  [<c10617ab>] ? __hrtimer_start_range_ns+0x1ab/0x500
> [11483.697930]  [<c1298543>] sock_sendmsg+0xc3/0xf0
> [11483.697957]  [<c100b2b4>] ? save_i387_fxsave+0x74/0x80
> [11483.697984]  [<c1189022>] ? _copy_from_user+0x32/0x50
> [11483.698010]  [<c1299702>] sys_sendto+0xb2/0xe0
> [11483.698035]  [<c100bd50>] ? restore_i387_xstate+0xd0/0x1f0
> [11483.698062]  [<c129a07d>] sys_socketcall+0x18d/0x270
> [11483.698088]  [<c1002cd0>] sysenter_do_call+0x12/0x26
> [11483.698123] Code: 53 c1 e8 ac 0b 0a 00 5b c9 c3 89 f6 8d bc 27 00 =
00
> 00 00 55 89 e5 83 ec 08 85 c0 89 1c 24 89 74 24 04 89 c3 74 11 be ff =
ff
> ff ff <f0> 0f c1 70 40 4e 78 2f 85 f6 74 0c 8b 1c 24 8b 74 24 04 c9 c=
3=20
> [11483.698319] EIP: [<c12b0638>] dst_release+0x18/0x60 SS:ESP
> 0068:f445fd10
> [11483.698350] CR2: 000000000000002a
> [11483.698594] ---[ end trace cb654a6638801e35 ]---
>=20
>=20
> crash in=20
>=20
> c12b0638:   f0 0f c1 70 40          lock xadd %esi,0x40(%eax)
>=20
> EAX =3D -EINVAL
>=20
>=20
>=20
> commit b23dd4fe42b455af (ipv4: Make output route lookup return rtable
> directly) introduced a regression ...
>=20
> We could add a sanity test in dst_release(), or fix callers ?
>=20
> What do you think ?
>=20
>=20


Here is the patch I cooked after an audit

[PATCH net-next-2.6] udp: udp_sendmsg() fix

commit b23dd4fe42b455af (ipv4: Make output route lookup return rtable
directly) introduced a regression in udp_sendmsg()

If IP route lookup fails, we should not try to release an non existent
route.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 95e0c2c..f6c0c00 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -927,7 +927,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk=
, struct msghdr *msg,
 			err =3D PTR_ERR(rt);
 			if (err =3D=3D -ENETUNREACH)
 				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
-			goto out;
+			goto out2;
 		}
=20
 		err =3D -EACCES;
@@ -991,6 +991,7 @@ do_append_data:
=20
 out:
 	ip_rt_put(rt);
+out2:
 	if (free)
 		kfree(ipc.opt);
 	if (!err)


