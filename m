From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH 3.10.y 1/2] ipv6: prevent fib6_run_gc() contention
Date: Wed, 10 Jun 2015 13:40:43 +0300
Message-ID: <20150610104043.3791.92411.stgit@buzz>
References: <20150610103926.3791.22866.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150610103926.3791.22866.stgit@buzz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Michal Kube=C4=8Dek <mkubecek@suse.cz>

commit 2ac3ac8f86f2fe065d746d9a9abaca867adec577 upstream

On a high-traffic router with many processors and many IPv6 dst
entries, soft lockup in fib6_run_gc() can occur when number of
entries reaches gc_thresh.

This happens because fib6_run_gc() uses fib6_gc_lock to allow
only one thread to run the garbage collector but ip6_dst_gc()
doesn't update net->ipv6.ip6_rt_last_gc until fib6_run_gc()
returns. On a system with many entries, this can take some time
so that in the meantime, other threads pass the tests in
ip6_dst_gc() (ip6_rt_last_gc is still not updated) and wait for
the lock. They then have to run the garbage collector one after
another which blocks them for quite long.

Resolve this by replacing special value ~0UL of expire parameter
to fib6_run_gc() by explicit "force" parameter to choose between
spin_lock_bh() and spin_trylock_bh() and call fib6_run_gc() with
force=3Dfalse if gc_thresh is reached but not max_size.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_fib.h |    2 +-
 net/ipv6/ip6_fib.c    |   19 ++++++++-----------
 net/ipv6/ndisc.c      |    4 ++--
 net/ipv6/route.c      |    4 ++--
 4 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 665e0cee59bd..5e661a979694 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -301,7 +301,7 @@ extern void			inet6_rt_notify(int event, struct rt6=
_info *rt,
 						struct nl_info *info);
=20
 extern void			fib6_run_gc(unsigned long expires,
-					    struct net *net);
+					    struct net *net, bool force);
=20
 extern void			fib6_gc_cleanup(void);
=20
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ceeb9458bb60..0b5e9086322d 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1648,19 +1648,16 @@ static int fib6_age(struct rt6_info *rt, void *=
arg)
=20
 static DEFINE_SPINLOCK(fib6_gc_lock);
=20
-void fib6_run_gc(unsigned long expires, struct net *net)
+void fib6_run_gc(unsigned long expires, struct net *net, bool force)
 {
-	if (expires !=3D ~0UL) {
+	if (force) {
 		spin_lock_bh(&fib6_gc_lock);
-		gc_args.timeout =3D expires ? (int)expires :
-			net->ipv6.sysctl.ip6_rt_gc_interval;
-	} else {
-		if (!spin_trylock_bh(&fib6_gc_lock)) {
-			mod_timer(&net->ipv6.ip6_fib_timer, jiffies + HZ);
-			return;
-		}
-		gc_args.timeout =3D net->ipv6.sysctl.ip6_rt_gc_interval;
+	} else if (!spin_trylock_bh(&fib6_gc_lock)) {
+		mod_timer(&net->ipv6.ip6_fib_timer, jiffies + HZ);
+		return;
 	}
+	gc_args.timeout =3D expires ? (int)expires :
+			  net->ipv6.sysctl.ip6_rt_gc_interval;
=20
 	gc_args.more =3D icmp6_dst_gc();
=20
@@ -1677,7 +1674,7 @@ void fib6_run_gc(unsigned long expires, struct ne=
t *net)
=20
 static void fib6_gc_timer_cb(unsigned long arg)
 {
-	fib6_run_gc(0, (struct net *)arg);
+	fib6_run_gc(0, (struct net *)arg, true);
 }
=20
 static int __net_init fib6_net_init(struct net *net)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 05f361338c2e..deedf7ddbc6e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1584,7 +1584,7 @@ static int ndisc_netdev_event(struct notifier_blo=
ck *this, unsigned long event,
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&nd_tbl, dev);
-		fib6_run_gc(~0UL, net);
+		fib6_run_gc(0, net, false);
 		idev =3D in6_dev_get(dev);
 		if (!idev)
 			break;
@@ -1594,7 +1594,7 @@ static int ndisc_netdev_event(struct notifier_blo=
ck *this, unsigned long event,
 		break;
 	case NETDEV_DOWN:
 		neigh_ifdown(&nd_tbl, dev);
-		fib6_run_gc(~0UL, net);
+		fib6_run_gc(0, net, false);
 		break;
 	case NETDEV_NOTIFY_PEERS:
 		ndisc_send_unsol_na(dev);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d94d224f7e68..bd83c90f970c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1349,7 +1349,7 @@ static int ip6_dst_gc(struct dst_ops *ops)
 		goto out;
=20
 	net->ipv6.ip6_rt_gc_expire++;
-	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net);
+	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net, entries > rt_max_size);
 	net->ipv6.ip6_rt_last_gc =3D now;
 	entries =3D dst_entries_get_slow(ops);
 	if (entries < ops->gc_thresh)
@@ -2849,7 +2849,7 @@ int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int=
 write,
 	net =3D (struct net *)ctl->extra1;
 	delay =3D net->ipv6.sysctl.flush_delay;
 	proc_dointvec(ctl, write, buffer, lenp, ppos);
-	fib6_run_gc(delay <=3D 0 ? ~0UL : (unsigned long)delay, net);
+	fib6_run_gc(delay <=3D 0 ? 0 : (unsigned long)delay, net, delay > 0);
 	return 0;
 }
=20
