From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] net: proper locking in skb_update_prio()
Date: Wed, 30 Nov 2011 00:24:38 +0100
Message-ID: <1322609078.2596.53.camel@edumazet-laptop>
References: <alpine.WNT.2.00.1111291027320.1036@TSI>
	 <1322589661.2596.2.camel@edumazet-laptop>
	 <1322599437.2596.10.camel@edumazet-laptop>
	 <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com>
	 <1322599991.2596.11.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291359290.1036@TSI>
	 <1322601444.2596.21.camel@edumazet-laptop>
	 <1322602283.2596.25.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291527360.228@TSI>
	 <1322606542.2596.43.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291600220.228@TSI>
	 <1322608261.2596.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322608261.2596.48.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mercredi 30 novembre 2011 =C3=A0 00:11 +0100, Eric Dumazet a =C3=A9c=
rit :

> Some changes are needed now rcu_read_lock_bh() doesnt imply
> rcu_read_lock().
>=20
> For example, recently added skb_update_prio() is buggy, since it uses
> rcu_dereference() while its caller, dev_queue_xmit() called
> rcu_read_lock_bh()
>=20
>=20

[PATCH net-next] net: proper locking in skb_update_prio()

We must use rcu_read_lock() in skb_update_prio(), since dev_queue_xmit(=
)
uses rcu_read_lock_bh()

[   15.441620] [ INFO: suspicious RCU usage. ]
[   15.441622] -------------------------------
[   15.441624] net/core/dev.c:2476 suspicious rcu_dereference_check() u=
sage!
[   15.441625]=20
[   15.441626] other info that might help us debug this:
[   15.441626]=20
[   15.441628]=20
[   15.441628] rcu_scheduler_active =3D 1, debug_locks =3D 1
[   15.441630] 1 lock held by arping/4373:
[   15.441632]  #0:  (rcu_read_lock_bh){......}, at: [<c13049b0>] dev_q=
ueue_xmit+0x0/0xa90
[   15.441641]=20
[   15.441642] stack backtrace:
[   15.441644] Pid: 4373, comm: arping Not tainted 3.2.0-rc2-12727-gd69=
d22a-dirty #1261
[   15.441646] Call Trace:
[   15.441651]  [<c13bae42>] ? printk+0x18/0x1e
[   15.441656]  [<c107f1aa>] lockdep_rcu_suspicious+0xaa/0xc0
[   15.441658]  [<c130507a>] dev_queue_xmit+0x6ca/0xa90
[   15.441661]  [<c13049b0>] ? dev_hard_start_xmit+0x810/0x810
[   15.441665]  [<c131cb84>] ? eth_header+0x24/0xb0
[   15.441668]  [<c139c4f8>] packet_sendmsg+0x978/0x9d0
[   15.441671]  [<c131cb60>] ? eth_rebuild_header+0x80/0x80
[   15.441675]  [<c12f3173>] ? sock_update_netprioidx+0xa3/0x110
[   15.441678]  [<c12ee93e>] sock_sendmsg+0xce/0x100
[   15.441682]  [<c10e354e>] ? might_fault+0x2e/0x80
[   15.441684]  [<c10e354e>] ? might_fault+0x2e/0x80
[   15.441687]  [<c10e3594>] ? might_fault+0x74/0x80
[   15.441691]  [<c11ce55f>] ? _copy_from_user+0x3f/0x60
[   15.441693]  [<c12f03e2>] sys_sendto+0xb2/0xe0
[   15.441696]  [<c108288b>] ? lock_release_non_nested+0x8b/0x300
[   15.441699]  [<c10e354e>] ? might_fault+0x2e/0x80
[   15.441701]  [<c10e354e>] ? might_fault+0x2e/0x80
[   15.441704]  [<c12f0cd0>] sys_socketcall+0x1a0/0x280
[   15.441708]  [<c13bfc90>] sysenter_do_call+0x12/0x36

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 net/core/dev.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 91a5991..903fd9d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2473,10 +2473,15 @@ static inline int __dev_xmit_skb(struct sk_buff=
 *skb, struct Qdisc *q,
 #if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 static void skb_update_prio(struct sk_buff *skb)
 {
-	struct netprio_map *map =3D rcu_dereference(skb->dev->priomap);
+	if (!skb->priority && skb->sk) {
+		struct netprio_map *map;
=20
-	if ((!skb->priority) && (skb->sk) && map)
-		skb->priority =3D map->priomap[skb->sk->sk_cgrp_prioidx];
+		rcu_read_lock();
+		map =3D rcu_dereference(skb->dev->priomap);
+		if (map)
+			skb->priority =3D map->priomap[skb->sk->sk_cgrp_prioidx];
+		rcu_read_unlock();
+	}
 }
 #else
 #define skb_update_prio(skb)


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
