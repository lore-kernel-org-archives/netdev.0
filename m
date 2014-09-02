From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/7] ipvs: properly declare tunnel encapsulation
Date: Tue,  2 Sep 2014 12:14:02 +0200
Message-ID: <1409652844-10289-6-git-send-email-pablo@netfilter.org>
References: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48025 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753311AbaIBKNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 06:13:23 -0400
In-Reply-To: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

The tunneling method should properly use tunnel encapsulation.
Fixes problem with CHECKSUM_PARTIAL packets when TCP/UDP csum
offload is supported.

Thanks to Alex Gartrell for reporting the problem, providing
solution and for all suggestions.

Reported-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Alex Gartrell <agartrell@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6f70bdd..56896a4 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -38,6 +38,7 @@
 #include <net/route.h>                  /* for ip_route_output */
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/ip_tunnels.h>
 #include <net/addrconf.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter.h>
@@ -862,11 +863,15 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ip_hdr(skb);
 	}
 
-	skb->transport_header = skb->network_header;
-
 	/* fix old IP header checksum */
 	ip_send_check(old_iph);
 
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	if (IS_ERR(skb))
+		goto tx_error;
+
+	skb->transport_header = skb->network_header;
+
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
@@ -900,7 +905,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	return NF_STOLEN;
 
   tx_error:
-	kfree_skb(skb);
+	if (!IS_ERR(skb))
+		kfree_skb(skb);
 	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
@@ -953,6 +959,11 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		old_iph = ipv6_hdr(skb);
 	}
 
+	/* GSO: we need to provide proper SKB_GSO_ value for IPv6 */
+	skb = iptunnel_handle_offloads(skb, false, 0); /* SKB_GSO_SIT/IPV6 */
+	if (IS_ERR(skb))
+		goto tx_error;
+
 	skb->transport_header = skb->network_header;
 
 	skb_push(skb, sizeof(struct ipv6hdr));
@@ -988,7 +999,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	return NF_STOLEN;
 
 tx_error:
-	kfree_skb(skb);
+	if (!IS_ERR(skb))
+		kfree_skb(skb);
 	rcu_read_unlock();
 	LeaveFunction(10);
 	return NF_STOLEN;
-- 
1.7.10.4
