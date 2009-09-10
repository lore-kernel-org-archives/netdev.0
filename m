From: Patrick McHardy <kaber@trash.net>
Subject: IPVS 30/31: Add handling of incoming ICMPV6 messages
Date: Thu, 10 Sep 2009 18:12:25 +0200 (MEST)
Message-ID: <20090910161220.31179.91921.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 94b265514a8398ba3cfecb5a821a027b68a5c38e
Author: Julius Volz <julius.volz@gmail.com>
Date:   Mon Aug 31 16:22:23 2009 +0200

    IPVS: Add handling of incoming ICMPV6 messages
    
    Add handling of incoming ICMPv6 messages.
    This follows the handling of IPv4 ICMP messages.
    
    Amongst ther things this problem allows IPVS to behave sensibly
    when an ICMPV6_PKT_TOOBIG message is received:
    
    This message is received when a realserver sends a packet >PMTU to the
    client. The hop on this path with insufficient MTU will generate an
    ICMPv6 Packet Too Big message back to the VIP. The LVS server receives
    this message, but the call to the function handling this has been
    missing. Thus, IPVS fails to forward the message to the real server,
    which then does not adjust the path MTU. This patch adds the missing
    call to ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.
    
    Thanks to Rob Gallagher from HEAnet for reporting this issue and for
    testing this patch in production (with direct routing mode).
    
    [horms@verge.net.au: tweaked changelog]
    Signed-off-by: Julius Volz <julius.volz@gmail.com>
    Tested-by: Rob Gallagher <robert.gallagher@heanet.ie>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a986ee2..b95699f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1277,13 +1277,24 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 		return NF_ACCEPT;
 	}
 
-	if (unlikely(iph.protocol == IPPROTO_ICMP)) {
-		int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
+#ifdef CONFIG_IP_VS_IPV6
+	if (af == AF_INET6) {
+		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
+			int related, verdict = ip_vs_in_icmp_v6(skb, &related, hooknum);
 
-		if (related)
-			return verdict;
-		ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
-	}
+			if (related)
+				return verdict;
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
+	} else
+#endif
+		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
+			int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
+
+			if (related)
+				return verdict;
+			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
+		}
 
 	/* Protocol supported? */
 	pp = ip_vs_proto_get(iph.protocol);
