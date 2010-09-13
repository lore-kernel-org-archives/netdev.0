From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: use rcu_barrier() in rollback_registered_many
Date: Tue, 14 Sep 2010 00:24:54 +0200
Message-ID: <1284416694.2627.89.camel@edumazet-laptop>
References: <4C8A3430.2070105@6wind.com>
	 <1284128679.24675.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Benjamin LaHaise <bcrl@kvack.org>
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50329 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab0IMWY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 18:24:59 -0400
Received: by wyf22 with SMTP id 22so6755873wyf.19
        for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 15:24:58 -0700 (PDT)
In-Reply-To: <1284128679.24675.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 septembre 2010 =C3=A0 16:24 +0200, Eric Dumazet a =C3=A9=
crit :=20
> Le vendredi 10 septembre 2010 =C3=A0 15:35 +0200, Nicolas Dichtel a =C3=
=A9crit :
> > Hi all,
> >=20
> > We got a scalability problem when we try to remove a lot of virtual=
 interfaces.=20
> > After analysis, we found that a refcnt on a device was released too=
 late.
> > Here is a proposal patch. If we are not missing something, the refc=
nt can be=20
> > release before call_rcu(). In IPv6, this is already the case.
> >=20
> > Comments are welcome.
> >=20
> >=20
> > Regards,
> > Nicolas
> > pi=C3=A8ce jointe diff=C3=A9rences entre fichiers
> > (0001-ipv4-release-dev-refcnt-early-when-destroying-inetd.patch)
> > From 6fe291ff56b1f94599dfaa57dfb0ed4c168b603f Mon Sep 17 00:00:00 2=
001
> > From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > Date: Fri, 10 Sep 2010 14:52:15 +0200
> > Subject: [PATCH] ipv4: release dev refcnt early when destroying ine=
tdev
> >=20
> > When a virtual device is removed, refcnt on dev is released
> > after rcu barrier, hence we fall always in the msleep(250)
> > of netdev_wait_allrefs(). This causes a long delay when
> > a lot of interfaces are removed.
> > Refcnt can be released before this rcu barrier, this allows
> > to accelerate the removing of virtual interfaces.
> >=20
> > Test of removing 50 ipip tunnel interfaces:
> >  Before the patch:
> >   real    0m12.804s
> >   user    0m0.020s
> >   sys     0m0.000s
> >=20
> >  After the patch:
> >   real    0m0.988s
> >   user    0m0.004s
> >   sys     0m0.016s
> >=20
> > Signed-off-by: Wang Xuefu <xuefu.wang@6wind.com>
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > ---
>=20
> This is a well known problem, (many patches were sent some months ago=
)
> but your patch is not the right solution.
>=20
> As long as the idev is not yet freed, it can be used and we need to
> access idev->dev
>=20
>=20

I believe I understood one problem.

In rollback_registered_many(), we call the inetdev_event() (and
inetdev_destroy() at line 4844 :

call_netdevice_notifiers(NETDEV_UNREGISTER, dev);

Then, we call synchronize_net() at line 4870

So by the time netdev_wait_allrefs() is called, we should have called
in_dev_finish_destroy()=20

But using synchronize_net() is a bit wrong here :=20

	"It waits until all pre-existing rcu readers have completed."

We have no guarantee all call_rcu() that we posted to dismantle the
device completed :

- If number of online cpus is 1, synchronize_net() is a no op
- If our thread migrates to another cpu, synchronize_net() can returns
  while old callbacks are not yet processed.

We should probably use rcu_barrier() instead, to wait for all
outstanding RCU callbacks to complete.

I also believe the order of netdevice notifiers is wrong (we dont set
priority), and that we should call fib_netdev_event() _before_
dst_dev_event(). This needs another patch.

Thanks

[PATCH] net: use rcu_barrier() in rollback_registered_many

netdev_wait_allrefs() waits that all references to a device vanishes.

It currently uses a _very_ pessimistic 250 ms delay between each probe.
Some users reported that no more than 4 devices can be dismantled per
second, this is a pretty serious problem for some setups.

Most of the time, a refcount is about to be released by an RCU callback=
,
that is still in flight because rollback_registered_many() uses a
synchronize_rcu() call instead of rcu_barrier(). Problem is visible if
number of online cpus is one, because synchronize_rcu() is then a no op=
=2E

time to remove 50 ipip tunnels on a UP machine :

before patch : real 11.910s
after patch : real 1.250s

Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Reported-by: Octavian Purdila <opurdila@ixiacom.com>
Reported-by: Benjamin LaHaise <bcrl@kvack.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fc2dc93..6de5a82 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4867,7 +4867,7 @@ static void rollback_registered_many(struct list_=
head *head)
 	dev =3D list_first_entry(head, struct net_device, unreg_list);
 	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
=20
-	synchronize_net();
+	rcu_barrier();
=20
 	list_for_each_entry(dev, head, unreg_list)
 		dev_put(dev);


