From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] ipv6: do lazy dst->__use update when per cpu dst is available
Date: Wed, 27 Sep 2017 19:14:31 +0200
Message-ID: <9d32116e61596b0de6a584b6cf05cae3ce7abb56.1506532145.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60951 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750752AbdI0RPY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 13:15:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a host is under high ipv6 load, the updates of the ingress
route '__use' field are a source of relevant contention: such
field is updated for each packet and several cores can access
concurrently the dst, even if percpu dst entries are available
and used.

The __use value is just a rough indication of the dst usage: is
already updated concurrently from multiple CPUs without any lock,
so we can decrease the contention leveraging the percpu dst to perform
__use bulk updates: if a per cpu dst entry is found, we account on
such entry and we flush the percpu counter once per jiffy.

Performace gain under UDP flood is as follows:

nr RX queues	before		after		delta
		kpps		kpps		(%)
2		2316		2688		16
3		3033		3605		18
4		3963		4328		9
5		4379		5253		19
6		5137		6000		16

Performance gain under TCP syn flood should be measurable as well.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/route.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 26cc9f483b6d..e69f304de950 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1170,12 +1170,24 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 
 		struct rt6_info *pcpu_rt;
 
-		rt->dst.lastuse = jiffies;
-		rt->dst.__use++;
 		pcpu_rt = rt6_get_pcpu_route(rt);
 
 		if (pcpu_rt) {
+			unsigned long ts;
+
 			read_unlock_bh(&table->tb6_lock);
+
+			/* do lazy updates of rt->dst->__use, at most once
+			 * per jiffy, to avoid contention on such cacheline.
+			 */
+			ts = jiffies;
+			pcpu_rt->dst.__use++;
+			if (pcpu_rt->dst.lastuse != ts) {
+				rt->dst.__use += pcpu_rt->dst.__use;
+				rt->dst.lastuse = ts;
+				pcpu_rt->dst.__use = 0;
+				pcpu_rt->dst.lastuse = ts;
+			}
 		} else {
 			/* We have to do the read_unlock first
 			 * because rt6_make_pcpu_route() may trigger
@@ -1185,6 +1197,8 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			read_unlock_bh(&table->tb6_lock);
 			pcpu_rt = rt6_make_pcpu_route(rt);
 			dst_release(&rt->dst);
+			rt->dst.lastuse = jiffies;
+			rt->dst.__use++;
 		}
 
 		trace_fib6_table_lookup(net, pcpu_rt, table->tb6_id, fl6);
-- 
2.13.5
