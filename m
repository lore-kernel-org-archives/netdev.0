From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 1/3] ipv4: Lock-less per-packet multipath
Date: Wed, 17 Jun 2015 22:08:04 +0200
Message-ID: <1434571686-5149-2-git-send-email-pch@ordbogen.com>
References: <1434571686-5149-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434571686-5149-1-git-send-email-pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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
 include/net/ip_fib.h     |   6 +--
 net/ipv4/Kconfig         |   1 +
 net/ipv4/fib_semantics.c | 116 ++++++++++++++++++++++++++-------------=
--------
 3 files changed, 68 insertions(+), 55 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 54271ed..4be4f25 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -76,8 +76,8 @@ struct fib_nh {
 	unsigned int		nh_flags;
 	unsigned char		nh_scope;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	int			nh_weight;
-	int			nh_power;
+	int			nh_mp_weight;
+	atomic_t		nh_mp_upper_bound;
 #endif
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	__u32			nh_tclassid;
@@ -115,7 +115,7 @@ struct fib_info {
 #define fib_advmss fib_metrics[RTAX_ADVMSS-1]
 	int			fib_nhs;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	int			fib_power;
+	int			fib_mp_weight;
 #endif
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index d83071d..cb91f67 100644
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
index 28ec3c1..8c8df80 100644
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
@@ -57,7 +58,7 @@ static struct hlist_head fib_info_devhash[DEVINDEX_HA=
SHSIZE];
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
=20
-static DEFINE_SPINLOCK(fib_multipath_lock);
+static DEFINE_PER_CPU(u8, fib_mp_rr_counter);
=20
 #define for_nexthops(fi) {						\
 	int nhsel; const struct fib_nh *nh;				\
@@ -261,7 +262,7 @@ static inline int nh_comp(const struct fib_info *fi=
, const struct fib_info *ofi)
 		    nh->nh_gw  !=3D onh->nh_gw ||
 		    nh->nh_scope !=3D onh->nh_scope ||
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-		    nh->nh_weight !=3D onh->nh_weight ||
+		    nh->nh_mp_weight !=3D onh->nh_mp_weight ||
 #endif
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		    nh->nh_tclassid !=3D onh->nh_tclassid ||
@@ -449,6 +450,43 @@ static int fib_count_nexthops(struct rtnexthop *rt=
nh, int remaining)
 	return remaining > 0 ? 0 : nhs;
 }
=20
+static void fib_rebalance(struct fib_info *fi)
+{
+	int factor;
+	int total;
+	int w;
+
+	if (fi->fib_nhs < 2)
+		return;
+
+	total =3D 0;
+	for_nexthops(fi) {
+		if (!(nh->nh_flags & RTNH_F_DEAD))
+			total +=3D nh->nh_mp_weight;
+	} endfor_nexthops(fi);
+
+	if (likely(total !=3D 0)) {
+		factor =3D DIV_ROUND_UP(total, 8388608);
+		total /=3D factor;
+	} else {
+		factor =3D 1;
+	}
+
+	w =3D 0;
+	change_nexthops(fi) {
+		int upper_bound;
+
+		if (nexthop_nh->nh_flags & RTNH_F_DEAD) {
+			upper_bound =3D -1;
+		} else {
+			w +=3D nexthop_nh->nh_mp_weight / factor;
+			upper_bound =3D DIV_ROUND_CLOSEST(256 * w, total);
+		}
+
+		atomic_set(&nexthop_nh->nh_mp_upper_bound, upper_bound);
+	} endfor_nexthops(fi);
+}
+
 static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 		       int remaining, struct fib_config *cfg)
 {
@@ -461,7 +499,7 @@ static int fib_get_nhs(struct fib_info *fi, struct =
rtnexthop *rtnh,
 		nexthop_nh->nh_flags =3D
 			(cfg->fc_flags & ~0xFF) | rtnh->rtnh_flags;
 		nexthop_nh->nh_oif =3D rtnh->rtnh_ifindex;
-		nexthop_nh->nh_weight =3D rtnh->rtnh_hops + 1;
+		nexthop_nh->nh_mp_weight =3D rtnh->rtnh_hops + 1;
=20
 		attrlen =3D rtnh_attrlen(rtnh);
 		if (attrlen > 0) {
@@ -884,7 +922,7 @@ struct fib_info *fib_create_info(struct fib_config =
*cfg)
 			fi->fib_net->ipv4.fib_num_tclassid_users++;
 #endif
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-		nh->nh_weight =3D 1;
+		nh->nh_mp_weight =3D 1;
 #endif
 	}
=20
@@ -936,8 +974,15 @@ struct fib_info *fib_create_info(struct fib_config=
 *cfg)
=20
 	change_nexthops(fi) {
 		fib_info_update_nh_saddr(net, nexthop_nh);
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+		fi->fib_mp_weight +=3D nexthop_nh->nh_mp_weight;
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
@@ -1050,7 +1095,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid=
, u32 seq, int event,
 				goto nla_put_failure;
=20
 			rtnh->rtnh_flags =3D nh->nh_flags & 0xFF;
-			rtnh->rtnh_hops =3D nh->nh_weight - 1;
+			rtnh->rtnh_hops =3D nh->nh_mp_weight - 1;
 			rtnh->rtnh_ifindex =3D nh->nh_oif;
=20
 			if (nh->nh_gw &&
@@ -1130,12 +1175,6 @@ int fib_sync_down_dev(struct net_device *dev, in=
t force)
 			else if (nexthop_nh->nh_dev =3D=3D dev &&
 				 nexthop_nh->nh_scope !=3D scope) {
 				nexthop_nh->nh_flags |=3D RTNH_F_DEAD;
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-				spin_lock_bh(&fib_multipath_lock);
-				fi->fib_power -=3D nexthop_nh->nh_power;
-				nexthop_nh->nh_power =3D 0;
-				spin_unlock_bh(&fib_multipath_lock);
-#endif
 				dead++;
 			}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
@@ -1149,6 +1188,10 @@ int fib_sync_down_dev(struct net_device *dev, in=
t force)
 			fi->fib_flags |=3D RTNH_F_DEAD;
 			ret++;
 		}
+
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+		fib_rebalance(fi);
+#endif
 	}
=20
 	return ret;
@@ -1254,16 +1297,15 @@ int fib_sync_up(struct net_device *dev)
 			    !__in_dev_get_rtnl(dev))
 				continue;
 			alive++;
-			spin_lock_bh(&fib_multipath_lock);
-			nexthop_nh->nh_power =3D 0;
 			nexthop_nh->nh_flags &=3D ~RTNH_F_DEAD;
-			spin_unlock_bh(&fib_multipath_lock);
 		} endfor_nexthops(fi)
=20
 		if (alive > 0) {
 			fi->fib_flags &=3D ~RTNH_F_DEAD;
 			ret++;
 		}
+
+		fib_rebalance(fi);
 	}
=20
 	return ret;
@@ -1276,49 +1318,19 @@ int fib_sync_up(struct net_device *dev)
 void fib_select_multipath(struct fib_result *res)
 {
 	struct fib_info *fi =3D res->fi;
-	int w;
-
-	spin_lock_bh(&fib_multipath_lock);
-	if (fi->fib_power <=3D 0) {
-		int power =3D 0;
-		change_nexthops(fi) {
-			if (!(nexthop_nh->nh_flags & RTNH_F_DEAD)) {
-				power +=3D nexthop_nh->nh_weight;
-				nexthop_nh->nh_power =3D nexthop_nh->nh_weight;
-			}
-		} endfor_nexthops(fi);
-		fi->fib_power =3D power;
-		if (power <=3D 0) {
-			spin_unlock_bh(&fib_multipath_lock);
-			/* Race condition: route has just become dead. */
-			res->nh_sel =3D 0;
-			return;
-		}
-	}
+	u8 w;
=20
+	w =3D bitrev8(this_cpu_inc_return(fib_mp_rr_counter));
=20
-	/* w should be random number [0..fi->fib_power-1],
-	 * it is pretty bad approximation.
-	 */
-
-	w =3D jiffies % fi->fib_power;
+	for_nexthops(fi) {
+		if (w >=3D atomic_read(&nh->nh_mp_upper_bound))
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
+		res->nh_sel =3D nhsel;
+		return;
 	} endfor_nexthops(fi);
=20
-	/* Race condition: route has just become dead. */
+	/* Race condition: route has just become dead */
 	res->nh_sel =3D 0;
-	spin_unlock_bh(&fib_multipath_lock);
 }
 #endif
--=20
2.1.4
