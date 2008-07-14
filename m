From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 14 Jul 2008 23:22:23 +0200
Message-ID: <20080714212223.GA4849@ami.dom.local>
References: <20080710223141.GA2519@orion.carnet.hr> <20080710.162007.04790623.davem@davemloft.net> <20080711092416.GA26515@orion.carnet.hr> <20080711.025656.261409874.davem@davemloft.net> <48787E1A.3030804@gmail.com> <4878AFD8.1000307@gmail.com> <487B7061.5040306@trash.net> <20080714172055.GA2638@ami.dom.local> <20080714202151.GA28622@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org, devik@cdi.cz
To: Josip Rodin <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:51577 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842AbYGNVVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 17:21:11 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2167649fgg.17
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 14:21:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080714202151.GA28622@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 10:21:51PM +0200, Josip Rodin wrote:
> On Mon, Jul 14, 2008 at 07:20:55PM +0200, Jarek Poplawski wrote:
...
> > BTW, I wonder how Josip's testing?
> 
> Do you want me to try out David's patch? I was hoping to get a definite okay
> from someone before applying it, given that this is a production machine
> for us and we do need it in *some* kind of an operational state.

Hmm... if you trust me more than David?! As a matter of fact, I thought
it's under testing already, but since I've some doubts, I attach below
my version of David's patch. IMHO, it looks safe, but never knows...

> I've got many more tens of kilobytes of logs from the previous debugging
> patches, if you want I can send them over.

This debugging, I guess, shows corrupted data, but the reason is hard
to find. David found one of possible reasons and it needs checking. I
don't think this patch in any version can do more damage than doing
nothing - unless you prefer to use Michael's patch to next kernels
(BTW, don't remove this patch yet).

Thanks,
Jarek P.

---

diff -Nurp 2.6.25.4-/net/sched/sch_htb.c 2.6.25.4+/net/sched/sch_htb.c
--- 2.6.25.4-/net/sched/sch_htb.c	2008-05-17 19:23:44.000000000 +0200
+++ 2.6.25.4+/net/sched/sch_htb.c	2008-07-14 22:39:28.000000000 +0200
@@ -576,6 +576,7 @@ static int htb_enqueue(struct sk_buff *s
 		if (q->direct_queue.qlen < q->direct_qlen) {
 			__skb_queue_tail(&q->direct_queue, skb);
 			q->direct_pkts++;
+			ret = NET_XMIT_SUCCESS;
 		} else {
 			kfree_skb(skb);
 			sch->qstats.drops++;
@@ -588,22 +589,27 @@ static int htb_enqueue(struct sk_buff *s
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
-		   NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
-		return NET_XMIT_DROP;
 	} else {
-		cl->bstats.packets +=
-			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-		cl->bstats.bytes += skb->len;
-		htb_activate(q, cl);
+		ret = cl->un.leaf.q->enqueue(skb, cl->un.leaf.q);
+		if (ret == NET_XMIT_DROP) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		} else {
+			cl->bstats.packets +=
+				skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
+			cl->bstats.bytes += skb->len;
+			if (ret == NET_XMIT_SUCCESS)
+				htb_activate(q, cl);
+		}
 	}
 
-	sch->q.qlen++;
-	sch->bstats.packets += skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-	sch->bstats.bytes += skb->len;
-	return NET_XMIT_SUCCESS;
+	if (ret == NET_XMIT_SUCCESS) {
+		sch->q.qlen++;
+		sch->bstats.packets +=
+			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
+		sch->bstats.bytes += skb->len;
+	}
+	return ret;
 }
 
 /* TODO: requeuing packet charges it to policers again !! */
@@ -618,6 +624,7 @@ static int htb_requeue(struct sk_buff *s
 		/* enqueue to helper queue */
 		if (q->direct_queue.qlen < q->direct_qlen) {
 			__skb_queue_head(&q->direct_queue, skb);
+			ret = NET_XMIT_SUCCESS;
 		} else {
 			__skb_queue_head(&q->direct_queue, skb);
 			tskb = __skb_dequeue_tail(&q->direct_queue);
@@ -632,17 +639,21 @@ static int htb_requeue(struct sk_buff *s
 		kfree_skb(skb);
 		return ret;
 #endif
-	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
-		   NET_XMIT_SUCCESS) {
-		sch->qstats.drops++;
-		cl->qstats.drops++;
-		return NET_XMIT_DROP;
-	} else
-		htb_activate(q, cl);
-
-	sch->q.qlen++;
-	sch->qstats.requeues++;
-	return NET_XMIT_SUCCESS;
+	} else {
+		ret = cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q);
+		if (ret == NET_XMIT_DROP) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		} else if (ret == NET_XMIT_SUCCESS) {
+			htb_activate(q, cl);
+		}
+	}
+
+	if (ret == NET_XMIT_SUCCESS) {
+		sch->q.qlen++;
+		sch->qstats.requeues++;
+	}
+	return ret;
 }
 
 /**
