From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/7] [PPP] generic: Fix receive path data clobbering & non-linear handling
Date: Fri, 31 Aug 2007 17:11:36 +0800
Message-ID: <E1IR2XQ-0007QT-00@gondolin.me.apana.org.au>
References: <20070831090625.GA28175@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3603 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759061AbXHaJLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:11:40 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IR2XR-0004Rg-BK
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 19:11:37 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IR2XQ-0007QT-00
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 17:11:36 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP] generic: Fix receive path data clobbering & non-linear handling

This patch adds missing pskb_may_pull calls to deal with non-linear
packets that may arrive from pppoe or pppol2tp.

It also copies cloned packets before writing over them.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/ppp_generic.c |   44 +++++++++++++++++++++++++-------------------
 1 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 7e21342..4b49d0e 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1525,7 +1525,7 @@ ppp_input_error(struct ppp_channel *chan, int code)
 static void
 ppp_receive_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 {
-	if (skb->len >= 2) {
+	if (pskb_may_pull(skb, 2)) {
 #ifdef CONFIG_PPP_MULTILINK
 		/* XXX do channel-level decompression here */
 		if (PPP_PROTO(skb) == PPP_MP)
@@ -1577,7 +1577,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 		if (ppp->vj == 0 || (ppp->flags & SC_REJ_COMP_TCP))
 			goto err;
 
-		if (skb_tailroom(skb) < 124) {
+		if (skb_tailroom(skb) < 124 || skb_cloned(skb)) {
 			/* copy to a new sk_buff with more tailroom */
 			ns = dev_alloc_skb(skb->len + 128);
 			if (ns == 0) {
@@ -1648,23 +1648,29 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 		/* check if the packet passes the pass and active filters */
 		/* the filter instructions are constructed assuming
 		   a four-byte PPP header on each packet */
-		*skb_push(skb, 2) = 0;
-		if (ppp->pass_filter
-		    && sk_run_filter(skb, ppp->pass_filter,
-				     ppp->pass_len) == 0) {
-			if (ppp->debug & 1)
-				printk(KERN_DEBUG "PPP: inbound frame not passed\n");
-			kfree_skb(skb);
-			return;
-		}
-		if (!(ppp->active_filter
-		      && sk_run_filter(skb, ppp->active_filter,
-				       ppp->active_len) == 0))
-			ppp->last_recv = jiffies;
-		skb_pull(skb, 2);
-#else
-		ppp->last_recv = jiffies;
+		if (ppp->pass_filter || ppp->active_filter) {
+			if (skb_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				goto err;
+
+			*skb_push(skb, 2) = 0;
+			if (ppp->pass_filter
+			    && sk_run_filter(skb, ppp->pass_filter,
+					     ppp->pass_len) == 0) {
+				if (ppp->debug & 1)
+					printk(KERN_DEBUG "PPP: inbound frame "
+					       "not passed\n");
+				kfree_skb(skb);
+				return;
+			}
+			if (!(ppp->active_filter
+			      && sk_run_filter(skb, ppp->active_filter,
+					       ppp->active_len) == 0))
+				ppp->last_recv = jiffies;
+			__skb_pull(skb, 2);
+		} else
 #endif /* CONFIG_PPP_FILTER */
+			ppp->last_recv = jiffies;
 
 		if ((ppp->dev->flags & IFF_UP) == 0
 		    || ppp->npmode[npi] != NPMODE_PASS) {
@@ -1762,7 +1768,7 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 	struct channel *ch;
 	int mphdrlen = (ppp->flags & SC_MP_SHORTSEQ)? MPHDRLEN_SSN: MPHDRLEN;
 
-	if (!pskb_may_pull(skb, mphdrlen) || ppp->mrru == 0)
+	if (!pskb_may_pull(skb, mphdrlen + 1) || ppp->mrru == 0)
 		goto err;		/* no good, throw it away */
 
 	/* Decode sequence number and begin/end bits */
