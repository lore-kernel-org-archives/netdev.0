From: Tom Herbert <tom@herbertland.com>
Subject: [RFC net-next 3/6] net: Special routing hook
Date: Wed, 3 Jun 2015 12:58:19 -0700
Message-ID: <1433361502-3478761-4-git-send-email-tom@herbertland.com>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <agartrell@fb.com>, <maheshb@google.com>,
	<tgraf@suug.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50249 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755509AbbFCT6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:58:47 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t53JvH8f007862
	for <netdev@vger.kernel.org>; Wed, 3 Jun 2015 12:58:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1ut5660d37-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:58:46 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 f108e9240a2a11e597910002c991e86a-1fed7280 for <netdev@vger.kernel.org>;	Wed,
 03 Jun 2015 12:58:45 -0700
In-Reply-To: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A hack to provide an ultra light weight hook to do translations.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/ip6_route.h | 22 +++++++++++++++++++++
 net/ipv6/ip6_input.c    |  3 +++
 net/ipv6/ip6_output.c   | 24 ++++++++++++++++++++++-
 net/ipv6/route.c        | 51 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_input.c  |  4 ++++
 5 files changed, 103 insertions(+), 1 deletion(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 297629a..d6efa67 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -156,6 +156,28 @@ static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
 	spin_unlock(&sk->sk_dst_lock);
 }
 
+struct special_route {
+	int (*input)(struct sk_buff *skb);
+	int (*output)(struct sk_buff *skb);
+	struct list_head list;
+};
+
+extern struct list_head route_special_head __read_mostly;
+
+void ip6_route_special_add(struct special_route *sr);
+void ip6_route_special_remove(struct special_route *sr);
+int __ip6_route_special(struct sk_buff *skb, bool output);
+
+static inline int ip6_route_special_input(struct sk_buff *skb)
+{
+	return __ip6_route_special(skb, false);
+}
+
+static inline int ip6_route_special_output(struct sk_buff *skb)
+{
+	return __ip6_route_special(skb, true);
+}
+
 static inline bool ipv6_unicast_destination(const struct sk_buff *skb)
 {
 	struct rt6_info *rt = (struct rt6_info *) skb_dst(skb);
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index f2e464e..d0a61cc 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -177,6 +177,9 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 		}
 	}
 
+	if (ip6_route_special_input(skb) < 0)
+		goto drop;
+
 	rcu_read_unlock();
 
 	/* Must drop socket now because of tproxy. */
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d5f7716..857c873 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -77,13 +77,28 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 					 &ipv6_hdr(skb)->saddr))) {
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 
+			if (ip6_route_special_output(skb) < 0) {
+				IP6_INC_STATS(dev_net(dev), idev,
+					      IPSTATS_MIB_OUTDISCARDS);
+				kfree_skb(skb);
+				return 0;
+			}
+
 			/* Do not check for IFF_ALLMULTI; multicast routing
 			   is not supported in any case.
 			 */
-			if (newskb)
+			if (newskb) {
+				if (ip6_route_special_output(skb) < 0) {
+					IP6_INC_STATS(dev_net(dev), idev,
+						      IPSTATS_MIB_OUTDISCARDS);
+					kfree_skb(skb);
+					return 0;
+				}
+
 				NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING,
 					sk, newskb, NULL, newskb->dev,
 					dev_loopback_xmit);
+			}
 
 			if (ipv6_hdr(skb)->hop_limit == 0) {
 				IP6_INC_STATS(dev_net(dev), idev,
@@ -143,6 +158,13 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
+	if (ip6_route_special_output(skb) < 0) {
+		IP6_INC_STATS(dev_net(dev), idev,
+			      IPSTATS_MIB_OUTDISCARDS);
+		kfree_skb(skb);
+		return 0;
+	}
+
 	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb,
 			    NULL, dev,
 			    ip6_finish_output,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1a1122a..e6096e0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -44,6 +44,7 @@
 #include <linux/seq_file.h>
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
+#include <linux/list.h>
 #include <net/net_namespace.h>
 #include <net/snmp.h>
 #include <net/ipv6.h>
@@ -2590,6 +2591,54 @@ void rt6_mtu_change(struct net_device *dev, unsigned int mtu)
 	fib6_clean_all(dev_net(dev), rt6_mtu_change_route, &arg);
 }
 
+struct list_head route_special_head __read_mostly;
+static DEFINE_SPINLOCK(special_route_lock);
+
+void ip6_route_special_add(struct special_route *sr)
+{
+	spin_lock(&special_route_lock);
+	list_add_rcu(&sr->list, &route_special_head);
+	spin_unlock(&special_route_lock);
+}
+EXPORT_SYMBOL(ip6_route_special_add);
+
+void ip6_route_special_remove(struct special_route *sr)
+{
+	struct special_route *sr1;
+
+	spin_lock(&special_route_lock);
+
+	list_for_each_entry_rcu(sr1, &route_special_head, list) {
+		if (sr == sr1) {
+			list_del_rcu(&sr->list);
+			goto out;
+		}
+	}
+
+	pr_warn("route_special_remove: %p not found\n", sr);
+out:
+	spin_unlock(&special_route_lock);
+}
+EXPORT_SYMBOL(ip6_route_special_remove);
+
+int __ip6_route_special(struct sk_buff *skb, bool output)
+{
+	struct special_route *sr;
+	int ret = 0;
+
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(sr, &route_special_head, list) {
+		ret = output ? sr->output(skb) : sr->input(skb);
+		if (ret < 0)
+			break;
+	}
+
+	rcu_read_lock();
+	return ret;
+}
+EXPORT_SYMBOL(__ip6_route_special);
+
 static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_GATEWAY]           = { .len = sizeof(struct in6_addr) },
 	[RTA_OIF]               = { .type = NLA_U32 },
@@ -3488,6 +3537,8 @@ int __init ip6_route_init(void)
 		spin_lock_init(&ul->lock);
 	}
 
+	INIT_LIST_HEAD(&route_special_head);
+
 out:
 	return ret;
 
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 74bd178..d1f75b8 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -14,6 +14,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 #include <net/ipv6.h>
+#include <net/ip6_route.h>
 #include <net/xfrm.h>
 
 int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
@@ -42,6 +43,9 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
+	if (ip6_route_special_input(skb) < 0)
+		return 1;
+
 	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, NULL, skb,
 		skb->dev, NULL,
 		ip6_rcv_finish);
-- 
1.8.1
