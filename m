From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/7] [PPP] pppoe: Fix data clobbering in __pppoe_xmit and return value
Date: Fri, 31 Aug 2007 17:11:31 +0800
Message-ID: <E1IR2XL-0007Q8-00@gondolin.me.apana.org.au>
References: <20070831090625.GA28175@gondor.apana.org.au>
To: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	Herbert Xu <herbert@gondo
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3593 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755721AbXHaJLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:11:33 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IR2XM-0004RH-3K
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 19:11:32 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1IR2XL-0007Q8-00
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 17:11:31 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPP] pppoe: Fix data clobbering in __pppoe_xmit and return value

The function __pppoe_xmit modifies the skb data and therefore it needs
to copy and skb data if it's cloned.

In fact, it currently allocates a new skb so that it can return 0 in
case of error without freeing the original skb.  This is totally wrong
because returning zero is meant to indicate congestion whereupon pppoe
is supposed to wake up the upper layer once the congestion subsides.

This makes sense for ppp_async and ppp_sync but is out-of-place for
pppoe.  This patch makes it always return 1 and free the skb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/pppoe.c |   50 +++++++++++++-------------------------------------
 1 files changed, 13 insertions(+), 37 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 5ac3eff..8818253 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -850,9 +850,7 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 	struct net_device *dev = po->pppoe_dev;
 	struct pppoe_hdr hdr;
 	struct pppoe_hdr *ph;
-	int headroom = skb_headroom(skb);
 	int data_len = skb->len;
-	struct sk_buff *skb2;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
 		goto abort;
@@ -866,53 +864,31 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 	if (!dev)
 		goto abort;
 
-	/* Copy the skb if there is no space for the header. */
-	if (headroom < (sizeof(struct pppoe_hdr) + dev->hard_header_len)) {
-		skb2 = dev_alloc_skb(32+skb->len +
-				     sizeof(struct pppoe_hdr) +
-				     dev->hard_header_len);
-
-		if (skb2 == NULL)
-			goto abort;
-
-		skb_reserve(skb2, dev->hard_header_len + sizeof(struct pppoe_hdr));
-		skb_copy_from_linear_data(skb, skb_put(skb2, skb->len),
-					  skb->len);
-	} else {
-		/* Make a clone so as to not disturb the original skb,
-		 * give dev_queue_xmit something it can free.
-		 */
-		skb2 = skb_clone(skb, GFP_ATOMIC);
-
-		if (skb2 == NULL)
-			goto abort;
-	}
+	/* Copy the data if there is no space for the header or if it's
+	 * read-only.
+	 */
+	if (skb_cow(skb, sizeof(*ph) + dev->hard_header_len))
+		goto abort;
 
-	ph = (struct pppoe_hdr *) skb_push(skb2, sizeof(struct pppoe_hdr));
+	ph = (struct pppoe_hdr *) skb_push(skb, sizeof(struct pppoe_hdr));
 	memcpy(ph, &hdr, sizeof(struct pppoe_hdr));
-	skb2->protocol = __constant_htons(ETH_P_PPP_SES);
+	skb->protocol = __constant_htons(ETH_P_PPP_SES);
 
-	skb_reset_network_header(skb2);
+	skb_reset_network_header(skb);
 
-	skb2->dev = dev;
+	skb->dev = dev;
 
-	dev->hard_header(skb2, dev, ETH_P_PPP_SES,
+	dev->hard_header(skb, dev, ETH_P_PPP_SES,
 			 po->pppoe_pa.remote, NULL, data_len);
 
-	/* We're transmitting skb2, and assuming that dev_queue_xmit
-	 * will free it.  The generic ppp layer however, is expecting
-	 * that we give back 'skb' (not 'skb2') in case of failure,
-	 * but free it in case of success.
-	 */
-
-	if (dev_queue_xmit(skb2) < 0)
+	if (dev_queue_xmit(skb) < 0)
 		goto abort;
 
-	kfree_skb(skb);
 	return 1;
 
 abort:
-	return 0;
+	kfree_skb(skb);
+	return 1;
 }
 
 
