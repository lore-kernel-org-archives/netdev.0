From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 13/14] Phonet: emit errors when a packet cannot be delivered locally
Date: Tue, 16 Sep 2008 18:08:13 +0300
Message-ID: <1221577694-4513-13-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:44501 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754227AbYIPPIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:34 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF8Gn2000506
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:32 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there is no listener socket for a received packet, send an error
back to the sender.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |   82 +++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 78 insertions(+), 4 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index c18664d..3962969 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -134,7 +134,7 @@ EXPORT_SYMBOL(phonet_header_ops);
  * Prepends an ISI header and sends a datagram.
  */
 static int pn_send(struct sk_buff *skb, struct net_device *dev,
-			u16 dst, u16 src, u8 res)
+			u16 dst, u16 src, u8 res, u8 irq)
 {
 	struct phonethdr *ph;
 	int err;
@@ -163,7 +163,10 @@ static int pn_send(struct sk_buff *skb, struct net_device *dev,
 		skb_reset_mac_header(skb);
 		skb->pkt_type = PACKET_LOOPBACK;
 		skb_orphan(skb);
-		netif_rx_ni(skb);
+		if (irq)
+			netif_rx(skb);
+		else
+			netif_rx_ni(skb);
 		err = 0;
 	} else {
 		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
@@ -181,6 +184,18 @@ drop:
 	return err;
 }
 
+static int pn_raw_send(const void *data, int len, struct net_device *dev,
+			u16 dst, u16 src, u8 res)
+{
+	struct sk_buff *skb = alloc_skb(MAX_PHONET_HEADER + len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	skb_reserve(skb, MAX_PHONET_HEADER);
+	memcpy(skb_put(skb, len), data, len);
+	return pn_send(skb, dev, dst, src, res, 1);
+}
+
 /*
  * Create a Phonet header for the skb and send it out. Returns
  * non-zero error code if failed. The skb is freed then.
@@ -221,7 +236,7 @@ int pn_skb_send(struct sock *sk, struct sk_buff *skb,
 	spin_unlock_bh(&pndevs.lock);
 
 	err = pn_send(skb, dev, pn_sockaddr_get_object(target),
-			src, pn_sockaddr_get_resource(target));
+			src, pn_sockaddr_get_resource(target), 0);
 	dev_put(dev);
 	return err;
 
@@ -231,6 +246,60 @@ drop:
 }
 EXPORT_SYMBOL(pn_skb_send);
 
+static inline int can_respond(struct sk_buff *skb)
+{
+	const struct phonethdr *ph = pn_hdr(skb);
+	struct phonet_device *pnd;
+
+	if (!pskb_may_pull(skb, 3))
+		return 0;
+	if (skb->data[1] == 0xF0)
+		return 0;
+	if (skb->data[2] == 0x01 || skb->data[2] == 0x14)
+		return 0;
+
+	spin_lock(&pndevs.lock);
+	pnd = __phonet_get_by_index(skb->dev->ifindex);
+	if (!pnd
+	 || !phonet_dev2addr(pnd, ph->rdev & 0xFC, PN_FIND_EXACT)) {
+		spin_unlock(&pndevs.lock);
+		return 0;
+	}
+	spin_unlock(&pndevs.lock);
+	return 1;
+}
+
+static int send_obj_unreachable(struct sk_buff *rskb)
+{
+	struct phonethdr *oph = pn_hdr(rskb);
+	uint8_t data[8];
+
+	BUG_ON(skb_headlen(rskb) < 2);
+	data[0] = rskb->data[0];
+	data[1] = 0xF0;
+	data[2] = 0x14;
+	data[3] = rskb->data[1];
+	data[4] = 0x00;
+	data[5] = 0x00;
+	data[6] = 0x00;
+	data[7] = 0x00;
+	return pn_raw_send(data, sizeof(data), rskb->dev,
+				pn_object(oph->sdev, oph->sobj),
+				pn_object(oph->rdev, oph->robj),
+				oph->function);
+}
+
+static int send_reset_indications(struct sk_buff *rskb)
+{
+	struct phonethdr *oph = pn_hdr(rskb);
+	uint8_t data[4] = { 0x00, 0x10, 0x00, 0x00 };
+
+	return pn_raw_send(data, sizeof(data), rskb->dev,
+				pn_object(oph->sdev, 0x00),
+				pn_object(oph->rdev, oph->robj), 0x10);
+}
+
+
 /* packet type functions */
 
 /*
@@ -269,8 +338,13 @@ static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto out; /* currently, we cannot be device 0 */
 
 	sk = pn_find_sock_by_sa(&sa);
-	if (sk == NULL)
+	if (sk == NULL) {
+		if (can_respond(skb)) {
+			send_obj_unreachable(skb);
+			send_reset_indications(skb);
+		}
 		goto out;
+	}
 
 	/* Push data to the socket (or other sockets connected to it). */
 	err = pn_sk(sk)->handler(sk, skb);
-- 
1.5.4.3

