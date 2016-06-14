From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/10] net_sched: sch_netem: defer skb freeing
Date: Mon, 13 Jun 2016 20:21:57 -0700
Message-ID: <1465874519-25494-9-git-send-email-edumazet@google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33219 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423760AbcFNDYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 23:24:03 -0400
Received: by mail-pf0-f181.google.com with SMTP id y124so52573093pfy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 20:24:03 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl_kfree_skbs() can be used in tfifo_reset()

It would be nice if we could iterate through rb tree instead
of removing one skb at a time, and build a single skb chain.
But this is left for a future patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_netem.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 876df13c745a..e271967439bf 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -368,9 +368,7 @@ static void tfifo_reset(struct Qdisc *sch)
 		struct sk_buff *skb = netem_rb_to_skb(p);
 
 		rb_erase(p, &q->t_root);
-		skb->next = NULL;
-		skb->prev = NULL;
-		kfree_skb(skb);
+		rtnl_kfree_skbs(skb, skb);
 	}
 }
 
-- 
2.8.0.rc3.226.g39d4020
