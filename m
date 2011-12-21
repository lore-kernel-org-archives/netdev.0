From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel-DOS error in arp mechanism =?UTF-8?Q?=E2=80=93?= no
 delete off incomplete arp adresses
Date: Wed, 21 Dec 2011 10:51:12 +0100
Message-ID: <1324461072.2728.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EEC5286.3070408@gmx.de>
	 <CAFLxGvxjLCyMCPXtpm7a7RaOL4A4=bhCLPKD=FVAc8xOdx_CsQ@mail.gmail.com>
	 <1324453467.2610.20.camel@edumazet-laptop>
	 <20111221.030727.1528369698756365464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard.weinberger@gmail.com, gladewitz@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:52244 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440Ab1LUJvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 04:51:16 -0500
In-Reply-To: <20111221.030727.1528369698756365464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 03:07 -0500, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 21 Dec 2011 08:44:27 +0100
>=20
> > David, I suggest we add back the garbage collector for current kern=
els,
> > we'll remove it when route cache really disappear ?
> >=20
> > I'll send a patch today.
>=20
> Yes, it's the best idea.
>=20
> We can actually remove it again as early as when when route neigh's
> are ref-less.

Here is the patch I successfully tested in the neighbour stress
situation. This is a stable candidate (2.6.39+)

Thanks !

[PATCH] ipv4: reintroduce route cache garbage collector

Commit 2c8cec5c10b (ipv4: Cache learned PMTU information in inetpeer)
removed IP route cache garbage collector a bit too soon, as this gc was
responsible for expired routes cleanup, releasing their neighbour
reference.

As pointed out by Robert Gladewitz, recent kernels can fill and exhaust
their neighbour cache.

Reintroduce the garbage collection, since we'll have to wait our
neighbour lookups become refcount-less to not depend on this stuff.

Reported-by: Robert Gladewitz <gladewitz@gmx.de>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |  107 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 107 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 46af623..252c512 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -120,6 +120,7 @@
=20
 static int ip_rt_max_size;
 static int ip_rt_gc_timeout __read_mostly	=3D RT_GC_TIMEOUT;
+static int ip_rt_gc_interval __read_mostly  =3D 60 * HZ;
 static int ip_rt_gc_min_interval __read_mostly	=3D HZ / 2;
 static int ip_rt_redirect_number __read_mostly	=3D 9;
 static int ip_rt_redirect_load __read_mostly	=3D HZ / 50;
@@ -133,6 +134,9 @@ static int ip_rt_min_advmss __read_mostly	=3D 256;
 static int rt_chain_length_max __read_mostly	=3D 20;
 static int redirect_genid;
=20
+static struct delayed_work expires_work;
+static unsigned long expires_ljiffies;
+
 /*
  *	Interface to generic destination cache.
  */
@@ -830,6 +834,97 @@ static int has_noalias(const struct rtable *head, =
const struct rtable *rth)
 	return ONE;
 }
=20
+static void rt_check_expire(void)
+{
+	static unsigned int rover;
+	unsigned int i =3D rover, goal;
+	struct rtable *rth;
+	struct rtable __rcu **rthp;
+	unsigned long samples =3D 0;
+	unsigned long sum =3D 0, sum2 =3D 0;
+	unsigned long delta;
+	u64 mult;
+
+	delta =3D jiffies - expires_ljiffies;
+	expires_ljiffies =3D jiffies;
+	mult =3D ((u64)delta) << rt_hash_log;
+	if (ip_rt_gc_timeout > 1)
+		do_div(mult, ip_rt_gc_timeout);
+	goal =3D (unsigned int)mult;
+	if (goal > rt_hash_mask)
+		goal =3D rt_hash_mask + 1;
+	for (; goal > 0; goal--) {
+		unsigned long tmo =3D ip_rt_gc_timeout;
+		unsigned long length;
+
+		i =3D (i + 1) & rt_hash_mask;
+		rthp =3D &rt_hash_table[i].chain;
+
+		if (need_resched())
+			cond_resched();
+
+		samples++;
+
+		if (rcu_dereference_raw(*rthp) =3D=3D NULL)
+			continue;
+		length =3D 0;
+		spin_lock_bh(rt_hash_lock_addr(i));
+		while ((rth =3D rcu_dereference_protected(*rthp,
+					lockdep_is_held(rt_hash_lock_addr(i)))) !=3D NULL) {
+			prefetch(rth->dst.rt_next);
+			if (rt_is_expired(rth)) {
+				*rthp =3D rth->dst.rt_next;
+				rt_free(rth);
+				continue;
+			}
+			if (rth->dst.expires) {
+				/* Entry is expired even if it is in use */
+				if (time_before_eq(jiffies, rth->dst.expires)) {
+nofree:
+					tmo >>=3D 1;
+					rthp =3D &rth->dst.rt_next;
+					/*
+					 * We only count entries on
+					 * a chain with equal hash inputs once
+					 * so that entries for different QOS
+					 * levels, and other non-hash input
+					 * attributes don't unfairly skew
+					 * the length computation
+					 */
+					length +=3D has_noalias(rt_hash_table[i].chain, rth);
+					continue;
+				}
+			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
+				goto nofree;
+
+			/* Cleanup aged off entries. */
+			*rthp =3D rth->dst.rt_next;
+			rt_free(rth);
+		}
+		spin_unlock_bh(rt_hash_lock_addr(i));
+		sum +=3D length;
+		sum2 +=3D length*length;
+	}
+	if (samples) {
+		unsigned long avg =3D sum / samples;
+		unsigned long sd =3D int_sqrt(sum2 / samples - avg*avg);
+		rt_chain_length_max =3D max_t(unsigned long,
+					ip_rt_gc_elasticity,
+					(avg + 4*sd) >> FRACT_BITS);
+	}
+	rover =3D i;
+}
+
+/*
+ * rt_worker_func() is run in process context.
+ * we call rt_check_expire() to scan part of the hash table
+ */
+static void rt_worker_func(struct work_struct *work)
+{
+	rt_check_expire();
+	schedule_delayed_work(&expires_work, ip_rt_gc_interval);
+}
+
 /*
  * Perturbation of rt_genid by a small quantity [1..256]
  * Using 8 bits of shuffling ensure we can call rt_cache_invalidate()
@@ -3179,6 +3274,13 @@ static ctl_table ipv4_route_table[] =3D {
 		.proc_handler	=3D proc_dointvec_jiffies,
 	},
 	{
+		.procname	=3D "gc_interval",
+		.data		=3D &ip_rt_gc_interval,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_jiffies,
+	},
+	{
 		.procname	=3D "redirect_load",
 		.data		=3D &ip_rt_redirect_load,
 		.maxlen		=3D sizeof(int),
@@ -3388,6 +3490,11 @@ int __init ip_rt_init(void)
 	devinet_init();
 	ip_fib_init();
=20
+	INIT_DELAYED_WORK_DEFERRABLE(&expires_work, rt_worker_func);
+	expires_ljiffies =3D jiffies;
+	schedule_delayed_work(&expires_work,
+		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
+
 	if (ip_rt_proc_init())
 		printk(KERN_ERR "Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
