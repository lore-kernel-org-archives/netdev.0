From: Nick Jones <nick.jones@network-box.com>
Subject: [PATCH net-next v3] ipv6: Allocate unique metrics for icmp6 packets
 to prevent tainting dst metrics
Date: Sat, 17 Mar 2012 23:47:15 +0800
Message-ID: <4F64B203.40307@network-box.com>
References: <4F620DC5.7080607@network-box.com> <20120316.230245.1004014834159539357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from network-box.com ([175.45.17.220]:51932 "EHLO network-box.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753285Ab2CQPrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 11:47:18 -0400
In-Reply-To: <20120316.230245.1004014834159539357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The generation of an icmp6 packet, targeted to a specific desination
address, will cause the shared metrics of the ip6_dst and inetpeer
of that address to be tainted with the hoplimit value 255.
All packets, icmp6 or otherwise, will have this hoplimit value, and
if the destination is a router, not even advertisements specifying a
new hoplimit value will have any effect due to the way
ip6_dst_hoplimit works.

By allocating a unique metrics array for the icmp6 packet, the shared
metrics will not be tainted.  A ip6_dst flag is added to indicate that
the metrics for the dst don't belong to the peer, thus are not unique
and should be freed when the dst is freed.

Signed-off-by: Nick Jones <nick.jones@network-box.com>
---

v2: Take care of destroy side, that was neglected in the previous
    version, by setting a flag on the dst to indicate its metrics are
    unique, thus should be destroyed along with the dst.
v3: declare metrics pointer variable at function top

 include/net/dst.h |    1 +
 net/ipv6/route.c  |   13 +++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

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
index 92be12b..1f217cb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -278,7 +278,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct inet6_dev *idev = rt->rt6i_idev;
 	struct inet_peer *peer = rt->rt6i_peer;

-	if (!(rt->dst.flags & DST_HOST))
+	if (!(rt->dst.flags & DST_HOST) || (rt->dst.flags & DST_NOPEERMETRICS))
 		dst_destroy_metrics_generic(dst);

 	if (idev) {
@@ -1088,6 +1088,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	struct rt6_info *rt;
 	struct inet6_dev *idev = in6_dev_get(dev);
 	struct net *net = dev_net(dev);
+	u32 *metrics;

 	if (unlikely(!idev))
 		return NULL;
@@ -1110,13 +1111,21 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
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
+	metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_ATOMIC);
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
