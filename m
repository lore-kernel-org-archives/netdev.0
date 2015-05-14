From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] packet: fix warnings in rollover lock contention
Date: Thu, 14 May 2015 10:42:40 -0400
Message-ID: <1431614560-8866-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:34455 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932428AbbENOmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 10:42:47 -0400
Received: by yhom41 with SMTP id m41so22923467yho.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 07:42:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Avoid two xchg calls whose return values were unused, causing this
warning on some architectures:

    warning: value computed is not used [-Wunused-value]
    #define xchg(ptr,x) ((__typeof__(*(ptr)))\
        __xchg((unsigned long)(x),(ptr),sizeof(*(ptr))))
                       ^
    net/packet/af_packet.c:1314:3: note: in expansion of macro 'xchg'
    xchg(&po->pressure, !has_room);

The relevant variable is a hint to avoid lock contention. It is
allowed to be imprecise (race).

Still, when rewriting this, also convert to use explicit atomic ops
and remove a race by switching to atomic_cmpxchg. A rerun of the
experiment from the original patch did not show this to cause
significant cache line contention. Another non-atomic conditional
clear remains in packet_poll, and is safe.

Fixes: 2ccdbaa6d55b ("packet: rollover lock contention avoidance")

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 12 ++++++------
 net/packet/internal.h  |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 31d5856..ac1a589 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1310,8 +1310,7 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
 	}
 
 	has_room = ret == ROOM_NORMAL;
-	if (po->pressure == has_room)
-		xchg(&po->pressure, !has_room);
+	if (atomic_cmpxchg(&po->pressure, has_room, !has_room)) {}
 
 	return ret;
 }
@@ -1409,7 +1408,7 @@ static unsigned int fanout_demux_rollover(struct packet_fanout *f,
 	i = j = min_t(int, po->rollover->sock, num - 1);
 	do {
 		po_next = pkt_sk(f->arr[i]);
-		if (po_next != po && !po_next->pressure &&
+		if (po_next != po && !atomic_read(&po_next->pressure) &&
 		    packet_rcv_has_room(po_next, skb) == ROOM_NORMAL) {
 			if (i != j)
 				po->rollover->sock = i;
@@ -3045,7 +3044,7 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	if (skb == NULL)
 		goto out;
 
-	if (pkt_sk(sk)->pressure)
+	if (atomic_read(&pkt_sk(sk)->pressure))
 		packet_rcv_has_room(pkt_sk(sk), NULL);
 
 	if (pkt_sk(sk)->has_vnet_hdr) {
@@ -3813,8 +3812,9 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 			TP_STATUS_KERNEL))
 			mask |= POLLIN | POLLRDNORM;
 	}
-	if (po->pressure && __packet_rcv_has_room(po, NULL) == ROOM_NORMAL)
-		xchg(&po->pressure, 0);
+	if (atomic_read(&po->pressure) &&
+	    __packet_rcv_has_room(po, NULL) == ROOM_NORMAL)
+		atomic_set(&po->pressure, 0);
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	spin_lock_bh(&sk->sk_write_queue.lock);
 	if (po->tx_ring.pg_vec) {
diff --git a/net/packet/internal.h b/net/packet/internal.h
index c035d26..f96cf54 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -110,7 +110,7 @@ struct packet_sock {
 				auxdata:1,
 				origdev:1,
 				has_vnet_hdr:1;
-	int			pressure;
+	atomic_t		pressure;
 	int			ifindex;	/* bound device		*/
 	__be16			num;
 	struct packet_rollover	*rollover;
-- 
2.2.0.rc0.207.ga3a616c
