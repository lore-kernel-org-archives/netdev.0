From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net/dst: dst_dev_event() called after other notifiers
Date: Tue, 09 Nov 2010 20:37:55 +0100
Message-ID: <1289331475.2774.41.camel@edumazet-laptop>
References: <4CD893C6.2030803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61769 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325Ab0KITiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 14:38:02 -0500
Received: by yxt3 with SMTP id 3so212198yxt.19
        for <netdev@vger.kernel.org>; Tue, 09 Nov 2010 11:38:01 -0800 (PST)
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

OK, I confirm I already knew how to correct the problem.

http://www.spinics.net/lists/netdev/msg140729.html

quote :

I also believe the order of netdevice notifiers is wrong (we dont set
priority), and that we should call fib_netdev_event() _before_
dst_dev_event(). This needs another patch.


Thanks

[PATCH] net/dst: dst_dev_event() called after other notifiers

=46ollowup of commit ef885afbf8a37689 (net: use rcu_barrier() in
rollback_registered_many)

dst_dev_event() scans a garbage dst list that might be feeded by variou=
s
network notifiers at device dismantle time.

Its important to call dst_dev_event() after other notifiers, or we migh=
t
enter the infamous msleep(250) in netdev_wait_allrefs(), and wait one
second before calling again call_netdevice_notifiers(NETDEV_UNREGISTER,
dev) to properly remove last device references.

Use priority -10 to let dst_dev_notifier be called after other network
notifiers (they have the default 0 priority)

Reported-by: Ben Greear <greearb@candelatech.com>
Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Reported-by: Octavian Purdila <opurdila@ixiacom.com>
Reported-by: Benjamin LaHaise <bcrl@kvack.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dst.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/net/core/dst.c b/net/core/dst.c
index 8abe628..e234bf1 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -370,6 +370,7 @@ static int dst_dev_event(struct notifier_block *thi=
s, unsigned long event,
=20
 static struct notifier_block dst_dev_notifier =3D {
 	.notifier_call  =3D dst_dev_event,
+	.priority =3D -10, /* must be called after other network notifiers */
 };
=20
 void __init dst_init(void)


