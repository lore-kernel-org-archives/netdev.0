From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 4/9] sctp: Change sctp to implement csum_levels
Date: Wed, 27 Aug 2014 21:27:06 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408272109250.32129@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:43960 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872AbaH1Gfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 02:35:54 -0400
Received: by mail-vc0-f202.google.com with SMTP id id10so84709vcb.3
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 23:35:53 -0700 (PDT)
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
index c1b9912..b6493b3 100644
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
+		__skb_decr_checksum_unnecessary(skb);
+	else if (!sctp_checksum_disable && sctp_rcv_checksum(net, skb) < 0)
 		goto discard_it;
+	skb->csum_valid = 1;
 
 	skb_pull(skb, sizeof(struct sctphdr));
 
-- 
2.1.0.rc2.206.gedb03e5
