From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: fix net_alloc_generic()
Date: Thu, 26 Jan 2012 14:57:02 -0800
Message-ID: <m1zkdacbsx.fsf@fess.ebiederm.org>
References: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
	<1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
	<1327574498.2500.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4F212E7E.2040801@parallels.com>
	<1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sjur =?utf-8?Q?Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	"levinsasha928\@gmail.com" <levinsasha928@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davej\@redhat.com" <davej@redhat.com>,
	"sjurbren\@gmail.com" <sjurbren@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	(Eric Dumazet's message of "Thu, 26 Jan 2012 11:51:48 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le jeudi 26 janvier 2012 =C3=A0 14:44 +0400, Pavel Emelyanov a =C3=A9=
crit :
>> > I believe the problem is in net_namespace infrastructure, not in C=
AIF.
>> >=20
>> > Could you test following patch instead ?
>> >=20
>> > [PATCH] netns: fix net_alloc_generic()
>> >=20
>> > When a new net namespace is created, we should attach to it a "str=
uct
>> > net_generic" with enough slots (even empty), or we can hit the fol=
lowing
>> > BUG_ON() :
>> >=20
>> > [  200.752016] kernel BUG at include/net/netns/generic.h:40!
>> > ...
>> > [  200.752016]  [<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x180
>> > [  200.752016]  [<ffffffff821cf0b0>] ? lockdep_rtnl_is_held+0x10/0=
x20
>> > [  200.752016]  [<ffffffff825c41be>] caif_device_notify+0x2e/0x530
>> > [  200.752016]  [<ffffffff810d61b7>] notifier_call_chain+0x67/0x11=
0
>> > [  200.752016]  [<ffffffff810d67c1>] raw_notifier_call_chain+0x11/=
0x20
>> > [  200.752016]  [<ffffffff821bae82>] call_netdevice_notifiers+0x32=
/0x60
>> > [  200.752016]  [<ffffffff821c2b26>] register_netdevice+0x196/0x30=
0
>> > [  200.752016]  [<ffffffff821c2ca9>] register_netdev+0x19/0x30
>> > [  200.752016]  [<ffffffff81c1c67a>] loopback_net_init+0x4a/0xa0
>> > [  200.752016]  [<ffffffff821b5e62>] ops_init+0x42/0x180
>> > [  200.752016]  [<ffffffff821b600b>] setup_net+0x6b/0x100
>> > [  200.752016]  [<ffffffff821b6466>] copy_net_ns+0x86/0x110
>> > [  200.752016]  [<ffffffff810d5789>] create_new_namespaces+0xd9/0x=
190
>> >=20
>> > net_alloc_generic() should take into account the maximum index int=
o the
>> > ptr array, as a subsystem might use net_generic() anytime.
>>=20
>> I'm not sure I understand it correctly, but subsystem can only use t=
he
>> net_generic() only (!) after the net_assign_generic() is performed.
>
> Yes, but here, loopback_net_init() calls register_netdev()
>
> So every subsystems _notify are called, even if subsystem _init_net()
> was not yet called.
>
> Its a chicken and egg problem.

It is not a chicken and egg problem.  It is a bug in caif.
caif is claiming to be a network device when it is acting as a subsytem=
=2E
That means it is being initialized too late.

Untested but this should trivially fix the problem, and a bunch
of others of the same ilk.

It is not safe to shutdown subsystems until all of the devices
are gone, otherwise there will be problems with packets in flight.

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 673728a..cf5bdd3 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -569,7 +569,7 @@ static int __init caif_device_init(void)
 {
 	int result;
=20
-	result =3D register_pernet_device(&caif_net_ops);
+	result =3D register_pernet_subsys(&caif_net_ops);
=20
 	if (result)
 		return result;
@@ -582,7 +582,7 @@ static int __init caif_device_init(void)
=20
 static void __exit caif_device_exit(void)
 {
-	unregister_pernet_device(&caif_net_ops);
+	unregister_pernet_subsys(&caif_net_ops);
 	unregister_netdevice_notifier(&caif_device_notifier);
 	dev_remove_pack(&caif_packet_type);
 }


Eric
