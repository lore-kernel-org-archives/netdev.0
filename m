From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH] can: fix NOHZ local_softirq_pending 08 warning
Date: Tue, 15 Sep 2009 08:57:54 +0200
Message-ID: <4AAF3AF2.60309@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060101070805030600080601"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Urs Thuermann <urs@isnogud.escape.de>,
	Michael Buesch <mb@bu3sch.de>
To: David Miller <davem@davemloft.net>, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:54122 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757991AbZIOG6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 02:58:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060101070805030600080601
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

When using nanosleep() in an userspace application we get a ratelimit warning

NOHZ: local_softirq_pending 08

for 10 times.

The echo of CAN frames is done from process context and softirq context only.
Therefore the usage of netif_rx() was wrong (for years).

This patch replaces netif_rx() with netif_rx_ni() which has to be used from
process/softirq context. It also adds a missing comment that can_send() must
no be used from hardirq context.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

---


--------------060101070805030600080601
Content-Type: text/x-patch;
 name="can-NOHZ-local_softirq_pending-08.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can-NOHZ-local_softirq_pending-08.patch"

diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 6971f6c..80ac563 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -80,7 +80,7 @@ static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 	skb->dev       = dev;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	netif_rx(skb);
+	netif_rx_ni(skb);
 }
 
 static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
diff --git a/net/can/af_can.c b/net/can/af_can.c
index ef1c43a..6068321 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -199,6 +199,8 @@ static int can_create(struct net *net, struct socket *sock, int protocol)
  * @skb: pointer to socket buffer with CAN frame in data section
  * @loop: loopback for listeners on local CAN sockets (recommended default!)
  *
+ * Due to the loopback this routine must not be called from hardirq context.
+ *
  * Return:
  *  0 on success
  *  -ENETDOWN when the selected interface is down
@@ -278,7 +280,7 @@ int can_send(struct sk_buff *skb, int loop)
 	}
 
 	if (newskb)
-		netif_rx(newskb);
+		netif_rx_ni(newskb);
 
 	/* update statistics */
 	can_stats.tx_frames++;

--------------060101070805030600080601--
