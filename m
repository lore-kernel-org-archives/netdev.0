From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Mon, 04 Jun 2007 20:26:53 +0200
Message-ID: <4664596D.1030800@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de>	<20070530131204.10843.5@janus.isnogud.escape.de>	<465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net>	<46603340.2050309@trash.net> <46613DBE.3010602@hartkopp.net>	<4661CBE7.7040901@hartkopp.net> <46631396.8030004@hartkopp.net> <ygfejkrrk16.fsf@janus.isnogud.escape.de> <46643EB2.2060204@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:60465 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756327AbXFDS1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 14:27:09 -0400
In-Reply-To: <46643EB2.2060204@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> I think, it goes into the right direction to use skb->pkt_type. The flag
> should really be somewhere inside the skb as all back references into
> the sk would become sticky in the implementation.
>
> But regarding the use of skb->pkt_type i would suggest to take a closer
> look on the definitions in include/linux/if_packet.h and how the
> pkt_type is to be used inside the kernel. In my opinion we should use ...
>
> * TX-Path:
> PACKET_OTHERHOST: send the CAN frame without loopback
> PACKET_BROADCAST : send the CAN frame with loopback (aka local broadcast)
>
> See an example of this approach in drivers/net/arcnet/rfc1051.c :
> http://www.linux-m32r.org/lxr/http/source/drivers/net/arcnet/rfc1051.c?a=i386#L99
>
> * RX-Path:
> PACKET_HOST : just an incoming CAN frame for this host
>
> Any comments? ACKs?
>
> Best regards,
> Oliver
>
>
>   

The updated changes would look like this. Of course it has been tested
and is working fine :-)

Regards,
Oliver

Index: net/can/af_can.c
===================================================================
--- net/can/af_can.c    (revision 325)
+++ net/can/af_can.c    (working copy)
@@ -257,7 +257,6 @@
  */
 int can_send(struct sk_buff *skb, int loop)
 {
-    struct sock **tx_sk = (struct sock **)skb->cb;
     int err;
 
     if (skb->dev->type != ARPHRD_CAN) {
@@ -265,30 +264,43 @@
         return -EPERM;
     }
 
+    skb->protocol = htons(ETH_P_CAN);
+
     if (loop) {
         /* local loopback of sent CAN frames (default) */
 
-        /* indication for the CAN driver: do loopback */
-        *tx_sk = skb->sk;
+        /*
+         * This packet is not only sent on the CAN bus but
+         * also broadcasted to local subscribers on this host.
+         */
+        skb->pkt_type = PACKET_BROADCAST;
 
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
-            newskb->protocol  = htons(ETH_P_CAN);
             newskb->ip_summed = CHECKSUM_UNNECESSARY;
+            newskb->sk = srcsk;
             netif_rx(newskb);
         }
     } else {
-        /* indication for the CAN driver: no loopback required */
-        *tx_sk = NULL;
+        /*
+         * Indication for the CAN driver: No loopback required!
+         * This packet is only transmitted to the CAN bus.
+         */
+        skb->pkt_type = PACKET_OTHERHOST;
     }
 
     if (!(skb->dev->flags & IFF_UP))
@@ -581,10 +593,12 @@
 
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
--- net/can/raw.c    (revision 325)
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
--- drivers/net/can/vcan.c    (revision 325)
+++ drivers/net/can/vcan.c    (working copy)
@@ -133,6 +133,7 @@
     skb->protocol  = htons(ETH_P_CAN);
     skb->dev       = dev;
     skb->ip_summed = CHECKSUM_UNNECESSARY;
+    skb->pkt_type  = PACKET_HOST;
 
     DBG("received skbuff on interface %d\n", dev->ifindex);
 
@@ -149,8 +150,8 @@
     stats->tx_packets++;
     stats->tx_bytes += skb->len;
 
-    /* tx socket reference pointer: Loopback required if not NULL */
-    loop = *(struct sock **)skb->cb != NULL;
+    /* indication for CAN netdevice drivers that loopback is required */
+    loop = (skb->pkt_type == PACKET_BROADCAST);
 
     if (!loopback) {
         /* no loopback handling available inside this driver */
@@ -170,6 +171,8 @@
     /* perform standard loopback handling for CAN network interfaces */
 
     if (loop) {
+        struct sock *srcsk = skb->sk;
+
         if (atomic_read(&skb->users) != 1) {
             struct sk_buff *old_skb = skb;
 
@@ -183,6 +186,8 @@
         } else
             skb_orphan(skb);
 
+        skb->sk = srcsk;
+
         /* receive with packet counting */
         vcan_rx(skb, dev);
     } else {


