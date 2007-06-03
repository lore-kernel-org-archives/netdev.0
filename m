From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sun, 03 Jun 2007 21:16:38 +0200
Message-ID: <46631396.8030004@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net> <46603340.2050309@trash.net> <46613DBE.3010602@hartkopp.net> <4661CBE7.7040901@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:24099 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbXFCTQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 15:16:51 -0400
In-Reply-To: <4661CBE7.7040901@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> The more i was thinking about my own suggested solution the more it
> turned out to be ugly for me ...
>
> Summarizing we have two problems to solve:
>
> 1. Identify the originating sk to potentially trash my own sent messages.
> 2. Indicate a requested local loopback to the lower (driver) layer.
>
> Regarding point 1.:
> skb->sk is intentionally set to NULL, when ever skb_orphan() or
> skb_clone() is invoked to cut the reference to the sk. Performing a
> loopback this is a reasonable thing to do as also skb->destructor(skb)
> is called in skb_orphan().
>
> Indeed skb->sk is completely unused in the rx path, so we just would
> have to 'preserve' skb->sk the way 'up' whenever we make use of
> skb_orphan() or skb_clone().
>
> E.g. in af_can.c the deliver() function would be changed like this: 

(..)

Now it's done:

1. The needed skb->sk is preserved for the rx path (the way 'up').
2. The loopback indication is done by using the unused skb->protocol in
the tx path.
3. skb->cb is now unused (which was a breaking of rules as remarked by
Patrick)

And finally: It's working fine and appears nice :-)

Please have a look on the sparse changes i would like to commit on the
project SVN.
If there are no objections from your side these (and the other remarked)
changes will go into the next patch series for PF_CAN.

Special thanks to Patrick for the important feedback on the skb->cb usage!!

Best regards,
Oliver

(please excuse the wrong white spaces ...)

Index: net/can/af_can.c
===================================================================
--- net/can/af_can.c    (revision 324)
+++ net/can/af_can.c    (working copy)
@@ -257,7 +257,6 @@
  */
 int can_send(struct sk_buff *skb, int loop)
 {
-    struct sock **tx_sk = (struct sock **)skb->cb;
     int err;
 
     if (skb->dev->type != ARPHRD_CAN) {
@@ -268,27 +267,34 @@
     if (loop) {
         /* local loopback of sent CAN frames (default) */
 
-        /* indication for the CAN driver: do loopback */
-        *tx_sk = skb->sk;
+        /*
+         * skb->protocol is unused in the tx path. We use it
+         * to indicate to the CAN driver 'do loopback!' by
+         * setting skb->protocol to an appropriate value.
+         */
+        skb->protocol = htons(ETH_P_CAN);
 
         /*
-         * The reference to the originating sock may be also required
+         * The reference to the originating sock may be required
          * by the receiving socket to indicate (and ignore) his own
-         * sent data. Example: can_raw sockopt CAN_RAW_RECV_OWN_MSGS
+         * sent data. Example: can_raw sockopt CAN_RAW_RECV_OWN_MSGS.
+         * Therefore we have to ensure that skb->sk remains the
+         * reference to the originating sock by restoring skb->sk
+         * after each skb_clone() or skb_orphan() usage.
+         * skb->sk is usually unused and unset in the rx path.
          */
 
         /* interface not capabable to do the loopback itself? */
         if (!(skb->dev->flags & IFF_LOOPBACK)) {
+            struct sock *srcsk = skb->sk;
             struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 
             /* perform the local loopback here */
             newskb->protocol  = htons(ETH_P_CAN);
             newskb->ip_summed = CHECKSUM_UNNECESSARY;
+            newskb->sk = srcsk;
             netif_rx(newskb);
         }
-    } else {
-        /* indication for the CAN driver: no loopback required */
-        *tx_sk = NULL;
     }
 
     if (!(skb->dev->flags & IFF_UP))
@@ -581,10 +587,12 @@
 
 static inline void deliver(struct sk_buff *skb, struct receiver *r)
 {
+    struct sock *srcsk = skb->sk;
     struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
 
     DBG("skbuff %p cloned to %p\n", skb, clone);
     if (clone) {
+        clone->sk = srcsk;
         r->func(clone, r->data);
         r->matches++;
     }
Index: net/can/raw.c
===================================================================
--- net/can/raw.c    (revision 324)
+++ net/can/raw.c    (working copy)
@@ -154,7 +154,7 @@
 
     if (!ro->recv_own_msgs) {
         /* check the received tx sock reference */
-        if (*(struct sock **)skb->cb == sk) {
+        if (skb->sk == sk) {
             DBG("trashed own tx msg\n");
             kfree_skb(skb);
             return;
Index: drivers/net/can/vcan.c
===================================================================
--- drivers/net/can/vcan.c    (revision 324)
+++ drivers/net/can/vcan.c    (working copy)
@@ -149,8 +149,8 @@
     stats->tx_packets++;
     stats->tx_bytes += skb->len;
 
-    /* tx socket reference pointer: Loopback required if not NULL */
-    loop = *(struct sock **)skb->cb != NULL;
+    /* indication for CAN netdevice drivers that loopback is required */
+    loop = (skb->protocol == htons(ETH_P_CAN));
 
     if (!loopback) {
         /* no loopback handling available inside this driver */
@@ -170,6 +170,8 @@
     /* perform standard loopback handling for CAN network interfaces */
 
     if (loop) {
+        struct sock *srcsk = skb->sk;
+
         if (atomic_read(&skb->users) != 1) {
             struct sk_buff *old_skb = skb;
 
@@ -183,6 +185,8 @@
         } else
             skb_orphan(skb);
 
+        skb->sk = srcsk;
+
         /* receive with packet counting */
         vcan_rx(skb, dev);
     } else {


