From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC,PATCH] mutex: mutex_is_owner() helper
Date: Tue, 10 Nov 2009 00:21:47 +0100
Message-ID: <4AF8A40B.10708@gmail.com>
References: <4AF19D06.3060401@gmail.com> <20091104154015.GA32567@elte.hu>	 <4AF1B7A7.6030902@gmail.com> <1257792987.4108.364.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46401 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbZKIXWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 18:22:30 -0500
In-Reply-To: <1257792987.4108.364.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra a =C3=A9crit :
> On Wed, 2009-11-04 at 18:19 +0100, Eric Dumazet wrote:
>> BTW, I was thinking of a mutex_yield() implementation, but could not
>> cook it without hard thinking, maybe you already have some nice
>> implementation ?
>=20
> Why? Yield sets off alarm bells, since 99.9%, and possibly more, of i=
ts
> uses are wrong.

If I remember well, I had problems doing "modprobe dummy numdummies=3D3=
0000",
because it creates 30000 netdevices, and thanks to hotplug starts 30000=
 udev
that all wait that my modprobe is finished... Nice to see load average =
going
so big by the way :)

I tried following patch without success, because rtnl_unlock()/rtnl_loc=
k()
is too fast (awaken process(es) ha(s/ve) no chance to get the lock, as =
we
take it immediately after releasing it)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 37dcfdc..3de1466 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -138,8 +138,11 @@ static int __init dummy_init_module(void)
 	rtnl_lock();
 	err =3D __rtnl_link_register(&dummy_link_ops);
=20
-	for (i =3D 0; i < numdummies && !err; i++)
+	for (i =3D 0; i < numdummies && !err; i++) {
 		err =3D dummy_init_one();
+		rtnl_unlock();
+		rtnl_lock();
+	}
 	if (err < 0)
 		__rtnl_link_unregister(&dummy_link_ops);
 	rtnl_unlock();



Then I added a msleep(1) between the unlock/lock and got beter results.



diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 37dcfdc..108c4fa 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -138,8 +138,12 @@ static int __init dummy_init_module(void)
 	rtnl_lock();
 	err =3D __rtnl_link_register(&dummy_link_ops);
=20
-	for (i =3D 0; i < numdummies && !err; i++)
+	for (i =3D 0; i < numdummies && !err; i++) {
 		err =3D dummy_init_one();
+		rtnl_unlock();
+		msleep(1);
+		rtnl_lock();
+	}
 	if (err < 0)
 		__rtnl_link_unregister(&dummy_link_ops);
 	rtnl_unlock();

But if hotplug is disabled, this force a useless msleep(1) * 30000 -> t=
his is bit slow

Yes, this code is stupid, but I use it to stress network stack
with insane number of devices, to spot scalability problems.


mutex_yield() could help in this situation.

mutex is said to be FIFO, but its not exactly true : A new comer can ta=
ke the mutex
even if 10000 threads are waiting on mutex...

I wont mention other problems, because mutex_{try}lock() has no timedwa=
it variant, and
funny code doing :

if (!rtnl_trylock())
	return restart_syscall();

Making 30000 processes running/fighting to get the mutex :(

