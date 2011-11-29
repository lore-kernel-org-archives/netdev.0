From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sch_sfq: use skb_flow_dissect()
Date: Tue, 29 Nov 2011 14:40:45 +0100
Message-ID: <1322574045.2465.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56022 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127Ab1K2Nks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 08:40:48 -0500
Received: by qadc14 with SMTP id c14so1957092qad.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 05:40:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a custom flow dissector, use skb_flow_dissect() and
benefit from tunnelling support.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |   65 ++++++------------------------------------
 1 file changed, 10 insertions(+), 55 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 4f5510e..c8da556 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -17,14 +17,13 @@
 #include <linux/in.h>
 #include <linux/errno.h>
 #include <linux/init.h>
-#include <linux/ipv6.h>
 #include <linux/skbuff.h>
 #include <linux/jhash.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
-#include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/flow_keys.h>
 
 
 /*	Stochastic Fairness Queuing algorithm.
@@ -137,61 +136,17 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 	return &q->dep[val - SFQ_SLOTS];
 }
 
-static unsigned int sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
+static unsigned int sfq_hash(const struct sfq_sched_data *q,
+			     const struct sk_buff *skb)
 {
-	return jhash_2words(h, h1, q->perturbation) & (q->divisor - 1);
-}
-
-static unsigned int sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
-{
-	u32 h, h2;
-
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-	{
-		const struct iphdr *iph;
-		int poff;
-
-		if (!pskb_network_may_pull(skb, sizeof(*iph)))
-			goto err;
-		iph = ip_hdr(skb);
-		h = (__force u32)iph->daddr;
-		h2 = (__force u32)iph->saddr ^ iph->protocol;
-		if (ip_is_fragment(iph))
-			break;
-		poff = proto_ports_offset(iph->protocol);
-		if (poff >= 0 &&
-		    pskb_network_may_pull(skb, iph->ihl * 4 + 4 + poff)) {
-			iph = ip_hdr(skb);
-			h2 ^= *(u32 *)((void *)iph + iph->ihl * 4 + poff);
-		}
-		break;
-	}
-	case htons(ETH_P_IPV6):
-	{
-		const struct ipv6hdr *iph;
-		int poff;
-
-		if (!pskb_network_may_pull(skb, sizeof(*iph)))
-			goto err;
-		iph = ipv6_hdr(skb);
-		h = (__force u32)iph->daddr.s6_addr32[3];
-		h2 = (__force u32)iph->saddr.s6_addr32[3] ^ iph->nexthdr;
-		poff = proto_ports_offset(iph->nexthdr);
-		if (poff >= 0 &&
-		    pskb_network_may_pull(skb, sizeof(*iph) + 4 + poff)) {
-			iph = ipv6_hdr(skb);
-			h2 ^= *(u32 *)((void *)iph + sizeof(*iph) + poff);
-		}
-		break;
-	}
-	default:
-err:
-		h = (unsigned long)skb_dst(skb) ^ (__force u32)skb->protocol;
-		h2 = (unsigned long)skb->sk;
-	}
+	struct flow_keys keys;
+	unsigned int hash;
 
-	return sfq_fold_hash(q, h, h2);
+	skb_flow_dissect(skb, &keys);
+	hash = jhash_3words((__force u32)keys.dst,
+			    (__force u32)keys.src ^ keys.ip_proto,
+			    (__force u32)keys.ports, q->perturbation);
+	return hash & (q->divisor - 1);
 }
 
 static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
