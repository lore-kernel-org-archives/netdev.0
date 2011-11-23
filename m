From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/5] net: Move mtu handling down to the protocol depended
 handlers
Date: Wed, 23 Nov 2011 13:13:31 +0100
Message-ID: <20111123121331.GC6348@secunet.com>
References: <20111123121213.GA6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53446 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754897Ab1KWMNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 07:13:36 -0500
Content-Disposition: inline
In-Reply-To: <20111123121213.GA6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We move all mtu handling from dst_mtu() down to the protocol
layer. So each protocol can implement the mtu handling in
a different manner.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      |    7 +------
 net/decnet/dn_route.c  |    4 +++-
 net/ipv4/route.c       |   11 +++++++++--
 net/ipv6/route.c       |   11 +++++++++--
 net/xfrm/xfrm_policy.c |    4 +++-
 5 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 666de31..6faec1a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -205,12 +205,7 @@ dst_feature(const struct dst_entry *dst, u32 feature)
 
 static inline u32 dst_mtu(const struct dst_entry *dst)
 {
-	u32 mtu = dst_metric_raw(dst, RTAX_MTU);
-
-	if (!mtu)
-		mtu = dst->ops->mtu(dst);
-
-	return mtu;
+	return dst->ops->mtu(dst);
 }
 
 /* RTT metrics are stored in milliseconds for user ABI, but used as jiffies */
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index db48679..94f4ec0 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -827,7 +827,9 @@ static unsigned int dn_dst_default_advmss(const struct dst_entry *dst)
 
 static unsigned int dn_dst_mtu(const struct dst_entry *dst)
 {
-	return dst->dev->mtu;
+	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
+
+	return mtu ? : dst->dev->mtu;
 }
 
 static struct neighbour *dn_dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f1ac3ef..11d1b20 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1816,7 +1816,12 @@ static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
 
 static unsigned int ipv4_mtu(const struct dst_entry *dst)
 {
-	unsigned int mtu = dst->dev->mtu;
+	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
+
+	if (mtu)
+		return mtu;
+
+	mtu = dst->dev->mtu;
 
 	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
 		const struct rtable *rt = (const struct rtable *) dst;
@@ -2757,7 +2762,9 @@ static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 coo
 
 static unsigned int ipv4_blackhole_mtu(const struct dst_entry *dst)
 {
-	return dst->dev->mtu;
+	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
+
+	return mtu ? : dst->dev->mtu;
 }
 
 static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 76645d7..3399dd3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -157,7 +157,9 @@ static struct dst_ops ip6_dst_ops_template = {
 
 static unsigned int ip6_blackhole_mtu(const struct dst_entry *dst)
 {
-	return dst->dev->mtu;
+	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
+
+	return mtu ? : dst->dev->mtu;
 }
 
 static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
@@ -1043,8 +1045,13 @@ static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 
 static unsigned int ip6_mtu(const struct dst_entry *dst)
 {
-	unsigned int mtu = IPV6_MIN_MTU;
 	struct inet6_dev *idev;
+	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
+
+	if (mtu)
+		return mtu;
+
+	mtu = IPV6_MIN_MTU;
 
 	rcu_read_lock();
 	idev = __in6_dev_get(dst->dev);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b8be51e..2118d64 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2384,7 +2384,9 @@ static unsigned int xfrm_default_advmss(const struct dst_entry *dst)
 
 static unsigned int xfrm_mtu(const struct dst_entry *dst)
 {
-	return dst_mtu(dst->path);
+	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
+
+	return mtu ? : dst_mtu(dst->path);
 }
 
 static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst, const void *daddr)
-- 
1.7.0.4
