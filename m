From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 3/3] gre: receive also TEB packets for lwtunnels
Date: Tue,  3 May 2016 17:10:08 +0200
Message-ID: <43bffa0d4c4086ff6f38d39923b5a86d49ccced8.1462286214.git.jbenc@redhat.com>
References: <cover.1462286214.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, pravin shelar <pshelar@ovn.org>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933471AbcECPKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 11:10:44 -0400
In-Reply-To: <cover.1462286214.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For ipgre interfaces in collect metadata mode, receive also traffic with
encapsulated Ethernet headers. The lwtunnel users are supposed to sort this
out correctly. This allows to have mixed Ethernet + L3-only traffic on the
same lwtunnel interface. This is the same way as VXLAN-GPE behaves.

To keep backwards compatibility and prevent any surprises, gretap interfaces
have priority in receiving packets with Ethernet headers.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/ip_tunnels.h |  1 +
 net/ipv4/ip_gre.c        | 39 ++++++++++++++++++++++++++++-----------
 2 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 6d790910ebdf..d916b4315903 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -160,6 +160,7 @@ struct tnl_ptk_info {
 
 #define PACKET_RCVD	0
 #define PACKET_REJECT	1
+#define PACKET_NEXT	2
 
 #define IP_TNL_HASH_BITS   7
 #define IP_TNL_HASH_SIZE   (1 << IP_TNL_HASH_BITS)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 8f377dad5489..2b267e71ebf5 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -260,26 +260,20 @@ static __be32 tunnel_id_to_key(__be64 x)
 #endif
 }
 
-static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
-		     int hdr_len)
+static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
+		       struct ip_tunnel_net *itn, int hdr_len, bool raw_proto)
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
 
 	if (tunnel) {
-		if (iptunnel_pull_header(skb, hdr_len, tpi->proto, false) < 0)
+		if (__iptunnel_pull_header(skb, hdr_len, tpi->proto,
+					   raw_proto, false) < 0)
 			goto drop;
 
 		skb_pop_mac_header(skb);
@@ -297,13 +291,36 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
 		return PACKET_RCVD;
 	}
-	return PACKET_REJECT;
+	return PACKET_NEXT;
 
 drop:
 	kfree_skb(skb);
 	return PACKET_RCVD;
 }
 
+static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
+		     int hdr_len)
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
+	res = __ipgre_rcv(skb, tpi, itn, hdr_len, false);
+	if (res == PACKET_NEXT && tpi->proto == htons(ETH_P_TEB)) {
+		/* ipgre tunnels in collect metadata mode should receive
+		 * also ETH_P_TEB traffic.
+		 */
+		itn = net_generic(net, ipgre_net_id);
+		res = __ipgre_rcv(skb, tpi, itn, hdr_len, true);
+	}
+	return res;
+}
+
 static int gre_rcv(struct sk_buff *skb)
 {
 	struct tnl_ptk_info tpi;
-- 
1.8.3.1
