From: Weongyo Jeong <weongyo.linux@gmail.com>
Subject: [PATCH net-next v3] packet: uses kfree_skb() for errors.
Date: Fri,  8 Apr 2016 09:25:48 -0700
Message-ID: <1460132748-23561-1-git-send-email-weongyo.linux@gmail.com>
Cc: Weongyo Jeong <weongyo.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36612 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758610AbcDHQ0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:26:10 -0400
Received: by mail-pf0-f196.google.com with SMTP id q129so9795948pfb.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 09:26:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

consume_skb() isn't for error cases that kfree_skb() is more proper
one.  At this patch, it fixed tpacket_rcv() and packet_rcv() to be
consistent for error or non-error cases letting perf trace its event
properly.

Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
---
 net/packet/af_packet.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1ecfa71..4e054bb 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2042,6 +2042,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	u8 *skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned int snaplen, res;
+	bool err = false;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -2130,6 +2131,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 
 drop_n_acct:
+	err = true;
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.stats1.tp_drops++;
 	atomic_inc(&sk->sk_drops);
@@ -2141,7 +2143,10 @@ drop_n_restore:
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
 
@@ -2160,6 +2165,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct sk_buff *copy_skb = NULL;
 	struct timespec ts;
 	__u32 ts_status;
+	bool err = false;
 
 	/* struct tpacket{2,3}_hdr is aligned to a multiple of TPACKET_ALIGNMENT.
 	 * We may add members to them until current aligned size without forcing
@@ -2367,10 +2373,14 @@ drop_n_restore:
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
+	err = true;
 	po->stats.stats1.tp_drops++;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
-- 
2.1.3
