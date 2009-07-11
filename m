From: Johannes Berg <johannes@sipsolutions.net>
Subject: need help with wireless netns crash
Date: Sat, 11 Jul 2009 10:47:13 +0200
Message-ID: <1247302033.30647.72.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-/B38U+rnyqaKYVlVyydY"
Cc: netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58453 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbZGKIrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 04:47:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/B38U+rnyqaKYVlVyydY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

can somebody explain this comment to me?

 * Use these carefully.  If you implement a network device and it
 * needs per network namespace operations use device pernet operations,
 * otherwise use pernet subsys operations.
 *
 * This is critically important.  Most of the network code cleanup
 * runs with the assumption that dev_remove_pack has been called so no
 * new packets will arrive during and after the cleanup functions have
 * been called.  dev_remove_pack is not per namespace so instead the
 * guarantee of no more packets arriving in a network namespace is
 * provided by ensuring that all network devices and all sockets have
 * left the network namespace before the cleanup methods are called.
 *
 * For the longest time the ipv4 icmp code was registered as a pernet
 * device which caused kernel oops, and panics during network
 * namespace cleanup.   So please don't get this wrong.

I was running with this patch:
http://johannes.sipsolutions.net/patches/kernel/all/LATEST/NNN-cfg80211-net=
ns.patch

and if I use pernet_subsys I sometimes run into this warning and the
crash below, but if I use pernet_device I don't -- and would like to
understand why.


[  732.092471] WARNING: at kernel/sysctl.c:2120 unregister_sysctl_table+0xb=
9/0x120()
[  732.096093] Hardware name:=20
[  732.097069] Pid: 38, comm: netns Tainted: G        W  2.6.31-rc2-wl #407
[  732.099415] Call Trace:
[  732.103391]  [<ffffffff810520a6>] warn_slowpath_common+0x76/0xd0
[  732.105880]  [<ffffffff81052114>] warn_slowpath_null+0x14/0x20
[  732.108047]  [<ffffffff8105c429>] unregister_sysctl_table+0xb9/0x120
[  732.118549]  [<ffffffff813ab845>] __devinet_sysctl_unregister+0x25/0x40
[  732.120890]  [<ffffffff813ab8ec>] inetdev_destroy+0x8c/0x100
[  732.123037]  [<ffffffff813abe66>] inetdev_event+0x156/0x280
[  732.124939]  [<ffffffff81072ad5>] notifier_call_chain+0x65/0xa0
[  732.126959]  [<ffffffff81072be6>] raw_notifier_call_chain+0x16/0x20
[  732.129096]  [<ffffffff813618b6>] dev_change_net_namespace+0xc6/0x2b0
[  732.137437]  [<ffffffff813c7c9f>] cfg80211_switch_netns+0x5f/0x130
[  732.141569]  [<ffffffff813c7def>] cfg80211_pernet_exit+0x7f/0xa0
[  732.143656]  [<ffffffff8135a83e>] cleanup_net+0x5e/0xb0
[  732.145507]  [<ffffffff81067ae5>] run_workqueue+0x165/0x2a0
[  732.149376]  [<ffffffff81067ccf>] worker_thread+0xaf/0x130
[  732.155473]  [<ffffffff8106d136>] kthread+0xa6/0xb0
[  732.157144]  [<ffffffff8100c99a>] child_rip+0xa/0x20

and this error (sometimes _both_ but not always):

[  139.352125] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEAL=
LOC
[  139.354812] last sysfs file: /sys/devices/virtual/mac80211_hwsim/hwsim0/=
phy0/index
[  139.357859] CPU 3=20
[  139.358769] Pid: 38, comm: netns Tainted: G        W  2.6.31-rc2-wl #408=
=20
[  139.361542] RIP: 0010:[<ffffffff813b4e71>]  [<ffffffff813b4e71>] fib_mag=
ic+0x81/0xd0
[  139.361939] RSP: 0018:ffff88001fa79a10  EFLAGS: 00010202
[  139.361939] RAX: ffff88001ee75b18 RBX: 0000000000000019 RCX: 00000000000=
00000
[  139.361939] RDX: 6b6b6b6b6b6b6b6b RSI: 0000000000000003 RDI: ffff88001fa=
79a70
[  139.361939] RBP: ffff88001fa79a90 R08: 000000000000000c R09: ffff88001e4=
a0000
[  139.361939] R10: 0000000000000001 R11: ffff88001fa79a10 R12: 00000000010=
0000a
[  139.361939] R13: 0000000000000018 R14: ffff88001e490cd8 R15: 00000000010=
0000a
[  139.361939] FS:  0000000000000000(0000) GS:ffff880003d91000(0000) knlGS:=
0000000000000000
[  139.361939] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[  139.361939] CR2: 00007fced319b098 CR3: 000000001edb2000 CR4: 00000000000=
006e0
[  139.361939] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[  139.361939] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[  139.361939] Process netns (pid: 38, threadinfo ffff88001fa78000, task ff=
ff88001fa70000)
[  139.361939] Stack:
[  139.361939]  0000000100020018 0000000a00000000 0000000300000000 00000000=
00000000
[  139.361939] <0> 000000000100000a 0000000000000000 0000000000000000 00000=
00000000000
[  139.361939] <0> 00000c0000000000 0000000000000000 ffff88001e4a0000 00000=
00000000000
[  139.361939] Call Trace:
[  139.361939]  [<ffffffff813b5870>] fib_del_ifaddr+0x60/0x220
[  139.361939]  [<ffffffff813b5a98>] fib_inetaddr_event+0x68/0xb0
[  139.361939]  [<ffffffff81072ad5>] notifier_call_chain+0x65/0xa0
[  139.361939]  [<ffffffff81072de3>] __blocking_notifier_call_chain+0x63/0x=
90
[  139.361939]  [<ffffffff81072e26>] blocking_notifier_call_chain+0x16/0x20
[  139.361939]  [<ffffffff813ab589>] __inet_del_ifa+0xa9/0x220
[  139.361939]  [<ffffffff813ab8ba>] inetdev_destroy+0x5a/0x100
[  139.361939]  [<ffffffff813abe66>] inetdev_event+0x156/0x280
[  139.361939]  [<ffffffff81072ad5>] notifier_call_chain+0x65/0xa0
[  139.361939]  [<ffffffff81072be6>] raw_notifier_call_chain+0x16/0x20
[  139.361939]  [<ffffffff813618b6>] dev_change_net_namespace+0xc6/0x2b0
[  139.361939]  [<ffffffff813c7c9f>] cfg80211_switch_netns+0x5f/0x130
[  139.361939]  [<ffffffff813c7def>] cfg80211_pernet_exit+0x7f/0xa0
[  139.361939]  [<ffffffff8135a83e>] cleanup_net+0x5e/0xb0
[  139.361939]  [<ffffffff81067ae5>] run_workqueue+0x165/0x2a0
[  139.361939]  [<ffffffff81067ccf>] worker_thread+0xaf/0x130
[  139.361939]  [<ffffffff8106d136>] kthread+0xa6/0xb0
[  139.361939]  [<ffffffff8100c99a>] child_rip+0xa/0x20



It seems the problem is that during the netns removal notification I
reparent interfaces to init_net? I suppose I could just rely on that
happening automatically by unsetting only the NETNS_LOCAL flag for them
at this point? Or is this maybe too late and I need to be doing this
earlier, in some pre-removal callback?

And ... should they actually be reparented to init_net anyway? It seems
they should go to the parent of the ns if such a concept exists, since
namespaces would seem to follow the task hierarchy? If I create a netns
and from _within_ that create yet another netns it would seem that the
outer netns would get its interfaces back when the inner done goes away,
rather than its parent task's netns getting them.

Any help appreciated!

johannes

--=-/B38U+rnyqaKYVlVyydY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKWFGOAAoJEODzc/N7+QmakLMP/jd+GBMeL2hAuAxM5+JIZcmk
b9r8tAObwFwej7oTOX1rXgVzqgog/+NZ334Ra/slhgrKZxzhNFVe9I4IuTmT8LAH
go0Y5+BLhovyGeVt3ppPJY6MnQVn+NtCORaOoAXe1PGnx1e0QvbLx8dAXZ3kcu7h
L4Yfw4Lparc4TDqmghTus2WysZs1JH0Y8s/6GxwVnldz8MEhj9XOd6bPOQx/NPKq
ZlpruRhY6EOjE8We+wTeLZquo4Ce2MQKe3PP6dKDH9CO5yEWowb65zK8LzFoNGev
vX4KhjL98un9iwOVUXZk0/XKpB4vZBHLuhiPMWVzlfb4cWBM0adwEyMZydfQyQeS
38M1rLJAZSczNuyUDUjKzNTmj8O6K08ObLu7vuCyEbh4XmzY9Jt2pB8QB9TdRZEQ
r2OeZP6IU2HZRD6vMTx202LBDorfYAt/rEtFSEAIA07c5WUNYXDM9NSXCneBVuWw
nFex1KmIvN+IM0bEAcwa/JIp2Il4cyG0N97LMA7Akk88nePu/mI3o446PA8LgSlQ
Do7NXbv6v+/vPLpPfTgKWYsv5AGROZLq+h2qvoJ6Rv0ZV+vRY+JyflfiGhilOL62
PZxSHJKQA2fB5e60veC9uTVA0OXIfMlnPaEd50tcW1tziJYBbLyOJFeeys1VYaQi
/jWUdBWOGafA3jXc5ajV
=vXCg
-----END PGP SIGNATURE-----

--=-/B38U+rnyqaKYVlVyydY--

