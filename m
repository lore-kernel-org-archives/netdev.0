From: Weongyo Jeong <weongyo.linux@gmail.com>
Subject: [PATCH v2] packet: uses kfree_skb() for drops or errors.
Date: Wed,  6 Apr 2016 14:14:58 -0700
Message-ID: <1459977298-16670-1-git-send-email-weongyo.linux@gmail.com>
Cc: Weongyo Jeong <weongyo.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36127 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbcDFVPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 17:15:33 -0400
Received: by mail-pa0-f68.google.com with SMTP id k3so1367522pav.3
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 14:15:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

consume_skb() isn't for drop or error cases that  kfree_skb() is more proper
one.  At this patch, it fixed tpacket_rcv() and packet_rcv() to be
consistent for error or non-error cases letting perf trace its event
properly.

Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
---
 net/packet/af_packet.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1ecfa71..cd100cf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2040,7 +2040,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct sockaddr_ll *sll;
 	struct packet_sock *po;
 	u8 *skb_head = skb->data;
-	int skb_len = skb->len;
+	int err = 0, skb_len = skb->len;
 	unsigned int snaplen, res;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
@@ -2130,6 +2130,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 
 drop_n_acct:
+	err = -1;
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.stats1.tp_drops++;
 	atomic_inc(&sk->sk_drops);
@@ -2141,7 +2142,10 @@ drop_n_restore:
 		skb->len = skb_len;
 	}
 drop:
-	consume_skb(skb);
+	if (!err)
+		consume_skb(skb);
+	else
+		kfree_skb(skb);
 	return 0;
 }
 
@@ -2153,7 +2157,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct sockaddr_ll *sll;
 	union tpacket_uhdr h;
 	u8 *skb_head = skb->data;
-	int skb_len = skb->len;
+	int err = 0, skb_len = skb->len;
 	unsigned int snaplen, res;
 	unsigned long status = TP_STATUS_USER;
 	unsigned short macoff, netoff, hdrlen;
@@ -2367,10 +2371,14 @@ drop_n_restore:
 		skb->len = skb_len;
 	}
 drop:
-	kfree_skb(skb);
+	if (!err)
+		consume_skb(skb);
+	else
+		kfree_skb(skb);
 	return 0;
 
 drop_n_account:
+	err = -1;
 	po->stats.stats1.tp_drops++;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
-- 
2.1.3
