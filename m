From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 07:47:17 -0800
Message-ID: <1391010437.28432.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E905C8.1060408@hartkopp.net>
	 <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:62598 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbaA2PrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 10:47:19 -0500
Received: by mail-pb0-f42.google.com with SMTP id jt11so1921394pbb.1
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 07:47:19 -0800 (PST)
In-Reply-To: <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-29 at 07:30 -0800, Eric Dumazet wrote:
> On Wed, 2014-01-29 at 07:02 -0800, Eric Dumazet wrote:
> 
> > Thats how every protocol does this, with variants.
> > 
> > Check l2tp_sock_wfree()/l2tp_skb_set_owner_w() for an example
> 
> Also keep in mind this patch is needed for all kernels, not only 3.11+
> 
> So better keep it as simple as possible, to ease backports.

Please try the following patch.

diff --git a/net/can/af_can.c b/net/can/af_can.c
index d249874a366d..98d74bd6030f 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -290,7 +290,8 @@ int can_send(struct sk_buff *skb, int loop)
 				return -ENOMEM;
 			}
 
-			newskb->sk = skb->sk;
+			if (skb->sk)
+				can_skb_set_owner(newskb, skb->sk);
 			newskb->ip_summed = CHECKSUM_UNNECESSARY;
 			newskb->pkt_type = PACKET_BROADCAST;
 		}
diff --git a/net/can/af_can.h b/net/can/af_can.h
index 6de58b40535c..e9cd045ba1cc 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -45,6 +45,7 @@
 #include <linux/list.h>
 #include <linux/rcupdate.h>
 #include <linux/can.h>
+#include <net/sock.h>
 
 /* af_can rx dispatcher structures */
 
@@ -118,4 +119,17 @@ extern struct s_stats    can_stats;        /* packet statistics */
 extern struct s_pstats   can_pstats;       /* receive list statistics */
 extern struct hlist_head can_rx_dev_list;  /* rx dispatcher structures */
 
+static inline void can_skb_destructor(struct sk_buff *skb)
+{
+	sock_put(skb->sk);
+}
+
+static inline void can_skb_set_owner(struct sk_buff *skb, struct sock *sk)
+{
+	skb_orphan(skb);
+	skb->destructor = can_skb_destructor;
+	skb->sk = sk;
+	sock_hold(sk);
+}
+
 #endif /* AF_CAN_H */
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 3fc737b214c7..b31480f3a97c 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -59,6 +59,7 @@
 #include <linux/slab.h>
 #include <net/sock.h>
 #include <net/net_namespace.h>
+#include "af_can.h"
 
 /*
  * To send multiple CAN frame content within TX_SETUP or to filter
@@ -268,7 +269,8 @@ static void bcm_can_tx(struct bcm_op *op)
 
 	/* send with loopback */
 	skb->dev = dev;
-	skb->sk = op->sk;
+	if (op->sk)
+		can_skb_set_owner(skb, op->sk);
 	can_send(skb, 1);
 
 	/* update statistics */
