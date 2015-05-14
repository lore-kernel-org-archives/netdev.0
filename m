From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2] packet: fix warnings in rollover lock contention
Date: Thu, 14 May 2015 15:25:02 -0400
Message-ID: <1431631502-19417-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:35863 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964795AbbENTZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 15:25:06 -0400
Received: by yhrr66 with SMTP id r66so26138021yhr.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 12:25:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Avoid two xchg calls whose return values were unused, causing a
warning on some architectures.

The relevant variable is a hint and read without mutual exclusion.
This fix makes all writers hold the receive_queue lock.

Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 31d5856..c30d147 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1301,17 +1301,12 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 	int ret;
 	bool has_room;
 
-	if (po->prot_hook.func == tpacket_rcv) {
-		spin_lock(&po->sk.sk_receive_queue.lock);
-		ret = __packet_rcv_has_room(po, skb);
-		spin_unlock(&po->sk.sk_receive_queue.lock);
-	} else {
-		ret = __packet_rcv_has_room(po, skb);
-	}
-
+	spin_lock_bh(&po->sk.sk_receive_queue.lock);
+	ret = __packet_rcv_has_room(po, skb);
 	has_room = ret == ROOM_NORMAL;
 	if (po->pressure == has_room)
-		xchg(&po->pressure, !has_room);
+		po->pressure = !has_room;
+	spin_unlock_bh(&po->sk.sk_receive_queue.lock);
 
 	return ret;
 }
@@ -3814,7 +3809,7 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 			mask |= POLLIN | POLLRDNORM;
 	}
 	if (po->pressure && __packet_rcv_has_room(po, NULL) == ROOM_NORMAL)
-		xchg(&po->pressure, 0);
+		po->pressure = 0;
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	spin_lock_bh(&sk->sk_write_queue.lock);
 	if (po->tx_ring.pg_vec) {
-- 
2.2.0.rc0.207.ga3a616c
