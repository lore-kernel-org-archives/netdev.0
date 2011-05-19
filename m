From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/4] rps: Some minor cleanup in get_rps_cpus
Date: Thu, 19 May 2011 08:39:04 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1105190827480.12796@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4932 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245Ab1ESPjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 11:39:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use some variables for clarity and extensibility.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 155de20..a40eea9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2508,15 +2508,17 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 	const struct ipv6hdr *ip6;
 	const struct iphdr *ip;
 	u8 ip_proto;
-	u32 addr1, addr2, ihl;
+	u32 addr1, addr2;
+	u16 proto;
 	union {
 		u32 v32;
 		u16 v16[2];
 	} ports;
 
 	nhoff = skb_network_offset(skb);
+	proto = skb->protocol;
 
-	switch (skb->protocol) {
+	switch (proto) {
 	case __constant_htons(ETH_P_IP):
 		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
 			goto done;
@@ -2528,7 +2530,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 			ip_proto = ip->protocol;
 		addr1 = (__force u32) ip->saddr;
 		addr2 = (__force u32) ip->daddr;
-		ihl = ip->ihl;
+		nhoff += ip->ihl * 4;
 		break;
 	case __constant_htons(ETH_P_IPV6):
 		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
@@ -2538,7 +2540,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 		ip_proto = ip6->nexthdr;
 		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
 		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
-		ihl = (40 >> 2);
+		nhoff += 40;
 		break;
 	default:
 		goto done;
@@ -2547,7 +2549,7 @@ __u32 __skb_get_rxhash(struct sk_buff *skb)
 	ports.v32 = 0;
 	poff = proto_ports_offset(ip_proto);
 	if (poff >= 0) {
-		nhoff += ihl * 4 + poff;
+		nhoff += poff;
 		if (pskb_may_pull(skb, nhoff + 4)) {
 			ports.v32 = * (__force u32 *) (skb->data + nhoff);
 			if (ports.v16[1] < ports.v16[0])
-- 
1.7.3.1

