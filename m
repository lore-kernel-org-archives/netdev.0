From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add rbnode to struct sk_buff
Date: Mon, 03 Nov 2014 08:19:53 -0800
Message-ID: <1415031593.14083.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yaogong Wang <wygivan@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36609 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615AbaKCQT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 11:19:56 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn18so4926469igb.13
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 08:19:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Yaogong replaces TCP out of order receive queue by an RB tree.

As netem already does a private skb->{next/prev/tstamp} union
with a 'struct rb_node', lets do this in a cleaner way.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yaogong Wang <wygivan@google.com>
---
 include/linux/skbuff.h |   20 +++++++++++++-------
 net/sched/sch_netem.c  |   27 +++++++--------------------
 2 files changed, 20 insertions(+), 27 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6c8b6f604e7609f2d320a7aa572a8ec6a870f4b8..5ad9675b6fe17b2819476c181a4707780a2e03f2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -20,6 +20,7 @@
 #include <linux/time.h>
 #include <linux/bug.h>
 #include <linux/cache.h>
+#include <linux/rbtree.h>
 
 #include <linux/atomic.h>
 #include <asm/types.h>
@@ -440,6 +441,7 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  *	@next: Next buffer in list
  *	@prev: Previous buffer in list
  *	@tstamp: Time we arrived/left
+ *	@rbnode: RB tree node, alternative to next/prev for netem/tcp
  *	@sk: Socket we are owned by
  *	@dev: Device we arrived on/are leaving by
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
@@ -504,15 +506,19 @@ static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
  */
 
 struct sk_buff {
-	/* These two members must be first. */
-	struct sk_buff		*next;
-	struct sk_buff		*prev;
-
 	union {
-		ktime_t		tstamp;
-		struct skb_mstamp skb_mstamp;
+		struct {
+			/* These two members must be first. */
+			struct sk_buff		*next;
+			struct sk_buff		*prev;
+
+			union {
+				ktime_t		tstamp;
+				struct skb_mstamp skb_mstamp;
+			};
+		};
+		struct rb_node	rbnode; /* used in netem & tcp stack */
 	};
-
 	struct sock		*sk;
 	struct net_device	*dev;
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index b34331967e020b6f1151b25be8f744e494a80ad6..179f1c8c0d8bba4aa00705e6c9ca41ef909f7d50 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -139,33 +139,20 @@ struct netem_sched_data {
 
 /* Time stamp put into socket buffer control block
  * Only valid when skbs are in our internal t(ime)fifo queue.
+ *
+ * As skb->rbnode uses same storage than skb->next, skb->prev and skb->tstamp,
+ * and skb->next & skb->prev are scratch space for a qdisc,
+ * we save skb->tstamp value in skb->cb[] before destroying it.
  */
 struct netem_skb_cb {
 	psched_time_t	time_to_send;
 	ktime_t		tstamp_save;
 };
 
-/* Because space in skb->cb[] is tight, netem overloads skb->next/prev/tstamp
- * to hold a rb_node structure.
- *
- * If struct sk_buff layout is changed, the following checks will complain.
- */
-static struct rb_node *netem_rb_node(struct sk_buff *skb)
-{
-	BUILD_BUG_ON(offsetof(struct sk_buff, next) != 0);
-	BUILD_BUG_ON(offsetof(struct sk_buff, prev) !=
-		     offsetof(struct sk_buff, next) + sizeof(skb->next));
-	BUILD_BUG_ON(offsetof(struct sk_buff, tstamp) !=
-		     offsetof(struct sk_buff, prev) + sizeof(skb->prev));
-	BUILD_BUG_ON(sizeof(struct rb_node) > sizeof(skb->next) +
-					      sizeof(skb->prev) +
-					      sizeof(skb->tstamp));
-	return (struct rb_node *)&skb->next;
-}
 
 static struct sk_buff *netem_rb_to_skb(struct rb_node *rb)
 {
-	return (struct sk_buff *)rb;
+	return container_of(rb, struct sk_buff, rbnode);
 }
 
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
@@ -403,8 +390,8 @@ static void tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 		else
 			p = &parent->rb_left;
 	}
-	rb_link_node(netem_rb_node(nskb), parent, p);
-	rb_insert_color(netem_rb_node(nskb), &q->t_root);
+	rb_link_node(&nskb->rbnode, parent, p);
+	rb_insert_color(&nskb->rbnode, &q->t_root);
 	sch->q.qlen++;
 }
 
