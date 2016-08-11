From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: fix a success return may hide an error
Date: Thu, 11 Aug 2016 20:52:58 +0800
Message-ID: <31f3b581258d0458edcf30f65ef9513bdc41acc1.1470919978.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33580 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbcHKMxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 08:53:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now in the end of sctp_outq_flush, sctp calls sctp_packet_transmit
in a loop. The return of current sctp_packet_transmit always covers
the prior one's. If the last call of sctp_packet_transmit return a
success, it may hide the error that returns from the prior call.

This patch is to fix this by keeping the old error until the new
error returns from sctp_packet_transmit. Did TAHI test against this
fix, no regression is found.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/outqueue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 72e54a4..b97c8ad 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1193,7 +1193,7 @@ sctp_flush_out:
 						      send_ready);
 		packet = &t->packet;
 		if (!sctp_packet_empty(packet))
-			error = sctp_packet_transmit(packet, gfp);
+			error = sctp_packet_transmit(packet, gfp) ? : error;
 
 		/* Clear the burst limited state, if any */
 		sctp_transport_burst_reset(t);
-- 
2.1.0
