From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
Subject: [PATCH v4 net-next 1/2] ipv4: L3 hash-based multipath
Date: Wed, 23 Sep 2015 21:49:36 +0200
Message-ID: <1443037777-25390-2-git-send-email-pch@ordbogen.com>
References: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:50862 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710AbbIWTuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 15:50:24 -0400
In-Reply-To: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replaces the per-packet multipath with a hash-based multipath using
source and destination address.

Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
---
 include/net/ip_fib.h     |   14 ++++-
 net/ipv4/fib_semantics.c |  140 +++++++++++++++++++++++++-------------=
--------
 net/ipv4/route.c         |   16 ++++--
 3 files changed, 98 insertions(+), 72 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index a37d043..c454203 100644
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
@@ -312,7 +312,15 @@ int ip_fib_check_default(__be32 gw, struct net_dev=
ice *dev);
 int fib_sync_down_dev(struct net_device *dev, unsigned long event);
 int fib_sync_down_addr(struct net *net, __be32 local);
 int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
-void fib_select_multipath(struct fib_result *res);
+
+extern u32 fib_multipath_secret __read_mostly;
+
+static inline int fib_multipath_hash(__be32 saddr, __be32 daddr)
+{
+	return jhash_2words(saddr, daddr, fib_multipath_secret) >> 1;
+}
+
+void fib_select_multipath(struct fib_result *res, int hash);
=20
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 064bd3c..0c49d2f 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -57,8 +57,7 @@ static unsigned int fib_info_cnt;
 static struct hlist_head fib_info_devhash[DEVINDEX_HASHSIZE];
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-
-static DEFINE_SPINLOCK(fib_multipath_lock);
+u32 fib_multipath_secret __read_mostly;
=20
 #define for_nexthops(fi) {						\
 	int nhsel; const struct fib_nh *nh;				\
@@ -532,7 +531,67 @@ errout:
 	return ret;
 }
=20
-#endif
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
+
+	net_get_random_once(&fib_multipath_secret,
+			    sizeof(fib_multipath_secret));
+}
+
+static inline void fib_add_weight(struct fib_info *fi,
+				  const struct fib_nh *nh)
+{
+	fi->fib_weight +=3D nh->nh_weight;
+}
+
+#else /* CONFIG_IP_ROUTE_MULTIPATH */
+
+#define fib_rebalance(fi) do { } while (0)
+#define fib_add_weight(fi, nh) do { } while (0)
+
+#endif /* CONFIG_IP_ROUTE_MULTIPATH */
=20
 static int fib_encap_match(struct net *net, u16 encap_type,
 			   struct nlattr *encap,
@@ -1094,8 +1153,11 @@ struct fib_info *fib_create_info(struct fib_conf=
ig *cfg)
=20
 	change_nexthops(fi) {
 		fib_info_update_nh_saddr(net, nexthop_nh);
+		fib_add_weight(fi, nexthop_nh);
 	} endfor_nexthops(fi)
=20
+	fib_rebalance(fi);
+
 link_it:
 	ofi =3D fib_find_info(fi);
 	if (ofi) {
@@ -1317,12 +1379,6 @@ int fib_sync_down_dev(struct net_device *dev, un=
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
@@ -1345,6 +1401,8 @@ int fib_sync_down_dev(struct net_device *dev, uns=
igned long event)
 			}
 			ret++;
 		}
+
+		fib_rebalance(fi);
 	}
=20
 	return ret;
@@ -1467,20 +1525,15 @@ int fib_sync_up(struct net_device *dev, unsigne=
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
+		fib_rebalance(fi);
 	}
=20
 	return ret;
@@ -1488,62 +1541,19 @@ int fib_sync_up(struct net_device *dev, unsigne=
d int nh_flags)
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
=20
-/*
- * The algorithm is suboptimal, but it provides really
- * fair weighted route distribution.
- */
-void fib_select_multipath(struct fib_result *res)
+void fib_select_multipath(struct fib_result *res, int hash)
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
-
=20
-	/* w should be random number [0..fi->fib_power-1],
-	 * it is pretty bad approximation.
-	 */
-
-	w =3D jiffies % fi->fib_power;
+	for_nexthops(fi) {
+		if (hash > atomic_read(&nh->nh_upper_bound))
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
 	/* Race condition: route has just become dead. */
 	res->nh_sel =3D 0;
-	spin_unlock_bh(&fib_multipath_lock);
 }
 #endif
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 80f7c5b..3dc83b6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1659,8 +1659,12 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res->fi && res->fi->fib_nhs > 1)
-		fib_select_multipath(res);
+	if (res->fi && res->fi->fib_nhs > 1) {
+		int h;
+
+		h =3D fib_multipath_hash(saddr, daddr);
+		fib_select_multipath(res, h);
+	}
 #endif
=20
 	/* create a routing cache entry */
@@ -2190,8 +2194,12 @@ struct rtable *__ip_route_output_key(struct net =
*net, struct flowi4 *fl4)
 	}
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0)
-		fib_select_multipath(&res);
+	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0) {
+		int h;
+
+		h =3D fib_multipath_hash(fl4->saddr, fl4->daddr);
+		fib_select_multipath(&res, h);
+	}
 	else
 #endif
 	if (!res.prefixlen &&
--=20
1.7.10.4
