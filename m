From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39-rc6-mmotm0506 - another lockdep splat (networking this
 time)
Date: Tue, 10 May 2011 04:23:08 +0200
Message-ID: <1304994188.3050.17.camel@edumazet-laptop>
References: <6954.1304989523@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6954.1304989523@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 09 mai 2011 =C3=A0 21:05 -0400, Valdis.Kletnieks@vt.edu a =C3=A9=
crit :
> Seen during boot this afternoon:
>=20
> [   43.309549]=20
> [   43.309550] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [   43.309553] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   43.309555] ---------------------------------------------------
> [   43.309558] include/linux/inetdevice.h:226 invoked rcu_dereference=
_check() without protection!
> [   43.309560]=20
> [   43.309561] other info that might help us debug this:
> [   43.309561]=20
> [   43.309563]=20
> [   43.309564] rcu_scheduler_active =3D 1, debug_locks =3D 1
> [   43.309567] 2 locks held by ip/1193:
> [   43.309568]  #0:  (nlk->cb_mutex){+.+...}, at: [<ffffffff81426c1d>=
] netlink_dump+0x45/0x1d0
> [   43.309579]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8141b9b9>=
] rtnl_dump_ifinfo+0x0/0x156

strange : rcu_read_lock() is correctly held at this point

> [   43.309587]=20
> [   43.309587] stack backtrace:
> [   43.309590] Pid: 1193, comm: ip Not tainted 2.6.39-rc6-mmotm0506 #=
1
> [   43.309592] Call Trace:
> [   43.309599]  [<ffffffff81066b6e>] lockdep_rcu_dereference+0x9a/0xa=
2
> [   43.309604]  [<ffffffff81468d41>] __in_dev_get_rtnl+0x3c/0x47
> [   43.309607]  [<ffffffff81468ef0>] inet_fill_link_af+0x12/0x5b
> [   43.309611]  [<ffffffff8141b8fc>] rtnl_fill_ifinfo+0x665/0x710
> [   43.309616]  [<ffffffff8141ba76>] rtnl_dump_ifinfo+0xbd/0x156
> [   43.309620]  [<ffffffff81426c37>] netlink_dump+0x5f/0x1d0
> [   43.309624]  [<ffffffff81404e3e>] ? consume_skb+0x8a/0x8f
> [   43.309628]  [<ffffffff81426fc8>] netlink_recvmsg+0x1dd/0x31d
> [   43.309632]  [<ffffffff813ff21f>] ? rcu_read_unlock+0x21/0x23
> [   43.309636]  [<ffffffff813fab57>] sock_recvmsg+0xed/0x112
> [   43.309641]  [<ffffffff810d1ebf>] ? might_fault+0x4e/0x9e
> [   43.309645]  [<ffffffff81068816>] ? __lock_release+0x93/0x9c
> [   43.309649]  [<ffffffff810d1ebf>] ? might_fault+0x4e/0x9e
> [   43.309652]  [<ffffffff810d1f08>] ? might_fault+0x97/0x9e
> [   43.309656]  [<ffffffff814065f8>] ? copy_from_user+0x3c/0x44
> [   43.309660]  [<ffffffff813fc047>] __sys_recvmsg+0x16c/0x224
> [   43.309665]  [<ffffffff81059240>] ? up_read+0x23/0x27
> [   43.309669]  [<ffffffff81065165>] ? arch_local_irq_save+0x9/0xc
> [   43.309673]  [<ffffffff810f736b>] ? fcheck_files+0xb4/0xeb
> [   43.309676]  [<ffffffff810f79f3>] ? fget_light+0x35/0x96
> [   43.309680]  [<ffffffff813fdded>] sys_recvmsg+0x3d/0x5b
> [   43.309686]  [<ffffffff815705bb>] system_call_fastpath+0x16/0x1b
> [   44.437679] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
> [   44.488363] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
> [   44.494680] ADDRCONF(NETDEV_UP): eth0: link is not ready
>=20
>=20

Thanks for the report, I am taking a look how to fix this.

I am testing following patch, I'll provide an official one when
validated.



diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cd9ca08..6b1eb92 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1369,7 +1369,7 @@ errout:
=20
 static size_t inet_get_link_af_size(const struct net_device *dev)
 {
-	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
+	struct in_device *in_dev =3D __in_dev_get_rcu(dev);
=20
 	if (!in_dev)
 		return 0;
@@ -1379,7 +1379,7 @@ static size_t inet_get_link_af_size(const struct =
net_device *dev)
=20
 static int inet_fill_link_af(struct sk_buff *skb, const struct net_dev=
ice *dev)
 {
-	struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
+	struct in_device *in_dev =3D __in_dev_get_rcu(dev);
 	struct nlattr *nla;
 	int i;
=20
