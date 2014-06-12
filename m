From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/4] net: add skb_pop_rcv_encapsulation
Date: Thu, 12 Jun 2014 16:04:16 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406121554350.29731@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:45680 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaFLXER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 19:04:17 -0400
Received: by mail-pb0-f73.google.com with SMTP id ma3so186899pbc.2
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 16:04:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is used by UDP encapsulation protocols in RX when
crossing encapsulation boundary. If ip_summed is set to
CHECKSUM_UNNECESSARY and encapsulation is not set, change to
CHECKSUM_NONE since the checksum has not been validated within the
encapsulation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5b5cd31..fdb510c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1853,6 +1853,17 @@ static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
 	return pskb_may_pull(skb, skb_network_offset(skb) + len);
 }
 
+static inline void skb_pop_rcv_encapsulation(struct sk_buff *skb)
+{
+	/* Only continue with checksum unnecessary if device indicated
+	 * it is valid across encapsulation (skb->encapsulation was set).
+	 */
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY && !skb->encapsulation)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	skb->encapsulation = 0;
+}
+
 /*
  * CPUs often take a performance hit when accessing unaligned memory
  * locations. The actual performance hit varies, it can be small if the
-- 
2.0.0.526.g5318336
