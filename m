From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] packet: fix tp_reserve race in packet_set_ring
Date: Thu, 10 Aug 2017 12:41:58 -0400
Message-ID: <20170810164158.52213-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, andreyknvl@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:38471 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753396AbdHJQm1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:42:27 -0400
Received: by mail-qt0-f194.google.com with SMTP id p3so1225737qtg.5
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 09:42:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Updates to tp_reserve can race with reads of the field in
packet_set_ring. Avoid this by holding the socket lock during
updates in setsockopt PACKET_RESERVE.

This bug was discovered by syzkaller.

Fixes: 8913336a7e8d ("packet: add PACKET_RESERVE sockopt")
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0615c2a950fa..008a45ca3112 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3700,14 +3700,19 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 
 		if (optlen != sizeof(val))
 			return -EINVAL;
-		if (po->rx_ring.pg_vec || po->tx_ring.pg_vec)
-			return -EBUSY;
 		if (copy_from_user(&val, optval, sizeof(val)))
 			return -EFAULT;
 		if (val > INT_MAX)
 			return -EINVAL;
-		po->tp_reserve = val;
-		return 0;
+		lock_sock(sk);
+		if (po->rx_ring.pg_vec || po->tx_ring.pg_vec) {
+			ret = -EBUSY;
+		} else {
+			po->tp_reserve = val;
+			ret = 0;
+		}
+		release_sock(sk);
+		return ret;
 	}
 	case PACKET_LOSS:
 	{
-- 
2.14.0.434.g98096fd7a8-goog
