From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3] route: allow to route in a peer netns via lwt framework
Date: Wed, 29 Jul 2015 15:16:14 +0200
Message-ID: <1438175774-4408-1-git-send-email-nicolas.dichtel@6wind.com>
References: <55B68CE2.10008@6wind.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, tgraf@suug.ch,
	eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:58694 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbbG2NQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 09:16:45 -0400
In-Reply-To: <55B68CE2.10008@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes advantage of the newly added lwtunnel framework to
allow the user to set routes that point to a peer netns.

Packets are injected to the peer netns via the loopback device. It works
only when the output device is 'lo'.

Example:
ip route add 40.1.1.1/32 encap netns nsid 5 via dev lo

The goal is to be scalable when the number of netns is high (10k or more).
Which this patch, we can save two interfaces (veth) per netns, which helps
to to reduce memory consumption and the time needed to create a netns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v3: fix skb use after free in loopback_xmit()
    inc err stats if unable to find the peer netns
    fix a checkpatch style report

v2: rework loopback handling part (update stats and call skb_dst_force())
    fix ipv6 processing
    check lwtunnel type before converting data to a nsid

 drivers/net/loopback.c        | 40 +++++++++++++++++++++++++--------
 include/net/lwtunnel.h        | 27 ++++++++++++++++++++++
 include/uapi/linux/lwtunnel.h |  1 +
 net/core/net_namespace.c      | 52 +++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/route.c              |  9 ++++++--
 5 files changed, 118 insertions(+), 11 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c76283c2f84a..1b83efcbfbb3 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -57,6 +57,7 @@
 #include <linux/percpu.h>
 #include <net/net_namespace.h>
 #include <linux/u64_stats_sync.h>
+#include <net/lwtunnel.h>
 
 struct pcpu_lstats {
 	u64			packets;
@@ -71,29 +72,49 @@ struct pcpu_lstats {
 static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 				 struct net_device *dev)
 {
+	int nsid = skb_lwt_netns_info(skb);
 	struct pcpu_lstats *lb_stats;
-	int len;
-
-	skb_orphan(skb);
+	struct net *peernet = NULL;
+	int len, ret;
 
 	/* Before queueing this packet to netif_rx(),
 	 * make sure dst is refcounted.
 	 */
 	skb_dst_force(skb);
 
-	skb->protocol = eth_type_trans(skb, dev);
-
-	/* it's OK to use per_cpu_ptr() because BHs are off */
-	lb_stats = this_cpu_ptr(dev->lstats);
+	if (nsid != NETNSA_NSID_NOT_ASSIGNED) {
+		peernet = get_net_ns_by_id(dev_net(dev), nsid);
+		if (!peernet) {
+			dev->stats.tx_errors++;
+			kfree_skb(skb);
+			goto end;
+		}
+
+		/* it's OK to use per_cpu_ptr() because BHs are off */
+		lb_stats = this_cpu_ptr(peernet->loopback_dev->lstats);
+		len = skb->len;
+		ret = dev_forward_skb(peernet->loopback_dev, skb);
+	} else {
+		skb_orphan(skb);
+
+		skb->protocol = eth_type_trans(skb, dev);
+
+		/* it's OK to use per_cpu_ptr() because BHs are off */
+		lb_stats = this_cpu_ptr(dev->lstats);
+		len = skb->len;
+		ret = netif_rx(skb);
+	}
 
-	len = skb->len;
-	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
+	if (likely(ret == NET_RX_SUCCESS)) {
 		u64_stats_update_begin(&lb_stats->syncp);
 		lb_stats->bytes += len;
 		lb_stats->packets++;
 		u64_stats_update_end(&lb_stats->syncp);
 	}
 
+end:
+	if (peernet)
+		put_net(peernet);
 	return NETDEV_TX_OK;
 }
 
@@ -122,6 +143,7 @@ static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev,
 	stats->tx_packets = packets;
 	stats->rx_bytes   = bytes;
 	stats->tx_bytes   = bytes;
+	stats->tx_errors  = dev->stats.tx_errors;
 	return stats;
 }
 
diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index b02039081b04..78376da1afa2 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -5,7 +5,9 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/types.h>
+#include <linux/net_namespace.h>
 #include <net/route.h>
+#include <net/ip6_fib.h>
 
 #define LWTUNNEL_HASH_BITS   7
 #define LWTUNNEL_HASH_SIZE   (1 << LWTUNNEL_HASH_BITS)
@@ -147,4 +149,29 @@ static inline int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
 
 #endif
 
+static inline u32 *lwt_netns_info(struct lwtunnel_state *lwtstate)
+{
+	return (u32 *)lwtstate->data;
+}
+
+static inline int skb_lwt_netns_info(struct sk_buff *skb)
+{
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct rtable *rt = (struct rtable *)skb_dst(skb);
+
+		if (rt &&
+		    rt->rt_lwtstate &&
+		    rt->rt_lwtstate->type & LWTUNNEL_ENCAP_NETNS)
+			return *lwt_netns_info(rt->rt_lwtstate);
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
+
+		if (rt6 &&
+		    rt6->rt6i_lwtstate &&
+		    rt6->rt6i_lwtstate->type & LWTUNNEL_ENCAP_NETNS)
+			return *lwt_netns_info(rt6->rt6i_lwtstate);
+	}
+
+	return NETNSA_NSID_NOT_ASSIGNED;
+}
 #endif /* __NET_LWTUNNEL_H */
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index 31377bbea3f8..6715e7a1b335 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -7,6 +7,7 @@ enum lwtunnel_encap_types {
 	LWTUNNEL_ENCAP_NONE,
 	LWTUNNEL_ENCAP_MPLS,
 	LWTUNNEL_ENCAP_IP,
+	LWTUNNEL_ENCAP_NETNS,
 	__LWTUNNEL_ENCAP_MAX,
 };
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2c2eb1b629b1..c1267aac373d 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -20,6 +20,7 @@
 #include <net/netlink.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/lwtunnel.h>
 
 /*
  *	Our network namespace constructor/destructor lists
@@ -725,6 +726,56 @@ out:
 	rtnl_set_sk_err(net, RTNLGRP_NSID, err);
 }
 
+static int lwt_netns_build_state(struct net_device *dev, struct nlattr *nla,
+				 struct lwtunnel_state **ts)
+{
+	struct nlattr *tb[NETNSA_MAX + 1];
+	struct lwtunnel_state *newts;
+	int *nsid;
+	int ret;
+
+	ret = nla_parse_nested(tb, NETNSA_MAX, nla, rtnl_net_policy);
+	if (ret < 0)
+		return ret;
+
+	if (!tb[NETNSA_NSID])
+		return -EINVAL;
+
+	newts = lwtunnel_state_alloc(sizeof(*nsid));
+	if (!newts)
+		return -ENOMEM;
+
+	newts->len = sizeof(*nsid);
+	nsid = lwt_netns_info(newts);
+	*nsid = nla_get_s32(tb[NETNSA_NSID]);
+	newts->type = LWTUNNEL_ENCAP_NETNS;
+
+	*ts = newts;
+	return 0;
+}
+
+static int lwt_netns_fill_encap_info(struct sk_buff *skb,
+				     struct lwtunnel_state *lwtstate)
+{
+	int *nsid = lwt_netns_info(lwtstate);
+
+	if (nla_put_s32(skb, NETNSA_NSID, *nsid))
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int lwt_netns_encap_nlsize(struct lwtunnel_state *lwtstate)
+{
+	return nla_total_size(4);	/* NETNSA_NSID */
+}
+
+static const struct lwtunnel_encap_ops lwt_netns_ops = {
+	.build_state = lwt_netns_build_state,
+	.fill_encap = lwt_netns_fill_encap_info,
+	.get_encap_size = lwt_netns_encap_nlsize,
+};
+
 static int __init net_ns_init(void)
 {
 	struct net_generic *ng;
@@ -762,6 +813,7 @@ static int __init net_ns_init(void)
 	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, rtnl_net_dumpid,
 		      NULL);
 
+	lwtunnel_encap_add_ops(&lwt_netns_ops, LWTUNNEL_ENCAP_NETNS);
 	return 0;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 54fccf0d705d..6e77d4b1380d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1796,10 +1796,13 @@ int ip6_route_add(struct fib6_config *cfg)
 	rt->rt6i_metric = cfg->fc_metric;
 
 	/* We cannot add true routes via loopback here,
-	   they would result in kernel looping; promote them to reject routes
+	 * they would result in kernel looping; promote them to reject routes.
+	 * Exception: routes that point to a peer netns.
 	 */
 	if ((cfg->fc_flags & RTF_REJECT) ||
 	    (dev && (dev->flags & IFF_LOOPBACK) &&
+	     (!rt->rt6i_lwtstate ||
+	      rt->rt6i_lwtstate->type != LWTUNNEL_ENCAP_NETNS) &&
 	     !(addr_type & IPV6_ADDR_LOOPBACK) &&
 	     !(cfg->fc_flags & RTF_LOCAL))) {
 		/* hold loopback dev/idev if we haven't done so. */
@@ -2880,7 +2883,9 @@ static int rt6_fill_node(struct net *net,
 	}
 	else if (rt->rt6i_flags & RTF_LOCAL)
 		rtm->rtm_type = RTN_LOCAL;
-	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
+	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK) &&
+		 (!rt->rt6i_lwtstate ||
+		  rt->rt6i_lwtstate->type != LWTUNNEL_ENCAP_NETNS))
 		rtm->rtm_type = RTN_LOCAL;
 	else
 		rtm->rtm_type = RTN_UNICAST;
-- 
2.4.2
