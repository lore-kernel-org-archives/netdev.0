From: Eyal Birger <eyal.birger@gmail.com>
Subject: [PATCH net-next 6/7] net: add common accessor for setting dropcount on packets
Date: Thu, 26 Feb 2015 04:10:11 +0200
Message-ID: <1424916612-744-7-git-send-email-eyal.birger@gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
Cc: willemb@google.com, edumazet@google.com, shmulik.ladkani@gmail.com,
	marcel@holtmann.org, netdev@vger.kernel.org,
	Eyal Birger <eyal.birger@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:37123 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbbBZCKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 21:10:41 -0500
Received: by wesw55 with SMTP id w55so7240907wes.4
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 18:10:40 -0800 (PST)
In-Reply-To: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of an effort to move skb->dropcount to skb->cb[], use
a common function in order to set dropcount in struct sk_buff.

Signed-off-by: Eyal Birger <eyal.birger@gmail.com>
---
 include/net/sock.h     | 5 +++++
 net/core/sock.c        | 2 +-
 net/packet/af_packet.c | 2 +-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a2502d2..d462f5e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2081,6 +2081,11 @@ static inline int sock_intr_errno(long timeo)
 #define sock_skb_cb_check_size(size) \
 	BUILD_BUG_ON((size) > FIELD_SIZEOF(struct sk_buff, cb))
 
+static inline void sock_skb_set_dropcount(struct sock *sk, struct sk_buff *skb)
+{
+	skb->dropcount = atomic_read(&sk->sk_drops);
+}
+
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 			   struct sk_buff *skb);
 void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
diff --git a/net/core/sock.c b/net/core/sock.c
index 93c8b20..9c74fc8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -466,7 +466,7 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	skb_dst_force(skb);
 
 	spin_lock_irqsave(&list->lock, flags);
-	skb->dropcount = atomic_read(&sk->sk_drops);
+	sock_skb_set_dropcount(sk, skb);
 	__skb_queue_tail(list, skb);
 	spin_unlock_irqrestore(&list->lock, flags);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6ce6e00..cc51b87 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1837,7 +1837,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	spin_lock(&sk->sk_receive_queue.lock);
 	po->stats.stats1.tp_packets++;
-	skb->dropcount = atomic_read(&sk->sk_drops);
+	sock_skb_set_dropcount(sk, skb);
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	spin_unlock(&sk->sk_receive_queue.lock);
 	sk->sk_data_ready(sk);
-- 
2.1.4
