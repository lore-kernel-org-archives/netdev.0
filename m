From: Nick Jones <nick.jones@network-box.com>
Subject: [PATCH net-next v2] ipv6: Allocate unique metrics for icmp6 packets
 to prevent tainting dst metrics
Date: Thu, 15 Mar 2012 23:41:57 +0800
Message-ID: <4F620DC5.7080607@network-box.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from network-box.com ([175.45.17.220]:39332 "EHLO network-box.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030466Ab2COPmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 11:42:00 -0400
Received: from hqnickjones-macbook.local (unknown [10.8.2.241])
	by network-box.com (Postfix) with ESMTP id A35FD3EC90
	for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 23:41:57 +0800 (HKT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The generation of an icmp6 packet, targeted to a specific desination
address, will cause the shared metrics of the ip6_dst and inetpeer
of that address to be tainted with the hoplimit value 255.
All subsequent packets to the dst, will have this hoplimit value, and
if the destination is a router, not even advertisements specifying a
new hoplimit value will have any effect reverting this due to the way
ip6_dst_hoplimit works.

By allocating a unique metrics array for the icmp6 packet, the shared
metrics will not be tainted.  A ip6_dst flag is added to indicate that
the metrics for the dst don't belong to the peer, thus are not unique
and should be freed when the dst is destroyed.

Signed-off-by: Nick Jones <nick.jones@network-box.com>
---

v2: Take care of destroy side, that was neglected in the previous
    version, by setting a flag on the dst to indicate its metrics are
    unique, thus should be destroyed along with the dst.

 include/net/dst.h |    1 +
 net/ipv6/route.c  |   12 ++++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 344c8dd..ee7a781 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -54,6 +54,7 @@ struct dst_entry {
 #define DST_NOCACHE		0x0010
 #define DST_NOCOUNT		0x0020
 #define DST_NOPEER		0x0040
+#define DST_NOPEERMETRICS	0x0080

 	short			error;
 	short			obsolete;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 92be12b..f0a1839 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -278,7 +278,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct inet6_dev *idev = rt->rt6i_idev;
 	struct inet_peer *peer = rt->rt6i_peer;

-	if (!(rt->dst.flags & DST_HOST))
+	if (!(rt->dst.flags & DST_HOST) || (rt->dst.flags & DST_NOPEERMETRICS))
 		dst_destroy_metrics_generic(dst);

 	if (idev) {
@@ -1110,13 +1110,21 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 		}
 	}

-	rt->dst.flags |= DST_HOST;
+	rt->dst.flags |= (DST_HOST | DST_NOPEERMETRICS);
 	rt->dst.output  = ip6_output;
 	dst_set_neighbour(&rt->dst, neigh);
 	atomic_set(&rt->dst.__refcnt, 1);
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_idev     = idev;
+
+	u32 *metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
+	if (unlikely(!metrics)) {
+		in6_dev_put(idev);
+		dst_free(&rt->dst);
+		return ERR_CAST(-ENOMEM);
+	}
+	dst_init_metrics(&rt->dst, metrics, 0);
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);

 	spin_lock_bh(&icmp6_dst_lock);
-- 
1.7.1
