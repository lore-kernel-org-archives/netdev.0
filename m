From: David Miller <davem@davemloft.net>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 03:49:50 -0700 (PDT)
Message-ID: <20080501.034950.261408566.davem@davemloft.net>
References: <20080501.024320.212547875.davem@davemloft.net>
	<E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752563AbYEAKtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:49:51 -0400
In-Reply-To: <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 01 May 2008 18:36:49 +0800

> David Miller <davem@davemloft.net> wrote:
> > +       /* This is safe because the buffer has been orphaned.  */
> > +       skb->truesize += sizeof(*rthdr);
> 
> skb->truesize should always account the skb->head area in its
> entirety so we should never need to adjust it when pushing or
> pulling.  So I suggest we find the place that expanded the head
> area and make the adjustment there.  Alternative we could adjust
> it right after the orphan call if the expansion occurs where we
> can't adjust the truesize.

That makes more sense, good catch Herbert.

I guess it's the pskb_expand_head() calls done by net/mac80211/tx.c
I suspect we'll need to orphan early in order to accomodate these
adjustments, otherwise socket memory buffer allocations will
be corrupted.

Once that is cured, I think we can detect this better, by adding a
carefully constructed assertion to pskb_expand_head().  Basically, the
idea is, if "nhead" or "ntail" are non-zero, and there is a socket
still attached to the SKB, print a warning message.

Something like:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4fe605f..9bfca08 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -699,6 +699,12 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	if (skb_shared(skb))
 		BUG();
 
+	if (unlikely((nhead || ntail) && skb->sk)) {
+		printk(KERN_ERR "SKB BUG: Illegal pskb expand (%d:%d) "
+		       "with socket attached\n",
+		       nhead, ntail);
+	}
+
 	size = SKB_DATA_ALIGN(size);
 
 	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);

