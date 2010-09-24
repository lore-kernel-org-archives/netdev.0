From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: fix rcu use in ip_route_output_slow
Date: Fri, 24 Sep 2010 09:46:03 +0200
Message-ID: <1285314363.2503.12.camel@edumazet-laptop>
References: <20100922214438.GN2435@linux.vnet.ibm.com>
	 <1285196665.2380.54.camel@edumazet-laptop>
	 <20100922231221.GS2435@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43289 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395Ab0IXHqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 03:46:08 -0400
Received: by fxm3 with SMTP id 3so574391fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 00:46:06 -0700 (PDT)
In-Reply-To: <20100922231221.GS2435@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 septembre 2010 =C3=A0 16:12 -0700, Paul E. McKenney a =C3=
=A9crit :
> On Thu, Sep 23, 2010 at 01:04:25AM +0200, Eric Dumazet wrote:
> > Le mercredi 22 septembre 2010 =C3=A0 14:44 -0700, Paul E. McKenney =
a =C3=A9crit :
> > > > Date: Wed, 22 Sep 2010 13:52:28 -0700
> > > > From: Andrew Morton <akpm@linux-foundation.org>
> > > > To: "Paul E. McKenney" <paulmck@us.ibm.com>
> > > > Subject: rcu warning
> > > > X-Mailer: Sylpheed 2.4.8 (GTK+ 2.12.9; x86_64-pc-linux-gnu)
> > > >=20
> > > > [   56.803750]=20
> > > > [   56.803752] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > [   56.804082] [ INFO: suspicious rcu_dereference_check() usage=
=2E ]
> > > > [   56.804249] ------------------------------------------------=
---
> > > > [   56.804421] include/linux/inetdevice.h:219 invoked rcu_deref=
erence_check() without protection!
> > > > [   56.804708]=20
> > > > [   56.804709] other info that might help us debug this:
> > > > [   56.804710]=20
> > > > [   56.805183]=20
> > > > [   56.805184] rcu_scheduler_active =3D 1, debug_locks =3D 1
> > > > [   56.805501] 3 locks held by kworker/0:1/0:
> > > > [   56.805664]  #0:  (&in_dev->mr_ifc_timer){+.-...}, at: [<fff=
fffff81042466>] run_timer_softirq+0xfd/0x226
> > > > [   56.806126]  #1:  (&in_dev->mc_list_lock){++.-..}, at: [<fff=
fffff8133e81d>] igmp_ifc_timer_expire+0x2a/0x221
> > > > [   56.806588]  #2:  (&(&im->lock)->rlock){+.-...}, at: [<fffff=
fff8133e948>] igmp_ifc_timer_expire+0x155/0x221
> > > > [   56.807043]=20
> > > > [   56.807044] stack backtrace:
> > > > [   56.807364] Pid: 0, comm: kworker/0:1 Not tainted 2.6.36-rc5=
-mm1 #1
> > > > [   56.807561] Call Trace:
> > > > [   56.807723]  <IRQ>  [<ffffffff8105b88b>] lockdep_rcu_derefer=
ence+0x99/0xa2
> > > > [   56.807948]  [<ffffffff8130dc66>] __ip_route_output_key+0x34=
f/0xb19
> > > > [   56.808120]  [<ffffffff8130d94a>] ? __ip_route_output_key+0x=
33/0xb19
> > > > [   56.814367]  [<ffffffff8130e453>] ip_route_output_flow+0x23/=
0x1ee
> > > > [   56.814536]  [<ffffffff8130e62c>] ip_route_output_key+0xe/0x=
10
> > > > [   56.814704]  [<ffffffff8133e19d>] igmpv3_newpack+0x7f/0x1c2
> > > > [   56.814873]  [<ffffffff8133e30d>] add_grhead+0x2d/0x94
> > > > [   56.815039]  [<ffffffff8133e6c2>] add_grec+0x34e/0x38c
> > > > [   56.815206]  [<ffffffff8133e9a8>] igmp_ifc_timer_expire+0x1b=
5/0x221
> > > > [   56.815375]  [<ffffffff810424e8>] run_timer_softirq+0x17f/0x=
226
> > > > [   56.815547]  [<ffffffff81042466>] ? run_timer_softirq+0xfd/0=
x226
> > > > [   56.815715]  [<ffffffff8133e7f3>] ? igmp_ifc_timer_expire+0x=
0/0x221
> > > > [   56.815885]  [<ffffffff8103ca8f>] __do_softirq+0xa5/0x13a
> > > > [   56.816051]  [<ffffffff8100390c>] call_softirq+0x1c/0x28
> > > > [   56.816219]  [<ffffffff81004eba>] do_softirq+0x38/0x82
> > > > [   56.816385]  [<ffffffff8103c9e8>] irq_exit+0x47/0x49
> > > > [   56.816553]  [<ffffffff81019ce3>] smp_apic_timer_interrupt+0=
x88/0x96
> > > > [   56.816722]  [<ffffffff810033d3>] apic_timer_interrupt+0x13/=
0x20
> > > > [   56.816888]  <EOI>  [<ffffffff8138607a>] ? __atomic_notifier=
_call_chain+0x0/0x84
> > > > [   56.817215]  [<ffffffff81009a9b>] ? mwait_idle+0x65/0x71
> > > > [   56.817382]  [<ffffffff81009a91>] ? mwait_idle+0x5b/0x71
> > > > [   56.817549]  [<ffffffff810014ca>] cpu_idle+0x48/0x66
> > > > [   56.817716]  [<ffffffff8137b4da>] start_secondary+0x1b9/0x1b=
d
> > > > [   56.817883]  [<ffffffff8137b321>] ? start_secondary+0x0/0x1b=
d
> > >=20
> > > Hello, Eric,
> > >=20
> > > In linux/master, there is an rcu_read_lock_bh() in the call path,=
 but
> > > an rcu_dereference() instead of an rcu_dereference_bh().  Thought=
s?
> > >=20
> > > (I have asked Andrew what kernel this is against -- I don't see t=
he
> > > rcu_read_lock() that I would expect to see in the lockdep output.=
)
> > >=20
> > > 							Thanx, Paul
> >=20
> > This seems strange
> >=20
> > include/linux/inetdevice.h:219
> >=20
> > static inline struct in_device *__in_dev_get_rtnl(const struct net_=
device *dev)
> > {
> > 	return rcu_dereference_check(dev->ip_ptr, lockdep_rtnl_is_held());
> > }
> >=20
> > But I dont think RTNL can possibly be held at this point ???
> >=20
> > Oh wait, this is line 2582 in net/ipv4/route.c
> >=20
> > It seems buggy and proud of it :)
> >=20
> > 	/* RACE: Check return value of inet_select_addr instead. */=20
> > 	if (__in_dev_get_rtnl(dev_out) =3D=3D NULL) {
> >=20
> > This should be changed to=20
> >=20
> > 	if (rcu_dereference_raw(dev_out->ip_ptr) =3D=3D NULL) {
> >=20
> > No ?
>=20
> You beat me to it.  ;-)
>=20
> 							Thanx, Paul

OK, here is official submission to David then.

I based it against net-next-2.6.

Thanks

[PATCH net-next-2.6] net: fix rcu use in ip_route_output_slow

__in_dev_get_rtnl(dev_out) is called while RTNL is not held, thus
triggers a lockdep fault.

At this point, we only perform a raw test of dev_out->ip_ptr being NULL=
,
we dont need to make sure ip_ptr cant changed right after.

We can use rcu_dereference_raw() for this.

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e24d48d..8d08377 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2579,7 +2579,7 @@ static int ip_route_output_slow(struct net *net, =
struct rtable **rp,
 			goto out;
=20
 		/* RACE: Check return value of inet_select_addr instead. */
-		if (__in_dev_get_rtnl(dev_out) =3D=3D NULL) {
+		if (rcu_dereference_raw(dev_out->ip_ptr) =3D=3D NULL) {
 			dev_put(dev_out);
 			goto out;	/* Wrong error code */
 		}


