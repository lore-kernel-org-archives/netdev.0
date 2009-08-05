From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: mmotm 2009-08-04-14-22 uploaded
Date: Wed, 05 Aug 2009 09:14:15 +0200
Message-ID: <4A793147.1010600@gmail.com>
References: <200908042125.n74LP9qY018119@imap1.linux-foundation.org> <20090805063946.GA1934@darkstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Ingo Molnar <mingo@elte.hu>
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933657AbZHEHOw@vger.kernel.org>
In-Reply-To: <20090805063946.GA1934@darkstar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Young a =E9crit :
> Hi andrew,
>=20
> I see following lockdep warning with this release:
>=20
> [    0.474144] INFO: trying to register non-static key.
> [    0.474144] the code is fine but needs lockdep annotation.
> [    0.474144] turning off the locking correctness validator.
> [    0.474144] Pid: 1, comm: swapper Not tainted 2.6.31-rc5-mm1 #7
> [    0.474144] Call Trace:
> [    0.474144]  [<c1047f1e>] register_lock_class+0x58/0x241
> [    0.474144]  [<c1049ab1>] __lock_acquire+0xac/0xb73
> [    0.474144]  [<c1076eb5>] ? __alloc_pages_nodemask+0xe2/0x483
> [    0.474144]  [<c1048b64>] ? mark_lock+0x1e/0x1c7
> [    0.474144]  [<c1048b64>] ? mark_lock+0x1e/0x1c7
> [    0.474144]  [<c1048d50>] ? mark_held_locks+0x43/0x5b
> [    0.474144]  [<c10940a6>] ? kmem_cache_alloc+0xac/0x11b
> [    0.474144]  [<c104a615>] lock_acquire+0x9d/0xc0
> [    0.474144]  [<c12b8b96>] ? netif_addr_lock_bh+0xd/0xf
> [    0.474144]  [<c1330feb>] _spin_lock_bh+0x20/0x2f
> [    0.474144]  [<c12b8b96>] ? netif_addr_lock_bh+0xd/0xf
> [    0.474144]  [<c12b8b96>] netif_addr_lock_bh+0xd/0xf
> [    0.474144]  [<c12bc3c3>] alloc_netdev_mq+0xf9/0x1a5
> [    0.474144]  [<c121f016>] ? loopback_setup+0x0/0x74
> [    0.474144]  [<c1578d49>] loopback_net_init+0x20/0x5d
> [    0.474144]  [<c12b7907>] register_pernet_operations+0x13/0x15
> [    0.474144]  [<c12b7970>] register_pernet_device+0x1f/0x47
> [    0.474144]  [<c157ee8d>] net_dev_init+0xfe/0x14d
> [    0.474144]  [<c1001137>] do_one_initcall+0x4a/0x11a
> [    0.474144]  [<c157ed8f>] ? net_dev_init+0x0/0x14d
> [    0.474144]  [<c1067e00>] ? register_irq_proc+0x64/0xa8
> [    0.474144]  [<c1067e97>] ? init_irq_proc+0x53/0x60
> [    0.474144]  [<c1557535>] kernel_init+0x129/0x17a
> [    0.474144]  [<c155740c>] ? kernel_init+0x0/0x17a
> [    0.474144]  [<c1003d47>] kernel_thread_helper+0x7/0x10
>=20
> --

Hmm, it seems addr_list_lock is not initialized at the right place...

commit a6ac65db addded a netif_addr_lock_bh() in dev_unicast_init()

We initialize dev->addr_list_lock in register_netdevice(), we should
init it earlier, right after allocation and before dev_unicast_init()

But dev->type being 0, we probably cannot call netdev_set_addr_lockdep_=
class()
at this point...

David, what do you think ? Is it safe to call netdev_set_addr_lockdep_c=
lass()
in register_netdevice(), after lock being used one time in dev_unicast_=
init() ?

Thank you

[PATCH] net: Init dev->addr_list_lock in alloc_netdev_mq()

We initialize dev->addr_list_lock in register_netdevice(), we should
init it earlier, right after allocation and before dev_unicast_init()


Reported-by: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 43e61ba..e50356b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4728,7 +4728,6 @@ int register_netdevice(struct net_device *dev)
 	BUG_ON(dev->reg_state !=3D NETREG_UNINITIALIZED);
 	BUG_ON(!net);
=20
-	spin_lock_init(&dev->addr_list_lock);
 	netdev_set_addr_lockdep_class(dev);
 	netdev_init_queue_locks(dev);
=20
@@ -5106,6 +5105,7 @@ struct net_device *alloc_netdev_mq(int sizeof_pri=
v, const char *name,
 	dev =3D PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded =3D (char *)dev - (char *)p;
=20
+	spin_lock_init(&dev->addr_list_lock);
 	if (dev_addr_init(dev))
 		goto free_tx;
=20
