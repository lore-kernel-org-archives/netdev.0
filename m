From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] rps: optimize rps_get_cpu()
Date: Tue, 20 Apr 2010 17:55:58 +0800
Message-ID: <1271757358-8926-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f171.google.com ([209.85.210.171]:51818 "EHLO
	mail-yx0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab0DTJ4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 05:56:34 -0400
Received: by yxe1 with SMTP id 1so3592244yxe.33
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 02:56:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

optimize rps_get_cpu().

don't initialize ports when we can get the ports. one memory access for ports
than two.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/dev.c |   24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index b31d5d6..a281727 100644
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
@@ -2271,7 +2275,6 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	default:
 		goto done;
 	}
-	ports = 0;
 	switch (ip_proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
@@ -2281,25 +2284,20 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	case IPPROTO_SCTP:
 	case IPPROTO_UDPLITE:
 		if (pskb_may_pull(skb, (ihl * 4) + 4)) {
-			__be16 *hports = (__be16 *) (skb->data + (ihl * 4));
-			u32 sport, dport;
-
-			sport = (__force u16) hports[0];
-			dport = (__force u16) hports[1];
-			if (dport < sport)
-				swap(sport, dport);
-			ports = (sport << 16) + dport;
+			ports.v32 = * (__force u32 *) (skb->data + (ihl * 4));
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
 
