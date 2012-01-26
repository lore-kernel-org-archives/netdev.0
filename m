From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netns: fix net_alloc_generic()
Date: Thu, 26 Jan 2012 11:41:38 +0100
Message-ID: <1327574498.2500.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
	 <1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: levinsasha928@gmail.com, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	davej@redhat.com, sjurbren@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 25 janvier 2012 =C3=A0 21:33 +0100, Sjur Br=C3=A6ndeland a =
=C3=A9crit :
> net_generic() calls BUG_ON() if called with uninitialized
> network name-space. Add check if net is initialized before
> calling net_generic(). This fixes the following oops:
>=20
> [  200.752016] kernel BUG at include/net/netns/generic.h:40!
> ...
> [  200.752016]  [<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x180
> [  200.752016]  [<ffffffff821cf0b0>] ? lockdep_rtnl_is_held+0x10/0x20
> [  200.752016]  [<ffffffff825c41be>] caif_device_notify+0x2e/0x530
> [  200.752016]  [<ffffffff810d61b7>] notifier_call_chain+0x67/0x110
> [  200.752016]  [<ffffffff810d67c1>] raw_notifier_call_chain+0x11/0x2=
0
> [  200.752016]  [<ffffffff821bae82>] call_netdevice_notifiers+0x32/0x=
60
> [  200.752016]  [<ffffffff821c2b26>] register_netdevice+0x196/0x300
> [  200.752016]  [<ffffffff821c2ca9>] register_netdev+0x19/0x30
> [  200.752016]  [<ffffffff81c1c67a>] loopback_net_init+0x4a/0xa0
> [  200.752016]  [<ffffffff821b5e62>] ops_init+0x42/0x180
> [  200.752016]  [<ffffffff821b600b>] setup_net+0x6b/0x100
> [  200.752016]  [<ffffffff821b6466>] copy_net_ns+0x86/0x110
> [  200.752016]  [<ffffffff810d5789>] create_new_namespaces+0xd9/0x190
>=20
> Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
> Tested-by: Sasha Levin <levinsasha928@gmail.com>
>=20
> ---
>=20
> Hi Sasha and Dave,
>=20
> [Sasha]
> >Works for me.
> Thank you Sasha for reporting this bug and testing my patch,
> I appreciate it.
>=20
> [Dave]
> >Please post all networking patches CC:'d
> Sorry, I missed the obvious.
> I'm resending the same patch as yesterday, this time to:netdev
> and with "Tested-by: Sasha". Please apply to net.
>=20
> Thanks,
> Sjur
>=20
>  net/caif/caif_dev.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
> index 673728a..6110ade 100644
> --- a/net/caif/caif_dev.c
> +++ b/net/caif/caif_dev.c
> @@ -371,6 +371,14 @@ static int caif_device_notify(struct notifier_bl=
ock *me, unsigned long what,
>  	struct cflayer *layer, *link_support;
>  	int head_room =3D 0;
>  	struct caif_device_entry_list *caifdevs;
> +	int len;
> +
> +	rcu_read_lock();
> +	len =3D rcu_dereference(dev_net(dev)->gen)->len;
> +	rcu_read_unlock();
> +
> +	if (caif_net_id =3D=3D 0 || caif_net_id > len)
> +		return 0;
> =20
>  	cfg =3D get_cfcnfg(dev_net(dev));
>  	caifdevs =3D caif_device_list(dev_net(dev));

I believe the problem is in net_namespace infrastructure, not in CAIF.

Could you test following patch instead ?

[PATCH] netns: fix net_alloc_generic()

When a new net namespace is created, we should attach to it a "struct
net_generic" with enough slots (even empty), or we can hit the followin=
g
BUG_ON() :

[  200.752016] kernel BUG at include/net/netns/generic.h:40!
=2E..
[  200.752016]  [<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x180
[  200.752016]  [<ffffffff821cf0b0>] ? lockdep_rtnl_is_held+0x10/0x20
[  200.752016]  [<ffffffff825c41be>] caif_device_notify+0x2e/0x530
[  200.752016]  [<ffffffff810d61b7>] notifier_call_chain+0x67/0x110
[  200.752016]  [<ffffffff810d67c1>] raw_notifier_call_chain+0x11/0x20
[  200.752016]  [<ffffffff821bae82>] call_netdevice_notifiers+0x32/0x60
[  200.752016]  [<ffffffff821c2b26>] register_netdevice+0x196/0x300
[  200.752016]  [<ffffffff821c2ca9>] register_netdev+0x19/0x30
[  200.752016]  [<ffffffff81c1c67a>] loopback_net_init+0x4a/0xa0
[  200.752016]  [<ffffffff821b5e62>] ops_init+0x42/0x180
[  200.752016]  [<ffffffff821b600b>] setup_net+0x6b/0x100
[  200.752016]  [<ffffffff821b6466>] copy_net_ns+0x86/0x110
[  200.752016]  [<ffffffff810d5789>] create_new_namespaces+0xd9/0x190

net_alloc_generic() should take into account the maximum index into the
ptr array, as a subsystem might use net_generic() anytime.

This also reduces number of reallocations in net_assign_generic()

Reported-by: Sasha Levin <levinsasha928@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Pavel Emelyanov <xemul@openvz.org>
---
 net/core/net_namespace.c |   31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index aefcd7a..0e950fd 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -30,6 +30,20 @@ EXPORT_SYMBOL(init_net);
=20
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
=20
+static unsigned int max_gen_ptrs =3D INITIAL_NET_GEN_PTRS;
+
+static struct net_generic *net_alloc_generic(void)
+{
+	struct net_generic *ng;
+	size_t generic_size =3D offsetof(struct net_generic, ptr[max_gen_ptrs=
]);
+
+	ng =3D kzalloc(generic_size, GFP_KERNEL);
+	if (ng)
+		ng->len =3D max_gen_ptrs;
+
+	return ng;
+}
+
 static int net_assign_generic(struct net *net, int id, void *data)
 {
 	struct net_generic *ng, *old_ng;
@@ -43,8 +57,7 @@ static int net_assign_generic(struct net *net, int id=
, void *data)
 	if (old_ng->len >=3D id)
 		goto assign;
=20
-	ng =3D kzalloc(sizeof(struct net_generic) +
-			id * sizeof(void *), GFP_KERNEL);
+	ng =3D net_alloc_generic();
 	if (ng =3D=3D NULL)
 		return -ENOMEM;
=20
@@ -59,7 +72,6 @@ static int net_assign_generic(struct net *net, int id=
, void *data)
 	 * the old copy for kfree after a grace period.
 	 */
=20
-	ng->len =3D id;
 	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void*));
=20
 	rcu_assign_pointer(net->gen, ng);
@@ -161,18 +173,6 @@ out_undo:
 	goto out;
 }
=20
-static struct net_generic *net_alloc_generic(void)
-{
-	struct net_generic *ng;
-	size_t generic_size =3D sizeof(struct net_generic) +
-		INITIAL_NET_GEN_PTRS * sizeof(void *);
-
-	ng =3D kzalloc(generic_size, GFP_KERNEL);
-	if (ng)
-		ng->len =3D INITIAL_NET_GEN_PTRS;
-
-	return ng;
-}
=20
 #ifdef CONFIG_NET_NS
 static struct kmem_cache *net_cachep;
@@ -483,6 +483,7 @@ again:
 			}
 			return error;
 		}
+		max_gen_ptrs =3D max_t(unsigned int, max_gen_ptrs, *ops->id);
 	}
 	error =3D __register_pernet_operations(list, ops);
 	if (error) {
