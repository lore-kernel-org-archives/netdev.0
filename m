From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Wed, 20 Feb 2008 00:06:40 +0100
Message-ID: <20080219230640.GA2755@ami.dom.local>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:5138 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759113AbYBSXDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 18:03:41 -0500
Received: by ug-out-1314.google.com with SMTP id z38so656168ugc.16
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 15:03:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47BA0214.40703@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2008 at 10:09:24PM +0000, James Chapman wrote:
...
> Unfortunately the ISP's syslog stops. But I've been able to borrow
> two Quad Xeon boxes and have reproduced the problem.
>
> Here's a new version of the patch. The patch avoids disabling irqs
> and fixes the sk_dst_get() usage that DaveM mentioned. But even with
> this patch, lockdep still complains if hundreds of ppp sessions are
> inserted into a tunnel as rapidly as possible (lockdep trace is below).
> I can stop these errors by wrapping the call to ppp_input() in
> pppol2tp_recv_dequeue_skb() with local_irq_save/restore. What is a
> better fix?

I send here my proposal: it's intended for testing and to check one of
possible solutions here. IMHO your lockdep reports show there is no
use to change anything around sk_dst_lock: it would need the global
change of this lock to fix this problem. So the fix should be done
around pch->upl lock and this means changing ppp_generic.

In the patch below I've used trylock in places which seem to allow
for skipping some things (while config is changed only) or simply
don't need this lock because there is no ppp struct. This could be
modified to add some waiting loop if necessary. Another option is to
change the write side of this lock: it looks like more vulnerable if
something missed because there are more locks involved, but probably
should be enough to solve this problem too.

I think pppol2tp need to be first checked only with hlist_lock bh
patch, unless there were some lockdep reports on these other locks
too. (BTW, I added ppp maintainer to CC - I hope we get Paul's opinion
on this.)

Regards,
Jarek P.

(testing patch #1)
---

 drivers/net/ppp_generic.c |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 4dc5b4b..5cbc534 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1473,7 +1473,7 @@ void
 ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct channel *pch = chan->ppp;
-	int proto;
+	int proto, locked;
 
 	if (!pch || skb->len == 0) {
 		kfree_skb(skb);
@@ -1481,8 +1481,13 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 	}
 
 	proto = PPP_PROTO(skb);
-	read_lock_bh(&pch->upl);
-	if (!pch->ppp || proto >= 0xc000 || proto == PPP_CCPFRAG) {
+	/*
+	 * We use trylock to avoid dependency between soft-irq-safe upl lock
+	 * and soft-irq-unsafe sk_dst_lock.
+	 */
+	local_bh_disable();
+	locked = read_trylock(&pch->upl);
+	if (!locked || !pch->ppp || proto >= 0xc000 || proto == PPP_CCPFRAG) {
 		/* put it on the channel queue */
 		skb_queue_tail(&pch->file.rq, skb);
 		/* drop old frames if queue too long */
@@ -1493,7 +1498,10 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 	} else {
 		ppp_do_recv(pch->ppp, skb, pch);
 	}
-	read_unlock_bh(&pch->upl);
+
+	if (locked)
+		read_unlock(&pch->upl);
+	local_bh_enable();
 }
 
 /* Put a 0-length skb in the receive queue as an error indication */
@@ -1506,16 +1514,18 @@ ppp_input_error(struct ppp_channel *chan, int code)
 	if (!pch)
 		return;
 
-	read_lock_bh(&pch->upl);
-	if (pch->ppp) {
+	/* a trylock comment in ppp_input() */
+	local_bh_disable();
+	if (read_trylock(&pch->upl) && pch->ppp) {
 		skb = alloc_skb(0, GFP_ATOMIC);
 		if (skb) {
 			skb->len = 0;		/* probably unnecessary */
 			skb->cb[0] = code;
 			ppp_do_recv(pch->ppp, skb, pch);
 		}
+		read_unlock(&pch->upl);
 	}
-	read_unlock_bh(&pch->upl);
+	local_bh_enable();
 }
 
 /*
@@ -2044,10 +2054,13 @@ int ppp_unit_number(struct ppp_channel *chan)
 	int unit = -1;
 
 	if (pch) {
-		read_lock_bh(&pch->upl);
-		if (pch->ppp)
+		/* a trylock comment in ppp_input() */
+		local_bh_disable();
+		if (read_trylock(&pch->upl) && pch->ppp) {
 			unit = pch->ppp->file.index;
-		read_unlock_bh(&pch->upl);
+			read_unlock(&pch->upl);
+		}
+		local_bh_enable();
 	}
 	return unit;
 }
