From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 02/14] ipv6: consolidate error paths in ipv6_frag_rcv
Date: Wed,  8 Oct 2008 15:51:50 +0400
Message-ID: <1223466722-8169-2-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28875 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754341AbYJHLy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:28 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv6/reassembly.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 2eeadfa..f4f62f0 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -578,19 +578,12 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
-	if (hdr->payload_len==0) {
-		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
-		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
-				  skb_network_header_len(skb));
-		return -1;
-	}
+	if (hdr->payload_len==0)
+		goto fail_hdr;
+
 	if (!pskb_may_pull(skb, (skb_transport_offset(skb) +
-				 sizeof(struct frag_hdr)))) {
-		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
-		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
-				  skb_network_header_len(skb));
-		return -1;
-	}
+				 sizeof(struct frag_hdr))))
+		goto fail_hdr;
 
 	hdr = ipv6_hdr(skb);
 	fhdr = (struct frag_hdr *)skb_transport_header(skb);
@@ -624,6 +617,11 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
+
+fail_hdr:
+	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb_network_header_len(skb));
+	return -1;
 }
 
 static struct inet6_protocol frag_protocol =
-- 
1.5.3.rc5

