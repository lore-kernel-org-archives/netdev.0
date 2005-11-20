From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Sun, 20 Nov 2005 17:31:36 +0100
Message-ID: <20051120163135.16666.76993.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[IPV4/6]: Netfilter IPsec input hooks

When the innermost transform uses transport mode the decapsulated packet
is not visible to netfilter. Pass the packet through the PRE_ROUTING and
LOCAL_IN hooks again before handing it to upper layer protocols to make
netfilter-visibility symetrical to the output path.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 08cf39d5d7d8b942431a6529daa3ab69ecfb34b5
tree 6f2a1a85f915b1b6f89ad50cf3d8855f21a561b6
parent b847425c693f43a63137d18e36e5c8cf0187c175
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 21:50:22 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 21:50:22 +0100

 include/linux/netfilter_ipv4.h |    2 +-
 include/net/ipv6.h             |    2 ++
 net/ipv4/netfilter.c           |   20 ++++++++++++++++++++
 net/ipv4/xfrm4_input.c         |   14 ++++++++++++++
 net/ipv6/ip6_input.c           |    2 +-
 net/ipv6/xfrm6_input.c         |   13 +++++++++++++
 6 files changed, 51 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index fdc4a95..e9103fe 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -79,7 +79,7 @@ enum nf_ip_hook_priorities {
 
 #ifdef __KERNEL__
 extern int ip_route_me_harder(struct sk_buff **pskb);
-
+extern int ip_xfrm_transport_hook(struct sk_buff *skb);
 #endif /*__KERNEL__*/
 
 #endif /*__LINUX_IP_NETFILTER_H*/
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6addb4d..4fbfe43 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -414,6 +414,8 @@ extern int			ipv6_rcv(struct sk_buff *sk
 					 struct packet_type *pt,
 					 struct net_device *orig_dev);
 
+extern int			ip6_rcv_finish(struct sk_buff *skb);
+
 /*
  *	upper-layer output functions
  */
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index b93e7cd..3c39296 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -105,6 +105,26 @@ int ip_dst_output(struct sk_buff *skb)
 	return dst_output(skb);
 }
 EXPORT_SYMBOL(ip_dst_output);
+
+/*
+ * okfn for transport mode xfrm_input.c hook. Basically a copy of
+ * ip_rcv_finish without statistics and option parsing.
+ */
+int ip_xfrm_transport_hook(struct sk_buff *skb)
+{
+	struct iphdr *iph = skb->nh.iph;
+
+	if (likely(skb->dst == NULL)) {
+		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
+		                         skb->dev);
+		if (unlikely(err))
+			goto drop;
+	}
+	return dst_input(skb);
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
 #endif /* CONFIG_XFRM */
 
 /*
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 2d3849c..d90cd93 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -11,6 +11,8 @@
 
 #include <linux/module.h>
 #include <linux/string.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -137,6 +139,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 	memcpy(skb->sp->x+skb->sp->len, xfrm_vec, xfrm_nr*sizeof(struct sec_decap_state));
 	skb->sp->len += xfrm_nr;
 
+	nf_reset(skb);
+
 	if (decaps) {
 		if (!(skb->dev->flags&IFF_LOOPBACK)) {
 			dst_release(skb->dst);
@@ -145,7 +149,17 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 		netif_rx(skb);
 		return 0;
 	} else {
+#ifdef CONFIG_NETFILTER
+		__skb_push(skb, skb->data - skb->nh.raw);
+		skb->nh.iph->tot_len = htons(skb->len);
+		ip_send_check(skb->nh.iph);
+
+		NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
+		        ip_xfrm_transport_hook);
+		return 0;
+#else
 		return -skb->nh.iph->protocol;
+#endif
 	}
 
 drop_unlock:
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 33d3b0e..e84b3cd 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -48,7 +48,7 @@
 
 
 
-static inline int ip6_rcv_finish( struct sk_buff *skb) 
+inline int ip6_rcv_finish(struct sk_buff *skb) 
 {
 	if (skb->dst == NULL)
 		ip6_route_input(skb);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 28c29d7..9987416 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -11,6 +11,8 @@
 
 #include <linux/module.h>
 #include <linux/string.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv6.h>
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
@@ -121,6 +123,8 @@ int xfrm6_rcv_spi(struct sk_buff **pskb,
 	skb->sp->len += xfrm_nr;
 	skb->ip_summed = CHECKSUM_NONE;
 
+	nf_reset(skb);
+
 	if (decaps) {
 		if (!(skb->dev->flags&IFF_LOOPBACK)) {
 			dst_release(skb->dst);
@@ -129,7 +133,16 @@ int xfrm6_rcv_spi(struct sk_buff **pskb,
 		netif_rx(skb);
 		return -1;
 	} else {
+#ifdef CONFIG_NETFILTER
+		skb->nh.ipv6h->payload_len = htons(skb->len);
+		__skb_push(skb, skb->data - skb->nh.raw);
+
+		NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
+		        ip6_rcv_finish);
+		return -1;
+#else
 		return 1;
+#endif
 	}
 
 drop_unlock:
