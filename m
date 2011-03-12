From: David Miller <davem@davemloft.net>
Subject: [PATCH 25/25] decnet: Convert to use flowidn where applicable.
Date: Sat, 12 Mar 2011 15:32:36 -0800 (PST)
Message-ID: <20110312.153236.68133247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55989
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756282Ab1CLXb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:31:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B8A3824C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:32:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dn.h        |    6 +-
 include/net/dn_fib.h    |    8 +-
 include/net/dn_route.h  |    8 +-
 include/net/flow.h      |   12 ++-
 net/decnet/af_decnet.c  |   16 ++--
 net/decnet/dn_fib.c     |   23 ++--
 net/decnet/dn_nsp_out.c |   16 ++--
 net/decnet/dn_route.c   |  269 ++++++++++++++++++++++++-----------------------
 net/decnet/dn_rules.c   |   17 ++--
 net/decnet/dn_table.c   |    6 +-
 10 files changed, 196 insertions(+), 185 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index 558dc7f..298521e 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -192,10 +192,10 @@ static inline void dn_dn2eth(unsigned char *ethaddr, __le16 addr)
 	ethaddr[5] = (__u8)(a >> 8);
 }
 
-static inline void dn_sk_ports_copy(struct flowi *fl, struct dn_scp *scp)
+static inline void dn_sk_ports_copy(struct flowidn *fld, struct dn_scp *scp)
 {
-	fl->u.dn.uli.ports.sport = scp->addrloc;
-	fl->u.dn.uli.ports.dport = scp->addrrem;
+	fld->fld_sport = scp->addrloc;
+	fld->fld_dport = scp->addrrem;
 }
 
 extern unsigned dn_mss_from_pmtu(struct net_device *dev, int mtu);
diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index bbcde32..782ef7c 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -98,7 +98,7 @@ struct dn_fib_table {
 	int (*delete)(struct dn_fib_table *t, struct rtmsg *r,
 			struct dn_kern_rta *rta, struct nlmsghdr *n,
 			struct netlink_skb_parms *req);
-	int (*lookup)(struct dn_fib_table *t, const struct flowi *fl,
+	int (*lookup)(struct dn_fib_table *t, const struct flowidn *fld,
 			struct dn_fib_res *res);
 	int (*flush)(struct dn_fib_table *t);
 	int (*dump)(struct dn_fib_table *t, struct sk_buff *skb, struct netlink_callback *cb);
@@ -119,12 +119,12 @@ extern struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r,
 				struct dn_kern_rta *rta, 
 				const struct nlmsghdr *nlh, int *errp);
 extern int dn_fib_semantic_match(int type, struct dn_fib_info *fi, 
-			const struct flowi *fl,
+			const struct flowidn *fld,
 			struct dn_fib_res *res);
 extern void dn_fib_release_info(struct dn_fib_info *fi);
 extern __le16 dn_fib_get_attr16(struct rtattr *attr, int attrlen, int type);
 extern void dn_fib_flush(void);
-extern void dn_fib_select_multipath(const struct flowi *fl,
+extern void dn_fib_select_multipath(const struct flowidn *fld,
 					struct dn_fib_res *res);
 
 /*
@@ -141,7 +141,7 @@ extern void dn_fib_table_cleanup(void);
 extern void dn_fib_rules_init(void);
 extern void dn_fib_rules_cleanup(void);
 extern unsigned dnet_addr_type(__le16 addr);
-extern int dn_fib_lookup(struct flowi *fl, struct dn_fib_res *res);
+extern int dn_fib_lookup(struct flowidn *fld, struct dn_fib_res *res);
 
 extern int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index 1f59005..81712cf 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -16,7 +16,7 @@
 *******************************************************************************/
 
 extern struct sk_buff *dn_alloc_skb(struct sock *sk, int size, gfp_t pri);
-extern int dn_route_output_sock(struct dst_entry **pprt, struct flowi *, struct sock *sk, int flags);
+extern int dn_route_output_sock(struct dst_entry **pprt, struct flowidn *, struct sock *sk, int flags);
 extern int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb);
 extern void dn_rt_cache_flush(int delay);
 
@@ -67,7 +67,7 @@ extern void dn_rt_cache_flush(int delay);
 struct dn_route {
 	struct dst_entry dst;
 
-	struct flowi fl;
+	struct flowidn fld;
 
 	__le16 rt_saddr;
 	__le16 rt_daddr;
@@ -82,12 +82,12 @@ struct dn_route {
 
 static inline bool dn_is_input_route(struct dn_route *rt)
 {
-	return rt->fl.flowi_iif != 0;
+	return rt->fld.flowidn_iif != 0;
 }
 
 static inline bool dn_is_output_route(struct dn_route *rt)
 {
-	return rt->fl.flowi_iif == 0;
+	return rt->fld.flowidn_iif == 0;
 }
 
 extern void dn_route_init(void);
diff --git a/include/net/flow.h b/include/net/flow.h
index 172d76d..7fe5a0f 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -95,9 +95,17 @@ struct flowi6 {
 
 struct flowidn {
 	struct flowi_common	__fl_common;
+#define flowidn_oif		__fl_common.flowic_oif
+#define flowidn_iif		__fl_common.flowic_iif
+#define flowidn_mark		__fl_common.flowic_mark
+#define flowidn_scope		__fl_common.flowic_scope
+#define flowidn_proto		__fl_common.flowic_proto
+#define flowidn_flags		__fl_common.flowic_flags
 	__le16			daddr;
 	__le16			saddr;
 	union flowi_uli		uli;
+#define fld_sport		uli.ports.sport
+#define fld_dport		uli.ports.dport
 };
 
 struct flowi {
@@ -115,10 +123,6 @@ struct flowi {
 #define flowi_proto	u.__fl_common.flowic_proto
 #define flowi_flags	u.__fl_common.flowic_flags
 #define flowi_secid	u.__fl_common.flowic_secid
-#define fld_scope	flowi_scope
-
-#define fld_dst		u.dn.daddr
-#define fld_src		u.dn.saddr
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline struct flowi *flowi4_to_flowi(struct flowi4 *fl4)
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index aafd15a..ea3b6ee 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -908,7 +908,7 @@ static int __dn_connect(struct sock *sk, struct sockaddr_dn *addr, int addrlen,
 	struct socket *sock = sk->sk_socket;
 	struct dn_scp *scp = DN_SK(sk);
 	int err = -EISCONN;
-	struct flowi fl;
+	struct flowidn fld;
 
 	if (sock->state == SS_CONNECTED)
 		goto out;
@@ -947,13 +947,13 @@ static int __dn_connect(struct sock *sk, struct sockaddr_dn *addr, int addrlen,
 	memcpy(&scp->peer, addr, sizeof(struct sockaddr_dn));
 
 	err = -EHOSTUNREACH;
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_oif = sk->sk_bound_dev_if;
-	fl.fld_dst = dn_saddr2dn(&scp->peer);
-	fl.fld_src = dn_saddr2dn(&scp->addr);
-	dn_sk_ports_copy(&fl, scp);
-	fl.flowi_proto = DNPROTO_NSP;
-	if (dn_route_output_sock(&sk->sk_dst_cache, &fl, sk, flags) < 0)
+	memset(&fld, 0, sizeof(fld));
+	fld.flowidn_oif = sk->sk_bound_dev_if;
+	fld.daddr = dn_saddr2dn(&scp->peer);
+	fld.saddr = dn_saddr2dn(&scp->addr);
+	dn_sk_ports_copy(&fld, scp);
+	fld.flowidn_proto = DNPROTO_NSP;
+	if (dn_route_output_sock(&sk->sk_dst_cache, &fld, sk, flags) < 0)
 		goto out;
 	sk->sk_route_caps = sk->sk_dst_cache->dev->features;
 	sock->state = SS_CONNECTING;
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 4dfffa0..1c74ed3 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -201,7 +201,7 @@ static int dn_fib_check_nh(const struct rtmsg *r, struct dn_fib_info *fi, struct
 	int err;
 
 	if (nh->nh_gw) {
-		struct flowi fl;
+		struct flowidn fld;
 		struct dn_fib_res res;
 
 		if (nh->nh_flags&RTNH_F_ONLINK) {
@@ -221,15 +221,15 @@ static int dn_fib_check_nh(const struct rtmsg *r, struct dn_fib_info *fi, struct
 			return 0;
 		}
 
-		memset(&fl, 0, sizeof(fl));
-		fl.fld_dst = nh->nh_gw;
-		fl.flowi_oif = nh->nh_oif;
-		fl.fld_scope = r->rtm_scope + 1;
+		memset(&fld, 0, sizeof(fld));
+		fld.daddr = nh->nh_gw;
+		fld.flowidn_oif = nh->nh_oif;
+		fld.flowidn_scope = r->rtm_scope + 1;
 
-		if (fl.fld_scope < RT_SCOPE_LINK)
-			fl.fld_scope = RT_SCOPE_LINK;
+		if (fld.flowidn_scope < RT_SCOPE_LINK)
+			fld.flowidn_scope = RT_SCOPE_LINK;
 
-		if ((err = dn_fib_lookup(&fl, &res)) != 0)
+		if ((err = dn_fib_lookup(&fld, &res)) != 0)
 			return err;
 
 		err = -EINVAL;
@@ -404,7 +404,7 @@ failure:
 	return NULL;
 }
 
-int dn_fib_semantic_match(int type, struct dn_fib_info *fi, const struct flowi *fl, struct dn_fib_res *res)
+int dn_fib_semantic_match(int type, struct dn_fib_info *fi, const struct flowidn *fld, struct dn_fib_res *res)
 {
 	int err = dn_fib_props[type].error;
 
@@ -424,7 +424,8 @@ int dn_fib_semantic_match(int type, struct dn_fib_info *fi, const struct flowi *
 				for_nexthops(fi) {
 					if (nh->nh_flags & RTNH_F_DEAD)
 						continue;
-					if (!fl->flowi_oif || fl->flowi_oif == nh->nh_oif)
+					if (!fld->flowidn_oif ||
+					    fld->flowidn_oif == nh->nh_oif)
 						break;
 				}
 				if (nhsel < fi->fib_nhs) {
@@ -445,7 +446,7 @@ int dn_fib_semantic_match(int type, struct dn_fib_info *fi, const struct flowi *
 	return err;
 }
 
-void dn_fib_select_multipath(const struct flowi *fl, struct dn_fib_res *res)
+void dn_fib_select_multipath(const struct flowidn *fld, struct dn_fib_res *res)
 {
 	struct dn_fib_info *fi = res->fi;
 	int w;
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index b3d6674..bd78836 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -78,7 +78,7 @@ static void dn_nsp_send(struct sk_buff *skb)
 	struct sock *sk = skb->sk;
 	struct dn_scp *scp = DN_SK(sk);
 	struct dst_entry *dst;
-	struct flowi fl;
+	struct flowidn fld;
 
 	skb_reset_transport_header(skb);
 	scp->stamp = jiffies;
@@ -91,13 +91,13 @@ try_again:
 		return;
 	}
 
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_oif = sk->sk_bound_dev_if;
-	fl.fld_src = dn_saddr2dn(&scp->addr);
-	fl.fld_dst = dn_saddr2dn(&scp->peer);
-	dn_sk_ports_copy(&fl, scp);
-	fl.flowi_proto = DNPROTO_NSP;
-	if (dn_route_output_sock(&sk->sk_dst_cache, &fl, sk, 0) == 0) {
+	memset(&fld, 0, sizeof(fld));
+	fld.flowidn_oif = sk->sk_bound_dev_if;
+	fld.saddr = dn_saddr2dn(&scp->addr);
+	fld.daddr = dn_saddr2dn(&scp->peer);
+	dn_sk_ports_copy(&fld, scp);
+	fld.flowidn_proto = DNPROTO_NSP;
+	if (dn_route_output_sock(&sk->sk_dst_cache, &fld, sk, 0) == 0) {
 		dst = sk_dst_get(sk);
 		sk->sk_route_caps = dst->dev->features;
 		goto try_again;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index d74d34b..9f09d4f 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -282,14 +282,14 @@ static void dn_dst_link_failure(struct sk_buff *skb)
 {
 }
 
-static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
+static inline int compare_keys(struct flowidn *fl1, struct flowidn *fl2)
 {
-	return ((fl1->fld_dst ^ fl2->fld_dst) |
-		(fl1->fld_src ^ fl2->fld_src) |
-		(fl1->flowi_mark ^ fl2->flowi_mark) |
-		(fl1->fld_scope ^ fl2->fld_scope) |
-		(fl1->flowi_oif ^ fl2->flowi_oif) |
-		(fl1->flowi_iif ^ fl2->flowi_iif)) == 0;
+	return ((fl1->daddr ^ fl2->daddr) |
+		(fl1->saddr ^ fl2->saddr) |
+		(fl1->flowidn_mark ^ fl2->flowidn_mark) |
+		(fl1->flowidn_scope ^ fl2->flowidn_scope) |
+		(fl1->flowidn_oif ^ fl2->flowidn_oif) |
+		(fl1->flowidn_iif ^ fl2->flowidn_iif)) == 0;
 }
 
 static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route **rp)
@@ -303,7 +303,7 @@ static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route *
 	spin_lock_bh(&dn_rt_hash_table[hash].lock);
 	while ((rth = rcu_dereference_protected(*rthp,
 						lockdep_is_held(&dn_rt_hash_table[hash].lock))) != NULL) {
-		if (compare_keys(&rth->fl, &rt->fl)) {
+		if (compare_keys(&rth->fld, &rt->fld)) {
 			/* Put it first */
 			*rthp = rth->dst.dn_next;
 			rcu_assign_pointer(rth->dst.dn_next,
@@ -903,15 +903,15 @@ static inline __le16 dn_fib_rules_map_destination(__le16 daddr, struct dn_fib_re
 	return (daddr&~mask)|res->fi->fib_nh->nh_gw;
 }
 
-static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *oldflp, int try_hard)
+static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *oldflp, int try_hard)
 {
-	struct flowi fl = {
-		.fld_dst = oldflp->fld_dst,
-		.fld_src = oldflp->fld_src,
-		.fld_scope = RT_SCOPE_UNIVERSE,
-		.flowi_mark = oldflp->flowi_mark,
-		.flowi_iif = init_net.loopback_dev->ifindex,
-		.flowi_oif = oldflp->flowi_oif,
+	struct flowidn fld = {
+		.daddr = oldflp->daddr,
+		.saddr = oldflp->saddr,
+		.flowidn_scope = RT_SCOPE_UNIVERSE,
+		.flowidn_mark = oldflp->flowidn_mark,
+		.flowidn_iif = init_net.loopback_dev->ifindex,
+		.flowidn_oif = oldflp->flowidn_oif,
 	};
 	struct dn_route *rt = NULL;
 	struct net_device *dev_out = NULL, *dev;
@@ -926,13 +926,14 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *old
 	if (decnet_debug_level & 16)
 		printk(KERN_DEBUG
 		       "dn_route_output_slow: dst=%04x src=%04x mark=%d"
-		       " iif=%d oif=%d\n", le16_to_cpu(oldflp->fld_dst),
-		       le16_to_cpu(oldflp->fld_src),
-		       oldflp->flowi_mark, init_net.loopback_dev->ifindex, oldflp->flowi_oif);
+		       " iif=%d oif=%d\n", le16_to_cpu(oldflp->daddr),
+		       le16_to_cpu(oldflp->saddr),
+		       oldflp->flowidn_mark, init_net.loopback_dev->ifindex,
+		       oldflp->flowidn_oif);
 
 	/* If we have an output interface, verify its a DECnet device */
-	if (oldflp->flowi_oif) {
-		dev_out = dev_get_by_index(&init_net, oldflp->flowi_oif);
+	if (oldflp->flowidn_oif) {
+		dev_out = dev_get_by_index(&init_net, oldflp->flowidn_oif);
 		err = -ENODEV;
 		if (dev_out && dev_out->dn_ptr == NULL) {
 			dev_put(dev_out);
@@ -943,11 +944,11 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *old
 	}
 
 	/* If we have a source address, verify that its a local address */
-	if (oldflp->fld_src) {
+	if (oldflp->saddr) {
 		err = -EADDRNOTAVAIL;
 
 		if (dev_out) {
-			if (dn_dev_islocal(dev_out, oldflp->fld_src))
+			if (dn_dev_islocal(dev_out, oldflp->saddr))
 				goto source_ok;
 			dev_put(dev_out);
 			goto out;
@@ -956,11 +957,11 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *old
 		for_each_netdev_rcu(&init_net, dev) {
 			if (!dev->dn_ptr)
 				continue;
-			if (!dn_dev_islocal(dev, oldflp->fld_src))
+			if (!dn_dev_islocal(dev, oldflp->saddr))
 				continue;
 			if ((dev->flags & IFF_LOOPBACK) &&
-			    oldflp->fld_dst &&
-			    !dn_dev_islocal(dev, oldflp->fld_dst))
+			    oldflp->daddr &&
+			    !dn_dev_islocal(dev, oldflp->daddr))
 				continue;
 
 			dev_out = dev;
@@ -975,22 +976,22 @@ source_ok:
 	}
 
 	/* No destination? Assume its local */
-	if (!fl.fld_dst) {
-		fl.fld_dst = fl.fld_src;
+	if (!fld.daddr) {
+		fld.daddr = fld.saddr;
 
 		err = -EADDRNOTAVAIL;
 		if (dev_out)
 			dev_put(dev_out);
 		dev_out = init_net.loopback_dev;
 		dev_hold(dev_out);
-		if (!fl.fld_dst) {
-			fl.fld_dst =
-			fl.fld_src = dnet_select_source(dev_out, 0,
+		if (!fld.daddr) {
+			fld.daddr =
+			fld.saddr = dnet_select_source(dev_out, 0,
 						       RT_SCOPE_HOST);
-			if (!fl.fld_dst)
+			if (!fld.daddr)
 				goto out;
 		}
-		fl.flowi_oif = init_net.loopback_dev->ifindex;
+		fld.flowidn_oif = init_net.loopback_dev->ifindex;
 		res.type = RTN_LOCAL;
 		goto make_route;
 	}
@@ -999,8 +1000,8 @@ source_ok:
 		printk(KERN_DEBUG
 		       "dn_route_output_slow: initial checks complete."
 		       " dst=%o4x src=%04x oif=%d try_hard=%d\n",
-		       le16_to_cpu(fl.fld_dst), le16_to_cpu(fl.fld_src),
-		       fl.flowi_oif, try_hard);
+		       le16_to_cpu(fld.daddr), le16_to_cpu(fld.saddr),
+		       fld.flowidn_oif, try_hard);
 
 	/*
 	 * N.B. If the kernel is compiled without router support then
@@ -1008,7 +1009,7 @@ source_ok:
 	 * will always be executed.
 	 */
 	err = -ESRCH;
-	if (try_hard || (err = dn_fib_lookup(&fl, &res)) != 0) {
+	if (try_hard || (err = dn_fib_lookup(&fld, &res)) != 0) {
 		struct dn_dev *dn_db;
 		if (err != -ESRCH)
 			goto out;
@@ -1023,19 +1024,19 @@ source_ok:
 		 * here
 		 */
 		if (!try_hard) {
-			neigh = neigh_lookup_nodev(&dn_neigh_table, &init_net, &fl.fld_dst);
+			neigh = neigh_lookup_nodev(&dn_neigh_table, &init_net, &fld.daddr);
 			if (neigh) {
-				if ((oldflp->flowi_oif &&
-				    (neigh->dev->ifindex != oldflp->flowi_oif)) ||
-				    (oldflp->fld_src &&
+				if ((oldflp->flowidn_oif &&
+				    (neigh->dev->ifindex != oldflp->flowidn_oif)) ||
+				    (oldflp->saddr &&
 				    (!dn_dev_islocal(neigh->dev,
-						      oldflp->fld_src)))) {
+						     oldflp->saddr)))) {
 					neigh_release(neigh);
 					neigh = NULL;
 				} else {
 					if (dev_out)
 						dev_put(dev_out);
-					if (dn_dev_islocal(neigh->dev, fl.fld_dst)) {
+					if (dn_dev_islocal(neigh->dev, fld.daddr)) {
 						dev_out = init_net.loopback_dev;
 						res.type = RTN_LOCAL;
 					} else {
@@ -1055,7 +1056,7 @@ source_ok:
 			goto out;
 		dn_db = rcu_dereference_raw(dev_out->dn_ptr);
 		/* Possible improvement - check all devices for local addr */
-		if (dn_dev_islocal(dev_out, fl.fld_dst)) {
+		if (dn_dev_islocal(dev_out, fld.daddr)) {
 			dev_put(dev_out);
 			dev_out = init_net.loopback_dev;
 			dev_hold(dev_out);
@@ -1071,16 +1072,16 @@ select_source:
 		if (neigh)
 			gateway = ((struct dn_neigh *)neigh)->addr;
 		if (gateway == 0)
-			gateway = fl.fld_dst;
-		if (fl.fld_src == 0) {
-			fl.fld_src = dnet_select_source(dev_out, gateway,
-							 res.type == RTN_LOCAL ?
-							 RT_SCOPE_HOST :
-							 RT_SCOPE_LINK);
-			if (fl.fld_src == 0 && res.type != RTN_LOCAL)
+			gateway = fld.daddr;
+		if (fld.saddr == 0) {
+			fld.saddr = dnet_select_source(dev_out, gateway,
+						       res.type == RTN_LOCAL ?
+						       RT_SCOPE_HOST :
+						       RT_SCOPE_LINK);
+			if (fld.saddr == 0 && res.type != RTN_LOCAL)
 				goto e_addr;
 		}
-		fl.flowi_oif = dev_out->ifindex;
+		fld.flowidn_oif = dev_out->ifindex;
 		goto make_route;
 	}
 	free_res = 1;
@@ -1089,35 +1090,35 @@ select_source:
 		goto e_inval;
 
 	if (res.type == RTN_LOCAL) {
-		if (!fl.fld_src)
-			fl.fld_src = fl.fld_dst;
+		if (!fld.saddr)
+			fld.saddr = fld.daddr;
 		if (dev_out)
 			dev_put(dev_out);
 		dev_out = init_net.loopback_dev;
 		dev_hold(dev_out);
-		fl.flowi_oif = dev_out->ifindex;
+		fld.flowidn_oif = dev_out->ifindex;
 		if (res.fi)
 			dn_fib_info_put(res.fi);
 		res.fi = NULL;
 		goto make_route;
 	}
 
-	if (res.fi->fib_nhs > 1 && fl.flowi_oif == 0)
-		dn_fib_select_multipath(&fl, &res);
+	if (res.fi->fib_nhs > 1 && fld.flowidn_oif == 0)
+		dn_fib_select_multipath(&fld, &res);
 
 	/*
 	 * We could add some logic to deal with default routes here and
 	 * get rid of some of the special casing above.
 	 */
 
-	if (!fl.fld_src)
-		fl.fld_src = DN_FIB_RES_PREFSRC(res);
+	if (!fld.saddr)
+		fld.saddr = DN_FIB_RES_PREFSRC(res);
 
 	if (dev_out)
 		dev_put(dev_out);
 	dev_out = DN_FIB_RES_DEV(res);
 	dev_hold(dev_out);
-	fl.flowi_oif = dev_out->ifindex;
+	fld.flowidn_oif = dev_out->ifindex;
 	gateway = DN_FIB_RES_GW(res);
 
 make_route:
@@ -1131,19 +1132,19 @@ make_route:
 	atomic_set(&rt->dst.__refcnt, 1);
 	rt->dst.flags   = DST_HOST;
 
-	rt->fl.fld_src    = oldflp->fld_src;
-	rt->fl.fld_dst    = oldflp->fld_dst;
-	rt->fl.flowi_oif     = oldflp->flowi_oif;
-	rt->fl.flowi_iif     = 0;
-	rt->fl.flowi_mark    = oldflp->flowi_mark;
+	rt->fld.saddr        = oldflp->saddr;
+	rt->fld.daddr        = oldflp->daddr;
+	rt->fld.flowidn_oif  = oldflp->flowidn_oif;
+	rt->fld.flowidn_iif  = 0;
+	rt->fld.flowidn_mark = oldflp->flowidn_mark;
 
-	rt->rt_saddr      = fl.fld_src;
-	rt->rt_daddr      = fl.fld_dst;
-	rt->rt_gateway    = gateway ? gateway : fl.fld_dst;
-	rt->rt_local_src  = fl.fld_src;
+	rt->rt_saddr      = fld.saddr;
+	rt->rt_daddr      = fld.daddr;
+	rt->rt_gateway    = gateway ? gateway : fld.daddr;
+	rt->rt_local_src  = fld.saddr;
 
-	rt->rt_dst_map    = fl.fld_dst;
-	rt->rt_src_map    = fl.fld_src;
+	rt->rt_dst_map    = fld.daddr;
+	rt->rt_src_map    = fld.saddr;
 
 	rt->dst.dev = dev_out;
 	dev_hold(dev_out);
@@ -1161,7 +1162,7 @@ make_route:
 	if (err)
 		goto e_neighbour;
 
-	hash = dn_hash(rt->fl.fld_src, rt->fl.fld_dst);
+	hash = dn_hash(rt->fld.saddr, rt->fld.daddr);
 	dn_insert_route(rt, hash, (struct dn_route **)pprt);
 
 done:
@@ -1192,20 +1193,20 @@ e_neighbour:
 /*
  * N.B. The flags may be moved into the flowi at some future stage.
  */
-static int __dn_route_output_key(struct dst_entry **pprt, const struct flowi *flp, int flags)
+static int __dn_route_output_key(struct dst_entry **pprt, const struct flowidn *flp, int flags)
 {
-	unsigned hash = dn_hash(flp->fld_src, flp->fld_dst);
+	unsigned hash = dn_hash(flp->saddr, flp->daddr);
 	struct dn_route *rt = NULL;
 
 	if (!(flags & MSG_TRYHARD)) {
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference_bh(dn_rt_hash_table[hash].chain); rt;
 			rt = rcu_dereference_bh(rt->dst.dn_next)) {
-			if ((flp->fld_dst == rt->fl.fld_dst) &&
-			    (flp->fld_src == rt->fl.fld_src) &&
-			    (flp->flowi_mark == rt->fl.flowi_mark) &&
+			if ((flp->daddr == rt->fld.daddr) &&
+			    (flp->saddr == rt->fld.saddr) &&
+			    (flp->flowidn_mark == rt->fld.flowidn_mark) &&
 			    dn_is_output_route(rt) &&
-			    (rt->fl.flowi_oif == flp->flowi_oif)) {
+			    (rt->fld.flowidn_oif == flp->flowidn_oif)) {
 				dst_use(&rt->dst, jiffies);
 				rcu_read_unlock_bh();
 				*pprt = &rt->dst;
@@ -1218,13 +1219,14 @@ static int __dn_route_output_key(struct dst_entry **pprt, const struct flowi *fl
 	return dn_route_output_slow(pprt, flp, flags);
 }
 
-static int dn_route_output_key(struct dst_entry **pprt, struct flowi *flp, int flags)
+static int dn_route_output_key(struct dst_entry **pprt, struct flowidn *flp, int flags)
 {
 	int err;
 
 	err = __dn_route_output_key(pprt, flp, flags);
-	if (err == 0 && flp->flowi_proto) {
-		*pprt = xfrm_lookup(&init_net, *pprt, flp, NULL, 0);
+	if (err == 0 && flp->flowidn_proto) {
+		*pprt = xfrm_lookup(&init_net, *pprt,
+				    flowidn_to_flowi(flp), NULL, 0);
 		if (IS_ERR(*pprt)) {
 			err = PTR_ERR(*pprt);
 			*pprt = NULL;
@@ -1233,15 +1235,16 @@ static int dn_route_output_key(struct dst_entry **pprt, struct flowi *flp, int f
 	return err;
 }
 
-int dn_route_output_sock(struct dst_entry **pprt, struct flowi *fl, struct sock *sk, int flags)
+int dn_route_output_sock(struct dst_entry **pprt, struct flowidn *fl, struct sock *sk, int flags)
 {
 	int err;
 
 	err = __dn_route_output_key(pprt, fl, flags & MSG_TRYHARD);
-	if (err == 0 && fl->flowi_proto) {
+	if (err == 0 && fl->flowidn_proto) {
 		if (!(flags & MSG_DONTWAIT))
-			fl->flowi_flags |= FLOWI_FLAG_CAN_SLEEP;
-		*pprt = xfrm_lookup(&init_net, *pprt, fl, sk, 0);
+			fl->flowidn_flags |= FLOWI_FLAG_CAN_SLEEP;
+		*pprt = xfrm_lookup(&init_net, *pprt,
+				    flowidn_to_flowi(fl), sk, 0);
 		if (IS_ERR(*pprt)) {
 			err = PTR_ERR(*pprt);
 			*pprt = NULL;
@@ -1262,12 +1265,12 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	int flags = 0;
 	__le16 gateway = 0;
 	__le16 local_src = 0;
-	struct flowi fl = {
-		.fld_dst = cb->dst,
-		.fld_src = cb->src,
-		.fld_scope = RT_SCOPE_UNIVERSE,
-		.flowi_mark = skb->mark,
-		.flowi_iif = skb->dev->ifindex,
+	struct flowidn fld = {
+		.daddr = cb->dst,
+		.saddr = cb->src,
+		.flowidn_scope = RT_SCOPE_UNIVERSE,
+		.flowidn_mark = skb->mark,
+		.flowidn_iif = skb->dev->ifindex,
 	};
 	struct dn_fib_res res = { .fi = NULL, .type = RTN_UNREACHABLE };
 	int err = -EINVAL;
@@ -1279,7 +1282,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 		goto out;
 
 	/* Zero source addresses are not allowed */
-	if (fl.fld_src == 0)
+	if (fld.saddr == 0)
 		goto out;
 
 	/*
@@ -1293,7 +1296,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	if (dn_dev_islocal(in_dev, cb->src))
 		goto out;
 
-	err = dn_fib_lookup(&fl, &res);
+	err = dn_fib_lookup(&fld, &res);
 	if (err) {
 		if (err != -ESRCH)
 			goto out;
@@ -1305,7 +1308,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 
 		res.type = RTN_LOCAL;
 	} else {
-		__le16 src_map = fl.fld_src;
+		__le16 src_map = fld.saddr;
 		free_res = 1;
 
 		out_dev = DN_FIB_RES_DEV(res);
@@ -1318,22 +1321,22 @@ static int dn_route_input_slow(struct sk_buff *skb)
 		dev_hold(out_dev);
 
 		if (res.r)
-			src_map = fl.fld_src; /* no NAT support for now */
+			src_map = fld.saddr; /* no NAT support for now */
 
 		gateway = DN_FIB_RES_GW(res);
 		if (res.type == RTN_NAT) {
-			fl.fld_dst = dn_fib_rules_map_destination(fl.fld_dst, &res);
+			fld.daddr = dn_fib_rules_map_destination(fld.daddr, &res);
 			dn_fib_res_put(&res);
 			free_res = 0;
-			if (dn_fib_lookup(&fl, &res))
+			if (dn_fib_lookup(&fld, &res))
 				goto e_inval;
 			free_res = 1;
 			if (res.type != RTN_UNICAST)
 				goto e_inval;
 			flags |= RTCF_DNAT;
-			gateway = fl.fld_dst;
+			gateway = fld.daddr;
 		}
-		fl.fld_src = src_map;
+		fld.saddr = src_map;
 	}
 
 	switch(res.type) {
@@ -1347,8 +1350,8 @@ static int dn_route_input_slow(struct sk_buff *skb)
 		if (dn_db->parms.forwarding == 0)
 			goto e_inval;
 
-		if (res.fi->fib_nhs > 1 && fl.flowi_oif == 0)
-			dn_fib_select_multipath(&fl, &res);
+		if (res.fi->fib_nhs > 1 && fld.flowidn_oif == 0)
+			dn_fib_select_multipath(&fld, &res);
 
 		/*
 		 * Check for out_dev == in_dev. We use the RTCF_DOREDIRECT
@@ -1366,8 +1369,8 @@ static int dn_route_input_slow(struct sk_buff *skb)
 		break;
 	case RTN_LOCAL:
 		flags |= RTCF_LOCAL;
-		fl.fld_src = cb->dst;
-		fl.fld_dst = cb->src;
+		fld.saddr = cb->dst;
+		fld.daddr = cb->src;
 
 		/* Routing tables gave us a gateway */
 		if (gateway)
@@ -1400,21 +1403,21 @@ make_route:
 	if (rt == NULL)
 		goto e_nobufs;
 
-	rt->rt_saddr      = fl.fld_src;
-	rt->rt_daddr      = fl.fld_dst;
-	rt->rt_gateway    = fl.fld_dst;
+	rt->rt_saddr      = fld.saddr;
+	rt->rt_daddr      = fld.daddr;
+	rt->rt_gateway    = fld.daddr;
 	if (gateway)
 		rt->rt_gateway = gateway;
 	rt->rt_local_src  = local_src ? local_src : rt->rt_saddr;
 
-	rt->rt_dst_map    = fl.fld_dst;
-	rt->rt_src_map    = fl.fld_src;
+	rt->rt_dst_map    = fld.daddr;
+	rt->rt_src_map    = fld.saddr;
 
-	rt->fl.fld_src    = cb->src;
-	rt->fl.fld_dst    = cb->dst;
-	rt->fl.flowi_oif     = 0;
-	rt->fl.flowi_iif     = in_dev->ifindex;
-	rt->fl.flowi_mark    = fl.flowi_mark;
+	rt->fld.saddr        = cb->src;
+	rt->fld.daddr        = cb->dst;
+	rt->fld.flowidn_oif  = 0;
+	rt->fld.flowidn_iif  = in_dev->ifindex;
+	rt->fld.flowidn_mark = fld.flowidn_mark;
 
 	rt->dst.flags = DST_HOST;
 	rt->dst.neighbour = neigh;
@@ -1444,7 +1447,7 @@ make_route:
 	if (err)
 		goto e_neighbour;
 
-	hash = dn_hash(rt->fl.fld_src, rt->fl.fld_dst);
+	hash = dn_hash(rt->fld.saddr, rt->fld.daddr);
 	dn_insert_route(rt, hash, &rt);
 	skb_dst_set(skb, &rt->dst);
 
@@ -1484,11 +1487,11 @@ static int dn_route_input(struct sk_buff *skb)
 	rcu_read_lock();
 	for(rt = rcu_dereference(dn_rt_hash_table[hash].chain); rt != NULL;
 	    rt = rcu_dereference(rt->dst.dn_next)) {
-		if ((rt->fl.fld_src == cb->src) &&
-		    (rt->fl.fld_dst == cb->dst) &&
-		    (rt->fl.flowi_oif == 0) &&
-		    (rt->fl.flowi_mark == skb->mark) &&
-		    (rt->fl.flowi_iif == cb->iif)) {
+		if ((rt->fld.saddr == cb->src) &&
+		    (rt->fld.daddr == cb->dst) &&
+		    (rt->fld.flowidn_oif == 0) &&
+		    (rt->fld.flowidn_mark == skb->mark) &&
+		    (rt->fld.flowidn_iif == cb->iif)) {
 			dst_use(&rt->dst, jiffies);
 			rcu_read_unlock();
 			skb_dst_set(skb, (struct dst_entry *)rt);
@@ -1524,9 +1527,9 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	if (rt->rt_flags & RTCF_NOTIFY)
 		r->rtm_flags |= RTM_F_NOTIFY;
 	RTA_PUT(skb, RTA_DST, 2, &rt->rt_daddr);
-	if (rt->fl.fld_src) {
+	if (rt->fld.saddr) {
 		r->rtm_src_len = 16;
-		RTA_PUT(skb, RTA_SRC, 2, &rt->fl.fld_src);
+		RTA_PUT(skb, RTA_SRC, 2, &rt->fld.saddr);
 	}
 	if (rt->dst.dev)
 		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->dst.dev->ifindex);
@@ -1545,7 +1548,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 			       rt->dst.error) < 0)
 		goto rtattr_failure;
 	if (dn_is_input_route(rt))
-		RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fl.flowi_iif);
+		RTA_PUT(skb, RTA_IIF, sizeof(int), &rt->fld.flowidn_iif);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
@@ -1568,13 +1571,13 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	struct dn_skb_cb *cb;
 	int err;
 	struct sk_buff *skb;
-	struct flowi fl;
+	struct flowidn fld;
 
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	memset(&fl, 0, sizeof(fl));
-	fl.flowi_proto = DNPROTO_NSP;
+	memset(&fld, 0, sizeof(fld));
+	fld.flowidn_proto = DNPROTO_NSP;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
@@ -1583,15 +1586,15 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	cb = DN_SKB_CB(skb);
 
 	if (rta[RTA_SRC-1])
-		memcpy(&fl.fld_src, RTA_DATA(rta[RTA_SRC-1]), 2);
+		memcpy(&fld.saddr, RTA_DATA(rta[RTA_SRC-1]), 2);
 	if (rta[RTA_DST-1])
-		memcpy(&fl.fld_dst, RTA_DATA(rta[RTA_DST-1]), 2);
+		memcpy(&fld.daddr, RTA_DATA(rta[RTA_DST-1]), 2);
 	if (rta[RTA_IIF-1])
-		memcpy(&fl.flowi_iif, RTA_DATA(rta[RTA_IIF-1]), sizeof(int));
+		memcpy(&fld.flowidn_iif, RTA_DATA(rta[RTA_IIF-1]), sizeof(int));
 
-	if (fl.flowi_iif) {
+	if (fld.flowidn_iif) {
 		struct net_device *dev;
-		if ((dev = dev_get_by_index(&init_net, fl.flowi_iif)) == NULL) {
+		if ((dev = dev_get_by_index(&init_net, fld.flowidn_iif)) == NULL) {
 			kfree_skb(skb);
 			return -ENODEV;
 		}
@@ -1602,8 +1605,8 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		}
 		skb->protocol = htons(ETH_P_DNA_RT);
 		skb->dev = dev;
-		cb->src = fl.fld_src;
-		cb->dst = fl.fld_dst;
+		cb->src = fld.saddr;
+		cb->dst = fld.daddr;
 		local_bh_disable();
 		err = dn_route_input(skb);
 		local_bh_enable();
@@ -1615,8 +1618,8 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		int oif = 0;
 		if (rta[RTA_OIF - 1])
 			memcpy(&oif, RTA_DATA(rta[RTA_OIF - 1]), sizeof(int));
-		fl.flowi_oif = oif;
-		err = dn_route_output_key((struct dst_entry **)&rt, &fl, 0);
+		fld.flowidn_oif = oif;
+		err = dn_route_output_key((struct dst_entry **)&rt, &fld, 0);
 	}
 
 	if (skb->dev)
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 6eb91df..f0efb0c 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -49,14 +49,15 @@ struct dn_fib_rule
 };
 
 
-int dn_fib_lookup(struct flowi *flp, struct dn_fib_res *res)
+int dn_fib_lookup(struct flowidn *flp, struct dn_fib_res *res)
 {
 	struct fib_lookup_arg arg = {
 		.result = res,
 	};
 	int err;
 
-	err = fib_rules_lookup(dn_fib_rules_ops, flp, 0, &arg);
+	err = fib_rules_lookup(dn_fib_rules_ops,
+			       flowidn_to_flowi(flp), 0, &arg);
 	res->r = arg.rule;
 
 	return err;
@@ -65,6 +66,7 @@ int dn_fib_lookup(struct flowi *flp, struct dn_fib_res *res)
 static int dn_fib_rule_action(struct fib_rule *rule, struct flowi *flp,
 			      int flags, struct fib_lookup_arg *arg)
 {
+	struct flowidn *fld = &flp->u.dn;
 	int err = -EAGAIN;
 	struct dn_fib_table *tbl;
 
@@ -90,7 +92,7 @@ static int dn_fib_rule_action(struct fib_rule *rule, struct flowi *flp,
 	if (tbl == NULL)
 		goto errout;
 
-	err = tbl->lookup(tbl, flp, (struct dn_fib_res *)arg->result);
+	err = tbl->lookup(tbl, fld, (struct dn_fib_res *)arg->result);
 	if (err > 0)
 		err = -EAGAIN;
 errout:
@@ -104,8 +106,9 @@ static const struct nla_policy dn_fib_rule_policy[FRA_MAX+1] = {
 static int dn_fib_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 {
 	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
-	__le16 daddr = fl->fld_dst;
-	__le16 saddr = fl->fld_src;
+	struct flowidn *fld = &fl->u.dn;
+	__le16 daddr = fld->daddr;
+	__le16 saddr = fld->saddr;
 
 	if (((saddr ^ r->src) & r->srcmask) ||
 	    ((daddr ^ r->dst) & r->dstmask))
@@ -175,7 +178,7 @@ static int dn_fib_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
 
 unsigned dnet_addr_type(__le16 addr)
 {
-	struct flowi fl = { .fld_dst = addr };
+	struct flowidn fld = { .daddr = addr };
 	struct dn_fib_res res;
 	unsigned ret = RTN_UNICAST;
 	struct dn_fib_table *tb = dn_fib_get_table(RT_TABLE_LOCAL, 0);
@@ -183,7 +186,7 @@ unsigned dnet_addr_type(__le16 addr)
 	res.r = NULL;
 
 	if (tb) {
-		if (!tb->lookup(tb, &fl, &res)) {
+		if (!tb->lookup(tb, &fld, &res)) {
 			ret = res.type;
 			dn_fib_res_put(&res);
 		}
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index b66600b..99d8d3a 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -764,7 +764,7 @@ static int dn_fib_table_flush(struct dn_fib_table *tb)
 	return found;
 }
 
-static int dn_fib_table_lookup(struct dn_fib_table *tb, const struct flowi *flp, struct dn_fib_res *res)
+static int dn_fib_table_lookup(struct dn_fib_table *tb, const struct flowidn *flp, struct dn_fib_res *res)
 {
 	int err;
 	struct dn_zone *dz;
@@ -773,7 +773,7 @@ static int dn_fib_table_lookup(struct dn_fib_table *tb, const struct flowi *flp,
 	read_lock(&dn_fib_tables_lock);
 	for(dz = t->dh_zone_list; dz; dz = dz->dz_next) {
 		struct dn_fib_node *f;
-		dn_fib_key_t k = dz_key(flp->fld_dst, dz);
+		dn_fib_key_t k = dz_key(flp->daddr, dz);
 
 		for(f = dz_chain(k, dz); f; f = f->fn_next) {
 			if (!dn_key_eq(k, f->fn_key)) {
@@ -788,7 +788,7 @@ static int dn_fib_table_lookup(struct dn_fib_table *tb, const struct flowi *flp,
 			if (f->fn_state&DN_S_ZOMBIE)
 				continue;
 
-			if (f->fn_scope < flp->fld_scope)
+			if (f->fn_scope < flp->flowidn_scope)
 				continue;
 
 			err = dn_fib_semantic_match(f->fn_type, DN_FIB_INFO(f), flp, res);
-- 
1.7.4.1

