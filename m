From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 22:00:12 +0100
Message-ID: <52E96BDC.9070209@hartkopp.net>
References: <52E905C8.1060408@hartkopp.net>		 <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>		 <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com>	 <1391010437.28432.39.camel@edumazet-glaptop2.roam.corp.google.com>	 <52E956E6.7090002@hartkopp.net> <1391025348.28432.63.camel@edumazet-glaptop2.roam.corp.google.com> <52E9675A.4070201@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:18698 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbaA2VAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 16:00:15 -0500
In-Reply-To: <52E9675A.4070201@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So here we are:

Introduced can_create_echo_skb() which creates a skb which is properly
owned to be send back (echo'ed) into the network stack. 

Regards,
Oliver

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 13a9098..fc59bc6 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -323,19 +323,10 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	if (!priv->echo_skb[idx]) {
-		struct sock *srcsk = skb->sk;
 
-		if (atomic_read(&skb->users) != 1) {
-			struct sk_buff *old_skb = skb;
-
-			skb = skb_clone(old_skb, GFP_ATOMIC);
-			kfree_skb(old_skb);
-			if (!skb)
-				return;
-		} else
-			skb_orphan(skb);
-
-		skb->sk = srcsk;
+		skb = can_create_echo_skb(skb);
+		if (!skb)
+			return;
 
 		/* make settings for echo to reduce code in irq context */
 		skb->protocol = htons(ETH_P_CAN);
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index e24e669..2124c679 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -18,6 +18,7 @@
 #include <linux/netdevice.h>
 #include <linux/can.h>
 #include <linux/can/dev.h>
+#include <linux/can/skb.h>
 #include <linux/can/error.h>
 
 #include <linux/mfd/janz.h>
@@ -1133,20 +1134,9 @@ static void ican3_handle_message(struct ican3_dev *mod, struct ican3_msg *msg)
  */
 static void ican3_put_echo_skb(struct ican3_dev *mod, struct sk_buff *skb)
 {
-	struct sock *srcsk = skb->sk;
-
-	if (atomic_read(&skb->users) != 1) {
-		struct sk_buff *old_skb = skb;
-
-		skb = skb_clone(old_skb, GFP_ATOMIC);
-		kfree_skb(old_skb);
-		if (!skb)
-			return;
-	} else {
-		skb_orphan(skb);
-	}
-
-	skb->sk = srcsk;
+	skb = can_create_echo_skb(skb);
+	if (!skb)
+		return;
 
 	/* save this skb for tx interrupt echo handling */
 	skb_queue_tail(&mod->echoq, skb);
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 0a2a5ee..4e94057 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -46,6 +46,7 @@
 #include <linux/if_ether.h>
 #include <linux/can.h>
 #include <linux/can/dev.h>
+#include <linux/can/skb.h>
 #include <linux/slab.h>
 #include <net/rtnetlink.h>
 
@@ -109,25 +110,23 @@ static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 			stats->rx_packets++;
 			stats->rx_bytes += cfd->len;
 		}
-		kfree_skb(skb);
+		consume_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
 	/* perform standard echo handling for CAN network interfaces */
 
 	if (loop) {
-		struct sock *srcsk = skb->sk;
 
-		skb = skb_share_check(skb, GFP_ATOMIC);
+		skb = can_create_echo_skb(skb);
 		if (!skb)
 			return NETDEV_TX_OK;
 
 		/* receive with packet counting */
-		skb->sk = srcsk;
 		vcan_rx(skb, dev);
 	} else {
 		/* no looped packets => no counting */
-		kfree_skb(skb);
+		consume_skb(skb);
 	}
 	return NETDEV_TX_OK;
 }
diff --git a/include/linux/can/skb.h b/include/linux/can/skb.h
index 2f0543f..f9bbbb4 100644
--- a/include/linux/can/skb.h
+++ b/include/linux/can/skb.h
@@ -11,7 +11,9 @@
 #define CAN_SKB_H
 
 #include <linux/types.h>
+#include <linux/skbuff.h>
 #include <linux/can.h>
+#include <net/sock.h>
 
 /*
  * The struct can_skb_priv is used to transport additional information along
@@ -42,4 +44,40 @@ static inline void can_skb_reserve(struct sk_buff *skb)
 	skb_reserve(skb, sizeof(struct can_skb_priv));
 }
 
+static inline void can_skb_destructor(struct sk_buff *skb)
+{
+	sock_put(skb->sk);
+}
+
+static inline void can_skb_set_owner(struct sk_buff *skb, struct sock *sk)
+{
+	if (sk) {
+		sock_hold(sk);
+		skb->destructor = can_skb_destructor;
+		skb->sk = sk;
+	}
+}
+
+/*
+ * returns an unshared skb owned by the original sock to be echo'ed back
+ */
+static inline struct sk_buff *can_create_echo_skb(struct sk_buff *skb)
+{
+	if (skb_shared(skb)) {
+		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
+
+		if (likely(nskb)) {
+			can_skb_set_owner(nskb, skb->sk);
+			consume_skb(skb);
+			return nskb;
+		} else {
+			kfree_skb(skb);
+			return NULL;
+		}
+	}
+
+	/* we can assume to have an unshared skb with proper owner */
+	return skb;
+}
+
 #endif /* CAN_SKB_H */
diff --git a/net/can/af_can.c b/net/can/af_can.c
index d249874..a27f8aa 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -57,6 +57,7 @@
 #include <linux/skbuff.h>
 #include <linux/can.h>
 #include <linux/can/core.h>
+#include <linux/can/skb.h>
 #include <linux/ratelimit.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -290,7 +291,7 @@ int can_send(struct sk_buff *skb, int loop)
 				return -ENOMEM;
 			}
 
-			newskb->sk = skb->sk;
+			can_skb_set_owner(newskb, skb->sk);
 			newskb->ip_summed = CHECKSUM_UNNECESSARY;
 			newskb->pkt_type = PACKET_BROADCAST;
 		}
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 3fc737b..dcb75c0 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -268,7 +268,7 @@ static void bcm_can_tx(struct bcm_op *op)
 
 	/* send with loopback */
 	skb->dev = dev;
-	skb->sk = op->sk;
+	can_skb_set_owner(skb, op->sk);
 	can_send(skb, 1);
 
 	/* update statistics */
@@ -1223,7 +1223,7 @@ static int bcm_tx_send(struct msghdr *msg, int ifindex, struct sock *sk)
 
 	can_skb_prv(skb)->ifindex = dev->ifindex;
 	skb->dev = dev;
-	skb->sk  = sk;
+	can_skb_set_owner(skb, sk);
 	err = can_send(skb, 1); /* send with loopback */
 	dev_put(dev);
 




On 29.01.2014 21:40, Oliver Hartkopp wrote:
> On 29.01.2014 20:55, Eric Dumazet wrote:
> 
>>> 2. The check for sk and the additional skb_orphan() is not needed as the
>>> can_skb_set_owner() is invoked only after 'fresh' skb allocation or after
>>> clone/skb_orphan() - so we know the skb state very good.
>>
>> Yep, but then you added skb_orphan() calls. when skb is not shared.
> 
> I did that e.g. in the sources placed in driver/net/can because I assume that
> I can not be sure that I always get skbs created by AF_CAN.
> 
> E.g. one could also use AF_PACKET to send CAN frames to the CAN interfaces.
> 
> Btw. assuming AF_PACKET does it correct too with the destructor I will omit
> the skb_orphan() / can_skb_set_owner() sequence in drivers/net/can in the next
> attempt.
> 
> Tnx
> Oliver
> 
>>
>> I think you really should have a helper instead of copying this 3 times.
>>
> 
> ok
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-can" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
