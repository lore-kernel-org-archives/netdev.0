From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] sfq: fix sfq stats handling
Date: Wed, 22 Dec 2010 07:14:59 +0100
Message-ID: <1292998499.4317.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55737 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab0LVGPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 01:15:05 -0500
Received: by wyb28 with SMTP id 28so4699774wyb.19
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 22:15:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, since this one fixes a bug, could you apply it before the pending
SFQ patch (sch_sfq: allow big packets and be fair), I'll respin this one
if necessary.

Thanks

[PATCH net-next-2.6] sfq: fix sfq class stats handling

sfq_walk() runs without qdisc lock. By the time it selects a non empty
hash slot and sfq_dump_class_stats() is run (with lock held), slot might
have been freed : We then access q->slots[SFQ_EMPTY_SLOT], out of
bounds, and crash in slot_queue_walk()

On previous kernels, bug is here but out of bounds qs[SFQ_DEPTH] and
allot[SFQ_DEPTH] are located in struct sfq_sched_data, so no illegal
memory access happens, only possibly wrong data reported to user.

Also, slot_dequeue_tail() should make sure slot skb chain is correctly
terminated, or sfq_dump_class_stats() can access freed skbs.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_sfq.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 13322e8..6a2f88f 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -281,6 +281,7 @@ static inline struct sk_buff *slot_dequeue_tail(struct sfq_slot *slot)
 	struct sk_buff *skb = slot->skblist_prev;
 
 	slot->skblist_prev = skb->prev;
+	skb->prev->next = (struct sk_buff *)slot;
 	skb->next = skb->prev = NULL;
 	return skb;
 }
@@ -608,14 +609,19 @@ static int sfq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 				struct gnet_dump *d)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	const struct sfq_slot *slot = &q->slots[q->ht[cl - 1]];
-	struct gnet_stats_queue qs = { .qlen = slot->qlen };
-	struct tc_sfq_xstats xstats = { .allot = slot->allot };
+	sfq_index idx = q->ht[cl - 1];
+	struct gnet_stats_queue qs = { 0 };
+	struct tc_sfq_xstats xstats = { 0 };
 	struct sk_buff *skb;
 
-	slot_queue_walk(slot, skb)
-		qs.backlog += qdisc_pkt_len(skb);
+	if (idx != SFQ_EMPTY_SLOT) {
+		const struct sfq_slot *slot = &q->slots[idx];
 
+		xstats.allot = slot->allot;
+		qs.qlen = slot->qlen;
+		slot_queue_walk(slot, skb)
+			qs.backlog += qdisc_pkt_len(skb);
+	}
 	if (gnet_stats_copy_queue(d, &qs) < 0)
 		return -1;
 	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));


