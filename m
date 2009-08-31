From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH] atm/br2684: netif_stop_queue() when atm device busy and netif_wake_queue() when we can send packets again.
Date: Mon, 31 Aug 2009 10:29:47 -0400
Message-ID: <200908311429.n7VETlTi000764@cmf.nrl.navy.mil>
References: <1251545092-18081-1-git-send-email-karl@hiramoto.org>
Cc: netdev@vger.kernel.org, Karl Hiramoto <karl@hiramoto.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45382 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbZHaO34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 10:29:56 -0400
In-reply-to: <1251545092-18081-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the call to dev_kfree_skb() when the atm device is busy.
Calling dev_kfree_skb() causes heavy packet loss then the device is under
heavy load, the more correct behavior should be to stop the upper layers,
then when the lower device can queue packets again wake the upper layers.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
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
@@ -142,6 +142,22 @@ static struct net_device *br2684_find_dev(const struct br
2684_if_spec *s)
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
@@ -200,20 +216,19 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct n
et_device *dev,
 
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
-	if (!atm_may_send(atmvcc, skb->truesize)) {
-		/*
-		 * We free this here for now, because we cannot know in a highe
r
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
 
@@ -503,8 +518,10 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __u
ser * arg)
 	atmvcc->user_back = brvcc;
 	brvcc->encaps = (enum br2684_encaps)be.encaps;
 	brvcc->old_push = atmvcc->push;
+	brvcc->old_pop = atmvcc->pop;
 	barrier();
 	atmvcc->push = br2684_push;
+	atmvcc->pop = br2684_pop;
 
 	__skb_queue_head_init(&queue);
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
