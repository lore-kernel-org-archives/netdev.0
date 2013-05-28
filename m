From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next 3/3] ipv4: use separate genid for next hop exceptions
Date: Tue, 28 May 2013 09:46:33 +0300
Message-ID: <1369723593-5307-3-git-send-email-timo.teras@iki.fi>
References: <20130527.233844.2081972819091665848.davem@davemloft.net>
 <1369723593-5307-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:36037 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702Ab3E1Go6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:44:58 -0400
Received: by mail-ee0-f49.google.com with SMTP id d17so4410233eek.22
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 23:44:57 -0700 (PDT)
In-Reply-To: <1369723593-5307-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 13d82bf5 (ipv4: Fix flushing of cached routing informations)
added the support to flush learned pmtu information.

However, using rt_genid is quite heavy as it is bumped on route
add/change and multicast events amongst other places. These can
happen quote often, especially if using dynamic routing protocols.

While this is ok with routes (as they are just recreated locally),
the pmtu information is learned from remote systems and the icmp
notification can come with long delays. It is worthy to have separate
genid to avoid excessive pmtu resets.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 include/net/ip_fib.h        |  1 +
 include/net/net_namespace.h | 11 +++++++++++
 net/ipv4/route.c            | 12 ++++++++++--
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e49db91..44424e9 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -51,6 +51,7 @@ struct rtable;
=20
 struct fib_nh_exception {
 	struct fib_nh_exception __rcu	*fnhe_next;
+	int				fnhe_genid;
 	__be32				fnhe_daddr;
 	u32				fnhe_pmtu;
 	__be32				fnhe_gw;
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index b176978..495bc57 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -118,6 +118,7 @@ struct net {
 	struct netns_ipvs	*ipvs;
 	struct sock		*diag_nlsk;
 	atomic_t		rt_genid;
+	atomic_t		fnhe_genid;
 };
=20
 /*
@@ -340,4 +341,14 @@ static inline void rt_genid_bump(struct net *net)
 	atomic_inc(&net->rt_genid);
 }
=20
+static inline int fnhe_genid(struct net *net)
+{
+	return atomic_read(&net->fnhe_genid);
+}
+
+static inline void fnhe_genid_bump(struct net *net)
+{
+	atomic_inc(&net->fnhe_genid);
+}
+
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a4082be..403e283 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -658,6 +658,7 @@ static void update_or_create_fnhe(struct fib_nh *nh=
, __be32 daddr, __be32 gw,
 			fnhe->fnhe_next =3D hash->chain;
 			rcu_assign_pointer(hash->chain, fnhe);
 		}
+		fnhe->fnhe_genid =3D fnhe_genid(dev_net(nh->nh_dev));
 		fnhe->fnhe_daddr =3D daddr;
 		fnhe->fnhe_gw =3D gw;
 		fnhe->fnhe_pmtu =3D pmtu;
@@ -1236,8 +1237,11 @@ static bool rt_bind_exception(struct rtable *rt,=
 struct fib_nh_exception *fnhe,
 	spin_lock_bh(&fnhe_lock);
=20
 	if (daddr =3D=3D fnhe->fnhe_daddr) {
+		int genid =3D fnhe_genid(dev_net(rt->dst.dev));
 		struct rtable *orig =3D rcu_dereference(fnhe->fnhe_rth);
-		if (orig && rt_is_expired(orig)) {
+
+		if (fnhe->fnhe_genid !=3D genid) {
+			fnhe->fnhe_genid =3D genid;
 			fnhe->fnhe_gw =3D 0;
 			fnhe->fnhe_pmtu =3D 0;
 			fnhe->fnhe_expires =3D 0;
@@ -2443,8 +2447,11 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *=
__ctl, int write,
 					void __user *buffer,
 					size_t *lenp, loff_t *ppos)
 {
+	struct net *net =3D (struct net *)__ctl->extra1;
+
 	if (write) {
-		rt_cache_flush((struct net *)__ctl->extra1);
+		rt_cache_flush(net);
+		fnhe_genid_bump(net);
 		return 0;
 	}
=20
@@ -2619,6 +2626,7 @@ static __net_initdata struct pernet_operations sy=
sctl_route_ops =3D {
 static __net_init int rt_genid_init(struct net *net)
 {
 	atomic_set(&net->rt_genid, 0);
+	atomic_set(&net->fnhe_genid, 0);
 	get_random_bytes(&net->ipv4.dev_addr_genid,
 			 sizeof(net->ipv4.dev_addr_genid));
 	return 0;
--=20
1.8.2.3
