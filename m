From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] route: allow to route in a peer netns via lwt framework
Date: Thu, 23 Jul 2015 16:22:29 +0200
Message-ID: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, tgraf@suug.ch,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:49506 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbbGWOWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 10:22:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes advantage of the newly added lwtunnel framework to
allow the user to set routes that points to a peer netns.

Packets are injected to the peer netns via the loopback device. It works
only when the output device is 'lo'.

Example:
ip route add 40.1.1.1/32 encap netns nsid 5 via dev lo

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/loopback.c        | 16 +++++++++++++
 include/net/lwtunnel.h        | 23 +++++++++++++++++++
 include/uapi/linux/lwtunnel.h |  1 +
 net/core/net_namespace.c      | 52 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 92 insertions(+)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c76283c2f84a..758d02f592f9 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -57,6 +57,7 @@
 #include <linux/percpu.h>
 #include <net/net_namespace.h>
 #include <linux/u64_stats_sync.h>
+#include <net/lwtunnel.h>
 
 struct pcpu_lstats {
 	u64			packets;
@@ -71,9 +72,23 @@ struct pcpu_lstats {
 static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 				 struct net_device *dev)
 {
+	int nsid = skb_lwt_netns_info(skb);
 	struct pcpu_lstats *lb_stats;
 	int len;
 
+	if (nsid >= 0) {
+		struct net *peernet = get_net_ns_by_id(dev_net(dev), nsid);
+
+		if (!peernet) {
+			kfree_skb(skb);
+			goto end;
+		}
+
+		dev_forward_skb(peernet->loopback_dev, skb);
+		put_net(peernet);
+		goto end;
+	}
+
 	skb_orphan(skb);
 
 	/* Before queueing this packet to netif_rx(),
@@ -94,6 +109,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 		u64_stats_update_end(&lb_stats->syncp);
 	}
 
+end:
 	return NETDEV_TX_OK;
 }
 
diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 918e03c1dafa..cc05ce3c1aae 100644
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
@@ -141,4 +143,25 @@ static inline int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
 
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
+		if (rt && rt->rt_lwtstate)
+			return *lwt_netns_info(rt->rt_lwtstate);
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
+
+		if (rt6 && rt6->rt6i_lwtstate)
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
 
-- 
2.4.2
