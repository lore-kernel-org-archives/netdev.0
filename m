From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Takes > 1 second to delete macvlan with global IPv6 address on
 it.
Date: Tue, 09 Nov 2010 07:15:36 +0100
Message-ID: <1289283336.2790.76.camel@edumazet-laptop>
References: <4CD893C6.2030803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56112 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab0KIGPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 01:15:48 -0500
Received: by wyb36 with SMTP id 36so4457269wyb.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 22:15:47 -0800 (PST)
In-Reply-To: <4CD893C6.2030803@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 novembre 2010 =C3=A0 16:20 -0800, Ben Greear a =C3=A9crit :
> This is on an otherwise lightly loaded 2.6.36 + hacks system, 12 phys=
ical interfaces,
> and two VETH interfaces.
>=20
> It's much faster to delete an interface when it has no IPv6 address:
>=20
> [root@ct503-60 lanforge]# time ip link add link eth5 up name eth5#0 a=
ddress 00:00:00:00:00:01 type macvlan
>=20
> real	0m0.005s
> user	0m0.001s
> sys	0m0.004s
> [root@ct503-60 lanforge]# time ip link delete eth5#0
>=20
> real	0m0.033s
> user	0m0.001s
> sys	0m0.005s
> [root@ct503-60 lanforge]# ip link add link eth5 up name eth5#0 addres=
s 00:00:00:00:00:01 type macvlan
>=20
> [root@ct503-60 lanforge]# ip -6 addr add 2002::1/64 dev eth5#0
> [root@ct503-60 lanforge]# time ip link delete eth5#0
>=20
> real	0m1.030s
> user	0m0.000s
> sys	0m0.013s
>=20
>=20
> Funny enough, if you explicitly remove the IPv6 addr first it seems
> to run at normal speed (adding both operation's times together)
>=20
> [root@ct503-60 lanforge]# ip link add link eth5 up name eth5#0 addres=
s 00:00:00:00:00:01 type macvlan
> [root@ct503-60 lanforge]# ip -6 addr add 2002::1/64 dev eth5#0
> [root@ct503-60 lanforge]# time ip -6 addr delete 2002::1/64 dev eth5#=
0
>=20
> real	0m0.001s
> user	0m0.000s
> sys	0m0.001s
> [root@ct503-60 lanforge]# time ip link delete eth5#0
>=20
> real	0m0.028s
> user	0m0.001s
> sys	0m0.005s
>=20

The key here is you have to wait a bit (2 seconds) between=20
"ip -6 addr add..." and the "ip link delete", or it is fast.

So ipv6 misses a cleanup somewhere and a device refcount is held.

here is a debugging patch on current kernels :

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 072652d..820d9ed 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1799,6 +1799,7 @@ extern void netdev_run_todo(void);
  */
 static inline void dev_put(struct net_device *dev)
 {
+	WARN_ON(dev->reg_state =3D=3D NETREG_UNREGISTERED);
 	irqsafe_cpu_dec(*dev->pcpu_refcnt);
 }
=20
gives :

[  418.614227] ------------[ cut here ]------------
[  418.614281] WARNING: at include/linux/netdevice.h:1802 in6_dev_finis=
h_destroy+0xc9/0xf0()
[  418.614348] Hardware name: ProLiant BL460c G6
[  418.614392] Modules linked in: macvlan ipmi_devintf ipmi_si ipmi_msg=
handler dm_mod tg3 libphy sg [last unloaded: x_tables]
[  418.614804] Pid: 5403, comm: ip Tainted: G        W   2.6.37-rc1-001=
86-g5c6f178-dirty #271
[  418.614857] Call Trace:
[  418.614901]  [<ffffffff814ecac9>] ? in6_dev_finish_destroy+0xc9/0xf0
[  418.614952]  [<ffffffff81046440>] warn_slowpath_common+0x90/0xc0
[  418.615002]  [<ffffffff8104648a>] warn_slowpath_null+0x1a/0x20
[  418.615051]  [<ffffffff814ecac9>] in6_dev_finish_destroy+0xc9/0xf0
[  418.615101]  [<ffffffff814f469e>] ip6_dst_ifdown+0x5e/0x60
[  418.615150]  [<ffffffff81448318>] dst_ifdown+0x38/0x110
[  418.615198]  [<ffffffff81448457>] dst_dev_event+0x67/0x130
[  418.615247]  [<ffffffff815d2888>] notifier_call_chain+0x58/0x80
[  418.615298]  [<ffffffff8106b86e>] __raw_notifier_call_chain+0xe/0x10
[  418.615348]  [<ffffffff8106b886>] raw_notifier_call_chain+0x16/0x20
[  418.615432]  [<ffffffff814408d7>] call_netdevice_notifiers+0x37/0x70
[  418.615496]  [<ffffffff81440a47>] netdev_run_todo+0x137/0x260
[  418.615560]  [<ffffffff8144f11e>] rtnl_unlock+0xe/0x10
[  418.615621]  [<ffffffff8144f18a>] rtnetlink_rcv+0x2a/0x40
[  418.615684]  [<ffffffff8148b043>] netlink_unicast+0x2c3/0x2d0
[  418.615747]  [<ffffffff81438a8b>] ? memcpy_fromiovec+0x7b/0xa0
[  418.615810]  [<ffffffff8148bddd>] netlink_sendmsg+0x24d/0x380
[  418.615874]  [<ffffffff8142dad0>] sock_sendmsg+0xc0/0xf0
[  418.615938]  [<ffffffff81458370>] ? verify_compat_iovec+0x80/0x130
[  418.616002]  [<ffffffff8142e894>] sys_sendmsg+0x1a4/0x340
[  418.616065]  [<ffffffff810dad46>] ? handle_mm_fault+0x676/0x8b0
[  418.616129]  [<ffffffff815d2610>] ? do_page_fault+0x2a0/0x4c0
[  418.616192]  [<ffffffff8142df09>] ? sys_recvmsg+0x49/0x70
[  418.616254]  [<ffffffff81457f14>] compat_sys_sendmsg+0x14/0x20
[  418.616317]  [<ffffffff81458cbf>] compat_sys_socketcall+0x1cf/0x220
[  418.616380]  [<ffffffff815cf1e5>] ? page_fault+0x25/0x30
[  418.616443]  [<ffffffff8102ec60>] sysenter_dispatch+0x7/0x2e
[  418.616520] ---[ end trace c2d75997b525ef59 ]---


