From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH] br2684 testing needed for packet loss and performance
Date: Fri, 28 Aug 2009 12:38:33 +0200
Message-ID: <4A97B3A9.6040103@hiramoto.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030002080407050302020300"
Cc: netdev@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:53419 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbZH1KjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 06:39:22 -0400
Received: from spunkymail-a1.g.dreamhost.com (caiajhbdcbhh.dreamhost.com [208.97.132.177])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 267AC17EB83
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 03:39:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030002080407050302020300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Hi,

Anyone care to test or comment on  these patches?  I've attached 
versions for 2.6.28 and 2.6.30.

Note I've done all my tests without any QOS settings.  I start my link 
by something like "br2684ctl -c 0 -e 0 -p 1 -b -a 8.32"

Without these patches, if you open one or many file transfers, then also 
do a ping you will notice heavy packet loss.  This packet loss is being 
caused by the call to dev_kfree_skb(skb);


With these patches my max throughput drops 20% to  40% or so on a 24 
Mbps ADSL2+  line, but no longer have packet loss.   On a 15Mbps (and 
slower) line,  I no longer see packet loss with these patches.



Thanks
--
Karl

--------------030002080407050302020300
Content-Type: text/plain;
 name="linux-2.6.28.br2684.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.28.br2684.patch"

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
--- linux-2.6.28.9.orig/net/atm/br2684.c	2009-03-23 22:55:52.000000000 +0100
+++ linux-2.6.28.9/net/atm/br2684.c	2009-08-28 12:00:43.000000000 +0200
@@ -69,7 +69,7 @@ struct br2684_vcc {
 	struct net_device *device;
 	/* keep old push, pop functions for chaining */
 	void (*old_push) (struct atm_vcc * vcc, struct sk_buff * skb);
-	/* void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb); */
+	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
 	enum br2684_encaps encaps;
 	struct list_head brvccs;
 #ifdef CONFIG_ATM_BR2684_IPFILTER
@@ -143,6 +143,23 @@ static struct net_device *br2684_find_de
 	return NULL;
 }
 
+/* chained vcc->pop function.  Check if we should wake the netif_queue */
+static void br2684_pop(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+	struct br2684_vcc *brvcc = BR2684_VCC(vcc);
+	struct net_device *net_dev = brvcc->device;
+
+	pr_debug("br2684_pop(vcc %p ; net_dev %p )\n", vcc, net_dev);
+	brvcc->old_pop(vcc, skb);
+
+	if (!net_dev)
+		return;
+
+ 	if (atm_may_send(vcc, 0)) {
+		netif_wake_queue(net_dev);
+ 	}
+}
+
 /*
  * Send a packet out a particular vcc.  Not to useful right now, but paves
  * the way for multiple vcc's per itf.  Returns true if we can send,
@@ -200,20 +217,22 @@ static int br2684_xmit_vcc(struct sk_buf
 
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
+
 	atomic_add(skb->truesize, &sk_atm(atmvcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = atmvcc->atm_options;
 	brdev->stats.tx_packets++;
 	brdev->stats.tx_bytes += skb->len;
 	atmvcc->send(atmvcc, skb);
+
+	if (!atm_may_send(atmvcc, 0)) {
+  		netif_stop_queue(brvcc->device);
+		barrier();
+		/* check for race with br26864_pop*/
+		if (atm_may_send(atmvcc, 0)) {
+			netif_start_queue(brvcc->device);
+		}
+	}
+
 	return 1;
 }
 
@@ -509,8 +528,10 @@ static int br2684_regvcc(struct atm_vcc 
 	atmvcc->user_back = brvcc;
 	brvcc->encaps = (enum br2684_encaps)be.encaps;
 	brvcc->old_push = atmvcc->push;
+	brvcc->old_pop = atmvcc->pop;
 	barrier();
 	atmvcc->push = br2684_push;
+	atmvcc->pop  = br2684_pop;
 
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
 
@@ -621,6 +642,8 @@ static int br2684_create(void __user * a
 
 	write_lock_irq(&devs_lock);
 	brdev->payload = payload;
+	netif_start_queue(netdev);
+
 	brdev->number = list_empty(&br2684_devs) ? 1 :
 	    BRPRIV(list_entry_brdev(br2684_devs.prev))->number + 1;
 	list_add_tail(&brdev->br2684_devs, &br2684_devs);

--------------030002080407050302020300
Content-Type: text/plain;
 name="linux-2.6.30.br2684.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.30.br2684.patch"

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>

--- /usr/src/linux-2.6.30.5/net/atm/br2684.c	2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30.5/net/atm/br2684.c	2009-08-28 12:02:41.000000000 +0200
@@ -69,7 +69,7 @@ struct br2684_vcc {
 	struct net_device *device;
 	/* keep old push, pop functions for chaining */
 	void (*old_push) (struct atm_vcc * vcc, struct sk_buff * skb);
-	/* void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb); */
+	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
 	enum br2684_encaps encaps;
 	struct list_head brvccs;
 #ifdef CONFIG_ATM_BR2684_IPFILTER
@@ -142,6 +142,22 @@ static struct net_device *br2684_find_de
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
+ 	if (atm_may_send(vcc, 0) {
+		netif_wake_queue(net_dev);
+ 	}
+}
 /*
  * Send a packet out a particular vcc.  Not to useful right now, but paves
  * the way for multiple vcc's per itf.  Returns true if we can send,
@@ -200,20 +216,20 @@ static int br2684_xmit_vcc(struct sk_buf
 
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
+		barrier();
+		/*check for race with br2684_pop*/
+		if (atm_may_send(atmvcc, 0))
+			netif_start_queue(brvcc->device);
+	}
+	
 	return 1;
 }
 
@@ -502,8 +518,10 @@ static int br2684_regvcc(struct atm_vcc 
 	atmvcc->user_back = brvcc;
 	brvcc->encaps = (enum br2684_encaps)be.encaps;
 	brvcc->old_push = atmvcc->push;
+	brvcc->old_pop = atmvcc->pop;
 	barrier();
 	atmvcc->push = br2684_push;
+	atmvcc->pop = br2684_pop;
 
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
 

--------------030002080407050302020300--
