From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] xfrm: Change initializations order in ipsec_pfkey_init()
Date: Fri, 29 Jan 2010 17:33:26 +0100
Message-ID: <1264782806.3184.42.camel@edumazet-laptop>
References: <20100129094822.GA8294@nb-core2.darkstar.lan>
	 <b6fcc0a1001290217l4edb0a0btbafa0c26b6f14ad5@mail.gmail.com>
	 <1264778549.3184.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753034Ab0A2Qdk@vger.kernel.org>
In-Reply-To: <1264778549.3184.28.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 janvier 2010 =C3=A0 16:22 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le vendredi 29 janvier 2010 =C3=A0 12:17 +0200, Alexey Dobriyan a =C3=
=A9crit :
> > On Fri, Jan 29, 2010 at 11:48 AM, Luca Tettamanti <kronos.it@gmail.=
com> wrote:
> > > with recent kernels I'm seeing this BUG - triggered by racoon - a=
t boot:
> > >
> > > NET: Registered protocol family 15
> > > ------------[ cut here ]------------
> > > kernel BUG at /home/kronos/src/linux-2.6.git/include/net/netns/ge=
neric.h:43!
> > > invalid opcode: 0000 [#1] PREEMPT SMP
> > > last sysfs file: /sys/kernel/uevent_seqnum
> > > CPU 1
> > > Pid: 1941, comm: racoon Not tainted 2.6.33-rc5-00271-gbe8cde8-dir=
ty #238 F3Sa      /F3Sa
> > > RIP: 0010:[<ffffffffa03035be>]  [<ffffffffa03035be>] pfkey_create=
+0x36/0x18b [af_key]
> >=20
> > Does it triggers after succesfull boot if you do
> >=20
> >     rmmod af_key; modprobe af_key
> >=20
> > a couple of times?
> >=20
> > Post .config, just in case.
>=20
> I am looking at ipsec_pfkey_init()
>=20
> We call sock_register(&pfkey_family_ops) before pfkey_net_id being
> initialized (by the call to register_pernet_subsys(&pfkey_net_ops);
>=20
> As soon as sock_register(&pfkey_family_ops) is done, another thread c=
an
> open a socket and call pfkey_create()  -> crash
>=20
> We should change order of initializations somehow
>=20

Something like this (compiled but not tested) patch ?

Should probably be sent to stable team...

[PATCH] xfrm: Change initializations order in ipsec_pfkey_init()

Before allowing other threads to create PF_KEY sockets, we must make
sure pfkey_net_id is properly initialized.

That means calling register_pernet_subsys(&pfkey_net_ops) before=20
sock_register(&pfkey_family_ops)

Reported-by: Luca Tettamanti <kronos.it@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/key/af_key.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 76fa6fe..e399ddf 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3807,21 +3807,24 @@ static int __init ipsec_pfkey_init(void)
 	if (err !=3D 0)
 		goto out;
=20
-	err =3D sock_register(&pfkey_family_ops);
-	if (err !=3D 0)
-		goto out_unregister_key_proto;
 	err =3D xfrm_register_km(&pfkeyv2_mgr);
 	if (err !=3D 0)
-		goto out_sock_unregister;
+		goto out_unregister_key_proto;
+
 	err =3D register_pernet_subsys(&pfkey_net_ops);
 	if (err !=3D 0)
 		goto out_xfrm_unregister_km;
+
+	err =3D sock_register(&pfkey_family_ops);
+	if (err !=3D 0)
+		goto out_unregister_pernet;
 out:
 	return err;
+
+out_unregister_pernet:
+	unregister_pernet_subsys(&pfkey_net_ops);
 out_xfrm_unregister_km:
 	xfrm_unregister_km(&pfkeyv2_mgr);
-out_sock_unregister:
-	sock_unregister(PF_KEY);
 out_unregister_key_proto:
 	proto_unregister(&key_proto);
 	goto out;
