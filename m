From: Patrick McHardy <kaber@trash.net>
Subject: [IPV4/6 03/10]: Netfilter IPsec input hooks
Date: Sat,  7 Jan 2006 02:09:35 +0100 (MET)
Message-ID: <20060107010859.8712.31079.sendpatchset@localhost.localdomain>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
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
commit 0ab5982305cae5d8e4fb41d8bb849ee1808946fc
tree 6fce75eaee3b9b8d4f34470d8988906e93a22b19
parent 7398b0fba81fbae5139c7a23d27477424125e8b2
author Patrick McHardy <kaber@trash.net> Fri, 06 Jan 2006 21:47:45 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 06 Jan 2006 21:47:45 +0100

 include/net/ipv6.h     |    2 ++
 net/ipv4/xfrm4_input.c |   31 +++++++++++++++++++++++++++++++
 net/ipv6/ip6_input.c   |    2 +-
 net/ipv6/xfrm6_input.c |   13 +++++++++++++
 4 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 860bbac..3b1d963 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -418,6 +418,8 @@ extern int			ipv6_rcv(struct sk_buff *sk
 					 struct packet_type *pt,
 					 struct net_device *orig_dev);
 
+extern int			ip6_rcv_finish(struct sk_buff *skb);
+
 /*
  *	upper-layer output functions
  */
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 2d3849c..850d919 100644
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
@@ -45,6 +47,23 @@ static int xfrm4_parse_spi(struct sk_buf
 	return xfrm_parse_spi(skb, nexthdr, spi, seq);
 }
 
+#ifdef CONFIG_NETFILTER
+static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
+{
+	struct iphdr *iph = skb->nh.iph;
+
+	if (skb->dst == NULL) {
+		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
+		                   skb->dev))
+			goto drop;
+	}
+	return dst_input(skb);
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+#endif
+
 int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
 {
 	int err;
@@ -137,6 +156,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 	memcpy(skb->sp->x+skb->sp->len, xfrm_vec, xfrm_nr*sizeof(struct sec_decap_state));
 	skb->sp->len += xfrm_nr;
 
+	nf_reset(skb);
+
 	if (decaps) {
 		if (!(skb->dev->flags&IFF_LOOPBACK)) {
 			dst_release(skb->dst);
@@ -145,7 +166,17 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 		netif_rx(skb);
 		return 0;
 	} else {
+#ifdef CONFIG_NETFILTER
+		__skb_push(skb, skb->data - skb->nh.raw);
+		skb->nh.iph->tot_len = htons(skb->len);
+		ip_send_check(skb->nh.iph);
+
+		NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
+		        xfrm4_rcv_encap_finish);
+		return 0;
+#else
 		return -skb->nh.iph->protocol;
+#endif
 	}
 
 drop_unlock:
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 13d7241..29f7359 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -48,7 +48,7 @@
 
 
 
-static inline int ip6_rcv_finish( struct sk_buff *skb) 
+inline int ip6_rcv_finish( struct sk_buff *skb) 
 {
 	if (skb->dst == NULL)
 		ip6_route_input(skb);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 1079e47..1ca2da6 100644
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
