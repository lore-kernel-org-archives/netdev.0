From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sched: factorize code (qdisc_drop())
Date: Fri, 04 May 2012 16:37:21 +0200
Message-ID: <1336142241.3752.331.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40236 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab2EDOhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 10:37:25 -0400
Received: by bkcji2 with SMTP id ji2so2268687bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 07:37:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use qdisc_drop() helper where possible.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_choke.c  |    8 +++-----
 net/sched/sch_dsmark.c |    3 +--
 net/sched/sch_htb.c    |    4 +---
 net/sched/sch_teql.c   |    4 +---
 4 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 81445cc..cc37dd5 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -332,15 +332,13 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 
 	q->stats.pdrop++;
-	sch->qstats.drops++;
-	kfree_skb(skb);
-	return NET_XMIT_DROP;
+	return qdisc_drop(skb, sch);
 
- congestion_drop:
+congestion_drop:
 	qdisc_drop(skb, sch);
 	return NET_XMIT_CN;
 
- other_drop:
+other_drop:
 	if (ret & __NET_XMIT_BYPASS)
 		sch->qstats.drops++;
 	kfree_skb(skb);
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 389b856..3886365 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -265,8 +265,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 
 drop:
-	kfree_skb(skb);
-	sch->qstats.drops++;
+	qdisc_drop(skb, sch);
 	return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 }
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2ea6f19..acae5b0 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -558,9 +558,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 			__skb_queue_tail(&q->direct_queue, skb);
 			q->direct_pkts++;
 		} else {
-			kfree_skb(skb);
-			sch->qstats.drops++;
-			return NET_XMIT_DROP;
+			return qdisc_drop(skb, sch);
 		}
 #ifdef CONFIG_NET_CLS_ACT
 	} else if (!cl) {
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 4532659..ca0c296 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -88,9 +88,7 @@ teql_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return NET_XMIT_SUCCESS;
 	}
 
-	kfree_skb(skb);
-	sch->qstats.drops++;
-	return NET_XMIT_DROP;
+	return qdisc_drop(skb, sch);
 }
 
 static struct sk_buff *
