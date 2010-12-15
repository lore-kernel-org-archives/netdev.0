From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Wed, 15 Dec 2010 16:50:52 +0100
Message-ID: <1292428252.3427.342.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57135 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450Ab0LOPu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 10:50:57 -0500
Received: by wyb28 with SMTP id 28so1594867wyb.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 07:50:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 8caf153974f2 (net: sch_netem: Fix an inconsistency in ingress
netem timestamps.), Jarek added a logic to refresh timestamps of
ingressed packets going through netem.

I believe we should generalize this, forcing a refresh of timestamps in
dev_queue_xmit_nit() for all ingress packets, whatever qdisc/class they
used before being delivered.

This way, we can have a good idea when packets are delivered to our
stack (tcpdump -i ifb0), while a tcpdump on original device gives
timestamps right before ingressing.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c        |    2 +-
 net/sched/sch_netem.c |    8 --------
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..a2846f8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1506,7 +1506,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 	struct packet_type *ptype;
 
 #ifdef CONFIG_NET_CLS_ACT
-	if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & AT_INGRESS)))
+	if (!skb->tstamp.tv64 || (G_TC_FROM(skb->tc_verd) & AT_INGRESS))
 		net_timestamp_set(skb);
 #else
 	net_timestamp_set(skb);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index e5593c0..1c29cc0 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -281,14 +281,6 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 			if (unlikely(!skb))
 				return NULL;
 
-#ifdef CONFIG_NET_CLS_ACT
-			/*
-			 * If it's at ingress let's pretend the delay is
-			 * from the network (tstamp will be updated).
-			 */
-			if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
-				skb->tstamp.tv64 = 0;
-#endif
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
 			sch->q.qlen--;
 			return skb;


