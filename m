From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netns: fix net_alloc_generic()
Date: Thu, 26 Jan 2012 11:51:48 +0100
Message-ID: <1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
		 <1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1327574498.2500.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F212E7E.2040801@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>,
	"levinsasha928@gmail.com" <levinsasha928@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davej@redhat.com" <davej@redhat.com>,
	"sjurbren@gmail.com" <sjurbren@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F212E7E.2040801@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 janvier 2012 =C3=A0 14:44 +0400, Pavel Emelyanov a =C3=A9cr=
it :
> > I believe the problem is in net_namespace infrastructure, not in CA=
IF.
> >=20
> > Could you test following patch instead ?
> >=20
> > [PATCH] netns: fix net_alloc_generic()
> >=20
> > When a new net namespace is created, we should attach to it a "stru=
ct
> > net_generic" with enough slots (even empty), or we can hit the foll=
owing
> > BUG_ON() :
> >=20
> > [  200.752016] kernel BUG at include/net/netns/generic.h:40!
> > ...
> > [  200.752016]  [<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x180
> > [  200.752016]  [<ffffffff821cf0b0>] ? lockdep_rtnl_is_held+0x10/0x=
20
> > [  200.752016]  [<ffffffff825c41be>] caif_device_notify+0x2e/0x530
> > [  200.752016]  [<ffffffff810d61b7>] notifier_call_chain+0x67/0x110
> > [  200.752016]  [<ffffffff810d67c1>] raw_notifier_call_chain+0x11/0=
x20
> > [  200.752016]  [<ffffffff821bae82>] call_netdevice_notifiers+0x32/=
0x60
> > [  200.752016]  [<ffffffff821c2b26>] register_netdevice+0x196/0x300
> > [  200.752016]  [<ffffffff821c2ca9>] register_netdev+0x19/0x30
> > [  200.752016]  [<ffffffff81c1c67a>] loopback_net_init+0x4a/0xa0
> > [  200.752016]  [<ffffffff821b5e62>] ops_init+0x42/0x180
> > [  200.752016]  [<ffffffff821b600b>] setup_net+0x6b/0x100
> > [  200.752016]  [<ffffffff821b6466>] copy_net_ns+0x86/0x110
> > [  200.752016]  [<ffffffff810d5789>] create_new_namespaces+0xd9/0x1=
90
> >=20
> > net_alloc_generic() should take into account the maximum index into=
 the
> > ptr array, as a subsystem might use net_generic() anytime.
>=20
> I'm not sure I understand it correctly, but subsystem can only use th=
e
> net_generic() only (!) after the net_assign_generic() is performed.

Yes, but here, loopback_net_init() calls register_netdev()

So every subsystems _notify are called, even if subsystem _init_net()
was not yet called.

Its a chicken and egg problem.
