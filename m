From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH] atm/br2684: netif_stop_queue() when atm device busy and netif_wake_queue() when we can send packets again.
Date: Sat, 29 Aug 2009 13:24:52 +0200
Message-ID: <1251545092-18081-1-git-send-email-karl@hiramoto.org>
References: <4A9901E7.9040804@hiramoto.org>
Cc: linux-atm-general@lists.sourceforge.net,
	Karl Hiramoto <karl@hiramoto.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdccac.dreamhost.com ([208.97.132.202]:40933 "EHLO
	spunkymail-a16.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751539AbZH2L1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 07:27:08 -0400
In-Reply-To: <4A9901E7.9040804@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the call to dev_kfree_skb() when the atm device is busy.
Calling dev_kfree_skb() causes heavy packet loss then the device is under
heavy load, the more correct behavior should be to stop the upper layers,
then when the lower device can queue packets again wake the upper layers.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 net/atm/br2684.c |   37 +++++++++++++++++++++++++++----------
 1 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 2912665..5c42225 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -69,7 +69,7 @@ struct br2684_vcc {
 	struct net_device *device;
 	/* keep old push, pop functions for chaining */
 	void (*old_push) (struct atm_vcc * vcc, struct sk_buff * skb);
-	/* void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb); */
+	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
 	enum br2684_encaps encaps;
 	struct list_head brvccs;
 #ifdef CONFIG_ATM_BR2684_IPFILTER
@@ -142,6 +142,22 @@ static struct net_device *br2684_find_dev(const struct br2684_if_spec *s)
 	return NULL;
 }
 
+/* chained vcc->pop function.  Check if we should wake the netif_queue */
+static void br2684_pop(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+	struct br2684_vcc *brvcc = BR2684_VCC(vcc);
+	struct net_device *net_dev = skb->dev;
+
+	pr_debug("br2684_pop(vcc %p ; net_dev %p )\n", vcc, net_dev);
+	brvcc->old_pop(vcc, skb);
+
+	if (!net_dev)
+		return;
+
+	if (atm_may_send(vcc, 0))
+		netif_wake_queue(net_dev);
+
+}
 /*
  * Send a packet out a particular vcc.  Not to useful right now, but paves
  * the way for multiple vcc's per itf.  Returns true if we can send,
@@ -200,20 +216,19 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct net_device *dev,
 
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
-	if (!atm_may_send(atmvcc, skb->truesize)) {
-		/*
-		 * We free this here for now, because we cannot know in a higher
-		 * layer whether the skb pointer it supplied wasn't freed yet.
-		 * Now, it always is.
-		 */
-		dev_kfree_skb(skb);
-		return 0;
-	}
 	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 	atmvcc->send(atmvcc, skb);
+
+	if (!atm_may_send(atmvcc, 0)) {
+		netif_stop_queue(brvcc->device);
+		/*check for race with br2684_pop*/
+		if (atm_may_send(atmvcc, 0))
+			netif_start_queue(brvcc->device);
+	}
+
 	return 1;
 }
 
@@ -503,8 +518,10 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	atmvcc->user_back = brvcc;
 	brvcc->encaps = (enum br2684_encaps)be.encaps;
 	brvcc->old_push = atmvcc->push;
+	brvcc->old_pop = atmvcc->pop;
 	barrier();
 	atmvcc->push = br2684_push;
+	atmvcc->pop = br2684_pop;
 
 	__skb_queue_head_init(&queue);
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
-- 
1.6.3.3

