From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 20:30:46 +0100
Message-ID: <52E956E6.7090002@hartkopp.net>
References: <52E905C8.1060408@hartkopp.net>	 <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>	 <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com> <1391010437.28432.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391010437.28432.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 29.01.2014 16:47, Eric Dumazet wrote:
> On Wed, 2014-01-29 at 07:30 -0800, Eric Dumazet wrote:
>> On Wed, 2014-01-29 at 07:02 -0800, Eric Dumazet wrote:
>>
>>> Thats how every protocol does this, with variants.
>>>
>>> Check l2tp_sock_wfree()/l2tp_skb_set_owner_w() for an example
>>
>> Also keep in mind this patch is needed for all kernels, not only 3.11+
>>
>> So better keep it as simple as possible, to ease backports.
> 
> Please try the following patch.
> 

Hello Eric,

there were at least two problems with your patch:

1. Only the stuff in net/can was addressed (missing drivers/net/can)

2. The check for sk and the additional skb_orphan() is not needed as the
can_skb_set_owner() is invoked only after 'fresh' skb allocation or after
clone/skb_orphan() - so we know the skb state very good.

I moved your suggested inline functions to include/linux/can/skb.h where
all users (net/can and drivers) can access them.

So what has been done:

- can_skb_set_owner() is invoked on new created skbuffs (tx path)
- can_skb_set_owner() is invoked on orphaned/cloned skbs (echo in drvs)

I did some tests with real CAN hardware and everything seems fine.

Please take a look if it looks correct to you.

If so I'll send a proper patch for it.

Regards,
Oliver

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 13a9098..17a0a00 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -325,17 +325,20 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
 	if (!priv->echo_skb[idx]) {
 		struct sock *srcsk = skb->sk;
 
-		if (atomic_read(&skb->users) != 1) {
-			struct sk_buff *old_skb = skb;
+		if (skb_shared(skb)) {
+			struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
 
-			skb = skb_clone(old_skb, GFP_ATOMIC);
-			kfree_skb(old_skb);
-			if (!skb)
+			if (likely(nskb))
+				consume_skb(skb);
+			else {
+				kfree_skb(skb);
 				return;
+			}
+			skb = nskb;
 		} else
 			skb_orphan(skb);
 
-		skb->sk = srcsk;
+		can_skb_set_owner(skb, srcsk);
 
 		/* make settings for echo to reduce code in irq context */
 		skb->protocol = htons(ETH_P_CAN);
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index e24e669..ee48cb1 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -18,6 +18,7 @@
 #include <linux/netdevice.h>
 #include <linux/can.h>
 #include <linux/can/dev.h>
+#include <linux/can/skb.h>
 #include <linux/can/error.h>
 
 #include <linux/mfd/janz.h>
@@ -1135,18 +1136,20 @@ static void ican3_put_echo_skb(struct ican3_dev *mod, struct sk_buff *skb)
 {
 	struct sock *srcsk = skb->sk;
 
-	if (atomic_read(&skb->users) != 1) {
-		struct sk_buff *old_skb = skb;
+	if (skb_shared(skb)) {
+		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
 
-		skb = skb_clone(old_skb, GFP_ATOMIC);
-		kfree_skb(old_skb);
-		if (!skb)
+		if (likely(nskb))
+			consume_skb(skb);
+		else {
+			kfree_skb(skb);
 			return;
-	} else {
+		}
+		skb = nskb;
+	} else
 		skb_orphan(skb);
-	}
 
-	skb->sk = srcsk;
+	can_skb_set_owner(skb, srcsk);
 
 	/* save this skb for tx interrupt echo handling */
 	skb_queue_tail(&mod->echoq, skb);
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 0a2a5ee..f764f00 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -46,6 +46,7 @@
 #include <linux/if_ether.h>
 #include <linux/can.h>
 #include <linux/can/dev.h>
+#include <linux/can/skb.h>
 #include <linux/slab.h>
 #include <net/rtnetlink.h>
 
@@ -118,12 +119,22 @@ static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 	if (loop) {
 		struct sock *srcsk = skb->sk;
 
-		skb = skb_share_check(skb, GFP_ATOMIC);
-		if (!skb)
-			return NETDEV_TX_OK;
+		if (skb_shared(skb)) {
+			struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
+
+			if (likely(nskb))
+				consume_skb(skb);
+			else {
+				kfree_skb(skb);
+				return NETDEV_TX_OK;
+			}
+			skb = nskb;
+		} else
+			skb_orphan(skb);
+
+		can_skb_set_owner(skb, srcsk);
 
 		/* receive with packet counting */
-		skb->sk = srcsk;
 		vcan_rx(skb, dev);
 	} else {
 		/* no looped packets => no counting */
diff --git a/include/linux/can/skb.h b/include/linux/can/skb.h
index 2f0543f..0429d36 100644
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
@@ -42,4 +44,16 @@ static inline void can_skb_reserve(struct sk_buff *skb)
 	skb_reserve(skb, sizeof(struct can_skb_priv));
 }
 
+static inline void can_skb_destructor(struct sk_buff *skb)
+{
+	sock_put(skb->sk);
+}
+
+static inline void can_skb_set_owner(struct sk_buff *skb, struct sock *sk)
+{
+	sock_hold(sk);
+	skb->destructor = can_skb_destructor;
+	skb->sk = sk;
+}
+
 #endif /* CAN_SKB_H */
diff --git a/net/can/af_can.c b/net/can/af_can.c
index d249874..7e4101b 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -290,7 +290,7 @@ int can_send(struct sk_buff *skb, int loop)
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
 

