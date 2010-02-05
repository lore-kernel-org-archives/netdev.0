From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 3/6] Bluetooth: Do not call rfcomm_session_put() for RFCOMM UA on closed socket
Date: Fri,  5 Feb 2010 12:05:36 -0800
Message-ID: <6c2718da59613d76013b501bf0f8bcf9d7794b2d.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
 <1038a00b458997661bcd0e780a24dc280a8841fc.1265399549.git.marcel@holtmann.org>
 <485f1eff73a7b932fd3abb0dfcf804e1a1f59025.1265399549.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54203 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755962Ab0BEUGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 15:06:45 -0500
In-Reply-To: <485f1eff73a7b932fd3abb0dfcf804e1a1f59025.1265399549.git.marcel@holtmann.org>
In-Reply-To: <cover.1265399549.git.marcel@holtmann.org>
References: <cover.1265399549.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Pelly <npelly@google.com>

When processing a RFCOMM UA frame when the socket is closed and we were
not the RFCOMM initiator would cause rfcomm_session_put() to be called
twice during rfcomm_process_rx(). This would cause a kernel panic in
rfcomm_session_close() then.

This could be easily reproduced during disconnect with devices such as
Motorola H270 that send RFCOMM UA followed quickly by L2CAP disconnect
request. This trace for this looks like:

2009-09-21 17:22:37.788895 < ACL data: handle 1 flags 0x02 dlen 8
   L2CAP(d): cid 0x0041 len 4 [psm 3]
     RFCOMM(s): DISC: cr 0 dlci 20 pf 1 ilen 0 fcs 0x7d
2009-09-21 17:22:37.906204 > HCI Event: Number of Completed Packets (0x13) plen 5
   handle 1 packets 1
2009-09-21 17:22:37.933090 > ACL data: handle 1 flags 0x02 dlen 8
   L2CAP(d): cid 0x0040 len 4 [psm 3]
     RFCOMM(s): UA: cr 0 dlci 20 pf 1 ilen 0 fcs 0x57
2009-09-21 17:22:38.636764 < ACL data: handle 1 flags 0x02 dlen 8
   L2CAP(d): cid 0x0041 len 4 [psm 3]
     RFCOMM(s): DISC: cr 0 dlci 0 pf 1 ilen 0 fcs 0x9c
2009-09-21 17:22:38.744125 > HCI Event: Number of Completed Packets (0x13) plen 5
   handle 1 packets 1
2009-09-21 17:22:38.763687 > ACL data: handle 1 flags 0x02 dlen 8
   L2CAP(d): cid 0x0040 len 4 [psm 3]
     RFCOMM(s): UA: cr 0 dlci 0 pf 1 ilen 0 fcs 0xb6
2009-09-21 17:22:38.783554 > ACL data: handle 1 flags 0x02 dlen 12
   L2CAP(s): Disconn req: dcid 0x0040 scid 0x0041

Avoid calling rfcomm_session_put() twice by skipping this call
in rfcomm_recv_ua() if the socket is closed.

Signed-off-by: Nick Pelly <npelly@google.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/rfcomm/core.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 2b50637..89f4a59 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -1150,7 +1150,11 @@ static int rfcomm_recv_ua(struct rfcomm_session *s, u8 dlci)
 			break;
 
 		case BT_DISCONN:
-			rfcomm_session_put(s);
+			/* When socket is closed and we are not RFCOMM
+			 * initiator rfcomm_process_rx already calls
+			 * rfcomm_session_put() */
+			if (s->sock->sk->sk_state != BT_CLOSED)
+				rfcomm_session_put(s);
 			break;
 		}
 	}
-- 
1.6.6

