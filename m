From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_qfq: fix overflow in qfq_update_start()
Date: Mon, 02 Jan 2012 16:47:57 +0100
Message-ID: <1325519277.2375.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Dave Taht <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:50098 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab2ABPsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 10:48:00 -0500
Received: by wibhm6 with SMTP id hm6so8469078wib.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 07:47:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

grp->slot_shift is between 22 and 41, so using 32bit wide variables is
probably a typo.

This could explain QFQ hangs Dave reported to me, after 2^23 packets ?

(23 = 64 - 41)

Reported-by: Dave Taht <dave.taht@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Dave Taht <dave.taht@gmail.com>
---
 net/sched/sch_qfq.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 1033434..7b03254 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -817,11 +817,11 @@ skip_unblock:
 static void qfq_update_start(struct qfq_sched *q, struct qfq_class *cl)
 {
 	unsigned long mask;
-	uint32_t limit, roundedF;
+	u64 limit, roundedF;
 	int slot_shift = cl->grp->slot_shift;
 
 	roundedF = qfq_round_down(cl->F, slot_shift);
-	limit = qfq_round_down(q->V, slot_shift) + (1UL << slot_shift);
+	limit = qfq_round_down(q->V, slot_shift) + (1ULL << slot_shift);
 
 	if (!qfq_gt(cl->F, q->V) || qfq_gt(roundedF, limit)) {
 		/* timestamp was stale */
