From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Fri, 22 Apr 2016 19:44:08 +0200
Message-ID: <017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
References: <cover.1461346798.git.jbenc@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932345AbcDVRoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 13:44:24 -0400
In-Reply-To: <cover.1461346798.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For ipgre interfaces in collect metadata mode, receive also traffic with
encapsulated Ethernet headers. The lwtunnel users are supposed to sort this
out correctly. This allows to have mixed Ethernet + L3-only traffic on the
same lwtunnel interface.

To keep backwards compatibility and prevent any surprises, gretap interfaces
have priority in receiving packets with Ethernet headers.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/ip_tunnels.h |  1 +
 net/ipv4/ip_gre.c        | 34 +++++++++++++++++++++++++---------
 2 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 56050f913339..ac8d6822072e 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -161,6 +161,7 @@ struct tnl_ptk_info {
 
 #define PACKET_RCVD	0
 #define PACKET_REJECT	1
+#define PACKET_NEXT	2
 
 #define IP_TNL_HASH_BITS   7
 #define IP_TNL_HASH_SIZE   (1 << IP_TNL_HASH_BITS)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f973e0a58993..ccd6b098928d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -379,19 +379,13 @@ static __be32 tunnel_id_to_key(__be64 x)
 #endif
 }
 
-static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
+static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
+		       struct ip_tunnel_net *itn)
 {
-	struct net *net = dev_net(skb->dev);
 	struct metadata_dst *tun_dst = NULL;
-	struct ip_tunnel_net *itn;
 	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
 
-	if (tpi->proto == htons(ETH_P_TEB))
-		itn = net_generic(net, gre_tap_net_id);
-	else
-		itn = net_generic(net, ipgre_net_id);
-
 	iph = ip_hdr(skb);
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
 				  iph->saddr, iph->daddr, tpi->key);
@@ -412,7 +406,29 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 		ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
 		return PACKET_RCVD;
 	}
-	return PACKET_REJECT;
+	return PACKET_NEXT;
+}
+
+static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
+{
+	struct net *net = dev_net(skb->dev);
+	struct ip_tunnel_net *itn;
+	int res;
+
+	if (tpi->proto == htons(ETH_P_TEB))
+		itn = net_generic(net, gre_tap_net_id);
+	else
+		itn = net_generic(net, ipgre_net_id);
+
+	res = __ipgre_rcv(skb, tpi, itn);
+	if (res == PACKET_NEXT && tpi->proto == htons(ETH_P_TEB)) {
+		/* ipgre tunnels in collect metadata mode should receive
+		 * also ETH_P_TEB traffic
+		 */
+		itn = net_generic(net, ipgre_net_id);
+		res = __ipgre_rcv(skb, tpi, itn);
+	}
+	return res;
 }
 
 static int gre_rcv(struct sk_buff *skb)
-- 
1.8.3.1
