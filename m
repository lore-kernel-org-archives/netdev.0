From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: identify chunks that need to be fragmented at IP level
Date: Thu,  8 Sep 2016 17:54:11 +0800
Message-ID: <d3a35eae75b431862cf96b55dd3a3614a11df8a3.1473328451.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33687 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758634AbcIHJyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 05:54:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Previously, without GSO, it was easy to identify it: if the chunk didn't
fit and there was no data chunk in the packet yet, we could fragment at
IP level. So if there was an auth chunk and we were bundling a big data
chunk, it would fragment regardless of the size of the auth chunk. This
also works for the context of PMTU reductions.

But with GSO, we cannot distinguish such PMTU events anymore, as the
packet is allowed to exceed PMTU.

So we need another check: to ensure that the chunk that we are adding,
actually fits the current PMTU. If it doesn't, trigger a flush and let
it be fragmented at IP level in the next round.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/output.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 1f1682b..31b7bc3 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -878,7 +878,7 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
 					struct sctp_chunk *chunk,
 					u16 chunk_len)
 {
-	size_t psize, pmtu;
+	size_t psize, pmtu, maxsize;
 	sctp_xmit_t retval = SCTP_XMIT_OK;
 
 	psize = packet->size;
@@ -906,6 +906,17 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
 			goto out;
 		}
 
+		/* Similarly, if this chunk was built before a PMTU
+		 * reduction, we have to fragment it at IP level now. So
+		 * if the packet already contains something, we need to
+		 * flush.
+		 */
+		maxsize = pmtu - packet->overhead;
+		if (packet->auth)
+			maxsize -= WORD_ROUND(packet->auth->skb->len);
+		if (chunk_len > maxsize)
+			retval = SCTP_XMIT_PMTU_FULL;
+
 		/* It is also okay to fragment if the chunk we are
 		 * adding is a control chunk, but only if current packet
 		 * is not a GSO one otherwise it causes fragmentation of
-- 
2.1.0
