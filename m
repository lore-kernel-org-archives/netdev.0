From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] rps: optimize rps_get_cpu()
Date: Tue, 20 Apr 2010 22:02:40 +0800
Message-ID: <1271772160-28177-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36224 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754623Ab0DTODN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 10:03:13 -0400
Received: by wyb39 with SMTP id 39so3290762wyb.19
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 07:03:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

optimize rps_get_cpu().

don't initialize ports when we can get the ports. one memory access for ports
than two. use ihl in bytes to eliminate later multiplyings.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/dev.c |   30 ++++++++++++++----------------
 1 file changed, 14 insertions(+), 16 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index b31d5d6..55ecfa9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2225,7 +2225,11 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	int cpu = -1;
 	u8 ip_proto;
 	u16 tcpu;
-	u32 addr1, addr2, ports, ihl;
+	u32 addr1, addr2, ihl;
+	union {
+		u32 v32;
+		u16 v16[2];
+	} ports;
 
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
@@ -2256,7 +2260,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		ip_proto = ip->protocol;
 		addr1 = (__force u32) ip->saddr;
 		addr2 = (__force u32) ip->daddr;
-		ihl = ip->ihl;
+		ihl = ip->ihl << 2;
 		break;
 	case __constant_htons(ETH_P_IPV6):
 		if (!pskb_may_pull(skb, sizeof(*ip6)))
@@ -2266,12 +2270,11 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		ip_proto = ip6->nexthdr;
 		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
 		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
-		ihl = (40 >> 2);
+		ihl = 40;
 		break;
 	default:
 		goto done;
 	}
-	ports = 0;
 	switch (ip_proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
@@ -2280,26 +2283,21 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	case IPPROTO_AH:
 	case IPPROTO_SCTP:
 	case IPPROTO_UDPLITE:
-		if (pskb_may_pull(skb, (ihl * 4) + 4)) {
-			__be16 *hports = (__be16 *) (skb->data + (ihl * 4));
-			u32 sport, dport;
-
-			sport = (__force u16) hports[0];
-			dport = (__force u16) hports[1];
-			if (dport < sport)
-				swap(sport, dport);
-			ports = (sport << 16) + dport;
+		if (pskb_may_pull(skb, ihl + 4)) {
+			ports.v32 = * (__force u32 *) (skb->data + ihl);
+			if (ports.v16[0] < ports.v16[1])
+				swap(ports.v16[0], ports.v16[1]);
+			break;
 		}
-		break;
-
 	default:
+		ports.v32 = 0;
 		break;
 	}
 
 	/* get a consistent hash (same value on both flow directions) */
 	if (addr2 < addr1)
 		swap(addr1, addr2);
-	skb->rxhash = jhash_3words(addr1, addr2, ports, hashrnd);
+	skb->rxhash = jhash_3words(addr1, addr2, ports.v32, hashrnd);
 	if (!skb->rxhash)
 		skb->rxhash = 1;
 
