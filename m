From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/8] sctp: Change sctp to implement csum_levels
Date: Mon, 25 Aug 2014 17:56:11 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408251736250.4816@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:61606 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757011AbaHZBDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 21:03:18 -0400
Received: by mail-qc0-f201.google.com with SMTP id c9so1662745qcz.2
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 18:03:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CHECKSUM_UNNECESSARY may be applied to the SCTP CRC so we need to
appropriate account for this by decrementing csum_level. This is
done by calling __skb_dec_checksum_unnecessary.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/sctp/input.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index c1b9912..c86b86c 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -133,9 +133,13 @@ int sctp_rcv(struct sk_buff *skb)
 	__skb_pull(skb, skb_transport_offset(skb));
 	if (skb->len < sizeof(struct sctphdr))
 		goto discard_it;
-	if (!sctp_checksum_disable && !skb_csum_unnecessary(skb) &&
-		  sctp_rcv_checksum(net, skb) < 0)
+
+	skb->csum_valid = 0; /* Previous value not applicable */
+	if (skb_csum_unnecessary(skb))
+		__skb_dec_checksum_unnecessary(skb);
+	else if (!sctp_checksum_disable && sctp_rcv_checksum(net, skb) < 0)
 		goto discard_it;
+	skb->csum_valid = 1;
 
 	skb_pull(skb, sizeof(struct sctphdr));
 
-- 
2.1.0.rc2.206.gedb03e5
