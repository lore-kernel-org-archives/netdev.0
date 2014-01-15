From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 2/3] packet: don't unconditionally schedule() in case of MSG_DONTWAIT
Date: Wed, 15 Jan 2014 16:25:35 +0100
Message-ID: <1389799536-23750-3-git-send-email-dborkman@redhat.com>
References: <1389799536-23750-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbaAOPZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 10:25:45 -0500
In-Reply-To: <1389799536-23750-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tpacket_snd(), when we've discovered a first frame that is
not in status TP_STATUS_SEND_REQUEST, and return a NULL buffer,
we exit the send routine in case of MSG_DONTWAIT, since we've
finished traversing the mmaped send ring buffer and don't care
about pending frames.

While doing so, we still unconditionally call an expensive
schedule() in the packet_current_frame() "error" path, which
is unnecessary in this case since it's enough to just quit
the function.

Also, in case MSG_DONTWAIT is not set, we should rather test
for need_resched() first and do schedule() only if necessary
since meanwhile pending frames could already have finished
processing and called skb destructor.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/af_packet.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 85bb38c..d5495d8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2156,6 +2156,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	int err, reserve = 0;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
+	bool need_wait = !(msg->msg_flags & MSG_DONTWAIT);
 	int tp_len, size_max;
 	unsigned char *addr;
 	int len_sum = 0;
@@ -2198,10 +2199,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 	do {
 		ph = packet_current_frame(po, &po->tx_ring,
-				TP_STATUS_SEND_REQUEST);
-
+					  TP_STATUS_SEND_REQUEST);
 		if (unlikely(ph == NULL)) {
-			schedule();
+			if (need_wait && need_resched())
+				schedule();
 			continue;
 		}
 
@@ -2255,10 +2256,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		}
 		packet_increment_head(&po->tx_ring);
 		len_sum += tp_len;
-	} while (likely((ph != NULL) ||
-			((!(msg->msg_flags & MSG_DONTWAIT)) &&
-			 (atomic_read(&po->tx_ring.pending))))
-		);
+	} while (likely((ph != NULL) || (need_wait &&
+					 atomic_read(&po->tx_ring.pending))));
 
 	err = len_sum;
 	goto out_put;
-- 
1.7.11.7
