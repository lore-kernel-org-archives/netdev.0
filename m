From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: [PATCH-net] af_packet / TX_RING not fully non-blocking (w/ MSG_DONTWAIT).
Date: Fri, 8 May 2015 15:44:37 +0200
Message-ID: <1431092677-19853-1-git-send-email-mathias.kretschmer@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay37-dus.antispameurope.com ([94.100.134.237]:56896 "EHLO
	mx-relay37-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751319AbbEHNoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 09:44:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an issue where the send(MSG_DONTWAIT) call
on a TX_RING is not fully non-blocking in cases where the device's sndBuf is
full. We pass nonblock=true to sock_alloc_send_skb() and return any possibly
occuring error code (most likely EGAIN) to the caller. As the fast-path stays
as it is, we keep the unlikely() around skb == NULL. 

Signed-off-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>

---
 net/packet/af_packet.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5102c3c..b5989c6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2311,11 +2311,14 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		tlen = dev->needed_tailroom;
 		skb = sock_alloc_send_skb(&po->sk,
 				hlen + tlen + sizeof(struct sockaddr_ll),
-				0, &err);
+				!need_wait, &err);
 
-		if (unlikely(skb == NULL))
+		if (unlikely(skb == NULL)) {
+			/* we assume the socket was initially writeable ... */
+			if (likely(len_sum > 0))
+				err = len_sum;
 			goto out_status;
-
+		}
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
 					  addr, hlen);
 		if (tp_len > dev->mtu + dev->hard_header_len) {
-- 
1.9.1
