From: Karl Hiramoto <karl@hiramoto.org>
Subject: [RFC] atm/br2684 netif_*_queue, packet loss or performance loss.
Date: Wed, 26 Aug 2009 11:45:16 +0200
Message-ID: <4A95042C.3010209@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:46521 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbZHZJp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 05:45:58 -0400
Received: from spunkymail-a6.g.dreamhost.com (caiajhbdcaid.dreamhost.com [208.97.132.83])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 2C1AF17F5AA
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 02:46:00 -0700 (PDT)
Received: from [192.168.10.51] (12.Red-81-44-17.dynamicIP.rima-tde.net [81.44.17.12])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by spunkymail-a6.g.dreamhost.com (Postfix) with ESMTP id BE616109F28
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 02:45:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

With a br2684/ IPoE  bridge,  I was seeing more than 50% packet loss 
under heavy load without this patch in a vanilla  2.6.28.9 and 2.6.30 
kernel.   With this patch,   I have less then 5% packet loss now, 
measured by doing a ping, while having HTTP downloads  with other 
connections.  Without this patch it seems one TCP connection monopolies 
the line, because the packet loss does not allow the other TCP 
connections to ramp up.

The problem this patch, is that my max throughput on a 24Mbps down/ 
1Mbps up line drops by about  30%  so I have about 15mbps utilization, 
looking at traffic on the line i see there are gaps when nothing is 
being transmitted..

How much latency should netif_wake_queue()  introduce?  

It seems that i call netif_wake_queue() but the upper layers in 
net/core/  sometimes take a while to restart sending packets to 
atm/br2684.c  and i see these gaps in data transmission.   Note if i 
change the ADSL2+ line speed to 4Mbps down/ 320Kbps up this patch seems 
to work perfectly, I have very low packet loss, and maximum utilization 
of the line.    I tried playing with the internal buffering that the 
hardware driver does in the high speed 24Mbps down/ 1Mbps up case but it 
did not seem to make any difference.   The TX seemed to be starved of 
data because the upper layers were not calling hard_start_xmit()

I see the atm/clip  driver calling netif_wake_queue() and 
netif_stop_queue() so i was trying to do the same in br2684.   I don't 
have any hardware at the moment though to test CLIP at high speed.


My setup is:

test client pc eth0 <--->  eth0 <--> arm ixp425 cpu <--  br2684 --> atm 
driver & device <--> ADSL2+ DSLAM <--->  Test server eth0


You can see in my patch that i remove  a line that has 
"dev_kfree_skb(skb);" that causes  the packet loss.  Then i added code 
to call netif_stop_queue() and netif_wake_queue()

--- linux-2.6.28.9.orig/net/atm/br2684.c	2009-03-23 22:55:52.000000000 +0100
+++ linux-2.6.28.9/net/atm/br2684.c	2009-08-26 11:03:34.000000000 +0200
@@ -69,7 +69,7 @@ struct br2684_vcc {
 	struct net_device *device;
 	/* keep old push, pop functions for chaining */
 	void (*old_push) (struct atm_vcc * vcc, struct sk_buff * skb);
-	/* void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb); */
+	void (*old_pop)(struct atm_vcc *vcc, struct sk_buff *skb);
 	enum br2684_encaps encaps;
 	struct list_head brvccs;
 #ifdef CONFIG_ATM_BR2684_IPFILTER
@@ -143,6 +143,26 @@ static struct net_device *br2684_find_de
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
+	if (atm_may_send(vcc, 0)) {
+		if (netif_queue_stopped(net_dev)) {
+			netif_wake_queue(net_dev);
+		}
+	}
+
+}
+
 /*
  * Send a packet out a particular vcc.  Not to useful right now, but paves
  * the way for multiple vcc's per itf.  Returns true if we can send,
@@ -200,20 +220,20 @@ static int br2684_xmit_vcc(struct sk_buf
 
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
+
 	atmvcc->send(atmvcc, skb);
+
+	if (!atm_may_send(atmvcc, 0)) {
+		/* the queue is now full so stop it
+ 		*  Restart the queue in br2684_pop */
+		netif_stop_queue(brvcc->device);
+	}
+
 	return 1;
 }
 
@@ -240,6 +260,8 @@ static int br2684_start_xmit(struct sk_b
 		read_unlock(&devs_lock);
 		return 0;
 	}
+	netif_tx_lock_bh(brdev->net_dev);
+
 	if (!br2684_xmit_vcc(skb, brdev, brvcc)) {
 		/*
 		 * We should probably use netif_*_queue() here, but that
@@ -251,6 +273,7 @@ static int br2684_start_xmit(struct sk_b
 		brdev->stats.tx_errors++;
 		brdev->stats.tx_fifo_errors++;
 	}
+	netif_tx_unlock_bh(brdev->net_dev);
 	read_unlock(&devs_lock);
 	return 0;
 }
@@ -509,8 +532,10 @@ static int br2684_regvcc(struct atm_vcc 
 	atmvcc->user_back = brvcc;
 	brvcc->encaps = (enum br2684_encaps)be.encaps;
 	brvcc->old_push = atmvcc->push;
+	brvcc->old_pop = atmvcc->pop;
 	barrier();
 	atmvcc->push = br2684_push;
+	atmvcc->pop  = br2684_pop;
 
 	rq = &sk_atm(atmvcc)->sk_receive_queue;
 
@@ -621,6 +646,8 @@ static int br2684_create(void __user * a
 
 	write_lock_irq(&devs_lock);
 	brdev->payload = payload;
+	netif_start_queue(netdev);
+
 	brdev->number = list_empty(&br2684_devs) ? 1 :
 	    BRPRIV(list_entry_brdev(br2684_devs.prev))->number + 1;
 	list_add_tail(&brdev->br2684_devs, &br2684_devs);



 
