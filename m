From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 09:56:38 +0200
Message-ID: <1271750198.3845.216.camel@edumazet-laptop>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
	 <1271743164.3845.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34393 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490Ab0DTH4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 03:56:44 -0400
Received: by bwz19 with SMTP id 19so39889bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 00:56:43 -0700 (PDT)
In-Reply-To: <1271743164.3845.128.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we compute a software skb->rxhash, we can generate a consistent
hash : Its value will be the same in both flow directions.

This helps some workloads, like conntracking, since the same state needs
to be accessed in both directions.

tbench + RFS + this patch gives better results than tbench with default
kernel configuration (no RPS, no RFS)

Also fixed some sparse warnings.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 05a2b29..cb150ec 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1974,7 +1974,7 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 	if (skb->sk && skb->sk->sk_hash)
 		hash = skb->sk->sk_hash;
 	else
-		hash = skb->protocol;
+		hash = (__force u16) skb->protocol;
 
 	hash = jhash_1word(hash, hashrnd);
 
@@ -2253,8 +2253,8 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 
 		ip = (struct iphdr *) skb->data;
 		ip_proto = ip->protocol;
-		addr1 = ip->saddr;
-		addr2 = ip->daddr;
+		addr1 = (__force u32) ip->saddr;
+		addr2 = (__force u32) ip->daddr;
 		ihl = ip->ihl;
 		break;
 	case __constant_htons(ETH_P_IPV6):
@@ -2263,8 +2263,8 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 
 		ip6 = (struct ipv6hdr *) skb->data;
 		ip_proto = ip6->nexthdr;
-		addr1 = ip6->saddr.s6_addr32[3];
-		addr2 = ip6->daddr.s6_addr32[3];
+		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
+		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
 		ihl = (40 >> 2);
 		break;
 	default:
@@ -2279,14 +2279,25 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	case IPPROTO_AH:
 	case IPPROTO_SCTP:
 	case IPPROTO_UDPLITE:
-		if (pskb_may_pull(skb, (ihl * 4) + 4))
-			ports = *((u32 *) (skb->data + (ihl * 4)));
+		if (pskb_may_pull(skb, (ihl * 4) + 4)) {
+			__be16 *hports = (__be16 *) (skb->data + (ihl * 4));
+			u32 sport, dport;
+
+			sport = (__force u16) hports[0];
+			dport = (__force u16) hports[1];
+			if (dport < sport)
+				swap(sport, dport);
+			ports = (sport << 16) + dport;
+		}
 		break;
 
 	default:
 		break;
 	}
 
+	/* get a consistent hash (same value on both flow directions) */
+	if (addr2 < addr1)
+		swap(addr1, addr2);
 	skb->rxhash = jhash_3words(addr1, addr2, ports, hashrnd);
 	if (!skb->rxhash)
 		skb->rxhash = 1;


