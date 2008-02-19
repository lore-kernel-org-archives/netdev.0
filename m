From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Wed, 20 Feb 2008 00:28:40 +0100
Message-ID: <20080219232840.GB2755@ami.dom.local>
References: <47B0C9F7.5040200@katalix.com> <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:60439 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbYBSXZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 18:25:42 -0500
Received: by ug-out-1314.google.com with SMTP id z38so659167ugc.16
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 15:25:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080219230640.GA2755@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2008 at 12:06:40AM +0100, Jarek Poplawski wrote:
...
> (testing patch #1)

SORRY!!! ----> take 2 (unlocking fixed)

---

 drivers/net/ppp_generic.c |   39 +++++++++++++++++++++++++++++----------
 1 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 4dc5b4b..c4e3808 100644
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
@@ -1502,12 +1510,14 @@ ppp_input_error(struct ppp_channel *chan, int code)
 {
 	struct channel *pch = chan->ppp;
 	struct sk_buff *skb;
+	int locked;
 
 	if (!pch)
 		return;
 
-	read_lock_bh(&pch->upl);
-	if (pch->ppp) {
+	/* a trylock comment in ppp_input() */
+	local_bh_disable();
+	if ((locked = read_trylock(&pch->upl)) && pch->ppp) {
 		skb = alloc_skb(0, GFP_ATOMIC);
 		if (skb) {
 			skb->len = 0;		/* probably unnecessary */
@@ -1515,7 +1525,10 @@ ppp_input_error(struct ppp_channel *chan, int code)
 			ppp_do_recv(pch->ppp, skb, pch);
 		}
 	}
-	read_unlock_bh(&pch->upl);
+
+	if (locked)
+		read_unlock(&pch->upl);
+	local_bh_enable();
 }
 
 /*
@@ -2044,10 +2057,16 @@ int ppp_unit_number(struct ppp_channel *chan)
 	int unit = -1;
 
 	if (pch) {
-		read_lock_bh(&pch->upl);
-		if (pch->ppp)
+		int locked;
+
+		/* a trylock comment in ppp_input() */
+		local_bh_disable();
+		if ((locked = read_trylock(&pch->upl)) && pch->ppp)
 			unit = pch->ppp->file.index;
-		read_unlock_bh(&pch->upl);
+
+		if (locked)
+			read_unlock(&pch->upl);
+		local_bh_enable();
 	}
 	return unit;
 }
