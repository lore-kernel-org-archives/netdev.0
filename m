From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH] [2.6.26] [CAN] Fix can_send() handling on dev_queue_xmit()
 failures
Date: Tue, 06 May 2008 21:49:57 +0200
Message-ID: <4820B665.6070609@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080707080306070803080009"
Cc: Urs Thuermann <urs@isnogud.escape.de>, nautsch@gmail.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:14562 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761955AbYEFTuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 15:50:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080707080306070803080009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

from Oliver Hartkopp <oliver@hartkopp.net>

The tx packet counting and the local loopback of CAN frames should
only happen in the case that the CAN frame has been enqueued to the
netdevice tx queue successfully.

Thanks to Andre Naujoks <nautsch@gmail.com> for reporting this issue.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

---

Hello Dave,

this patch should go into 2.6.26 and also applies fine on 2.6.25.1.

IMO this issue is not that 'critical' that it *requires* to become
part of 2.6.25.2. Please forward the patch to Greg at your own opinion.

Many Thanks!
Oliver




--------------080707080306070803080009
Content-Type: text/x-diff;
 name="can_send.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can_send.diff"

diff --git a/net/can/af_can.c b/net/can/af_can.c
index 2759b76..7e8ca28 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -208,6 +208,7 @@ static int can_create(struct net *net, struct socket *sock, int protocol)
  */
 int can_send(struct sk_buff *skb, int loop)
 {
+	struct sk_buff *newskb = NULL;
 	int err;
 
 	if (skb->dev->type != ARPHRD_CAN) {
@@ -244,8 +245,7 @@ int can_send(struct sk_buff *skb, int loop)
 			 * If the interface is not capable to do loopback
 			 * itself, we do it here.
 			 */
-			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
-
+			newskb = skb_clone(skb, GFP_ATOMIC);
 			if (!newskb) {
 				kfree_skb(skb);
 				return -ENOMEM;
@@ -254,7 +254,6 @@ int can_send(struct sk_buff *skb, int loop)
 			newskb->sk = skb->sk;
 			newskb->ip_summed = CHECKSUM_UNNECESSARY;
 			newskb->pkt_type = PACKET_BROADCAST;
-			netif_rx(newskb);
 		}
 	} else {
 		/* indication for the CAN driver: no loopback required */
@@ -266,11 +265,20 @@ int can_send(struct sk_buff *skb, int loop)
 	if (err > 0)
 		err = net_xmit_errno(err);
 
+	if (err) {
+		if (newskb)
+			kfree_skb(newskb);
+		return err;
+	}
+
+	if (newskb)
+		netif_rx(newskb);
+
 	/* update statistics */
 	can_stats.tx_frames++;
 	can_stats.tx_frames_delta++;
 
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL(can_send);
 

--------------080707080306070803080009--
