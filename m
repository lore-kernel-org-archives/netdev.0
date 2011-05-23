From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sch_sfq: avoid giving spurious NET_XMIT_CN signals
Date: Mon, 23 May 2011 23:02:42 +0200
Message-ID: <1306184562.2638.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60760 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030336Ab1EWVCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 17:02:46 -0400
Received: by wya21 with SMTP id 21so4515850wya.19
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 14:02:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While chasing a possible net_sched bug, I found that IP fragments have
litle chance to pass a congestioned SFQ qdisc :

- Say SFQ qdisc is full because one flow is non responsive.
- ip_fragment() wants to send two fragments belonging to an idle flow.
- sfq_enqueue() queues first packet, but see queue limit reached :
- sfq_enqueue() drops one packet from 'big consumer', and returns
NET_XMIT_CN.
- ip_fragment() cancel remaining fragments.

This patch restores fairness, making sure we return NET_XMIT_CN only if
we dropped a packet from the same flow.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: Jamal Hadi Salim <hadi@cyberus.ca>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 net/sched/sch_sfq.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 7ef87f9..b1d00f8 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -361,7 +361,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned int hash;
-	sfq_index x;
+	sfq_index x, qlen;
 	struct sfq_slot *slot;
 	int uninitialized_var(ret);
 
@@ -405,8 +405,12 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (++sch->q.qlen <= q->limit)
 		return NET_XMIT_SUCCESS;
 
+	qlen = slot->qlen;
 	sfq_drop(sch);
-	return NET_XMIT_CN;
+	/* Return Congestion Notification only if we dropped a packet
+	 * from this flow.
+	 */
+	return (qlen != slot->qlen) ? NET_XMIT_CN : NET_XMIT_SUCCESS;
 }
 
 static struct sk_buff *


