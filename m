From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Vague maybe ppp-related panic report for 2.6.23-rc9
Date: Fri, 5 Oct 2007 08:49:41 +0800
Message-ID: <20071005004941.GA8160@gondor.apana.org.au>
References: <ada4ph6da05.fsf@cisco.com> <20071004.135113.48807663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3367 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753550AbXJEAts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 20:49:48 -0400
Content-Disposition: inline
In-Reply-To: <20071004.135113.48807663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 04, 2007 at 01:51:13PM -0700, David Miller wrote:
> 
> I don't want to jump the gun on the analysis but it just might
> be the packet sharing fixes Herbert put in a short time ago.

I think the only change of mine that could affect ppp over a
serial line is this one.  I couldn't see anything obvious in
it but maybe someone else can.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
2a38b775b77f99308a4e571c13d908df78ac5e57
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
