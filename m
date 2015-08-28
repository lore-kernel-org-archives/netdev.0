From: pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org
Subject: [PATCH v2 net-next 1/3] ipv4: Lock-less per-packet multipath
Date: Fri, 28 Aug 2015 22:00:48 +0200
Message-ID: <1440792050-2109-2-git-send-email-pch@ordbogen.com>
References: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
	Scott Feldman <sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1440792050-2109-1-git-send-email-pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Peter N=C3=B8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>

The current multipath attempted to be quasi random, but in most cases i=
t
behaved just like a round robin balancing. This patch refactors the
algorithm to be exactly that and in doing so, avoids the spin lock.

The new design paves the way for hash-based multipath, replacing the
modulo with thresholds, minimizing disruption in case of failing paths =
or
route replacements.

Signed-off-by: Peter N=C3=B8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
---
 include/net/ip_fib.h     |   4 +-
 net/ipv4/Kconfig         |   1 +
 net/ipv4/fib_semantics.c | 129 ++++++++++++++++++++++++++-------------=
--------
 3 files changed, 74 insertions(+), 60 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index a37d043..18a3c7f 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -79,7 +79,7 @@ struct fib_nh {
 	unsigned char		nh_scope;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			nh_weight;
-	int			nh_power;
+	atomic_t		nh_upper_bound;
 #endif
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	__u32			nh_tclassid;
@@ -118,7 +118,7 @@ struct fib_info {
 #define fib_advmss fib_metrics[RTAX_ADVMSS-1]
 	int			fib_nhs;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	int			fib_power;
+	int			fib_weight;
 #endif
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 416dfa0..23d8b2b 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -81,6 +81,7 @@ config IP_MULTIPLE_TABLES
 config IP_ROUTE_MULTIPATH
 	bool "IP: equal cost multipath"
 	depends on IP_ADVANCED_ROUTER
+	select BITREVERSE
 	help
 	  Normally, the routing tables specify a single action to be taken in
 	  a deterministic manner for a given packet. If you say Y here
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1b2d011..becb63f 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -15,6 +15,7 @@
=20
 #include <asm/uaccess.h>
 #include <linux/bitops.h>
+#include <linux/bitrev.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
@@ -58,7 +59,7 @@ static struct hlist_head fib_info_devhash[DEVINDEX_HA=
SHSIZE];
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
=20
-static DEFINE_SPINLOCK(fib_multipath_lock);
+static DEFINE_PER_CPU(int, fib_multipath_rr_counter);
=20
 #define for_nexthops(fi) {						\
 	int nhsel; const struct fib_nh *nh;				\
@@ -468,6 +469,52 @@ static int fib_count_nexthops(struct rtnexthop *rt=
nh, int remaining)
 	return remaining > 0 ? 0 : nhs;
 }
=20
+static void fib_rebalance(struct fib_info *fi)
+{
+	int total;
+	int w;
+	struct in_device *in_dev;
+
+	if (fi->fib_nhs < 2)
+		return;
+
+	total =3D 0;
+	for_nexthops(fi) {
+		if (nh->nh_flags & RTNH_F_DEAD)
+			continue;
+
+		in_dev =3D __in_dev_get_rcu(nh->nh_dev);
+
+		if (in_dev &&
+		    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
+		    nh->nh_flags & RTNH_F_LINKDOWN)
+			continue;
+
+		total +=3D nh->nh_weight;
+	} endfor_nexthops(fi);
+
+	w =3D 0;
+	change_nexthops(fi) {
+		int upper_bound;
+
+		in_dev =3D __in_dev_get_rcu(nexthop_nh->nh_dev);
+
+		if (nexthop_nh->nh_flags & RTNH_F_DEAD) {
+			upper_bound =3D -1;
+		} else if (in_dev &&
+			   IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
+			   nexthop_nh->nh_flags & RTNH_F_LINKDOWN) {
+			upper_bound =3D -1;
+		} else {
+			w +=3D nexthop_nh->nh_weight;
+			upper_bound =3D DIV_ROUND_CLOSEST(2147483648LL * w,
+							total) - 1;
+		}
+
+		atomic_set(&nexthop_nh->nh_upper_bound, upper_bound);
+	} endfor_nexthops(fi);
+}
+
 static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 		       int remaining, struct fib_config *cfg)
 {
@@ -1077,8 +1124,15 @@ struct fib_info *fib_create_info(struct fib_conf=
ig *cfg)
=20
 	change_nexthops(fi) {
 		fib_info_update_nh_saddr(net, nexthop_nh);
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+		fi->fib_weight +=3D nexthop_nh->nh_weight;
+#endif
 	} endfor_nexthops(fi)
=20
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	fib_rebalance(fi);
+#endif
+
 link_it:
 	ofi =3D fib_find_info(fi);
 	if (ofi) {
@@ -1300,12 +1354,6 @@ int fib_sync_down_dev(struct net_device *dev, un=
signed long event)
 					nexthop_nh->nh_flags |=3D RTNH_F_LINKDOWN;
 					break;
 				}
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-				spin_lock_bh(&fib_multipath_lock);
-				fi->fib_power -=3D nexthop_nh->nh_power;
-				nexthop_nh->nh_power =3D 0;
-				spin_unlock_bh(&fib_multipath_lock);
-#endif
 				dead++;
 			}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
@@ -1328,6 +1376,10 @@ int fib_sync_down_dev(struct net_device *dev, un=
signed long event)
 			}
 			ret++;
 		}
+
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+		fib_rebalance(fi);
+#endif
 	}
=20
 	return ret;
@@ -1450,20 +1502,17 @@ int fib_sync_up(struct net_device *dev, unsigne=
d int nh_flags)
 			    !__in_dev_get_rtnl(dev))
 				continue;
 			alive++;
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-			spin_lock_bh(&fib_multipath_lock);
-			nexthop_nh->nh_power =3D 0;
-			nexthop_nh->nh_flags &=3D ~nh_flags;
-			spin_unlock_bh(&fib_multipath_lock);
-#else
 			nexthop_nh->nh_flags &=3D ~nh_flags;
-#endif
 		} endfor_nexthops(fi)
=20
 		if (alive > 0) {
 			fi->fib_flags &=3D ~nh_flags;
 			ret++;
 		}
+
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+		fib_rebalance(fi);
+#endif
 	}
=20
 	return ret;
@@ -1478,55 +1527,19 @@ int fib_sync_up(struct net_device *dev, unsigne=
d int nh_flags)
 void fib_select_multipath(struct fib_result *res)
 {
 	struct fib_info *fi =3D res->fi;
-	struct in_device *in_dev;
-	int w;
-
-	spin_lock_bh(&fib_multipath_lock);
-	if (fi->fib_power <=3D 0) {
-		int power =3D 0;
-		change_nexthops(fi) {
-			in_dev =3D __in_dev_get_rcu(nexthop_nh->nh_dev);
-			if (nexthop_nh->nh_flags & RTNH_F_DEAD)
-				continue;
-			if (in_dev &&
-			    IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
-			    nexthop_nh->nh_flags & RTNH_F_LINKDOWN)
-				continue;
-			power +=3D nexthop_nh->nh_weight;
-			nexthop_nh->nh_power =3D nexthop_nh->nh_weight;
-		} endfor_nexthops(fi);
-		fi->fib_power =3D power;
-		if (power <=3D 0) {
-			spin_unlock_bh(&fib_multipath_lock);
-			/* Race condition: route has just become dead. */
-			res->nh_sel =3D 0;
-			return;
-		}
-	}
+	int h;
=20
+	h =3D bitrev32(this_cpu_inc_return(fib_multipath_rr_counter)) >> 1;
=20
-	/* w should be random number [0..fi->fib_power-1],
-	 * it is pretty bad approximation.
-	 */
-
-	w =3D jiffies % fi->fib_power;
+	for_nexthops(fi) {
+		if (h > atomic_read(&nh->nh_upper_bound))
+			continue;
=20
-	change_nexthops(fi) {
-		if (!(nexthop_nh->nh_flags & RTNH_F_DEAD) &&
-		    nexthop_nh->nh_power) {
-			w -=3D nexthop_nh->nh_power;
-			if (w <=3D 0) {
-				nexthop_nh->nh_power--;
-				fi->fib_power--;
-				res->nh_sel =3D nhsel;
-				spin_unlock_bh(&fib_multipath_lock);
-				return;
-			}
-		}
-	} endfor_nexthops(fi);
+		res->nh_sel =3D nhsel;
+		return;
+	} endfor_nexthops(fi)
=20
 	/* Race condition: route has just become dead. */
 	res->nh_sel =3D 0;
-	spin_unlock_bh(&fib_multipath_lock);
 }
 #endif
--=20
2.1.4
