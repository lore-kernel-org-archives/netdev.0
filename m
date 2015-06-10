From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH 3.10.y 2/2] ipv6: update ip6_rt_last_gc every time GC is run
Date: Wed, 10 Jun 2015 13:40:45 +0300
Message-ID: <20150610104045.3791.99481.stgit@buzz>
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

commit 49a18d86f66d33a20144ecb5a34bba0d1856b260 upstream

As pointed out by Eric Dumazet, net->ipv6.ip6_rt_last_gc should
hold the last time garbage collector was run so that we should
update it whenever fib6_run_gc() calls fib6_clean_all(), not only
if we got there from ip6_dst_gc().

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_fib.c |    6 +++++-
 net/ipv6/route.c   |    4 +---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0b5e9086322d..46458ee31939 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1650,6 +1650,8 @@ static DEFINE_SPINLOCK(fib6_gc_lock);
=20
 void fib6_run_gc(unsigned long expires, struct net *net, bool force)
 {
+	unsigned long now;
+
 	if (force) {
 		spin_lock_bh(&fib6_gc_lock);
 	} else if (!spin_trylock_bh(&fib6_gc_lock)) {
@@ -1662,10 +1664,12 @@ void fib6_run_gc(unsigned long expires, struct =
net *net, bool force)
 	gc_args.more =3D icmp6_dst_gc();
=20
 	fib6_clean_all(net, fib6_age, 0, NULL);
+	now =3D jiffies;
+	net->ipv6.ip6_rt_last_gc =3D now;
=20
 	if (gc_args.more)
 		mod_timer(&net->ipv6.ip6_fib_timer,
-			  round_jiffies(jiffies
+			  round_jiffies(now
 					+ net->ipv6.sysctl.ip6_rt_gc_interval));
 	else
 		del_timer(&net->ipv6.ip6_fib_timer);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bd83c90f970c..6ebefd46f718 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1334,7 +1334,6 @@ static void icmp6_clean_all(int (*func)(struct rt=
6_info *rt, void *arg),
=20
 static int ip6_dst_gc(struct dst_ops *ops)
 {
-	unsigned long now =3D jiffies;
 	struct net *net =3D container_of(ops, struct net, ipv6.ip6_dst_ops);
 	int rt_min_interval =3D net->ipv6.sysctl.ip6_rt_gc_min_interval;
 	int rt_max_size =3D net->ipv6.sysctl.ip6_rt_max_size;
@@ -1344,13 +1343,12 @@ static int ip6_dst_gc(struct dst_ops *ops)
 	int entries;
=20
 	entries =3D dst_entries_get_fast(ops);
-	if (time_after(rt_last_gc + rt_min_interval, now) &&
+	if (time_after(rt_last_gc + rt_min_interval, jiffies) &&
 	    entries <=3D rt_max_size)
 		goto out;
=20
 	net->ipv6.ip6_rt_gc_expire++;
 	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net, entries > rt_max_size);
-	net->ipv6.ip6_rt_last_gc =3D now;
 	entries =3D dst_entries_get_slow(ops);
 	if (entries < ops->gc_thresh)
 		net->ipv6.ip6_rt_gc_expire =3D rt_gc_timeout>>1;
