From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Thu, 19 May 2016 21:56:35 -0700
Message-ID: <1463720195.18194.267.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
	 <1463684190.18194.228.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463686523.18194.232.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0Udd+8PtOfZzR3VqEGyUPLifEjDzK0x3cezxcN9Ltq_KzQ@mail.gmail.com>
	 <573E9766.7080105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35983 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035AbcETE4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 00:56:39 -0400
Received: by mail-pf0-f194.google.com with SMTP id g132so10121564pfb.3
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 21:56:38 -0700 (PDT)
In-Reply-To: <573E9766.7080105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 21:49 -0700, John Fastabend wrote:

> I plan to start looking at this again in June when I have some
> more time FWIW. The last set of RFCs I sent out bypassed both the
> qdisc lock and the busy poll lock. I remember thinking this was a
> net win at the time but I only did very basic testing e.g. firing
> up n sessions of pktgen.
> 
> And because we are talking about cruft I always thought the gso_skb
> requeue logic could be done away with as well. As far as I can tell
> it must be there from some historic code that has been re-factored
> or deleted pre-git days. It would be much better I think (no data)
> to use byte queue limits or some other way to ensure the driver can
> consume the packet vs popping and pushing skbs around.

Problem is : byte queue limit can tell qdisc to send one packet, that
happens to be a GSO packet needing software segmentation.

(BQL does not know the size of the next packet to be dequeued from
qdisc)

Let say this GSO packet had 45 segs.

Then the driver has a limited TX ring space and only accepts 10 segs,
or simply BQL budget is consumed after 10 segs.

You need to requeue the remaining 35 segs.

So for example, following patch does not even help the requeue syndrom.

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 269dd71b3828..a440c059fbcf 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -60,7 +60,7 @@ static void try_bulk_dequeue_skb(struct Qdisc *q,
 				 const struct netdev_queue *txq,
 				 int *packets)
 {
-	int bytelimit = qdisc_avail_bulklimit(txq) - skb->len;
+	int bytelimit = qdisc_avail_bulklimit(txq) - qdisc_skb_cb(skb)->pkt_len;
 
 	while (bytelimit > 0) {
 		struct sk_buff *nskb = q->dequeue(q);
@@ -68,7 +68,7 @@ static void try_bulk_dequeue_skb(struct Qdisc *q,
 		if (!nskb)
 			break;
 
-		bytelimit -= nskb->len; /* covers GSO len */
+		bytelimit -= qdisc_skb_cb(nskb)->pkt_len;
 		skb->next = nskb;
 		skb = nskb;
 		(*packets)++; /* GSO counts as one pkt */
