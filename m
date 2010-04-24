From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sat, 24 Apr 2010 23:17:07 +0800
Message-ID: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58123 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab0DXPgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 11:36:08 -0400
Received: by pwj9 with SMTP id 9so7555126pwj.19
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 08:36:07 -0700 (PDT)
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
index a4a7c36..4d43f1a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2229,7 +2229,11 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
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
@@ -2275,7 +2279,6 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	default:
 		goto done;
 	}
-	ports = 0;
 	switch (ip_proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
@@ -2285,25 +2288,20 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
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
+			if (ports.v16[1] < ports.v16[0])
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
 
