From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] pkt_sched: sch_drr: Fix drr_dequeue() loop
Date: Mon, 24 Nov 2008 13:15:07 +0100
Message-ID: <492A9ACB.4050504@trash.net>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net> <20081124105345.GB13957@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040407090903000307070301"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61942 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbYKXMPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 07:15:17 -0500
In-Reply-To: <20081124105345.GB13957@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040407090903000307070301
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:
> (Changelog fixed only)
> 
> pkt_sched: sch_drr: Fix drr_dequeue() loop
> 
> If all child qdiscs of sch_drr are non-work-conserving (e.g. sch_tbf)
> drr_dequeue() will busy-loop waiting for skbs instead of leaving the
> job for a watchdog. Checking for list_empty() in each loop isn't
> necessary either, because this can never be true except the first time.

Thanks for the report. I don't like to overcomplicate treatment
of this broken configuration though, so this patch simply returns
NULL when the inner qdiscs is non-work-conserving.




--------------040407090903000307070301
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit f995e708c778d5c3201d769ffae636f6941654ed
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 24 13:13:16 2008 +0100

    pkt_sched: sch_drr: fix drr_dequeue loop()
    
    Jarek Poplawski points out:
    
    If all child qdiscs of sch_drr are non-work-conserving (e.g. sch_tbf)
    drr_dequeue() will busy-loop waiting for skbs instead of leaving the
    job for a watchdog. Checking for list_empty() in each loop isn't
    necessary either, because this can never be true except the first time.
    
    Using non-work-conserving qdiscs as children of DRR makes no sense,
    simply bail out in that case.
    
    Reported-by: Jarek Poplawski <jarkao2@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 37e6ab9..e7a7e87 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -373,11 +373,13 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 	struct sk_buff *skb;
 	unsigned int len;
 
-	while (!list_empty(&q->active)) {
+	if (list_empty(&q->active))
+		goto out;
+	while (1) {
 		cl = list_first_entry(&q->active, struct drr_class, alist);
 		skb = cl->qdisc->ops->peek(cl->qdisc);
 		if (skb == NULL)
-			goto skip;
+			goto out;
 
 		len = qdisc_pkt_len(skb);
 		if (len <= cl->deficit) {
@@ -390,9 +392,9 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 		}
 
 		cl->deficit += cl->quantum;
-skip:
 		list_move_tail(&cl->alist, &q->active);
 	}
+out:
 	return NULL;
 }
 

--------------040407090903000307070301--
