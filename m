From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 3/7] packet: rollover prepare: single return in packet_rcv_has_room
Date: Wed,  6 May 2015 14:27:13 -0400
Message-ID: <1430936837-22655-4-git-send-email-willemb@google.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:35843 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbEFS1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:27:24 -0400
Received: by ykep21 with SMTP id p21so4908071yke.3
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:27:23 -0700 (PDT)
In-Reply-To: <1430936837-22655-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Convert

  if (x) {
    A;
    return y;
  }
  B;
  return y;

Into

  if (x) {
    A;
  } else {
    B;
  }

  return y;

No other changes.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f8ec909..8275056 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1239,20 +1239,21 @@ static bool packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 	struct sock *sk = &po->sk;
 	bool has_room;
 
-	if (po->prot_hook.func != tpacket_rcv)
-		return (atomic_read(&sk->sk_rmem_alloc) + skb->truesize)
-			<= sk->sk_rcvbuf;
-
-	spin_lock(&sk->sk_receive_queue.lock);
-	if (po->tp_version == TPACKET_V3)
-		has_room = prb_lookup_block(po, &po->rx_ring,
-					    po->rx_ring.prb_bdqc.kactive_blk_num,
-					    TP_STATUS_KERNEL);
-	else
-		has_room = packet_lookup_frame(po, &po->rx_ring,
-					       po->rx_ring.head,
-					       TP_STATUS_KERNEL);
-	spin_unlock(&sk->sk_receive_queue.lock);
+	if (po->prot_hook.func != tpacket_rcv) {
+		has_room = (atomic_read(&sk->sk_rmem_alloc) + skb->truesize)
+			   <= sk->sk_rcvbuf;
+	} else {
+		spin_lock(&sk->sk_receive_queue.lock);
+		if (po->tp_version == TPACKET_V3)
+			has_room = prb_lookup_block(po, &po->rx_ring,
+						    po->rx_ring.prb_bdqc.kactive_blk_num,
+						    TP_STATUS_KERNEL);
+		else
+			has_room = packet_lookup_frame(po, &po->rx_ring,
+						       po->rx_ring.head,
+						       TP_STATUS_KERNEL);
+		spin_unlock(&sk->sk_receive_queue.lock);
+	}
 
 	return has_room;
 }
-- 
2.2.0.rc0.207.ga3a616c
