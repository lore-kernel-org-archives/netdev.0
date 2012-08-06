From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/5] net: Loopback ifindex is constant now
Date: Mon, 06 Aug 2012 14:32:11 +0400
Message-ID: <501F9D2B.8000504@parallels.com>
References: <501F9CAF.3030605@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47354 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125Ab2HFKcQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 06:32:16 -0400
In-Reply-To: <501F9CAF.3030605@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As pointed out, there are places, that access net->loopback_dev->ifindex
and after ifindex generation is made per-net this value becomes constant
equals 1. So go ahead and introduce the LOOPBACK_IFINDEX constant and use
it where appropriate.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 drivers/net/loopback.c            |    1 +
 include/net/net_namespace.h       |    6 ++++++
 net/decnet/dn_route.c             |    6 +++---
 net/ipv4/fib_frontend.c           |    2 +-
 net/ipv4/ipmr.c                   |    2 +-
 net/ipv4/netfilter/ipt_rpfilter.c |    2 +-
 net/ipv4/route.c                  |    6 +++---
 net/ipv6/route.c                  |    2 +-
 8 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index e2a06fd..4a075ba 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -197,6 +197,7 @@ static __net_init int loopback_net_init(struct net *net)
 	if (err)
 		goto out_free_netdev;
 
+	BUG_ON(dev->ifindex != LOOPBACK_IFINDEX);
 	net->loopback_dev = dev;
 	return 0;
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index c5fbebf..841581b 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -105,6 +105,12 @@ struct net {
 	struct sock		*diag_nlsk;
 };
 
+/*
+ * ifindex generation is per-net namespace, thus any loopback
+ * device should get ifindex 1
+ */
+
+#define LOOPBACK_IFINDEX	1
 
 #include <linux/seq_file_net.h>
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 85a3604..c855e8d 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -961,7 +961,7 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 		.saddr = oldflp->saddr,
 		.flowidn_scope = RT_SCOPE_UNIVERSE,
 		.flowidn_mark = oldflp->flowidn_mark,
-		.flowidn_iif = init_net.loopback_dev->ifindex,
+		.flowidn_iif = LOOPBACK_IFINDEX,
 		.flowidn_oif = oldflp->flowidn_oif,
 	};
 	struct dn_route *rt = NULL;
@@ -979,7 +979,7 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 		       "dn_route_output_slow: dst=%04x src=%04x mark=%d"
 		       " iif=%d oif=%d\n", le16_to_cpu(oldflp->daddr),
 		       le16_to_cpu(oldflp->saddr),
-		       oldflp->flowidn_mark, init_net.loopback_dev->ifindex,
+		       oldflp->flowidn_mark, LOOPBACK_IFINDEX,
 		       oldflp->flowidn_oif);
 
 	/* If we have an output interface, verify its a DECnet device */
@@ -1042,7 +1042,7 @@ source_ok:
 			if (!fld.daddr)
 				goto out;
 		}
-		fld.flowidn_oif = init_net.loopback_dev->ifindex;
+		fld.flowidn_oif = LOOPBACK_IFINDEX;
 		res.type = RTN_LOCAL;
 		goto make_route;
 	}
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c43ae3f..7f073a3 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -218,7 +218,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 	scope = RT_SCOPE_UNIVERSE;
 	if (!ipv4_is_zeronet(ip_hdr(skb)->saddr)) {
 		fl4.flowi4_oif = 0;
-		fl4.flowi4_iif = net->loopback_dev->ifindex;
+		fl4.flowi4_iif = LOOPBACK_IFINDEX;
 		fl4.daddr = ip_hdr(skb)->saddr;
 		fl4.saddr = 0;
 		fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 8eec8f4..3a57570 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1798,7 +1798,7 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
 		.flowi4_oif = (rt_is_output_route(rt) ?
 			       skb->dev->ifindex : 0),
 		.flowi4_iif = (rt_is_output_route(rt) ?
-			       net->loopback_dev->ifindex :
+			       LOOPBACK_IFINDEX :
 			       skb->dev->ifindex),
 		.flowi4_mark = skb->mark,
 	};
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 31371be..24eb18c 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -85,7 +85,7 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			return ipv4_is_local_multicast(iph->daddr) ^ invert;
 		flow.flowi4_iif = 0;
 	} else {
-		flow.flowi4_iif = dev_net(par->in)->loopback_dev->ifindex;
+		flow.flowi4_iif = LOOPBACK_IFINDEX;
 	}
 
 	flow.daddr = iph->saddr;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 21ad369..c581373 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1619,7 +1619,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	if (res.type == RTN_LOCAL) {
 		err = fib_validate_source(skb, saddr, daddr, tos,
-					  net->loopback_dev->ifindex,
+					  LOOPBACK_IFINDEX,
 					  dev, in_dev, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
@@ -1895,7 +1895,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 	orig_oif = fl4->flowi4_oif;
 
-	fl4->flowi4_iif = net->loopback_dev->ifindex;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
 	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
 			 RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
@@ -1984,7 +1984,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		if (!fl4->daddr)
 			fl4->daddr = fl4->saddr = htonl(INADDR_LOOPBACK);
 		dev_out = net->loopback_dev;
-		fl4->flowi4_oif = net->loopback_dev->ifindex;
+		fl4->flowi4_oif = LOOPBACK_IFINDEX;
 		res.type = RTN_LOCAL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8e80fd2..0ddf2d1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -965,7 +965,7 @@ struct dst_entry * ip6_route_output(struct net *net, const struct sock *sk,
 {
 	int flags = 0;
 
-	fl6->flowi6_iif = net->loopback_dev->ifindex;
+	fl6->flowi6_iif = LOOPBACK_IFINDEX;
 
 	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr))
 		flags |= RT6_LOOKUP_F_IFACE;
-- 
1.7.6.5
