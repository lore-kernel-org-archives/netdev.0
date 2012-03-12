From: Nick Jones <nick.jones@network-box.com>
Subject: [PATCH net-next] Allocate unique metrics for icmp6 packets to prevent
 tainting dst metrics
Date: Mon, 12 Mar 2012 23:16:14 +0800
Message-ID: <4F5E133E.4040308@network-box.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from network-box.com ([175.45.17.220]:57651 "EHLO network-box.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755602Ab2CLPQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 11:16:16 -0400
Received: from hqnickjones-macbook.local (unknown [10.8.2.241])
	by network-box.com (Postfix) with ESMTP id 98AC23EB01
	for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 23:16:14 +0800 (HKT)
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
metrics will not be tainted.

Signed-off-by: Nick Jones <nick.jones@network-box.com>
---

First follow up after discussion at:
http://www.spinics.net/lists/netdev/msg191052.html

 net/ipv6/route.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 92be12b..209d156 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1117,6 +1117,14 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
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
