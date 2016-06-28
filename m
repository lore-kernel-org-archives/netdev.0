From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: netem: do not call qdisc_drop() with a
 NULL skb
Date: Tue, 28 Jun 2016 10:30:08 +0200
Message-ID: <1467102608.6850.196.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33953 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbcF1IaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 04:30:15 -0400
Received: by mail-wm0-f66.google.com with SMTP id 187so3787159wmz.1
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 01:30:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If skb_unshare() fails, we call qdisc_drop() with a NULL skb, which
is no longer supported.

Fixes: 520ac30f4551 ("net_sched: drop packets after root qdisc lock is released")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/sched/sch_netem.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index ccca8ca4c722c603e8b8e6052eead51243e590b5..6eac3d8800480a4c463ae8d3b78a4fcfeec8165b 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -487,10 +487,14 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 		skb = segs;
 		segs = segs->next;
 
-		if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
-		    (skb->ip_summed == CHECKSUM_PARTIAL &&
-		     skb_checksum_help(skb))) {
-			rc = qdisc_drop(skb, sch, to_free);
+		skb = skb_unshare(skb, GFP_ATOMIC);
+		if (unlikely(!skb)) {
+			qdisc_qstats_drop(sch);
+			goto finish_segs;
+		}
+		if (skb->ip_summed == CHECKSUM_PARTIAL &&
+		    skb_checksum_help(skb)) {
+			qdisc_drop(skb, sch, to_free);
 			goto finish_segs;
 		}
 
