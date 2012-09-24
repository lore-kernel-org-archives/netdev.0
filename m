From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] gre: conform to RFC6040 ECN progogation
Date: Mon, 24 Sep 2012 14:44:57 -0700
Message-ID: <20120924144457.0c76bce2@nehalam.linuxnetplumber.net>
References: <20120924184304.727711327@vyatta.com>
	<20120924185050.162920909@vyatta.com>
	<20120924205822.GI26494@x200.localdomain>
	<20120924141133.3c97e9de@nehalam.linuxnetplumber.net>
	<20120924212226.GJ26494@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44334 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735Ab2IXVp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 17:45:29 -0400
In-Reply-To: <20120924212226.GJ26494@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux GRE was likely written before this RFC and therefore does not
conform to one of the rules in Section 4.2.  Default Tunnel Egress Behaviour.

The new code addresses:
 o If the inner ECN field is Not-ECT, the decapsulator MUST NOT
      propagate any other ECN codepoint onwards.  This is because the
      inner Not-ECT marking is set by transports that rely on dropped
      packets as an indication of congestion and would not understand or
      respond to any other ECN codepoint [RFC4774].  Specifically:

      *  If the inner ECN field is Not-ECT and the outer ECN field is
         CE, the decapsulator MUST drop the packet.

      *  If the inner ECN field is Not-ECT and the outer ECN field is
         Not-ECT, ECT(0), or ECT(1), the decapsulator MUST forward the
         outgoing packet with the ECN field cleared to Not-ECT.

This was caught by Chris Wright while reviewing VXLAN.
This code has not been tested with real ECN through tunnel.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/ip_gre.c	2012-09-21 08:45:55.948772761 -0700
+++ b/net/ipv4/ip_gre.c	2012-09-24 14:35:54.666185603 -0700
@@ -567,15 +567,16 @@ out:
 	rcu_read_unlock();
 }
 
-static inline void ipgre_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
+static int ipgre_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
 {
 	if (INET_ECN_is_ce(iph->tos)) {
 		if (skb->protocol == htons(ETH_P_IP)) {
-			IP_ECN_set_ce(ip_hdr(skb));
+			return IP_ECN_set_ce(ip_hdr(skb));
 		} else if (skb->protocol == htons(ETH_P_IPV6)) {
-			IP6_ECN_set_ce(ipv6_hdr(skb));
+			return IP6_ECN_set_ce(ipv6_hdr(skb));
 		}
 	}
+	return 1;
 }
 
 static inline u8
@@ -703,17 +704,18 @@ static int ipgre_rcv(struct sk_buff *skb
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
 
+		__skb_tunnel_rx(skb, tunnel->dev);
+
+		skb_reset_network_header(skb);
+		if (!ipgre_ecn_decapsulate(iph, skb))
+			goto drop;
+
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		skb_reset_network_header(skb);
-		ipgre_ecn_decapsulate(iph, skb);
-
 		netif_rx(skb);
 
 		rcu_read_unlock();
